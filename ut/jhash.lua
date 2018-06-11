

local project = "ips"

local str_find = string.find
local s,e = str_find(package.path, project)
if not s then
	package.path = "../"..project.."/?.lua;;"..package.path
end

local jchash_server = require "resty.chash.server"

local jchash = require "resty.chash.jchash"

local jhash1 = require "ut.jhash1"
local tools = require("common.tools.tools")
local clib = require("jhash")

local buckets = 100


local my_servers = {
    { "127.0.0.1", 80, 1},   -- {addr, port, weight} weight can be left out if it's 1
    { "127.0.0.2", 80 },
    { "127.0.0.3", 80 }
}
--[[
local cs, err = jchash_server.new(my_servers)
]]--

--[[
local order = "44030110000120170224201922"
	
	--ngx.say("1: ".. cs:lookup( order )[1] )
	local id = jchash.hash_short_str(order, buckets)
	ngx.say("1: ".. id )
	
	local key2int = ngx.crc32_short( order )
	local id = clib.jumphash(key2int, buckets) + 1
	ngx.say("1: ".. id )
	
	--ngx.say("1: ".. hash_tool.get_hash_node( order ) )
	
	local order = "44030110000120170222224201923"
	--ngx.say("2: "..  cs:lookup( order )[1] )
	local id = jchash.hash_short_str(order, buckets)
	ngx.say("2: ".. id )
	local key2int = ngx.crc32_short( order )
	local id = clib.jumphash(key2int, buckets) + 1
	ngx.say("1: ".. id )
	
	local order = "44030110000120170224201924"
--	ngx.say("3: "..  cs:lookup( order )[1]  )
	local id = jchash.hash_short_str(order, buckets)
	ngx.say("3: ".. id )
	local key2int = ngx.crc32_short( order )
	local id = clib.jumphash(key2int, buckets) + 1
	ngx.say("1: ".. id )
	
	local order = "44030110000120170224201925"
--	ngx.say("4: "..  cs:lookup( order )[1]  )
	local id = jchash.hash_short_str(order, buckets)
	ngx.say("4: ".. id )
	local key2int = ngx.crc32_short( order )
	local id = clib.jumphash(key2int, buckets) + 1
	ngx.say("1: ".. id )

	local order = "44030110000120170224201923"
--	ngx.say("5: "..  cs:lookup( order )[1]  )
	local id = jchash.hash_short_str(order, buckets)
	ngx.say("5: ".. id )
	local key2int = ngx.crc32_short( order )
	local id = clib.jumphash(key2int, buckets) + 1
	ngx.say("1: ".. id )
	
	local order = "44030110000120170224201926"
--	ngx.say("6: "..  cs:lookup( order )[1]  )
	local id = jchash.hash_short_str(order, buckets)
	ngx.say("6: ".. id )
	local key2int = ngx.crc32_short( order )
	local id = clib.jumphash(key2int, buckets) + 1
	ngx.say("1: ".. id )

	local order = "144030110000120170224201923"
--	ngx.say("7: "..  cs:lookup( order )[1]  )
	local id = jchash.hash_short_str(order, buckets)
	ngx.say("7: ".. id )
	local key2int = ngx.crc32_short( order )
	local id = clib.jumphash(key2int, buckets) + 1
	ngx.say("1: ".. id )

	local order = "P142030110000120170224201923"
--	ngx.say("8: "..  cs:lookup( order )[1]  )
	local id = jchash.hash_short_str(order, buckets)
	ngx.say("8: ".. id )
	local key2int = ngx.crc32_short( order )
	local id = clib.jumphash(key2int, buckets) + 1
	ngx.say("1: ".. id )

	local order = "P14203011000012OK0Mms170224201923"
--	ngx.say("9: "..  cs:lookup( order )[1]  )
	local id = jchash.hash_short_str(order, buckets)
	ngx.say("9: ".. id )
	
	
	local order = "P14203019990012OK0Mms170224201929"
--	ngx.say("10: "..  cs:lookup( order )[1]  )
	local id = jchash.hash_short_str(order, buckets)
	ngx.say("10: ".. id )
]]--



local key2int = ngx.crc32_short( "20171019184331712129685" )
	local id = clib.jumphash(key2int, buckets) + 1
	ngx.say("1: ".. id )

local cnt = jhash1.get()

for i,v in pairs ( cnt ) do
	
	ngx.say(string.format("%-3s:%-10s", i,v))
end

