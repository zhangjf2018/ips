---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local tools  = loadmod("common.tools.tools")
local load_lua = tools.load_lua
local trim   = tools.trim
local commtool = loadmod("common.tools.commtool")
local ssntool = loadmod("common.tools.next")
local get_sys_ssn = ssntool.get_ssn 
local string_format = string.format
local string_gsub = string.gsub
local comm_valid = loadmod("common.validator.comm_valid")
local args_valid = comm_valid.args_valid

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local function get_uri() 
		local b_uri = string_gsub( ngx.var.uri, "/", "." )
		return b_uri
end

-- 加载业务参数定义
local function get_service_def( b_uri )
	local service_define_script = "service" .. b_uri .. ".maindef"

  local b_service_define, err_ = load_lua( service_define_script )
  if not b_service_define then
  	log( err_ )
  	throw( errinfo.MISS_SERVICE_URI )
  end
  local service_define, err_ = b_service_define.define
  if not service_define then
  	log( err_ )
  	throw( errinfo.MISS_SERVICE_URI )
  end
  
  return service_define
end

-- 加载业务脚本
local function get_service_script( b_uri )
	local service_script = "service" .. b_uri .. ".main"
  local b_service, err_ = load_lua( service_script )
  if not b_service then
  	log( err_ )
  	throw( errinfo.LOAD_SERVICE_ERROR )
  end
  return b_service
end

-- 获取处理服务
function _M.get_service( args )
		local b_uri = get_uri()
	  local service_define = get_service_def( b_uri ) -- 组服务脚本的参数校验脚本
  	args_valid( args, service_define )              -- 业务参数校验
  	local b_service = get_service_script( b_uri )
  	return b_service
end

return _M

