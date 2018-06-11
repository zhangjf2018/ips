

local project = "ips"

local str_find = string.find
local s,e = str_find(package.path, project)
if not s then
	package.path = "../"..project.."/?.lua;;"..package.path
end

local hash_tool = require("common.consistent.hashtool")
local tools = require("common.tools.tools")

local a,b = 1,1;
--[[

local sum = {}

for i=1, 10000 do

	local ser = consistent.get_upstream(math.random());
	
	local m = sum[ser] or 0
	sum[ser] = m + 1
 
end

local t1 = sum["t1"] or 0
local t2 = sum["t2"] or 0
]]--

function ch( key,  num_buckets) 
    math.randomseed(key) ;
    local b = -1; --  bucket number before the previous jump
    local j = 0; -- bucket number before the current jump
    while(j<num_buckets)
    	do
        b=j;
        local r=math.random(); --  0<r<1.0
        j = math.floor( (b+1) /r);
   	end
    return b;
end

function main()
		--ngx.say( t1 ..":" ..  t2 ) --5404,4598
	local order = "44030110000120170224201922"
	--[[
	ngx.say("1: ".. hash_tool.get_hash_order( order ) )
	--ngx.say("1: ".. hash_tool.get_hash_node( order ) )
	
	local order = "44030110000120170222224201923"
	ngx.say("2: "..  hash_tool.get_hash_order( order ) )
	
	local order = "44030110000120170224201924"
	ngx.say("3: "..  hash_tool.get_hash_order( order ) )
	
	local order = "44030110000120170224201925"
	ngx.say("4: "..  hash_tool.get_hash_order( order ) )

	local order = "44030110000120170224201923"
	ngx.say("5: "..  hash_tool.get_hash_order( order ) )
	
	local order = "44030110000120170224201926"
	ngx.say("6: "..  hash_tool.get_hash_order( order ) )

	local order = "144030110000120170224201923"
	ngx.say("7: "..  hash_tool.get_hash_order( order ) )

	local order = "P142030110000120170224201923"
	ngx.say("8: "..  hash_tool.get_hash_order( order ) )

	local order = "P14203011000012OK0Mms170224201923"
	ngx.say("9: "..  hash_tool.get_hash_order( order ) )
	
	local order = "P14203019990012OK0Mms170224201929"
	ngx.say("10: "..  hash_tool.get_hash_order( order ) )
	]]--
	local key = tools.gen_ssn()

--	ngx.say(key)
	--hash_tool.get_jhash_order(key)
	hash_tool.get_jhash_order( key )
	local conf = ngx.shared.conf
	for i=1, 100 do
		ngx.say(string.format("%-3s:%-10s", i,conf:get(i)))
	end

end

main()

