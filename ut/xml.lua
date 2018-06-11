-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-11-15 10:47
-- Last modified: 2016-11-15 10:47
-- description:   
-------------------------------------------------

local project = "ips"
local str_find = string.find
local s,e = str_find(package.path, project)
if not s then
	package.path = "../"..project.."/?.lua;;"..package.path
end
local logger = require("common.log.log")
-- Global method 全局函数定义 (减少require代码) -- 
errinfo          = require("constant.errinfo")
cjson            = require("cjson")
log              = logger.log 

require("LuaXML_lib")
xml = require "xml"

local xmls = require("common.parser.xml")

ngx.req.read_body()
local args = ngx.req.get_body_data()


local sml = xmls.parse( args )

ngx.say( cjson.encode(sml) )

function pack( tb )
	local xml = "<xml>"

    for k, v in pairs( tb ) do
        if v ~= nil and v ~= "" then
            xml = xml .. "<" .. k .. ">" .. v .. "</" .. k .. ">"
        end
    end

    xml = xml .. "</xml>"
    return xml
end

function pack_cdata ( tb )

	local xml = "<xml>"

	for k, v in pairs( tb ) do
		if v ~= nil and v ~= "" then
			xml = xml .. "<" .. k .. "><![CDATA[" .. v .. "]]></" .. k .. ">"
		end
	end

	xml = xml .. "</xml>"
	return xml
end

local mms = {
	retcode = "12312",
	retmsg = "sdfs324",	
}

ngx.say(pack(mms))
ngx.say(pack_cdata(mms))