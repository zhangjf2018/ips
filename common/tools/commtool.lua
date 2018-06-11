---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local logger  = loadmod("common.log.log")
local log     = logger.log 
local http    = require("resty.http")
local tools   = loadmod("common.tools.tools")
local trim    = tools.trim


local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

function _M.http_send(url, body, timeout, content_type, charset, ssl_verify)
	local httpc = http.new()	
	timeout = timeout or 30000	
	httpc:set_timeout(timeout)

	content_type = content_type or "application/x-www-form-urlencoded"
	charset      = charset or "utf-8"
	content_type = content_type..";charset="..charset
	
	local tmp = "URL  :" .. url .. "\r\n" .. "Body :" .. body.."\r\n".."Timeout:" .. timeout.."\r\n".."Content-type:"..content_type
	log( tmp )	
	
	local res, err_ = httpc:request_uri(url, {
		method     = "POST",
		body       = body,
		ssl_verify = ssl_verify or false,
		headers = {
			["Content-Type"] = content_type,
		}
	})

	if not res then
		err_ = err_ or "unkonwn"
		log("http err : " .. err_ )
		throw( errinfo.HTTP_ERROR)	
	end
	
	local body = res.body
	if not body then
		err_ = err_ or "unkonwn"
		log("http err : " .. err_ )
		throw( errinfo.HTTP_ERROR)	
	end
	-- max_idle_timeout, pool_size
	--[[
	local ok, errs = httpc:set_keepalive(30*1000, 20)
	if not ok then
		log(tostring(errs) )
	end
	]]--
	body = trim( body )
	return body, err_
end

function _M.http_send_no_exception(url, body, timeout, content_type, charset, ssl_verify)
	local httpc = http.new()
	timeout = timeout or 30000
	httpc:set_timeout(timeout)
	
	content_type = content_type or "application/x-www-form-urlencoded"
	charset      = charset or "utf-8"
	content_type = content_type..";charset="..charset
	
	local tmp = "URL  :" .. url .. "\r\n" .. "Body :" .. body.."\r\n".."Timeout:" .. timeout.."\r\n".."Content-type:"..content_type
	log( tmp )	

	local res, err_ = httpc:request_uri(url, {
		method     = "POST",
		body       = body,
		ssl_verify = ssl_verify or false,
		headers = {
			["Content-Type"] = content_type,
		}
	})

	if not res then
		err_ = err_ or "unkonwn"
		log("http err : " .. err_ )
		return nil, err_
	end
	local body = res.body
	if not body then
		err_ = err_ or "unkonwn"
		log("http err : " .. err_ )
		return nil, err_
	end
	body = trim( body )
	log("渠道响应数据: \r\n" .. body )
	return body, err_
end

return _M

