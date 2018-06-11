-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-17 19:31
-- Last modified: 2016-09-27 22:18
-- description:   
-------------------------------------------------

-- loadmod 加载自定义模块只能使用的方式
-- 系统模块 例如cjson 可以用require 和 loadmod 两种方式引用

local logger = loadmod("common.log.log")
local tools  = loadmod("common.tools.tools")
local h_filter   = loadmod("common.filter.http_head")
local constant   = loadmod("constant.constant")
local comm_valid = loadmod("common.validator.comm_valid")
local uri_valid  = comm_valid.uri_valid
local exception  = loadmod("common.exception.exception")
local t_execute  = tools.execute
local getBodyArgs = tools.getBodyArgs
local monitor    = logger.monitor
local reset_log_id     = logger.setLogID
local http_head_filter = h_filter.http_head_filter
local str_gsub      = string.gsub
local string_format = string.format
local load_lua   = tools.load_lua
local signtool   = loadmod("common.sign.sign")
local check_sign = signtool.check_sign
local cebtool  = loadmod("channel.bank.ceb.mobilepayment.cebtool")
local cebsign  = cebtool.sign
local cebcheck_sign = cebtool.checksign
local cjson      = require("cjson.safe")
local iniparser  = loadmod("common.parser.iniparser")
local sevpublic  = loadmod("serpublic.public")
local log_args   = sevpublic.log_args

throw   = exception.throw
log     = logger.log 
local json_decode = cjson.decode
local json_encode = cjson.encode
isNull = tools.isNull

local cebtool  = loadmod("channel.bank.ceb.mobilepayment.cebtool")
local cebcheck_sign = cebtool.checksign

local orderdao = loadmod("database.mobilepayment.orderdao")
local indexdao = loadmod("database.mobilepayment.indexdao")
local routerdao = loadmod("database.mobilepayment.routerdao")

local orderdao_query_order_by_trade_no_channel_id_exmch_id = orderdao.query_order_by_trade_no_channel_id_exmch_id
local orderdao_update_order_by = orderdao.update_order_by
local routerdao_query_router_by = routerdao.query_router_by

local commtool =  loadmod("common.tools.commtool")
local http_send_no_exception = commtool.http_send_no_exception

-- xml 解析全局引用
require("LuaXML_lib") 
xml = require "xml"

local xmltool  =  loadmod("common.tools.xmltool")
local xmlparse = xmltool.parse

local FAIL    = {retcode="0001", retmsg="fail"}
local SUCCESS = {retcode="0000", retmsg="success"}

local function change_wx_data( args, order_info )

	return args	
end

local function change_zfb_data( args, order_info )
	return args	
end

-- 响应数据转换
local change_data = {
	["WXSCAN"]    = change_wx_data,
	["WXQRCODE"]  = change_wx_data,
	["WXJSAPI"]   = change_wx_data,
	["ZFBSCAN"]   = change_zfb_data,
	["ZFBQRCODE"] = change_zfb_data,
	["ZFBJSAPI"]  = change_zfb_data,
}

local function query_order(trade_no, channel_id, exmch_id, transdate  )
	local order_info, ret = orderdao_query_order_by_trade_no_channel_id_exmch_id( trade_no, channel_id, exmch_id, transdate )
	
	if not order_info then
		if ret ~=0 then
			if ret == 1 then
				log( string.format("CEB 回调未查询到数据"))
			end
			if ret == 2 then
				log( "CEB回调数据库操作超时" )
			end
			throw( FAIL )
		end
	end
	
	return order_info
end

local function query_router ( mch_id, trade_type )
	local router,ret = routerdao_query_router_by( mch_id, trade_type, "1" )
	if not router then
		if ret == 1 then
			log( string.format("CEB 回调未查询到数据"))
		end
		if ret == 2 then
			log( "CEB回调数据库操作超时" )
		end
		throw( FAIL )
	end
	
	return router
end

local function data_set( args, order_info, trade_type )
	
	-- 支付宝微信特殊字段转换
	local ch_data = change_data[trade_type]
	if ch_data then
		args = ch_data( args, order_info )
	else
		log( "获取数据转换方法失败:" .. trade_type )
	end
	return args
end

local function update_order(order_info, args, router, transdate )
	local trade_state = order_info.trade_state
	local exmch_id    = args.mch_id
	
	local result_code = args.result_code
	local pay_result  = args.pay_result
	local total_fee   = args.total_fee or order_info.total_fee
	if tonumber( result_code ) == 0 and tonumber( pay_result ) == 0 then
		
		if trade_state == "NOTPAY" or trade_state == "USERPAYING" then
			
			local upcols = {
				bank_ssn     = args.transaction_id,
				time_end     = args.time_end,
				exmch_id     = exmch_id,
				channel_id   = router.channel_id,
				trade_state  = "SUCCESS",
				is_subscribe = args.is_subscribe,
				retcode      = "0000",
				openid       = args.openid,
			}
			
			local ret = orderdao_update_order_by( order_info.mch_id, order_info.out_trade_no, total_fee, transdate, upcols )
			
			if ret ~= 0 then
				log("数据更新失败")
				throw( FAIL )
			end
		end
	end
end

local function mer_notify( args, order_info )

	local retcode = "PAYMENT_FAIL"
	local result_code = tonumber( args.result_code )
	if result_code == 0 then
		retcode = "0000"
	end
	local notify_info = {
		retcode = retcode,
		mch_id  = order_info.mch_id,
		out_trade_no = order_info.out_trade_no,
		trade_no     = order_info.trade_no,
		total_fee    = order_info.total_fee,
		trade_type   = order_info.trade_type,
		sign_type    = order_info.sign_type,
		device_info  = order_info.device_info,
		attach       = order_info.attach,
		
		bank_type    = args.bank_type,
		openid       = args.openid,
		is_subscribe = args.is_subscribe,
		time_end     = args.time_end,
	}
	
	log( notify_info )
	local notify_url = order_info.notify_url or ""
	if #notify_url == 0 then
		log("通知地址为空, 不做通知")
		return 
	end
	
	-- 签名数据
	--sign( )
	
	local notify_msg = json_encode( notify_info )
	local body, _err = http_send_no_exception( notify_url, notify_msg )
	if #body == 0 then
		log("ceb 通讯超时")
		throw( FAIL )
	else
		if body == "SUCCESS" then
			log("通知成功！")
		else
			throw( FAIL )
		end
	end
end

local function process( args )
		
	local trade_no   = args.out_trade_no
	local transdate  = trade_no:sub(11,18)
	local channel_id = "303"
	local exmch_id   = args.mch_id
	
	local order_info = query_order( trade_no, channel_id, exmch_id, transdate )
	
	local trade_type = order_info.trade_type
	
	local router = query_router( order_info.mch_id, trade_type)
	
	local is_ok = cebcheck_sign( args, router.api_key )
	if is_ok ~= true then
		log("CEB 支付回调验证签名失败")
	--	throw( FAIL )
	end
	
	args = data_set( args, order_info, trade_type )
	
	update_order(order_info, args, router, transdate )
	
	mer_notify( args, order_info )
	
	return SUCCESS
end

local function main()
	-- 1. 生成日志标识
	reset_log_id()
	log("CEB MOBILEPAYMENT CALL START")
	http_head_filter()  -- 过滤http请求头
	uri_valid()         -- URI 合法校验
		
	local body = getBodyArgs()  -- 3. 获取请求参数
	if not body then
		throw( FAIL )
	end
	
	local args = xmlparse( body )
	if not args then
		throw( FAIL )
	end
	
	ngx.ctx[ constant.REQ_ARGS ] = args
	log_args( args )

  -- 执行业务处理 -- 未进入业务前，响应数据签名可以没有
  local ok, result = pcall ( process, args )

  if type(result) ~= "table" then
  	log( tostring(result) )
		result = FAIL
	end

	return result
end

local function ex_main(  )
    local ok, result = pcall( main )
    if not ok then
    	result = FAIL
    end
    -- 记录monitor 日志
    local args = ngx.ctx[ constant.REQ_ARGS ]
    
 		ngx.say( result.retmsg )
 		
 		local temp = "响应参数:\r\n".. json_encode(result) .. "\r\n" .. "CEB MOBILEPAYMENT CALL END"
 		
    log(temp)
		monitor( args, result )
    return result
end

--程序执行入口
local status = ex_main( )
