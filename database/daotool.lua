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

local mysql = loadmod("common.mysql.mysql")

function _M.gen_insert_sql(tablename, clos) 

	local fields_name = {}
	local fields_value = {}

	for k, v in pairs( clos ) do
		fields_name[#fields_name + 1] = k
		if type(v) == "number" then
		else
			v = string.format("'%s'", v)
		end
		fields_value[#fields_value + 1] = v
	end

	fields_name = table.concat(fields_name, ",")
	fields_value = table.concat(fields_value, ",")
	
	local sql = string.format("insert into %s (%s) values (%s)", tablename, fields_name, fields_value)
	
	return sql
end

function _M.gen_update_sql(tablename, condition, upcols ) 
	
	local constr = " "
	local upstr  = "set "

	for k, v in pairs( upcols ) do

		if type(v) == "number" then
		else
			v = string.format("'%s'", v)
		end
		upstr = upstr.. k.."="..v..","
	end
	upstr = upstr:sub(1, #upstr - 1 )
	
	for k, v in pairs( condition ) do

		if type(v) == "number" then
		else
			v = string.format("'%s'", v)
		end
		constr = constr.. k.."="..v.." and "
	end
	constr = constr:sub(1, #constr - 4 )

	local sql = string.format("update %s %s where %s ", tablename, upstr, constr)
	
	return sql
end

function _M.gen_order_index( mid )
	
	local smid = mid:sub(-2)
	local order_index = ""
	smid = tonumber( smid )
	if type(smid) == "number" then
		local index = smid % 20
		order_index = "orderindex"..index
	else
		order_index = "orderindex0"
	end
	
	return order_index
	
end

function _M.get_conn( db )
	local _err = ""
	if not db then
		db , _err = mysql:new()
	end
	
	if not db then
		log("数据库连接失败: " .. _err)
	end
	
	return db
end

return _M
