-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-17 19:31
-- Last modified: 2016-09-27 22:18
-- description:   
-------------------------------------------------

-- loadmod 加载自定义模块只能使用的方式
-- 系统模块 例如cjson 可以用require 和 loadmod 两种方式引用

local api = loadmod("api.api")
local exm = api.ex_main
local cjson = require("cjson")
-- xml 解析全局引用
require("LuaXML_lib") 
xml = require "xml"
local function main()
	

local result = exm()
ngx.say( cjson.encode( result ) )
end

main()