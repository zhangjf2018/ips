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

local cjson   = require("cjson.safe")
local cjson_encode = cjson.encode
local logger  = loadmod("common.log.log")
local errinfo = loadmod("constant.errinfo")
local log     = logger.log

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- 抛出异常
-- @param errinfo 错误定义码表 table
-- @param addition_msg 附加信息
function _M.throw ( errs, addition_msg )

	local err = errs or errinfo.SYSTEM_ERROR
	
	if type( err ) ~= "table" then
		err = err or ""
		log( "err is not table :" .. err )
		err = errinfo.SYSTEM_ERROR
	end 

	if type( addition_msg ) == "string" and #addition_msg>0 then
		err.retmsg = addition_msg;
	end

	log( "err.throw " .. cjson_encode( err ), 4)

	error( err ) 
end

return _M