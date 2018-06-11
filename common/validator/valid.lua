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

local errinfo   = loadmod("constant.errinfo")
local exception = loadmod("common.exception.exception")
local throw     = exception.throw
local ngx_re_match = ngx.re.match
local str_fmt      = string.format
local tostring     = tostring

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- 报文校验
-- @param  args  被校验参数
-- @param  args_define 参数校验规则
function _M.validate ( args, args_define )

	local check = {}

	for k, v in pairs( args_define ) do
		if v.mandatory == true then
			check[k] = v.fmt
		end 

		if args[k] then
			check[k] = v.fmt
		end 
	end 

	for k, v in pairs( check ) do
		if not args[k] then
			throw( errinfo.ARGUMENT_ERROR, str_fmt( "参数域 %s 不能为空", tostring(k) ) )
		end

		if type(args[k]) == "table" then
			throw( errinfo.ARGUMENT_DUPLICATE, str_fmt( "参数域 %s 不能为table类型", tostring(k) ) )
		end

		if not ngx_re_match( args[k], v, "jo") then
			throw( errinfo.ARGUMENT_ERROR, str_fmt( "参数域 %s 格式错误", tostring(k) ) )
		end
	end

end

return _M
