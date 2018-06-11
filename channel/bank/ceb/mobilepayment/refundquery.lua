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
		service       = "unified.trade.refundquery",
		-- version = "1.0",
		-- charset = "UTF-8",
		-- sign_type = "MD5",
		mch_id        = router.exmch_id,
	  sign_agentno  = router.agentno,
	  out_trade_no  = tb.trade_no,
	  out_refund_no = tb.refund_id,
	  refund_id     = tb.bank_ssn,	
		nonce_str     = nstr,
	}
	return data
end

local errcode_map = {
-- weixin 
["ORDERNOTEXIST"]    = "ORDER_NOT_EXIST",
["Order not exists"] = "ORDER_NOT_EXIST",
["ACQ.TRADE_NOT_EXIST"] = "ORDER_NOT_EXIST",
}

local REFUND_STATUS = {
SUCCESS    = "SUCCESS" , 
PROCESSING = "PROCESSING",
CHANGE     = "CHANGE",
NOTSURE    = "START",
FAIL       = "FAIL",
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
			resp.retcode        = "0000"
			resp.trade_no       = result.out_trade_no
			resp.exmch_id       = result.mch_id
			resp.total_fee      = result.total_fee 
			
			resp.refund_id           = result.out_refund_no_0
			resp.bank_ssn            = result.refund_id_0
			resp.refund_success_time = result.refund_time_0       
			resp.refund_fee          = result.refund_fee_0
			resp.refund_channel      = REFUND_CHANNEL[result.refund_channel_0]
			resp.refund_status       = REFUND_STATUS[result.refund_status_0] or "PROCESSING"
			
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
function _M.refundquery( tb, router )
	log(" -- bank ceb query process -- ")

	-- 组光大请求数据包
	local data = dataset( tb, router )
	
	-- 发送数据包, 并做签名验证
	local result = pcomm( data )

	local trade_type = router.trade_type
	
	-- 转换为内部数据
	local resp = packresp( result, trade_type )	
	log("process end")
	return resp 
end

return _M