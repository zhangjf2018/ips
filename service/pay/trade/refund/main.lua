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
local con_hash  = loadmod("common.consistent.hashtool")
local utils     = loadmod("public.utils")
local os_date   = os.date
local tonumber  = tonumber
local get_jhash_order = con_hash.get_jhash_order
local indexdao_insert = indexdao.insert
local getssn          = utils.getssn

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

-- 查询原交易
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

local function update_refund( args, mch_id, t_date, router, result )
	local upcols = {
		exmch_id            = router.exmch_id,
		channel_id          = router.channel_id,
		bank_ssn            = result.bank_ssn,
		retcode             = result.retcode,
		refund_id           = args.refund_id,
		refund_status       = result.refund_status,
		refund_success_time = result.refund_success_time,
		refund_channel      = result.refund_channel,
	}
	
	-- 更新订单
	local ret = refunddao.update_refund_by( mch_id, args.out_refund_no, args.refund_fee, t_date, upcols )
	if ret ~= 0 then
		log("退款更新订单失败")
	end
end

local function update_order(order_info, args, router, ot_date )
	
	local condition = {
			mch_id       = args.mch_id,
			out_trade_no = order_info.out_trade_no,
			total_fee    = order_info.total_fee,
			refund_fee   = order_info.refund_fee,
	}
	
	local upcols = {
		refund_fee  = order_info.refund_fee + args.refund_fee,
		trade_state = "REFUND",
	}
	
	-- 更新订单
	local ret = orderdao.update_order_by_con( ot_date, condition, upcols )
	
	if ret ~= 0 then
		log("退款更新交易订单失败")
	end
end

--- 处理订单index
-- @return order_info 已存在，但未支付订单 
local function insert_index(out_refund_no, mch_id, t_date, args )
	
	local node = get_jhash_order( out_refund_no )
	
	local index = {
		out_trade_no = out_refund_no,
		mch_id       = mch_id,
		transdate    = t_date,
	}
	local ret, db = indexdao.insert( index, node )
	local ot_date = ""
	-- 插入失败
	if ret ~= 0 then
			-- 数据已存在
			if ret == 1 then 
				log("订单存在于index表:"..mch_id..":"..out_refund_no)
				-- 获取交易所在流水表时间
				ot_date = indexdao.query_date_by( mch_id, out_refund_no, node )
				if #ot_date == 0 then
					log("退款订单index查询异常")
					throw( errinfo.SYSTEM_ERROR )
				end
				ot_date = ot_date:sub(1,6)
				local refund_info, ret = refunddao.query_refund_by( mch_id, out_refund_no, ot_date ) 
				log(refund_info)
				if not refund_info then
					if ret == 1 then
						-- 向渠道发起退款
						return nil 
					end
					log("退款订单查询异常")
					throw( errinfo.SYSTEM_ERROR )
				end
				
				if refund_info.refund_status ~= "START" then
					log("退款已受理，重复退款")
					throw( errinfo.REFUND_INPROCESS )
				end
				
				if refund_info.refund_fee ~= args.refund_fee then
					throw( errinfo.OUT_REFUND_NO_USED )
				end
				
				if refund_info.refund_status == "START" then
					log("重新向渠道发起退款")
					return refund_info
				end
			else
				log("退款订单index 插入异常")
				throw( errinfo.SYSTEM_ERROR )
			end
	end
	
	return nil
end

local function insert_refund( mch_id, args, order_info, ot_date, t_date, t_time )
	local cols = {
		mch_id        = mch_id,
		operator_id   = args.operator_id,
		out_trade_no  = order_info.out_trade_no,
		out_refund_no = args.out_refund_no,
		trade_no      = order_info.trade_no,
		device_info   = args.device_info,
		total_fee     = order_info.total_fee,
		refund_fee    = args.refund_fee,
		refund_status = "START",
		refund_reason = args.refund_reason,
		trade_type    = "REFUND",
		txtrade_type  = order_info.trade_type,
		txtransdate   = ot_date,
		transdate     = t_date,
		transtime     = t_time,		
	}
	
	local ret = refunddao.insert( cols, t_date )
	if ret ~= 0 then
		log("退款订单插入异常")
		throw( errinfo.SYSTEM_ERROR )
	end
end

local function channel_process( args, router  )
	local channel = router.channel_id
	local s_channel = "service.pay.trade.refund.ch" .. channel
	local s_script, err_ = load_lua( s_channel )
	
	if not s_script then
		log( err_ ) 
		throw( errinfo.SYSTEM_ERROR )
	end
	
	local result = s_script.process( args , router )
	return result
end

-- 获取平台退款单号
local function get_refund_id( mch_id, t_date, o_refund_info )
	local refund_id = ""
	if o_refund_info and o_refund_info.refund_id then -- 
		refund_id = o_refund_info.refund_id -- 使用原系统流水号
	else
		local ssn = getssn( )
		if not ssn then
			log("获取系统流水号失败")
			throw( errinfo.SYSTEM_ERROR )
		end
		refund_id  = mch_id .. t_date .. ssn 
	end
	return refund_id
end

function _M.process( args )
	log("-------refund service start---------")
	args.total_fee  = tonumber( args.total_fee )
	args.refund_fee = tonumber( args.refund_fee )
	local mch_id    = args.mch_id
	local out_trade_no = args.out_trade_no
	local trade_no     = args.trade_no
	local total_fee    = args.total_fee
	local refund_fee   = args.refund_fee
	
	if refund_fee == 0 then
		throw( errinfo.REFUND_FEE_ERROR )
	end
	
	if not trade_no and not out_trade_no then
		log("out_trade_no , trade_no 都未上送 ")
		throw( errinfo.REFUND_PARAM_ERROR )
	end
	-- 获取原订单信息
	local order_info, ot_date = get_ori_order( mch_id, out_trade_no, trade_no  )
	
	if order_info.total_fee ~= args.total_fee then
		throw( errinfo.REFUND_TOTAL_FEE_ERROR )
	end
	
	if  args.refund_fee > order_info.total_fee then
		throw( errinfo.REFUND_FEE_NOT_ENOUGH )
	end
	
	local n_refund_fee = order_info.refund_fee + args.refund_fee
	
	local dates  = os_date( "%Y%m%d%H%M%S" )
	local t_date = dates:sub(1,8)
	local t_time = dates:sub(-6)
	
	local o_refund_info = insert_index(args.out_refund_no, mch_id, t_date, args )
	
	if not o_refund_info then
		if  n_refund_fee > order_info.total_fee then
			throw( errinfo.REFUND_FEE_NOT_ENOUGH )
		end
		insert_refund( mch_id, args, order_info, ot_date, t_date, t_time )
	end
	
	local router = get_router( mch_id, order_info.trade_type )
	
	local refund_id = get_refund_id( mch_id, t_date, o_refund_info )
	
	args.trade_no  = order_info.trade_no
	args.refund_id = refund_id
	local result = channel_process( args, router  )
	
	local retcode = result.retcode
	
	update_refund( args, mch_id, t_date, router, result )
	
	if retcode ~= "0000" then
		local resp = {
			out_trade_no  = args.out_trade_no,
			out_refund_no = args.out_refund_no,	
			refund_fee    = args.refund_fee,
			total_fee     = args.total_fee,
			mch_id        = args.mch_id,
			retcode       = result.retcode,
		}
		return resp
	end
	
	if retcode == "0000" then
		if  order_info.refund_fee < order_info.total_fee then
			update_order(order_info, args, router, ot_date )
		end
	end

	local resp = {
		retcode ="0000",
		mch_id  = args.mch_id,
		out_trade_no = order_info.out_trade_no,
		trade_no     = order_info.trade_no,
		refund_id    = refund_id,
		refund_fee   = args.refund_fee,
		total_fee    = args.total_fee,
		refund_channel = result.refund_channel,
		out_refund_no = args.out_refund_no,
		device_info   = order_info.device_info,
	}
	
	return resp
end

return _M