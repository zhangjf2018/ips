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

local valid_tool = loadmod("common.validator.valid")
local valid      = valid_tool.validate

local ngx_re_match = ngx.re.match


local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- 获取合法URI
function _M.uri_valid ( )

	local uri = ngx.var.uri
 	-- URI 必须为字母数字或下划线组成，其它为非法字符
  local m = ngx_re_match(uri, "^/([-_a-zA-Z0-9/]+)$", "jo")
  
  if not m then
  	log(" URI 格式校验出错 :" .. uri)
  	throw( errinfo.URI_FORMAT_ERROR )
  end
  
  if #uri > 50 then
  	log(" URI 长度超过50 :" .. uri)
  	throw( errinfo.URI_FORMAT_ERROR )
  end
end

--- 业务参数校验
function _M.args_valid ( args, define )

	valid( args, define)
	
end

return _M
