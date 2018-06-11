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

local ngx_req_get_headers = ngx.req.get_headers
local ngx_req_get_method  = ngx.req.get_method
local str_upper = string.upper
local str_fmt = string.format

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

-- @description 过滤http头
function _M.http_head_filter ( ) 

	local headers     = ngx_req_get_headers()
	local http_method = ngx_req_get_method()
	http_method = str_upper( http_method )

	if http_method ~= "POST" and http_method ~= "GET" then
		throw( errinfo.HTTP_METHOD_ERROR )
	end
end

return _M
