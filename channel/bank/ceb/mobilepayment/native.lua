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
	
	local service = {
		["WXQRCODE"]  = "pay.weixin.native",	
		["ZFBQRCODE"] = "pay.alipay.native",	
	}
	
	local data = {
		service       = service[ router.trade_type ],
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
		mch_create_ip = tb.mch_create_ip,
		notify_url    = "http://192.168.29.12/callback",
		--time_start    = tb.time_start,
		--time_expire   = tb.time_expire,
		--goods_tag     = tb.goods_tag,
		nonce_str     = nstr,
	}
	return data
end

local errcode_map = {
-- weixin 
SYSTEMERROR    = "BANKERROR",
ORDERPAID      = "ORDERPAID",
ORDERCLOSED    = "ORDERCLOSED",
OUT_TRADE_NO_USED   = "OUT_TRADE_NO_USED",

}

-- 默认BANKERROR 扫码不用查询,商户重新下单
local function packresp( result, trade_type )
	local resp = {}
	
	if result == nil then
		return { retcode = "BANKERROR" }
	end
	
	if result.status ~= "0" then
		resp.retcode = "BANKERROR"
	else 
		if result.result_code == "0" then
			-- 付款成功
			-- 转换为内部数据字典
			resp.retcode = "0000"
			resp.trade_type   = trade_type           -- 交易类型
			
			resp.code_url     = result.code_url      -- 二维码
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
function _M.native( tb, router )
	log(" -- bank ceb native process -- ")

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