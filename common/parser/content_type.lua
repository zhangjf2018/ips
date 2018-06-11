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

local tools     = loadmod("common.tools.tools")
local exception = loadmod("common.exception.exception")
local errinfo   = loadmod("constant.errinfo")      
local ngx_req_get_headers = ngx.req.get_headers
local str_upper = string.upper

local _M = { _VERSION = '0.02' }
local mt = { __index = _M }

local charset_define = {

    ["charset=UTF-8" ]  = "utf8",
    ["charset=UTF8"  ]  = "utf8",
    ["charset=GB2312"]  = "gbk" ,
    ["charset=GBK"]     = "gbk" ,
}

local convert_type = {
    ["application/x-www-form-urlencoded"] = "kv",
    ["application/json"] = "json",
    ["text/xml"] = "xml",
}

-- @description 解析content-type
-- @return  返回解析content-type
function _M.handle ( )

	local headers = ngx_req_get_headers( )
	local http_content_type = headers["Content-Type"]
    
	if not http_content_type then
		exception.throw( errinfo.CONTENT_TYPE_ERR )
	end
    
	local arr = tools.split( http_content_type, ";" )
	
	if #arr ~= 3 then 
		exception.throw( errinfo.CONTENT_TYPE_ERR )
	end

	if arr[1] == nil or arr[2] == nil then
		exception.throw( errinfo.CONTENT_TYPE_ERR )
	end

    arr[1] = convert_type[ tools.trim( arr[1] ) ]
    arr[2] = tools.trim( arr[2] )
    
    if #arr[1] > 50 then
        exception.throw( errinfo.CONTENT_TYPE_ERR )
    end
    
	local _charset = charset_define[ arr[2] ] or "utf8"

	local _content_type = {
		content_type = arr[1],
		charset      = _charset,
	}	

	return _content_type
    
end 

return _M


