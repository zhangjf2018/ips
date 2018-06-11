---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local tools         = loadmod("common.tools.tools")
local trim          = tools.trim
local commtool      = loadmod("common.tools.commtool")
local ssntool       = loadmod("common.tools.next")
local get_sys_ssn   = ssntool.get_ssn 
local string_format = string.format

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

function _M.getssn( step )
	--local url = "http://127.0.0.1:8088/sequence/next"
	--local body = "moduleName=MC&keyName=FLOW"
	--local seqssn = commtool.http_send(url, body)
	--local ssn = cjson.decode( seqssn )
	local ssn = get_sys_ssn()
	if not ssn then
		return nil
	end
	return ssn.lastssn
end

function _M.log_args( args )
	local tmp = "请求参数 : \r\n"
	for i,v in pairs ( args ) do
		local tm = string_format("%15s : %s\r\n", i,v)
		tmp = tmp .. tm
	end
	log( tmp )
end

return _M

