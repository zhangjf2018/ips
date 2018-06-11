---------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------- 
----bugfix: 

--[[
    交易日志、监控日志模块
--]]

local project = ngx.var.PROJECTNAME

local conf    = loadmod("conf.conf")
local logger  = loadmod("common.log.logger")
local channelmonitor  = logger.channelmonitor

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local mdefine = {
		[1]  = {name="transId",   maxlen=20},
		[2]  = {name="channelno", maxlen=6 },
    [3]  = {name="exmerno",   maxlen=25},
    [4]  = {name="sysssn",    maxlen=32},
    [5]  = {name="channelssn",maxlen=32},
    [6]  = {name="retcode",   maxlen=4 },
    [7]  = {name="retmsg",    maxlen=30},
	
}

--- 监控日志
--  记录系统每笔交易的状态，以便快速定位查看和定位
-- @param args 交易参数
-- @param result 交易结果
function _M.channelmonitor( args, result, start_time )
	local mfields = {}
	if args then
		for i, v in ipairs(mdefine) do
			mfields[ v.name ] = args[ v.name ]
		end
	end
	
	if result then
		mfields["retcode"] = result.retcode
		mfields["retmsg"]  = result.retmsg
	end

	channelmonitor( mfields, mdefine, start_time , conf.CHANLELOGPATH ) 
end

return _M



