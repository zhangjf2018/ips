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

local logger = loadmod("common.log.log")
local mysql  = loadmod("common.mysql.mysql")
local redis  = loadmod("common.redis.redis")
local tools  = loadmod("common.tools.tools")
local h_filter   = loadmod("common.filter.http_head")
local constant   = loadmod("constant.constant")
local comm_valid = loadmod("common.validator.comm_valid")
local uri_valid  = comm_valid.uri_valid
local args_valid = comm_valid.args_valid
local exception  = loadmod("common.exception.exception")
local t_execute  = tools.execute
local monitor    = logger.monitor
local reset_log_id     = logger.setLogID
local http_head_filter = h_filter.http_head_filter
local str_gsub      = string.gsub
local string_format = string.format
local load_lua   = tools.load_lua
local signtool   = loadmod("common.sign.sign")
local sign       = signtool.sign
local check_sign = signtool.check_sign
local apidef     = loadmod("constant.apidef")
local apidefine  = apidef.define

local iniparser  = loadmod("common.parser.iniparser")

-- Global method 全局函数定义 (减少require代码) -- 
errinfo          = loadmod("constant.errinfo")
throw            = exception.throw
cjson            = require("cjson")
log              = logger.log 

-- xml 解析全局引用
require("LuaXML_lib") 
xml = require "xml"

--local inig = iniparser.get("/dev/shm/sys.ini")

local function main()
	-- 1. 生成日志标识 
	reset_log_id()
	log("main process!")
	-- 2. 过滤http请求头
	http_head_filter()
	-- URI 合法校验
	uri_valid()
	
	local uri = ngx.var.uri
	local b_uri = str_gsub( uri, "/", "." )
	log(b_uri)
	
	-- 3. 获取请求参数
	local args = tools.getArgs( )
	ngx.ctx[ constant.REQ_ARGS ] = args
	log("请求参数 : ")
	local tmp = ""
	for i,v in pairs ( args ) do
		local tm = string_format("%15s : %s\r\n", i,v)
		tmp = tmp .. tm
	end
	log( tmp )

	-- 4. 校验接口公共部分数据
	args_valid( args, apidefine )
	
	--- 加载渠道或商户信息
	-- 加载签名密钥
	
	-- 校验签名
	local key = "8d4646eb2d7067126eb08adb0672f7bb"
	local is_ok = check_sign( args, key )
	if not is_ok then
		throw( errinfo.CHECKSIGN_ERROR )
	end
  -- 4. 风险及交易控制
  
  -- 5. 加载业务脚本
  -- 组服务脚本地址
  local service_script = "service" .. b_uri .. ".main"
  -- 组服务脚本的参数校验脚本
  local service_define_script = "service" .. b_uri .. ".maindef"
  log( service_define_script )

  local b_service_define, err_ = load_lua( service_define_script )
  if not b_service_define then
  	log( err_ )
  	throw( errinfo.MISS_ARGS_DEFINE )
  end
  local service_define, err_ = b_service_define.define
  if not service_define then
  	log( err_ )
  	throw( errinfo.MISS_ARGS_DEFINE )
  end
  -- 业务参数校验
  args_valid( args, service_define )
  
  local b_service, err_ = load_lua( service_script )
  if not b_service then
  	log( err_ )
  	throw( errinfo.LOAD_SERVICE_ERROR )
  end
  
  local result = b_service.process( args )

	--local ini = iniparser.get("../ips/conf/sys.ini")
	--local ini = iniparser.get("/dev/shm/sys.ini")
  --log(ini.mysql.ip)
  --[[
  local conf = ngx.shared.conf
  --if conf:get("mysql") then
  --	log("conf is null")
  	local ini = iniparser.get("/dev/shm/sys.ini")
  	log( ini.mysql )
  	conf:set("mysql", ini.mysql.ip )
  --end
  
  log(conf:get("mysql"))
 ]]--
  --log(ini.mysql.ip)
 -- log( ini )
  
 -- log(inig)
  
	return result
end

local function ex_main(  )
    local result = t_execute( main )
    -- 记录monitor 日志
    local args = ngx.ctx[ constant.REQ_ARGS ]
		monitor(args, result)
    return 0
end

--程序执行入口
local status = ex_main( )
