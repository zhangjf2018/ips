-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-17 19:31
-- Last modified: 2016-09-27 22:18
-- description:   trade_no 系统流水号组成 商户号 + 日期 + ssn
--		            WXQRCODE  微信正扫
-------------------------------------------------

--bugfix: 
--[[
	
--]]

local tools     = loadmod("common.tools.tools")
local load_lua  = tools.load_lua
local commtool  = loadmod("common.tools.commtool")
local orderdao  = loadmod("database.mobilepayment.orderdao")
local indexdao  = loadmod("database.mobilepayment.indexdao")
local routerdao = loadmod("database.mobilepayment.routerdao")
local con_hash  = loadmod("common.consistent.hashtool")
local spublic   = loadmod("serpublic.public")
local os_date   = os.date
local tonumber  = tonumber
local get_jhash_order = con_hash.get_jhash_order
local indexdao_insert         = indexdao.insert
local indexdao_query_date_by  = indexdao.query_date_by
local routerdao_query_router_by = routerdao.query_router_by
local orderdao_insert           = orderdao.insert
local orderdao_query_order_by   = orderdao.query_order_by
local orderdao_update_order_by  = orderdao.update_order_by
local getssn   = spublic.getssn

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- 处理订单index
-- @return order_info 已存在，但未支付订单 
local function insert_index(out_trade_no, mch_id, t_date, node, args )
	local index = {
		out_trade_no = out_trade_no,
		mch_id       = mch_id,
		transdate    = t_date,
	}
	local ret = indexdao_insert( index, node )

	local ot_date = ""
	-- 插入失败
	if ret ~= 0 then
			-- 数据已存在
			if ret == 1 then 
				log("订单存在于index表:"..mch_id..":"..out_trade_no)
				-- 获取交易所在流水表时间
				ot_date, ret = indexdao_query_date_by( mch_id, out_trade_no, node )
				if #ot_date == 0 then
					log("索引查询异常")
					throw( errinfo.SYSTEM_ERROR )
				end
				
				local order_info, ret = orderdao_query_order_by( mch_id, out_trade_no, ot_date ) 
				if not order_info then
					if ret == 1 then
						log("未查询到订单")
						return nil
					end
					log("订单查询异常")
					throw( errinfo.SYSTEM_ERROR )
				end
				
				if order_info.trade_state ~= "NOTPAY" then
					log("订单已支付")
					throw( errinfo.ORDER_PAID )
				end
				local total_fee   = args.total_fee or ""
				local device_info = args.device_info or ""
				local body        = args.body or ""
				local attach      = args.attach or ""
				if order_info.total_fee ~= total_fee or 
					order_info.device_info ~= device_info or
					order_info.body ~= body or
					order_info.attach ~= attach then
						log("商户订单号重复")
						throw( errinfo.OUT_TRADE_NO_USED )
				end	
				-- 返回未支付订单
				return order_info
			else
				-- 数据插入其他异常
				log("index 插入异常")
				throw( errinfo.SYSTEM_ERROR )
			end
	end
	return nil
end

local function insert_order( mch_id, out_trade_no, trade_type, t_date, t_time, args  )
	local orderinfo = {
		--- 接口上送数据
		mch_id       = mch_id,
		out_trade_no = out_trade_no,
		device_info  = args.device_info,
		total_fee    = args.total_fee,
		body         = args.body,
		attach       = args.attach,	
		notify_url   = args.notify_url,
		sign_type    = args.sign_type,
		
		--- 系统数据
		trade_type   = trade_type, 
		transdate    = t_date,
		transtime    = t_time,
		trade_state  = "NOTPAY",
	}

	local ret = orderdao_insert( orderinfo, t_date )
	if ret ~= 0 then
		log("订单插入失败")
		throw( errinfo.SYSTEM_ERROR )
	end	
end

local function get_router( mch_id, trade_type  )
	local router, ret = routerdao_query_router_by( mch_id, trade_type, "1" )
	if not router then
		if ret == 1 then
			log("路由未配置")
		end
		if ret == 2 then
			log("路由获取失败, 数据库操作异常")
		end
		throw( errinfo.SYSTEM_ERROR )
	end
	return router
end

local function get_trade_no( mch_id, t_date, o_order_info )
	local trade_no = ""
	if o_order_info and o_order_info.trade_no then -- 订单存在但未支付
		trade_no = o_order_info.trade_no -- 使用原系统流水号
	else
		local ssn = getssn( )
		if not ssn then
			log("获取系统流水号失败")
			throw( errinfo.SYSTEM_ERROR )
		end
		trade_no  = mch_id .. t_date .. ssn 
	end
	
	return trade_no
end

local function update_order (trade_no, result, router, mch_id, out_trade_no, total_fee, t_date )
	local upcols = {
		trade_no     = trade_no,
		exmch_id     = router.exmch_id,
		channel_id   = router.channel_id,
		retcode      = result.retcode,
	}
	-- 更新订单
	local ret = orderdao_update_order_by( mch_id, out_trade_no, total_fee, t_date, upcols)
	if ret ~= 0 then
		log("更新订单失败")
		throw( errinfo.SYSTEM_ERROR )
	end
end

local function channel_process( args, router  )
	local channel = router.channel_id
	local s_channel = "service.pay.wxpay.native.ch" .. channel
	local s_script, err_ = load_lua( s_channel )
	
	if not s_script then
		log( err_ ) 
		throw( errinfo.SYSTEM_ERROR )
	end
	
	local result = s_script.process( args , router )
	return result
end

-- 微信正扫 WXQRCODE
function _M.process( args )
	log("-------WXQRCODE SERVICE START---------")
	local mch_id       = args.mch_id
	local out_trade_no = args.out_trade_no
	--out_trade_no = tools.gen_ssn() -- 压测用
	args.total_fee     = tonumber( args.total_fee ) 
	local total_fee    = args.total_fee
	local trade_type   = "WXQRCODE"
	
	local dates  = os_date( "%Y%m%d%H%M%S" )
	local t_date = dates:sub(1,8)
	local t_time = dates:sub(-6)
	local node   = get_jhash_order( args.out_trade_no )

	-- 入库index 表
	local o_order_info = insert_index(out_trade_no, mch_id, t_date, node, args) 

	if not o_order_info or not o_order_info.out_trade_no then -- 订单不存在
		insert_order( mch_id, out_trade_no, trade_type, t_date, t_time, args) -- 订单入库
	end
	
	-- 获取路由
	local router = get_router( mch_id, trade_type )
	-- 取系统流水号
	local trade_no = get_trade_no( mch_id, t_date, o_order_info )

	args.trade_no   = trade_no
	args.exmch_id   = router.exmch_id
	args.channel_id = router.channel_id
	args.trade_type = trade_type
	
	-- 送渠道处理
	local result = channel_process( args, router )

	update_order (trade_no, result, router, mch_id, out_trade_no, total_fee, t_date )

	return result
end

return _M