-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-17 19:31
-- Last modified: 2016-09-27 22:18
-- description:   
-------------------------------------------------

--bugfix: 

--[[

--]]


local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local mysql   = loadmod("common.mysql.mysql")
local daotool = loadmod("database.daotool")
local get_conn = daotool.get_conn

function _M.query_router_by( mch_id, trade_type, _status )
	local router
	local sql_fmt = "select channel_id, exmch_id, trade_type, api_key, exagent_id from pay_router where mch_id='%s' and trade_type='%s' and status='%s' limit 1 "
	local sql = string.format( sql_fmt, mch_id, trade_type, _status )
	local db = get_conn( )
	
	if not db then
		return router, 2
	end
	
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end

	if not rs then
		log(err_ .. ":"..errno)
		return router, 2
	end

	router = rs[1]
	if not router then
		return router, 1
	end

	return router, 0
end

function _M.query_router_by_exmch_id_channel_id( exmch_id, channel_id )
	local router
	local sql_fmt = " select mch_id, trade_type, exagent_id, api_key from pay_router where  exmch_id='%s' and channel_id='%s' limit 1 "
	local sql = string.format( sql_fmt, exmch_id, channel_id )
	local db = get_conn( )
	
	if not db then
		return router, 2
	end
	
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end

	if not rs then
		log(err_ .. ":"..errno)
		return router, 2
	end

	router = rs[1]
	if not router then
		return router, 1
	end

	return router, 0
end

return _M

