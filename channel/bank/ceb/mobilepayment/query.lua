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

local tools    = loadmod("common.tools.tools")
local load_lua = tools.load_lua
local noncestr = tools.noncestr
local cebtool  = loadmod("channel.bank.ceb.mobilepayment.cebtool")
local public   = loadmod("channel.bank.ceb.mobilepayment.public")
local pcomm    = public.comm
local xmltool  =  loadmod("common.tools.xmltool")
local commtool =  loadmod("common.tools.commtool")
local xmlparse = xmltool.parse
local exception    = loadmod("common.exception.exception")
local errinfo      = loadmod("constant.errinfo")
local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

-- 请求数据转换
local function dataset( tb, router )
	
	local nstr = noncestr()
	
	local data = {
		service       = "unified.trade.query",
		-- version = "1.0",
		-- charset = "UTF-8",
		-- sign_type = "MD5",
		mch_id        = router.exmch_id,
		sign_agentno  = router.exagent_id,
	  out_trade_no  = tb.trade_no,
		
		nonce_str     = nstr,
	}
	return data
end

local errcode_map = {
-- weixin 
	["Order not exists"] = "ORDER_NOT_EXIST",
}

local function change_wxscan_data( resp, result )

	return resp	
end

local function change_zfbscan_data( resp, result )
	return resp	
end

-- 响应数据转换
local change_data = {
	["WXSCAN"]    = change_wxscan_data,
	["WXQRCODE"]  = change_wxscan_data,
	["WXJSAPI"]   = change_wxscan_data,
	["ZFBSCAN"]   = change_zfbscan_data,
	["ZFBQRCODE"] = change_zfbscan_data,
	["ZFBJSAPI"]  = change_zfbscan_data,
}

local TRADE_STATE = {
	SUCCESS    = "SUCCESS" , -- 支付成功
	REFUND     = "REFUND",   -- 转入退款
	NOTPAY     = "NOTPAY",   -- 未支付
	CLOSED     = "CLOSED",   -- 已关闭
	REVOKED    = "REVOKED",  -- 已撤销（刷卡支付）
	USERPAYING = "USERPAYING",  --用户支付中
	PAYERROR   = "PAYERROR",    --支付失败(其他原因，如银行返回失败)	
}

-- 默认BANKERROR 重新发起查询
local function packresp( result, trade_type )
	local resp = {}
	
	if result == nil then
		return { retcode = "BANKERROR" }
	end
	
	if result.status ~= "0" then
		resp.retcode = "BANKERROR"
	else 
		if result.result_code == "0" then
			-- 转换为内部数据字典
			resp.retcode      = "0000"
			resp.trade_type   = trade_type           -- 交易类型
			
			resp.bank_ssn       = result.transaction_id  -- 银行流水号
			resp.time_end       = result.time_end        -- 支付完成时间
			resp.bank_type      = result.bank_type       -- 付款银行
			resp.fee_type       = result.fee_type        -- 币种
			resp.openid         = result.openid          -- 用户标识
			resp.total_fee      = result.total_fee       -- 交易金额
			resp.coupon_fee     = result.coupon_fee      -- 优惠金额
			resp.trade_state    = TRADE_STATE[ result.trade_state ] or "NOTPAY"   -- 交易状态
			resp.trade_no       = result.out_trade_no    -- 系统流水号
			resp.appid          = result.appid   
			resp.sub_appid      = result.sub_appid
			resp.is_subscribe   = result.is_subscribe
			resp.sub_is_subscribe = result.sub_is_subscribe      
			resp.third_trade_no   = result.out_transaction_id -- 第三方订单号 微信、支付宝、QQ等
			resp.attach           = result.attach             -- 商家数据包，原样返回
			resp.device_info      = result.device_info        -- 终端设备号(商户自定义，如门店编号)
			resp.mch_id           = result.mch_id             -- 渠道商户号
			
			-- 支付宝微信特殊字段转换
			local ch_data = change_data[trade_type]
			if ch_data then
				resp = ch_data( resp, result )
			else
				log( "获取数据转换方法失败:" .. trade_type )
			end
		else
			-- 错误码转换
			local errcode = errcode_map[ result.err_code ]
			if not errcode then
				local tmp = result.err_code or ""
				log("new errcode : " .. tmp)
			end
			resp.retcode = errcode or "BANKERROR"
		end
	end
	
	return resp
end

-- 光大扫码
function _M.query( tb, router )
	log(" -- bank ceb query process -- ")

	-- 组光大请求数据包
	local data = dataset( tb, router )
	
	-- 发送数据包, 并做签名验证
	local result = pcomm( data, router )

	local trade_type = router.trade_type
	
	-- 转换为内部数据
	local resp = packresp( result, trade_type )	
	log("process end")
	return resp 
end

return _M