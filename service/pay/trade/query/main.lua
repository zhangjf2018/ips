-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-17 19:31
-- Last modified: 2016-09-27 22:18
-- description:   
-------------------------------------------------

--bugfix: 

--[[
		trade_no 系统流水号组成 商户号 + 日期 + ssn
--]]

local tools = loadmod("common.tools.tools")
local load_lua = tools.load_lua
local commtool = loadmod("common.tools.commtool")
local orderdao = loadmod("database.mobilepayment.orderdao")
local indexdao = loadmod("database.mobilepayment.indexdao")
local routerdao = loadmod("database.mobilepayment.routerdao")
local con_hash = loadmod("common.consistent.hashtool")
local spublic  = loadmod("serpublic.public")
local os_date  = os.date
local tonumber = tonumber
local get_jhash_order = con_hash.get_jhash_order
local indexdao_insert = indexdao.insert
local getssn   = spublic.getssn

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local function get_ori_order( mch_id, out_trade_no, trade_no  )
	local order_info, ot_date, ret
	-- trade_no 存在，则优先
	if trade_no then
		local smch_id = trade_no:sub(1,10)
		ot_date = trade_no:sub(11,18)
		order_info, ret = orderdao.query_order_detail_by_trade_no( mch_id, trade_no, ot_date )
	else
		local node = get_jhash_order( out_trade_no )
		ot_date, ret = indexdao.query_date_by( mch_id, out_trade_no, node  )

		if ret ~= 0 then
			if ret == 1 then
				throw( errinfo.ORDER_NOT_EXIST )
			end
			throw( errinfo.SYSTEM_ERROR )
		end
		order_info, ret = orderdao.query_order_detail_by_out_trade_no( mch_id, out_trade_no, ot_date ) 
	end
	
	if not order_info then
		if ret == 1 then
			throw( errinfo.ORDER_NOT_EXIST )
		end
		throw( errinfo.SYSTEM_ERROR )
	end
	
	if out_trade_no then
		if order_info.out_trade_no ~= out_trade_no then
			throw( errinfo.QUERY_MATCH_ERROR )
		end
	end
	
	return order_info, ot_date
end

local function get_router( mch_id, trade_type  )
	local router = routerdao.query_router_by( mch_id, trade_type, "1" )
	if not router then
		log("路由获取失败")
		throw( errinfo.SYSTEM_ERROR )
	end
	return router
end

local function channel_process( args, router  )
	local channel = router.channel_id
	local s_channel = "service.pay.trade.query.ch" .. channel
	local s_script, err_ = load_lua( s_channel )
	
	if not s_script then
		log( err_ ) 
		throw( errinfo.SYSTEM_ERROR )
	end
	
	local result = s_script.process( args , router )
	return result
end

local function update_order (trade_no, result, router, mch_id, out_trade_no, total_fee, t_date )
	local upcols = {
		bank_ssn     = result.bank_ssn,
		time_end     = result.time_end,
		exmch_id     = router.exmch_id,
		channel_id   = router.channel_id,
		trade_state  = result.trade_state,
		is_subscribe = result.is_subscribe,
		retcode      = result.retcode,
		openid       = result.openid,
	}
	
	-- 更新订单
	local ret = orderdao.update_order_by( mch_id, out_trade_no, total_fee, t_date, upcols )
	if ret ~= 0 then
		log("查询更新订单失败")
	end
end

local function channel_order_query( order_info, ot_date )
	
	local mch_id       = order_info.mch_id
	local trade_type   = order_info.trade_type
	local total_fee    = order_info.total_fee
	local trade_no     = order_info.trade_no
	local trade_state  = order_info.trade_state
	local out_trade_no = order_info.out_trade_no
	local device_info  = order_info.device_info
	local attach       = order_info.attach
	
	local router = get_router( mch_id, trade_type  )
			
	local data = {
		trade_no = trade_no,	
	}
	
	local resp = channel_process( data, router )
log(resp)
	local rtrade_state = resp.trade_state 
	local retcode = resp.retcode
	
	if retcode == "0000" and rtrade_state ~= nil then
		if rtrade_state ~= trade_state then
		-- 与查询状态不同， 则更新最新订单状态
			
			update_order ( trade_no, resp, router, mch_id, out_trade_no, total_fee, ot_date )
		end
	else
		log("不满足更新订单条件")
	end
	
	local result = {
		retcode      = resp.retcode,
		mch_id       = mch_id,
		out_trade_no = out_trade_no,
		device_info  = device_info,
		trade_type   = trade_type,
		--bank_type   = order_info.bank_type,
		total_fee    = total_fee,
		trade_no     = trade_no,
		attach       = attach,
		time_end     = resp.time_end,	
		trade_state  = resp.trade_state,
		openid       = resp.openid,
		is_subscribe = resp.is_subscribe,
	}
	return result
end

function _M.process( args )
	
	log("-------query service start---------")
	local mch_id       = args.mch_id
	local out_trade_no = args.out_trade_no
	local trade_no     = args.trade_no
	
	if not trade_no and not out_trade_no then
		log("out_trade_no , trade_no 都未上送 ")
		throw( errinfo.QUERY_PARAM_ERROR )
	end
	-- 获取原订单信息
	local order_info, ot_date = get_ori_order( mch_id, out_trade_no, trade_no  )
	
	trade_no     = order_info.trade_no
	out_trade_no = order_info.out_trade_no
	local trade_state = order_info.trade_state
	
	-- 订单状态为 USERPAYING 、 NOTPAY 则向渠道发起查询
	if trade_state == "USERPAYING" or 
			trade_state == "NOTPAY" then
				
		local result = channel_order_query( order_info, ot_date )
		return result 
	end
	
	-- 非上述两种状态
	local result = {
			retcode      = "0000",
			mch_id       = mch_id,
			out_trade_no = order_info.out_trade_no,
			device_info  = order_info.device_info,
			openid       = order_info.openid,
			is_subscribe = order_info.is_subscribe,
			trade_type   = order_info.trade_type,
			trade_state  = order_info.trade_state,
			--bank_type   = order_info.bank_type,
			total_fee    = order_info.total_fee,
			trade_no     = order_info.trade_no,
			attach       = order_info.attach,
			time_end     = order_info.time_end,
	}
	
	return result
end

return _M