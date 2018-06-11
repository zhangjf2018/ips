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
		refund_id 系统退款流水号组成 商户号 + 日期 + ssn
--]]

local tools     = loadmod("common.tools.tools")
local load_lua  = tools.load_lua
local commtool  = loadmod("common.tools.commtool")
local orderdao  = loadmod("database.mobilepayment.orderdao")
local indexdao  = loadmod("database.mobilepayment.indexdao")
local routerdao = loadmod("database.mobilepayment.routerdao")
local refunddao = loadmod("database.mobilepayment.refunddao")

local query_refund_detail_by_refund_id     = refunddao.query_refund_detail_by_refund_id
local query_refund_detail_by_out_refund_no = refunddao.query_refund_detail_by_out_refund_no

local query_date_by = indexdao.query_date_by

local con_hash  = loadmod("common.consistent.hashtool")
local spublic   = loadmod("serpublic.public")
local os_date   = os.date
local tonumber  = tonumber
local get_jhash_order = con_hash.get_jhash_order

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

-- 查询原交易
local function get_ori_refund( mch_id, refund_id, out_refund_no, trade_no, out_trade_no )
	local refund_info, ot_date, ret 
	
	if refund_id then
		local mch_id_s = refund_id:sub(1, 10)
		ot_date  = refund_id:sub(11,17) 
		refund_info, ret = query_refund_detail_by_refund_id( mch_id, refund_id, ot_date )
	else
		local node = get_jhash_order( out_refund_no )
		ot_date, ret = query_date_by( mch_id, out_refund_no, node  )
		if ret ~= 0 then
			if ret == 1 then
				throw( errinfo.REFUND_NOT_EXIST )
			end
			throw( errinfo.SYSTEM_ERROR )
		end
		refund_info, ret = query_refund_detail_by_out_refund_no( mch_id, out_refund_no, ot_date ) 
	end
	
	if not refund_info then
		if ret == 1 then
			throw( errinfo.REFUND_NOT_EXIST )
		end
		throw( errinfo.SYSTEM_ERROR )
	end
	
	if refund_id then
		if isNull( refund_info.refund_id ) ~= refund_id then
			throw( errinfo.REFUND_MATCH_ERROR )
		end
	end
	
	if out_refund_no then
		if isNull( refund_info.out_refund_no ) ~= out_refund_no then
			throw( errinfo.REFUND_MATCH_ERROR )
		end
	end
	
	if trade_no then
		if isNull( refund_info.trade_no ) ~= trade_no then
			throw( errinfo.REFUND_MATCH_ERROR )
		end
	end
	
	if out_trade_no then
		if isNull( refund_info.out_trade_no ) ~= out_trade_no then
			throw( errinfo.REFUND_MATCH_ERROR )
		end
	end
	
	return refund_info, ot_date
end

local function get_router( mch_id, trade_type  )
	local router = routerdao.query_router_by( mch_id, trade_type, "1" )
	if not router then
		log("路由获取失败")
		throw( errinfo.SYSTEM_ERROR )
	end
	return router
end

local function update_refund( args, refund_info, ot_date, router, result )
	local upcols = {
		exmch_id            = router.exmch_id,
		channel_id          = router.channel_id,
		bank_ssn            = result.bank_ssn,
		refund_id           = args.refund_id,
		refund_status       = result.refund_status,
		refund_success_time = result.refund_success_time,
		refund_channel      = result.refund_channel,
	}
	
	-- 更新订单
	local ret = refunddao.update_refund_by( args.mch_id, refund_info.out_refund_no, refund_info.refund_fee, ot_date, upcols )
	if ret ~= 0 then
		log("退款更新订单失败")
	end
end

local function channel_process( args, router  )
	local channel = router.channel_id
	local s_channel = "service.pay.trade.refundquery.ch" .. channel
	local s_script, err_ = load_lua( s_channel )
	
	if not s_script then
		log( err_ ) 
		throw( errinfo.SYSTEM_ERROR )
	end
	
	local result = s_script.process( args , router )
	return result
end

function _M.process( args )
	
	log("-------REFUND QUERY SERVICE START---------")

	local mch_id        = args.mch_id
	local refund_id     = args.refund_id
	local out_refund_no = args.out_refund_no
	local trade_no      = args.trade_no
	local out_trade_no  = args.out_trade_no

	-- refund_id, out_refund_no 必须存在一个
	if not refund_id     and 
	   not out_refund_no then
		log("refund_id, out_refund_no 都未上送 ")
		throw( errinfo.REFUNDQUERY_PARAM_ERROR )
	end
	
	-- 优先级顺序 refund_id > out_refund_no

	-- 获取退款订单信息
	local refund_info, ot_date = get_ori_refund( mch_id, refund_id, out_refund_no, trade_no, out_trade_no )

	local refund_status = refund_info.refund_status
	
	if refund_status ~= "PROCESSING" then 
		log("refund_status ".. refund_status .." 退款状态")
		local resp = {
			retcode       = "0000",
			mch_id        = args.mch_id,
			out_trade_no  = refund_info.out_trade_no,
			trade_no      = refund_info.trade_no,
			refund_id     = refund_info.refund_id,
			refund_fee    = refund_info.refund_fee,
			total_fee     = refund_info.total_fee,
			out_refund_no = refund_info.out_refund_no,
			device_info   = refund_info.device_info,
			refund_status = refund_status,
			refund_success_time = refund_info.refund_success_time,
		}
		
		return resp
	end
		
	local router = get_router( mch_id, refund_info.txtrade_type )
	
	args.bank_ssn  = refund_info.bank_ssn
	args.refund_id = refund_info.refund_id
	args.trade_no  = refund_info.trade_no
	
	local result = channel_process( args, router )
	
	local retcode = result.retcode
	
	if retcode ~= "0000" then
		log( retcode )
		local resp = {
			retcode       = retcode,
			mch_id        = args.mch_id,
			out_trade_no  = args.out_trade_no,
			trade_no      = args.trade_no,
			refund_id     = args.refund_id,
			out_refund_no = args.out_refund_no,
		}
		
		return resp
	end
	
	update_refund( args, refund_info, ot_date, router, result )
	
	local resp = {
		retcode       = "0000",
		mch_id        = args.mch_id,
		out_trade_no  = refund_info.out_trade_no,
		trade_no      = refund_info.trade_no,
		refund_id     = refund_info.refund_id,
		refund_fee    = refund_info.refund_fee,
		total_fee     = refund_info.total_fee,
		out_refund_no = refund_info.out_refund_no,
		device_info   = refund_info.device_info,
		refund_status = result.refund_status,
		refund_success_time = result.refund_success_time,
		refund_channel      = result.refund_channel,
	}
	return resp
end

return _M