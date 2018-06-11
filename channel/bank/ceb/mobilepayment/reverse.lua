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

local tools = loadmod("common.tools.tools")
local load_lua = tools.load_lua

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local prefixs = {
    ["10"]="WXSCAN",
    ["11"]="WXSCAN",
    ["12"]="WXSCAN",
    ["13"]="WXSCAN",
    ["14"]="WXSCAN",
    ["15"]="WXSCAN",
    ["25"]="ZFBSCAN",
    ["26"]="ZFBSCAN",
    ["27"]="ZFBSCAN",
    ["28"]="ZFBSCAN",
    ["29"]="ZFBSCAN",
    ["30"]="ZFBSCAN",
}

function get_payway( auth_code )
	log("auth_code:"..auth_code)
	local prefix = auth_code:sub(1,2)
	local payway = prefixs[prefix]
	
	if not payway then
		throw( errinfo.AUTH_CODE_INVALID )
	end

	return payway
end

function _M.process( args )
	
	-- [[ trade_type
	WXJSAPI   微信公众号跳转支付
	WXQRCODE  微信正扫
	WXSCAN    微信反扫
	ZFBQRCODE 支付宝正扫
	ZFBSCAN   支付宝反扫
	ZFBJSAPI  支付宝服务窗
	]]--
	log("-------micropay service start---------")
	
	args.total_fee = tonumber(args.total_fee)
	
	-- 获取路由
	
	local forins = "10008000"
	
	local s_forins = "service.pay.trade.micropay." .. forins
	
	local forins_service = load_lua( s_forins )
	
	if not forins_service then 
		throw( errinfo.LOAD_SERVICE_ERROR )
	end
	
	local result = forins_service.process( args , router )
	
	log("===============================")
	--[[
	local db = mysql:new()
	local t = tools.gen_ssn()
	local sql = "insert into orders(orderno) values('"..t.."')"
	local p,e = db:query(sql)
	if not p then
		log(e)
	end
	db:close()
	]]--
	return result
end

return _M