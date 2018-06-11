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

--- 插入数据
-- @param cols 带插入数据库表table类型数据
-- @param index index表编号
-- @param _db 数据库连接
-- @return 0 插入成功， 1 数据已存在， 2 数据库操作异常
function _M.insert(cols, index )
	
	local transdate = cols.transdate
	local tablename = "index"..index
	local sql = daotool.gen_insert_sql( tablename, cols )

	local db = get_conn( )
	if not db then
		return 2
	end

	local rs, err_, errno  = db:query( sql )

	if rs then
		db:close() -- 正常则保存连接
	end

	if not rs then
		log(tostring(err_) .. ":".. tostring(errno))
		
		if errno == 1146 then
			log("表不存在:"..tablename.. " 错误码:".. tostring(errno))
		end
		if errno == 1062 then
			return 1
		end
		return 2
	end
	if rs.affected_rows == nil or rs.affected_rows ~= 1 then
		return 2
	end
	return 0
end

function _M.query_date_by( mch_id, out_trade_no, node )
	local transdate = ""
	local sql_fmt = "select transdate from index%d where mch_id='%s' and out_trade_no='%s' limit 1 "
	local sql = string.format( sql_fmt, node, mch_id, out_trade_no )
	local db = get_conn( )
	
	if not db then
		return transdate, 2
	end
	
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end
	
	if not rs then
		log(err_ .. ":"..errno)
		return transdate, 2
	end

	if not rs[1] then
		return transdate, 1
	end
	
	transdate = rs[1].transdate

	return transdate, 0
end

return _M

