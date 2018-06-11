-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-19 23:24
-- Last modified: 2016-09-20 02:10
-- description:   
-------------------------------------------------

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- API 接口公共部分
-- 需在进入业务处理脚本之前进行校验
-- 业务中无需再次校验
_M.define = {
	version       = { fmt = "^((1.0))$",                          mandatory = false },
	charset       = { fmt = "^(?i)((UTF-8))$",                    mandatory = false },
	sign_type     = { fmt = "^((MD5)|(SHA256)|(HMAC-SHA256))$",   mandatory = false },
	nonce_str     = { fmt = "^.{1,32}$",                          mandatory = true  },
	sign          = { fmt = "^.{1,128}$",                         mandatory = true  },
	
	mch_id        = { fmt = "^.{1,15}$",                          mandatory = true  }, 
	enc_type      = { fmt = "^((AES256)|(AES128)|(RSA))$",                    mandatory = false },
	biz_content   = { fmt = "^.{1,3096}$",                        mandatory = false },
}

return _M
