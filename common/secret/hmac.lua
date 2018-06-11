---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 
--bugfix: 

--[[

--]]

local resty_hmac = require("resty.hmac")
local resty_string = require('resty.string')

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- sha256 字符串计算
-- @param str 待计算字符串
-- @return hexstr 计算结果
function _M.hmac ( str, key )
	
	local hmac = resty_hmac:new( key, resty_hmac.ALGOS.SHA256)
	if not hmac then
		return nil
	end
	
	local ok = hmac:update( str )
	if not ok then
		return nil
	end

	local hmac_result = hmac:final()
	if not hmac:reset() then
		return nil
	end
	
  local hexstr = resty_string.to_hex( hmac_result )
  hexstr = string.upper( hexstr )
  return hexstr
end

return _M