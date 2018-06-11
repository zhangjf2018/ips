

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local jchash = require "resty.chash.jchash"
local tools = require "common.tools.tools"
local clib = require("jhash")


local buckets = 100
local cnt = {}

function _M.get()
	
	--local key = ngx.md5(tools.gen_ssn())
	local key = tools.gen_ssn()
	local key2int = ngx.crc32_short(key)
	local id = clib.jumphash(key2int, buckets) + 1
	--local id = jchash.hash_short_str ("Pm1" .. tools.gen_ssn(), buckets )

	local iv = cnt[id] or 0
	cnt[id] = iv + 1
	
	return cnt
end


return _M
