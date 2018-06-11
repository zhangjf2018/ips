---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local cjson   = require("cjson")
local iconv   = require("iconv")
local libtime = require("time")
local get_time_of_day = libtime.gettimeofday
local os_date = os.date
local str_fmt = string.format
local str_sub = string.sub
local str_byte = string.byte
local str_char = string.char
local str_gsub = string.gsub
local table_insert = table.insert
local tonumber     = tonumber
local tostring     = tostring
local pcall        = pcall
local type         = type
local logger       = loadmod("common.log.log")
local log          = logger.log 
local exception    = loadmod("common.exception.exception")
local throw        = exception.throw
local errinfo      = loadmod("constant.errinfo")
local _str         = require "resty.string"
local _random      = require "resty.random"

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- 通用执行函数调用的方法，该方法通过pcall调用，
-- 意在捕获error 然后通过ngx.say 返回结果
-- @param main 要被调用的函数名
-- @return 被调用函数执行返回的结果
function _M.execute( main, atexit )

	local ok, result = pcall( main )

	if type(result) ~= "table" then
		log(tostring(result))
		result = errinfo.SYSTEM_ERROR
	end

	-- 响应码描述统一处理
	if result.retmsg == nil or #result.retmsg == 0 then
		result.retmsg = errinfo.get_retmsg( result.retcode )
	end

	--[[
	local env = getfenv(1)
	if type( env.atexit ) == "function" then 
		result = env.atexit(ok, result) or result 
	end
	]]--
 	if type( atexit ) == "function" then 
		result = atexit( ok, result ) or result 
	end
	return result
end

function _M.getArgs( )

  local args = ngx.req.get_uri_args()
	if not args or next(args) == nil then
		ngx.req.read_body()
		args = ngx.req.get_post_args()
	end

	if not args or next(args) == nil then
		throw(errinfo.GET_ARGUMENT_ERROR)
	end

	for k, v in pairs(args) do
		args[k] = v
	end
	return args;
end

function _M.getBodyArgs( )

	local method = ngx.req.get_method()

	method = string.upper( method )
	
	if method ~= "POST" then
		log("http method must be POST, now is " .. method)
		return nil
	end
	-- 读取请求报文
	ngx.req.read_body()
	local body = ngx.req.get_body_data()

	if not body then
		log("请求报文为空")
		return nil
	end
	return body
end

function _M.gen_ssn()
	local tv = get_time_of_day()
	local temp = tv.usec.."000000000"
	temp = str_sub(temp,1,9)
	local ssn = os_date("%Y%m%d%H%M%S",tv.sec) .. temp
	return ssn
end

function _M.split( str, delimiter )

	local fields = {}
	str:gsub( str_fmt( "([^%s]*)%s?", delimiter, delimiter ), function(c) table_insert( fields, c ) end ) 

	return fields
end

function _M.noncestr( sand )
	sand = sand or 8
	return _str.to_hex( _random.bytes( sand, true) )
end

function _M.gbk_to_u8( s )
	return iconv.new( "utf-8", "gbk" ):iconv(s)
end

function _M.u8_to_gbk( s )
	return iconv.new( "gbk", "utf-8" ):iconv(s)
end

function _M.trim( s )
	return str_gsub( s, "^%s*(.-)%s*$", "%1" )
end

function xml_trim(s) 
	return str_gsub(s, "<!%[CDATA%[%]%]>", "")
end

function _M.json_decode( str )
	local json_value = nil
	pcall( function ( str ) json_value = cjson.decode( str ) end, str)
	return json_value
end

function _M.load_lua( f_lua )
	local lua_file = nil
	local ok,err_ = pcall( function ( f_lua ) lua_file = loadmod( f_lua ) end, f_lua )
	return lua_file, err_
end

function _M.to_hex( str )
	return ( { str:gsub( ".", function(c) return str_fmt( "%02X", c:byte(1) ) end ) } )[1]
end

function _M.to_bin( str )
	return ( { str:gsub( "..", function(x) return str_char( tonumber(x, 16) ) end) } )[1]
end

function _M.escape( s )
	return str_gsub( s, "([^A-Za-z0-9_])", function(c) return str_fmt( "%%%02x", str_byte( c ) ) end )
end

function _M.unescape( s )
	return str_gsub( s, "%%(%x%x)", function(hex) return str_char( tonumber(hex, 16) ) end )
end

function _M.isNull( str )
	if str == "null" or str == ngx.null then
		return nil
	end
	return str
end

return _M

