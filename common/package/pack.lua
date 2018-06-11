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


local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- hmac 
-- @param str 被计算字符串
-- @param key 密钥KEY
-- @param _macalg mac算法
function _M.query_string( tb )

	local packstr = ""

	for i,v in pairs ( tb ) do 
		packstr = packstr ..  i .."=" .. v .. "&"
	end

	return packstr
end

return _M