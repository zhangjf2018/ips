-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-17 19:31
-- Last modified: 2016-09-27 22:18
-- description: 哈希一致性
-------------------------------------------------

--bugfix: 

--[[

--]]

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local jhash = require("jhash")
local jumphash = jhash.jumphash

local jbuckets = 100

function _M.get_jhash( key )

	local keytmp = ngx.md5( key )
	local key2int = ngx.crc32_short( keytmp )
	local id = jumphash( key2int, jbuckets ) + 1

	return id
end

return _M
