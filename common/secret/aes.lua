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

local logger  = loadmod("common.log.log")
local log     = logger.log
local tools   = loadmod("common.tools.tools")
local to_bin  = tools.to_bin
local to_hex  = tools.to_hex

local aes = require("resty.aes")
local str = require("resty.string")

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local _iv = "8&@Bm*qL9#h8QbC6"

--- aes 128 cbc 加密
-- @param key 32位长度的 0~F 的密钥
function _M.aes_cbc_128_encrypt( key, msg )
	-- 长度32的key 转 16长度的 16进制数据
	-- aes cbc 只能用16位长度的密钥
	if not key or #key ~= 32 or not msg or #msg == 0 then
		log("加密 key 或 msg 参数错误")
		return nil
	end
	key = to_bin( key )
	local aes_default = aes:new( key, nil, aes.cipher(128,"cbc"), {iv = _iv})
	local encrypted, err = aes_default:encrypt( msg )
	if err then
		log("aes 128 cbc 加密错误 " .. err )
		return nil
	end
	
	encrypted = ngx.encode_base64( encrypted )
	--encrypted = to_hex( encrypted )
	return encrypted
end

--- aes 128 cbc 解密
-- @param key 32位长度的 0~F 的密钥
-- @param msg base64 密文数据
function _M.aes_cbc_128_decrypt( key, msg )
	-- 长度32的key 转 16长度的 16进制数据
	-- aes cbc 只能用16位长度的密钥
	if not key or #key ~= 32 or not msg or #msg == 0 then
		log("解密 key 或 msg 参数错误")
		return nil
	end
	msg = ngx.decode_base64( msg )
	if not msg then
		log("base64 解码失败")
		return nil
	end
	key = to_bin( key )
	local aes_default = aes:new( key, nil, aes.cipher(128,"cbc"), {iv = _iv})
	local decrypted, err = aes_default:decrypt( msg )
	if not decrypted then
		err = err or ""
		log("aes 128 cbc 解密错误 " .. err )
		return nil
	end
	return decrypted
end

--- aes 256 cbc 加密
-- @param key 32位长度的 0~F 的密钥
function _M.aes_cbc_256_encrypt( key, msg )
	-- 长度32的key 转 16长度的 16进制数据
	-- aes cbc 只能用16位长度的密钥
	if not key or #key ~= 32 or not msg or #msg == 0 then
		log("加密 key 或 msg 参数错误")
		return nil
	end
	local aes_default = aes:new( key, nil, aes.cipher(256,"cbc"), {iv = _iv})
	local encrypted, err = aes_default:encrypt( msg )
	if err then
		log("aes 256 cbc 加密错误 " .. err )
		return nil
	end
	
	encrypted = ngx.encode_base64( encrypted )
	--encrypted = to_hex( encrypted )
	return encrypted
end

--- aes 256 cbc 解密
-- @param key 32位长度的 0~F 的密钥
-- @param msg base64 密文数据
function _M.aes_cbc_256_decrypt( key, msg )
	-- 长度32的key 转 16长度的 16进制数据
	-- aes cbc 只能用16位长度的密钥
	if not key or #key ~= 32 or not msg or #msg == 0 then
		log("解密 key 或 msg 参数错误")
		return nil
	end
	msg = ngx.decode_base64( msg )
	if not msg then
		log("base64 解码失败")
		return nil
	end
	local aes_default = aes:new( key, nil, aes.cipher(256,"cbc"), {iv = _iv})
	local decrypted, err = aes_default:decrypt( msg )
	if not decrypted then
		err = err or ""
		log("aes 256 cbc 解密错误 " .. err )
		return nil
	end
	return decrypted
end

return _M