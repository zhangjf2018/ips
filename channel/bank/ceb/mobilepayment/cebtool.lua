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

local pairs        = pairs
local table_sort   = table.sort
local table_concat = table.concat
local string_upper = string.upper

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

function _M.sign( tb, signkey )

	local key = signkey or ""
	if #key == 0 then
		log("sign key is nil")
		return nil
	end
	
	local tsort = {}
	local index = 0
	for k, v in pairs( tb ) do
		if k ~= "sign" and v ~= nil and v ~= "" then
			index = index + 1
			tsort[ index ] = k .. "=" .. v
		end
	end

	table_sort( tsort )

	local tc_str = table_concat( tsort, "&" )
	
	log("ceb sign str: " .. tc_str)
	
	local suffix = "&key=" .. key
	local mstr = tc_str .. suffix
	local sign = ngx.md5( mstr )
	sign = string_upper( sign )

	return sign	
end

--- 光大签名校验
-- @param tb 待签名数据
-- @param key 签名key
-- @return true 验证签名成功  false 验证签名失败
function _M.checksign( tb, key )

	local osign = tb.sign or ""

	local sign = _M.sign( tb, key )

	if sign ~= osign then
		log("验证签名失败")
		return false		
	end

	return true
end

return _M