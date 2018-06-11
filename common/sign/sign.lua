---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local pairs        = pairs
local table_sort   = table.sort
local table_concat = table.concat
local string_upper = string.upper
local sha      = loadmod("common.secret.sha")
local sha256   = sha.sha256
local hmactool = loadmod("common.secret.hmac")
local hmac     = hmactool.hmac

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local DEFAULT_SIGNTYPE = "MD5"

local function gen_sign_str( tb ) 
	local tsort = {}
	local index = 0
	for k, v in pairs( tb ) do
		if k ~= "sign" and v ~= nil and v ~= "" then
			index = index + 1
			tsort[ index ] = k .. "=" .. v
		end
	end
	table_sort( tsort )
	local sign_str = table_concat( tsort, "&" )
	-- log("sign str: " .. sign_str)
	return sign_str
end

local function hmd5( str, key )
	local sign_str = str .. "&key="..key
	local md5_str = ngx.md5( sign_str )
	md5_str = string_upper( md5_str )
	return md5_str
end

local function hsha256( str, key )
	local sign_str = str .. "&key="..key
	local sha_str = sha256( sign_str )
	sha_str = string_upper( sha_str )
	return sha_str
end

local function hmac_sha256( str, key )
	local sign_str = str .. "&key="..key
	local hmac_str = hmac( sign_str, key )
	hmac_str = string_upper( hmac_str )
	return hmac_str
end

local SIGNTYPES = {
["MD5"]         = hmd5,
["SHA256"]      = hsha256,
["HMAC-SHA256"] = hmac_sha256,	
}

--- 接口签名
-- 默认签名算法MD5
-- @param tb 待签名数据 table 类型
-- @param key 密钥KEY
-- @return sign 签名结果，自动转大写
function _M.sign( tb, key )

	local signkey = key or ""
	if #signkey == 0 then
		log("sign key is nil")
		return nil
	end
	
	local sign_type = tb.sign_type or DEFAULT_SIGNTYPE
	local sign_method = SIGNTYPES[ sign_type ]
	
	if sign_method == nil then
		log("sign method is nil")
		return nil
	end
	
	local signstr = gen_sign_str( tb )
	local sign = sign_method( signstr, signkey )
	sign = string_upper( sign )
	return sign	
end

--- 接口签名验证
-- @param tb 待签名数据table类型
-- @param key 签名密钥KEY
-- @return true签名验证成功，false验证签名失败
function _M.check_sign( tb, key )

	local osign_value = tb.sign or ""
	local sign_value = _M.sign( tb, key )
	-- log("osign_value : " .. osign_value .. "\r\nsign_value  : " .. sign_value )

	if sign_value ~= osign_value then
		log("验证签名失败")
		return false		
	end

	return true
end


return _M

