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

local crypto = require("crypto")
local evp    = crypto.evp
local hmac   = crypto.hmac
local encrypt = crypto.encrypt
local decrypt = crypto.decrypt
local resty_string = require("resty.string")
local to_hex = resty_string.to_hex

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- hmac 
-- @param str 被计算字符串
-- @param key 密钥KEY
-- @param _macalg mac算法
function _M.hmac( str, key, _macalg )
	
	local macalg = _macalg or "sha256"

	local hmac_sha256 = hmac.digest( macalg, str, key)
	
	return hmac_sha256
end
--- chiper
--[[
aes-128-cbc       aes-128-ecb       aes-192-cbc       aes-192-ecb       
aes-256-cbc       aes-256-ecb       base64            bf                
bf-cbc            bf-cfb            bf-ecb            bf-ofb            
camellia-128-cbc  camellia-128-ecb  camellia-192-cbc  camellia-192-ecb  
camellia-256-cbc  camellia-256-ecb  cast              cast-cbc          
cast5-cbc         cast5-cfb         cast5-ecb         cast5-ofb         
des               des-cbc           des-cfb           des-ecb           
des-ede           des-ede-cbc       des-ede-cfb       des-ede-ofb       
des-ede3          des-ede3-cbc      des-ede3-cfb      des-ede3-ofb      
des-ofb           des3              desx              idea              
idea-cbc          idea-cfb          idea-ecb          idea-ofb          
rc2               rc2-40-cbc        rc2-64-cbc        rc2-cbc           
rc2-cfb           rc2-ecb           rc2-ofb           rc4               
rc4-40            seed              seed-cbc          seed-cfb          
seed-ecb          seed-ofb          zlib     
]]--
--- openssl 加密数据
-- @param chiper 加密算法
-- @param str 被加密数据
-- @param key 加密KEY
-- @param iv 机密向量
-- @return encstr 加密后的数据
function _M.encrypt(chiper, str, key, iv)
	
	local e_chiper = chiper or "aes-128-cbc"
	local e_str = str or ""
	
	local encstr = encrypt(d_chiper, str, key, iv)
	
	return encstr 
end

return _M