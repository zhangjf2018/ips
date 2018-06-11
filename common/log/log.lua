-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-19 22:58
-- Last modified: 2016-09-20 03:18
-- description:  日志记录模块
-------------------------------------------------

local conf           = loadmod("conf.conf")
local logger         = loadmod("common.log.logger")
local monitor_define = loadmod("constant.monitordefine") 
local mdefine        = monitor_define.define
local write_log      = logger.log

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

logger.setPath( conf.LOGPATH )
--logger.setRotateType( logger.HOUR )

function _M.setLogID( id )
    logger.setLogID( id )
end

--- 记录交易日志
--  记录系统每笔交易的记录
-- @param str  要记录的内容 可以是字符串或者table
-- @param level 
function _M.log ( str , level )
	local lev = level or 3
	write_log(str, lev) 
end

--- 监控日志
--  记录系统每笔交易的状态，以便快速定位查看和定位
-- @param args 交易参数
-- @param result 交易结果
function _M.monitor( args, result )
	logger.setMonitorDefine(mdefine)
	
	if args then
		for i, v in ipairs(mdefine) do
			logger.monitorSet(v.name , args[v.name])
		end
	end
	
	logger.monitorSet("uri", ngx.var.uri or "UNK")
	
	logger.monitorSet("retcode", result.retcode)
	logger.monitorSet("retmsg", result.retmsg)
	logger.monitor( )
end

return _M


