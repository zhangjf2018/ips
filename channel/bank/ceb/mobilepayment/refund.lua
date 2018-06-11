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
		service       = "unified.trade.refund",
		-- version = "1.0",
		-- charset = "UTF-8",
		-- sign_type = "MD5",
		mch_id        = router.exmch_id,
	  sign_agentno  = router.exagent_id,
	  out_trade_no  = tb.trade_no,
	  out_refund_no = tb.refund_id,
	  refund_fee    = tb.refund_fee,
	  total_fee     = tb.total_fee,
	  op_user_id    = router.exmch_id,
	  --refund_channel = tb.refund_channel,

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

local REFUND_CHANNEL = {

ORIGINAL = "ORIGINAL",
	
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
			resp.trade_no     = result.out_trade_no
			resp.refund_id    = result.out_refund_no
			--resp.bank_ssn   = result.transaction_id   -- 银行流水号
			resp.bank_ssn     = result.refund_id        -- 支付完成时间
			resp.exmch_id     = result.mch_id           -- 渠道商户号
			resp.refund_status  = "PROCESSING"
			resp.refund_channel = REFUND_CHANNEL[ result.refund_channel ] 
			-- 支付宝微信特殊字段转换
			
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
function _M.refund( tb, router )
	log(" -- bank ceb refund process -- ")

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