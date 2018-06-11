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

--]]

local tools     = loadmod("common.tools.tools")
local load_lua  = tools.load_lua
local noncestr  = tools.noncestr
local cebtool   = loadmod("channel.bank.ceb.mobilepayment.cebtool")
local public    = loadmod("channel.bank.ceb.mobilepayment.public")
local pcomm     = public.comm
local xmltool   = loadmod("common.tools.xmltool")
local commtool  = loadmod("common.tools.commtool")
local xmlparse  = xmltool.parse
local exception = loadmod("common.exception.exception")
local errinfo   = loadmod("constant.errinfo")

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

-- 请求数据转换
local function dataset( tb, router )
	
	local nstr = noncestr()
	
	local data = {
		service       = "unified.trade.micropay",
		-- version = "1.0",
		-- charset = "UTF-8",
		-- sign_type = "MD5",
		mch_id        = router.exmch_id,
		sign_agentno  = router.exagent_id,
		out_trade_no  = tb.trade_no,
		device_info   = tb.device_info,
		body          = tb.body,
		attach        = tb.attach,
		total_fee     = tb.total_fee,
		mch_create_ip = tb.mch_create_ip or "127.0.0.1",
		auth_code     = tb.auth_code,
		time_start    = tb.time_start,
		time_expire   = tb.time_expire,
		goods_tag     = tb.goods_tag,
		nonce_str     = nstr,
	}
	return data
end


local function change_wxscan_data( resp, result )

	
	return resp	
end

local function change_zfbscan_data( resp, result )
	
	
	return resp	
end

-- 响应数据转换
local change_data = {
		["WXSCAN"] = change_wxscan_data,
		["ZFBSCAN"] = change_zfbscan_data,
}

local errcode_map = {
-- wx
["SYSTEMERROR"]    = "BANK_ERROR",
["PARAM_ERROR"]    = "PAYMENT_FAIL",
["ORDERPAID"]      = "ORDER_PAID",
["NOAUTH"]         = "NO_AUTH",
["AUTHCODEEXPIRE"] = "AUTH_CODE_EXPIRE",
["NOTENOUGH"]      = "NOT_ENOUGH",
["NOTSUPORTCARD"]  = "NOT_SUPORT_CARD",
["ORDERCLOSED"]    = "ORDER_CLOSED",
["ORDERREVERSED"]  = "ORDER_REVERSED",
["BANKERROR"]      = "BANK_ERROR",
["USERPAYING"]     = "USER_PAYING",
["AUTH_CODE_ERROR"]     = "AUTH_CODE_ERROR",
["AUTH_CODE_INVALID"]   = "AUTH_CODE_INVALID",
["XML_FORMAT_ERROR"]    = "PAYMENT_FAIL",
["REQUIRE_POST_METHOD"] = "PAYMENT_FAIL",
["SIGNERROR"]           = "PAYMENT_FAIL",
["LACK_PARAMS"]         = "PAYMENT_FAIL",
["NOT_UTF8"]            = "PAYMENT_FAIL",
["BUYER_MISMATCH"]      = "BUYER_MISMATCH",
["APPID_NOT_EXIST"]     = "APPID_NOT_EXIST",
["MCHID_NOT_EXIST"]     = "MCHID_NOT_EXIST",
["OUT_TRADE_NO_USED"]   = "OUT_TRADE_NO_USED",
["APPID_MCHID_NOT_MATCH"] = "APPID_MCHID_NOT_MATCH",
["INVALID_REQUEST"]     = "INVALID_REQUEST",
["TRADE_ERROR"]	        = "TRADE_ERROR",
-- wft
["Auth code invalid"] = "AUTH_CODE_INVALID",
["Internal error"] = "BANK_ERROR",
["System error"]   = "BANK_ERROR",
["JMPT100027"]         = "PAYMENT_FAIL",                                                              -- 付款码已扣款	支付确认失败	请让买方更新付款码

-- zfb
["10003"]                = "USER_PAYING",
["aop.ACQ.SYSTEM_ERROR"] = "BANK_ERROR",
["ACQ.SYSTEM_ERROR"]     = "BANK_ERROR",
["RULELIMIT"]                = "BANK_ERROR",

["ACQ.INVALID_PARAMETER"]    = "INVALID_PARAMETER",                                   -- 参数无效	支付确认失败	检查请求参数，修改后重新发起请求
["ACQ.ACCESS_FORBIDDEN"]     = "ACCESS_FORBIDDEN",                                    -- 无权限使用接口	支付确认失败	未签约条码支付或者合同已到期
["ACQ.EXIST_FORBIDDEN_WORD"] = "EXIST_FORBIDDEN_WORD",                                -- 订单信息中包含违禁词	支付确认失败	修改订单信息后，重新发起请求
["ACQ.PAYMENT_AUTH_CODE_INVALID"]        = "AUTH_CODE_INVALID",                       -- 支付授权码无效	支付确认失败	用户刷新条码后，重新扫码发起请求
["ACQ.CONTEXT_INCONSISTENT"]             = "PAYMENT_FAIL",                            -- 交易信息被篡改	支付确认失败	更换商家订单号后，重新发起请求
["ACQ.BUYER_BALANCE_NOT_ENOUGH"]         = "NOT_ENOUGH",                              -- 买家余额不足	支付确认失败	买家绑定新的银行卡或者支付宝余额有钱后再发起支付
["ACQ.TRADE_BUYER_NOT_MATCH"]            = "TRADE_BUYER_NOT_MATCH",                   -- 交易买家不匹配	支付确认失败	更换商家订单号后，重新发起请求
["ACQ.BUYER_ENABLE_STATUS_FORBID"]       = "BUYER_ENABLE_STATUS_FORBID",              -- 买家状态非法	支付确认失败	用户联系支付宝小二（联系支付宝文档右边的客服头像或到支持中心咨询），确认买家状态为什么非法
["ACQ.PULL_MOBILE_CASHIER_FAIL"]         = "PULL_MOBILE_CASHIER_FAIL",                -- 唤起移动收银台失败	支付确认失败	用户刷新条码后，重新扫码发起请求
["ACQ.MOBILE_PAYMENT_SWITCH_OFF"]        = "MOBILE_PAYMENT_SWITCH_OFF",               -- 用户的无线支付开关关闭	支付确认失败	用户在PC上打开无线支付开关后，再重新发起支付
["ACQ.PAYMENT_FAIL"]                     = "PAYMENT_FAIL",                            -- 支付失败	支付确认失败	用户刷新条码后，重新发起请求，如果重试一次后仍未成功，更换其它方式付款     
["ACQ.BUYER_PAYMENT_AMOUNT_DAY_LIMIT_ERROR"] = "BUYER_PAYMENT_AMOUNT_DAY_LIMIT_ERROR", -- 买家付款日限额超限	支付确认失败	更换买家进行支付
["ACQ.BEYOND_PAY_RESTRICTION"]           = "BEYOND_PAY_RESTRICTION",                  -- 商户收款额度超限	支付确认失败	联系支付宝提高限额
["ACQ.BEYOND_PER_RECEIPT_RESTRICTION"]   = "BEYOND_PER_RECEIPT_RESTRICTION",          -- 商户收款金额超过月限额	支付确认失败	联系支付宝提高限额
["ACQ.BUYER_PAYMENT_AMOUNT_MONTH_LIMIT_ERROR"] = "BUYER_PAYMENT_AMOUNT_MONTH_LIMIT_ERROR",  -- 买家付款月额度超限	支付确认失败	让买家更换账号后，重新付款或者更换其它付款方式                           
["ACQ.ERROR_BUYER_CERTIFY_LEVEL_LIMIT"]	 = "ERROR_BUYER_CERTIFY_LEVEL_LIMIT",         -- 买家未通过人行认证	支付确认失败	更换其它付款方式
["ACQ.PAYMENT_REQUEST_HAS_RISK"]         = "PAYMENT_REQUEST_HAS_RISK",                -- 支付有风险	支付确认失败	更换其它付款方式
["ACQ.INVALID_STORE_ID"]                 = "INVALID_STORE_ID",                        -- 商户门店编号无效	支付确认失败 检查传入的门店编号是否有效
["ACQ.NO_PAYMENT_INSTRUMENTS_AVAILABLE"] = "NO_PAYMENT_INSTRUMENTS_AVAILABLE",        -- 没用可用的支付工具	支付确认失败	更换其它付款方式
}

local function packresp( result, trade_type )
	local resp = {}
	
	if result == nil then
		return { retcode = "BANKERROR" }
	end
	
	if result.status ~= "0" then

		resp.retcode = "BANKERROR"

		if result.need_query == "N" then
			resp.retcode = "PAYMENT_FAIL"
		end
	else 
		if result.result_code == "0" and result.pay_result == "0" then
			-- 付款成功
			-- 转换为内部数据字典
			resp.retcode = "0000"
			resp.trade_type = trade_type           -- 交易类型
			
			resp.bank_ssn  = result.transaction_id  -- 银行流水号
			resp.time_end  = result.time_end        -- 支付完成时间
			resp.bank_type = result.bank_type       -- 付款银行
			resp.fee_type  = result.fee_type        -- 币种
			resp.openid    = result.openid          -- 用户标识
			resp.total_fee = result.total_fee       -- 交易金额
			resp.coupon_fee     = result.coupon_fee      -- 优惠金额
			resp.trade_status   = result.trade_status    -- 交易状态
			resp.transaction_id = result.out_trade_no    -- 系统流水号
			resp.appid          = result.appid   
			resp.sub_appid      = result.sub_appid
			resp.is_subscribe   = result.is_subscribe
			resp.sub_is_subscribe = result.sub_is_subscribe      
			resp.third_trade_no = result.out_transaction_id -- 第三方订单号 微信、支付宝、QQ等
			resp.attach         = result.attach             -- 商家数据包，原样返回
			resp.device_info    = result.device_info        -- 终端设备号(商户自定义，如门店编号)
			resp.mch_id         = result.mch_id             -- 渠道商户号
			
			-- 支付宝微信特殊字段转换
			-- resp = change_data[trade_type]( resp, result )
		else
			-- 付款 失败
			-- 错误码转换
			local errcode = errcode_map[ result.err_code ]
			
			if not errcode then
				local tmp = result.err_code or ""
				log("new errcode : " .. tmp)
			end
			-- 默认BANKERROR 触发查询交易
			resp.retcode = errcode or "BANKERROR"
		end	
	end
	return resp
end

-- 光大统一小额
function _M.micropay( tb, router )
	log(" -- bank ceb micropay process start -- ")

	-- 组光大请求数据包
	local data = dataset( tb, router )
	
	-- 发送数据包, 并做签名验证
	local result = pcomm( data, router )
	
	local trade_type = router.trade_type
	
	-- 转换为内部数据
	local resp = packresp( result, trade_type )	
	log(" -- bank ceb micropay process end -- ")
	return resp 
end

return _M