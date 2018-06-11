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

local resty_sha256 = require("resty.sha256")
local resty_string = require('resty.string')

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- sha256 字符串计算
-- @param str 待计算字符串
-- @return hexstr 计算结果
function _M.sha256 ( str )

	local isha256 = resty_sha256:new()
  isha256:update( str )
  local digest = isha256:final()
  local hexstr = resty_string.to_hex( digest )
  
  return hexstr
end

return _M