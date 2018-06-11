---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local aestool = loadmod("common.secret.aes")
local aes_cbc_128_encrypt = aestool.aes_cbc_128_encrypt
local aes_cbc_128_decrypt = aestool.aes_cbc_128_decrypt
local aes_cbc_256_encrypt = aestool.aes_cbc_256_encrypt
local aes_cbc_256_decrypt = aestool.aes_cbc_256_decrypt
local logger     = loadmod("common.log.log")
local log        = logger.log
local exception  = loadmod("common.exception.exception")
local errinfo    = loadmod("constant.errinfo")
local throw      = exception.throw
local cjson      = require("cjson.safe")

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local DECFUNCS = {
	AES128 = aes_cbc_128_decrypt,
	AES256 = aes_cbc_256_decrypt,
}

local ENCFUNCS = {
	AES128 = aes_cbc_128_encrypt,
	AES256 = aes_cbc_256_encrypt,
}

local function get_dec_func( enc_type )
	local func = DECFUNCS[ enc_type ]
	if not func then
		log("获取解密方法失败，使用默认aes_cbc_256_decrypt进行解密")
		func = aes_cbc_256_decrypt
	end
	
	return func
end

local function get_enc_func( enc_type )
	local func = ENCFUNCS[ enc_type ]
	if not func then
		log("获取加密方法失败，使用默认aes_cbc_256_decrypt进行加密")
		func = aes_cbc_256_encrypt
	end
	
	return func
end

--- 解密
-- biz_content 需为base64数据
function _M.decrypt( args, key )
	local biz_content = args.biz_content
	if biz_content == nil then
		log("待解密数据为空")
		throw( errinfo.MISS_PARAM_BIZ_CONTENT )
	end
	local enc_type = args.enc_type
	local func = get_dec_func( enc_type )
	local dec_str = func( key, biz_content )
	if not dec_str then
		throw( errinfo.DECRYPT_ERROR )
	end
	local json_biz_content = cjson.decode( dec_str )
	
	for k, v in pairs ( json_biz_content ) do
		args[ k ] = v
	end
	return args
end

--- 加密
-- 返回base64数据
function _M.encrypt( msg, enc_type, key )
	if msg == nil then
		log("待加密数据为空")
		return nil
	end
	local func = get_enc_func( enc_type )
	local enc_str = func( key, msg )
	if not enc_str then
		throw( errinfo.ENCRYPT_ERROR )
	end
	return enc_str
end

return _M

