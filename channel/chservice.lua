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

local monitor = loadmod("channel.common.monitor")
local channelmonitor = monitor.channelmonitor
local logtool = loadmod("common.log.log" )
local log     = logtool.log
local exception = loadmod("common.exception.exception")
local throw     = exception.throw
local tools     = loadmod("common.tools.tools")
local load_lua  = tools.load_lua
local _time     = require "time" 

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local function main( script, func, args, router )
	
	local chservice, err_ = load_lua( script )
	if not chservice or type(chservice) ~= "table" then
		log( string.format("渠道服务脚本错误%s %s %s", script, func, tostring(err_)) )
		throw( errinfo.SYSTEM_ERROR )
	end
	
	local sprocess = chservice[ func ]
	if not sprocess then
		log("渠道服务脚本错误, 函数不存在" .. script .. ":" .. func )
		throw( errinfo.SYSTEM_ERROR )
	end
	
	local result = sprocess( args, router )

	return result
end

function _M.process( script, func, args, router )
	local tv = _time.gettimeofday()
	local trans_start_time  = os.date( "%Y-%m-%d %H:%M:%S", tv.sec ) .. "." .. string.format( "%03d", math.floor( tv.usec/1000000 ) )
	
	local ok, result = pcall( main, script, func, args, router )
	if type(result) ~= "table" then
		log( tostring( result ) )
		result = errinfo.SYSTEM_ERROR
	end

	channelmonitor( args, result, trans_start_time ) 
	
	return result
end

return _M

