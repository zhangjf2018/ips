-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-19 22:58
-- Last modified: 2016-09-20 03:18
-- description:  
-------------------------------------------------

local cjson = require("cjson")
local mysql = loadmod("common.mysql.mysql")
local logger = loadmod("common.log.log")
local log    = logger.log
local str_gsub = string.gsub
local rlock    = require "resty.lock"
local mysqlconf = loadmod("conf.seqmysql")

local sequence = ngx.shared.sequence

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local err = {
	NO_ARGUMENT        = { retcode = "0001", retmsg = "no argument" },
	UNFORMAL_ARGUMENT  = { retcode = "0002", retmsg = "argument format error" },
	ACCESS_URL_ERROR   = { retcode = "0003", retmsg = "access url error" },
	ACCESS_DB_ERROR    = { retcode = "0004", retmsg = "access database error" },
	TOO_BUSY           = { retcode = "0005", retmsg = "too busy" },
	NO_DATA_FOUND      = { retcode = "0006", retmsg = "no data found" },
	ARGUMENT_DUPLICATE = { retcode = "0007", retmsg = "argument duplicate" },
	NO_TABLE           = { retcode = "0008", retmsg = "table no found" },
	CONN_DB_ERROR      = { retcode = "0009", retmsg = "connect database error" },
	OPEN_FILE_ERROR    = { retcode = "0010", retmsg = "open file error"}	
}

function mysql_connect()
	local db , _err = mysql:new( mysqlconf.options )

	if not db then
		log("mysql conncet error, " .. tostring( _err ))
		error( err.CONN_DB_ERROR )
	end
	
	return db
end

function mysql_query(sql)

	local db = mysql_connect()

	local res, _err, errno = db:query(sql)
	if not res then
		log("mysql query error " .. tostring( _err ))
		error( err.CONN_DB_ERROR )
	end

	return res
end

function get_ssn( dict_key, _step )

	local info = sequence:get( dict_key.info )

	if not info then
		return nil 
	end

	info = cjson.decode(info)			

	local step = _step or info.step

	local value = sequence:incr( dict_key.value, step)

	if value == nil then
		return nil
	end

	local firstssn = value - step
	local lastssn = value - 1
	local cache = info.cache

	if cache < 1 then
		cache = 1
	end

	if lastssn >= info.value + cache then
		return nil	
	end

	if lastssn > info.max then
		return nil
	end

	firstssn = string.format("%0"..tostring(info.length).."d", firstssn)
	lastssn = string.format("%0"..tostring(info.length).."d", lastssn)

	return firstssn, lastssn
end

function get_ssn_from_db(moduleName, keyName)

	local sql = string.format("select * from sequence where moduleName = '%s' and keyName = '%s'", moduleName, keyName) 

	local rs = mysql_query(sql)
	if #rs == 0 then
		error(err.NO_DATA_FOUND)
	else
		return rs[1]
	end
end

function accumulate_ssn(ssn, moduleName, keyName)
	
	local min = ssn.min
	local max = ssn.max
	local value = ssn.value

	local cache = ssn.cache

	if cache < 1 then
		cache = 1
	end

	if value > max or value < min then
		value = min
	end

	local next_value = value + cache;

	if next_value > max or next_value < min then
		next_value = min
	end
	
	local sql = string.format("update sequence set value = %d where value=%d and moduleName='%s' and keyName='%s' ", 
										next_value, ssn.value, moduleName, keyName)
	local res = mysql_query( sql ) 

	if res.affected_rows ~= 1 then
		return false
	end

	return true
end

function update_cache(dict_key, info)
	local value = info.value
	local min = info.min
	local max = info.max

	if value < min or value > max then
		value = min
	end

	sequence:set(dict_key.value, value)	
	sequence:set(dict_key.info, cjson.encode(info))
end

function get_lock(name)
    
    local lock = rlock:new( name )

    return lock
end

function load_ssn(moduleName, keyName, dict_key, step)

	mysql_connect()

	log("get_lock")
	local lock = get_lock("sequence")

	log("lock")
	lock:lock( dict_key.lock )
	log("end")

	local firstssn, lastssn

	for i = 1, 5 do
		log(tostring(i).." get_ssn")
		firstssn, lastssn = get_ssn( dict_key, step )	

		if firstssn and lastssn then
			break
		end

		log("get_ssn_from_db")
		local info = get_ssn_from_db(moduleName, keyName)
	
		log("accumulate_ssn")	
		if accumulate_ssn(info, moduleName, keyName) then
			log("update_cache")
			update_cache(dict_key, info)
			log("update cache end")
		end
	end

	if lock then
		lock:unlock()
	end

	if db then
		db:close()
	end	

	log("loadssn end")
	return firstssn, lastssn
end

function init_dict_key(moduleName, keyName)
	local project = ngx.var.PROJECTNAME
	project = project or "DEF"
	local dict_key = {
		value = string.format("%s.%s.%s.value", project, moduleName, keyName),	
		info  = string.format("%s.%s.%s.info",  project, moduleName, keyName),
		lock  = string.format("%s.%s.%s.lock",  project, moduleName, keyName),
	}
	return dict_key 
end

local function main()

	local args = {
		moduleName = "MC",
		keyName    = "FLOW",
		--step       = "1",
	}

	local step

	log("get_ssn")
	local dict_key = init_dict_key( args.moduleName, args.keyName )
	local firstssn, lastssn = get_ssn( dict_key, step )

	if not firstssn or not lastssn then
		log("load_ssn")
		firstssn, lastssn = load_ssn(args.moduleName, args.keyName, dict_key, step)
	end

	if not firstssn or not lastssn then
		error(err.TOO_BUSY)
	end

	return { retcode = "0000", retmsg = "", firstssn = firstssn, lastssn = lastssn }
end

function _M.get_ssn()
    local _, result = pcall( main )

    if type(result) ~= "table" then
        result = { retcode = "9999" , retmsg = "system error : "..tostring(result) }
    end
    log(result)
    return result
end

return _M
