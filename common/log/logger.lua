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

local _random  = require "resty.random" 
local _str     = require "resty.string" 
local _time    = require "time" 
local str_fmt  = string.format
local str_gsub = string.gsub
local str_sub  = string.sub
local os_date  = os.date
local os_time  = os.time
local table_insert  = table.insert
local table_sort    = table.sort
local io_open       = io.open
local os_execute    = os.execute
local debug_getinfo = debug.getinfo
local math_floor    = math.floor
local tonumber      = tonumber
local tostring      = tostring

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }
local LOGID = "LOG_ID"

local function trim(s)
	return str_gsub(s, "^%s*(.-)%s*$", "%1")
end

--- 用分隔符切分字符串
-- @param  str       要切分的字符串
-- @param  delimiter 分隔符
-- @return 返回一个table 里面存有切分后的字符串
local function split(str, delimiter)

	local fields = {}
	str:gsub( str_fmt( "([^%s]*)%s?", delimiter, delimiter), function(c) table_insert(fields, c) end)

	if fields[#fields] == "" then
		fields[#fields] = nil
	end

	return fields
end

--- 将一个lua变量转换为字符串
--  可以让你更加清楚的看到这个变量里面到底存了什么内容
-- @param  value 要转换成字符串的变量
-- @return 变量内容的字符串形式
local function to_str( value )
	local str = ''

	if type(value) ~= 'table' then
		if type(value) == 'string' then
			str = str_fmt("%q", value)
		else
			str = tostring(value)
		end
	else
		local auxTable = {}
		for key in pairs(value) do
			if tonumber(key) ~= key then
				table_insert(auxTable, key)
			else
				table_insert(auxTable, to_str(key))
			end
		end
		table_sort(auxTable)

		str = str .. '{'
		local separator = ""
		local entry = ""
		for _, fieldName in ipairs(auxTable) do
			if tonumber( fieldName ) and tonumber( fieldName ) > 0 then
				entry = to_str( value[ tonumber( fieldName ) ] )
			else
				entry = fieldName .. "=" .. to_str( value[ fieldName ] )
			end
			str = str .. separator .. entry
			separator = ", "
		end
		str = str .. '}'
	end
	return str
end

--- log ID 
-- 当前交易的log标识号，查询log的时候可以用来定位一笔交易。
-- @class table
-- @name id
-- @field id 用于定义当前交易log的8位随机16进制字符。
--_M.id = _str.to_hex( _random.bytes(4, true) )

_M.DAY  = 1
_M.HOUR = 2
_M.rotateType = _M.DAY

--- 设置记录日志文件的类型。
-- @param rotateType 要设定的类型。 
-- @return 没有返回。
-- @usage logger.setRotateType(logger.HOUR)
function _M.setRotateType( rotateType )
	_M.rotateType = rotateType	
end

--- description 设置日志ID
function _M.setLogID( id )

    if id then
        _M.id = id
    else
        _M.id = _str.to_hex( _random.bytes(4, true) )
    end
    
    ngx.ctx[ LOGID ] = _M.id
    local tv = _time.gettimeofday()
    -- local t  = os_date( "%Y-%m-%d %H:%M:%S", tv.sec ) .. "." .. str_fmt( "%03d", math_floor( tv.usec/1000000 ) )
    local t  = os_date( "%Y-%m-%d %H:%M:%S", tv.sec ) .. "." .. str_fmt( "%03d", math_floor( tv.usec/1000 ) )
    ngx.ctx["trans_start_time"] = t
end

--- 设置记录日志的目录.
-- @param path 记录日志的目录。
-- @return 没有返回
-- @usage logger.setPath("../logs/quickpay/")
function _M.setPath( path )

	_M.path = path
	local f, err = io_open( path, "r" )
	if not f then
		os_execute( str_fmt("mkdir %s -p", path) )
		return
	end 
	f:close()
end

--- 记录日志信息到文件traceYYYYMMDD.log中.
-- 文件被记录由setPath指定的目录中。
-- 格式 ： [时间] [日志id] [文件, 行] 日志信息
-- @param str 记录的日志信息，如果str不是string类型，将会被转换为字符串。
-- @return 没有返回
-- @usage logger.log("retcode = " .. retcode)
local cache_t_file = { }
function _M.log(str, level)

	str = str or ""
	-- 1. 如果不是string 会将变量转换为字符串。
	if type( str ) ~= "string" then
		str = to_str( str )
	end
	
	local file
	if _M.rotateType == _M.DAY then
		file = str_fmt("%s/trace%s.log", _M.path, os_date( "%Y%m%d" ) )
	else
		file = str_fmt("%s/trace%s.log", _M.path, os_date( "%Y%m%d.%H" ) )
	end
	
	local tf = cache_t_file[ file ]

	--local file = str_fmt("%s/trace.log",_M.path)
	if not tf then
		tf, err = io_open( file, "a" )
		for i,v in pairs ( cache_t_file ) do
			if io.type(v) == "file" then
				v:close()
			end
		end
		cache_t_file = { }
		cache_t_file[ file ] = tf
	end

	-- 2. 如果打开文件失败直接返回，如果发现没有日志文件可以检查目录是否存在,还有权限。
	if not tf then return end

	-- 3. 获取打日志时候的代码位置
	level = tonumber( level ) or 2

	if level < 2 then  
		level = 2
	end

	local debug_info = debug_getinfo( level, "Snl" )

	local i, j = debug_info.short_src:find( "[^/]+$" )
	local filename = str_sub( debug_info.short_src, i, j )	
	local position = str_fmt( "%s, %d", filename, debug_info.currentline )

	local tv = _time.gettimeofday()
	-- local t = os_date( "%H:%M:%S", tv.sec ) .. ":" .. str_fmt( "%03d", math_floor( tv.usec/1000000 ) )
	local t = os_date( "%H:%M:%S", tv.sec ) .. ":" .. str_fmt( "%03d", math_floor( tv.usec/1000 ) )

	-- 4. 每一行都要按照日志格式输出到日志文件中。
	local slines = split(str, "\n")
	for i, v in ipairs(slines) do
		local line = str_fmt("[%s] [%s] [%s] %s\r\n", t, ngx.ctx[ LOGID ], position, v )
	--	local line = str_fmt("%s\n", v )
		tf:write( line )
		tf:flush()
	end
	--f:close()
end

_M.monitorData   = {}
_M.monitorDefine = {}
_M.monitorFields = {}

local placeholder   = "_"

--- 设置monitor的格式定义。
-- @param define monitor格式定义。
-- @return 没有返回
-- @usage logger.setMonitorDefine(require("paymentMonDefine"))
function _M.setMonitorDefine(define)

	_M.monitorDefine = define
	for i, v in ipairs(_M.monitorDefine) do
		_M.monitorFields[ v.name ] = placeholder
	end
end

--- 设置monitor相关域的值。
-- @param key 要设置的域。
-- @param value 要设置的相关域对应的值。
-- @return 没有返回。
-- @usage logger.monitorSet("mcssn", mcssn)
function _M.monitorSet( key, value )
	_M.monitorFields[ key ] = value or placeholder
end

--- 记录monitor日志.
-- @return 没有返回
-- @usage logger.monitor()
local cache_mf_file = { }
function _M.monitor()

	-- 1. 获取文件名
	local file = str_fmt( "%s/monitor%s.log", _M.path, os_date( "%Y%m%d" ) )										

	--local file = str_fmt("%s/monitor.log",_M.path)
	local mf = cache_mf_file[ file ]
	if not mf then
		mf, err = io_open( file, "a" )
		for i,v in pairs ( cache_mf_file ) do
			if io.type(v) == "file" then
				v:close()
			end
		end
		cache_mf_file = { }
		cache_mf_file[ file ] = mf
	end
	-- 2. 如果打开文件失败直接返回，如果发现没有日志文件可以检查目录是否存在,还有权限。
	if not mf then return end

	local tv = _time.gettimeofday()
	-- local trans_end_time  = os_date( "%Y-%m-%d %H:%M:%S", tv.sec ) .. "." .. str_fmt( "%03d", math_floor( tv.usec/1000000 ) )
	local trans_end_time  = os_date( "%Y-%m-%d %H:%M:%S", tv.sec ) .. "." .. str_fmt( "%03d", math_floor( tv.usec/1000 ) )

	local t_end_time = trans_end_time:sub( 12 )  -- 交易结束时间 去掉 年月日
	
	local trans_start_time = ngx.ctx["trans_start_time"] 
	local t_start_time = trans_start_time:sub(12)  -- 交易起始时间 去掉 年月日

	local pt = _M.cal_diff_time( trans_start_time, trans_end_time ) -- 时间差

	--local line = str_fmt( "%s %s %04d %s", t_start_time, t_end_time, pt, ngx.ctx[ LOGID ] )
	local line = str_fmt( "%s|%s|%04d|%s", t_start_time, t_end_time, pt, ngx.ctx[ LOGID ] )

	for i, v in ipairs( _M.monitorDefine ) do
		local s = _M.monitorFields[ v.name ]
		s = s or ""
		s = trim( s )
		if #s == 0 then s = placeholder end
		s = s:sub( -tonumber( v.maxlen ) )
		--line = line .. str_fmt( " %-" .. v.maxlen .. "s", s )	
		line = line .. "|".. s
	end

	line = line .. "\r\n"

	mf:write( line )
	mf:flush()

end

--- 记录monitor日志.
-- @return 没有返回
-- @usage logger.monitor()
-- @param mfields 数据table  
-- @param mdefine 记录项 
-- @param start_time 交易起始时间 %Y%m%d%H%M%S.SSS 
-- @param end_time 交易结束时间
local cache_chmf_file = { }
function _M.channelmonitor( mfields, mdefine, start_time, _logpath )

	local logpath = _logpath or _M.path

	-- 1. 获取文件名
	local file = str_fmt( "%s/monitor%s.log", logpath, os_date( "%Y%m%d" ) )										

	--local file = str_fmt("%s/monitor.log",_M.path)
	local mf = cache_chmf_file[ file ]
	if not mf then
		mf, err = io_open( file, "a" )
		for i,v in pairs ( cache_chmf_file ) do
			if io.type(v) == "file" then
				v:close()
			end
		end
		cache_chmf_file = { }
		cache_chmf_file[ file ] = mf
	end
	-- 2. 如果打开文件失败直接返回，如果发现没有日志文件可以检查目录是否存在,还有权限。
	if not mf then return end

	local tv = _time.gettimeofday()
	-- local trans_end_time  = os_date( "%Y-%m-%d %H:%M:%S", tv.sec ) .. "." .. str_fmt( "%03d", math_floor( tv.usec/1000000 ) )
	local trans_end_time  = os_date( "%Y-%m-%d %H:%M:%S", tv.sec ) .. "." .. str_fmt( "%03d", math_floor( tv.usec/1000 ) )

	local t_end_time = trans_end_time:sub( 12 )  -- 交易结束时间 去掉 年月日
	local t_start_time = start_time:sub( 12 )  -- 交易起始时间 去掉 年月日

	local pt = _M.cal_diff_time( start_time, trans_end_time ) -- 时间差

	--local line = str_fmt( "%s %s %04d %s", t_start_time, t_end_time, pt, ngx.ctx[ LOGID ] )
	local line = str_fmt( "%s|%s|%04d|%s", t_start_time, t_end_time, pt, ngx.ctx[ LOGID ] )

	for i, v in ipairs( mdefine ) do
		local s = mfields[ v.name ]
		s = s or ""
		s = trim( s )
		if #s == 0 then s = placeholder end
		s = s:sub( -tonumber( v.maxlen ) )
		--line = line .. str_fmt( " %-" .. v.maxlen .. "s", s )	
		line = line .. "|" .. s
	end

	line = line .. "\r\n"

	mf:write( line )
	mf:flush()
end

--- 计算时间差
-- @param _start_time 起始时间字符串 例如 %Y%m%d%H%M%S.SSS 毫秒
-- @param _end_time  结束时间字符串 例如 %Y%m%d%H%M%S.SSS 毫秒
function _M.cal_diff_time( _start_time, _end_time )
	
	local start_time = str_gsub( _start_time,"[(%.)|(:)|(%s)|(%-)]", "")
	local mss = start_time:sub(-3)
	local start_time_tb = _M.getdate( start_time )
	local ts1 = os_time( start_time_tb )
	
	local end_time = str_gsub( _end_time,"[(%.)|(:)|(%s)|(%-)]", "")
	local mse = end_time:sub(-3)
	local end_time_tb = _M.getdate( end_time )
	local ts2 = os_time( end_time_tb )

	local pt = ts2 - ts1 -- 交易耗时
	pt = pt*1000 + tonumber( mse ) - tonumber( mss )
	return pt
end

function _M.getdate(str)
    local Y = str:sub(1,4)
    local M = str:sub(5,6)
    local D = str:sub(7,8)
    local H = str:sub(9,10)
    local MM = str:sub(11,12)
    local SS = str:sub(13,14)
    return { year=Y, month=M, day=D, hour=H, min=MM, sec=SS }
end

return _M

