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

-- virtual nodes number
local VIRTUAL_COUNT = 160
-- sharding vaitual nodes number
local CONSISTENT_BUCKETS = 65535
-- the table of virtual nodes
local VIRTUAL_NODE = {}
-- the talbe of sharding
local BUCKETS = {}
-- crc32 algorithm
local crc32 = function( arg ) return math.abs( ngx.crc32_long( arg ) ) end

-- add servers and to generate the 'BUCKETS'
-- _M.add_server( server )
-- @param {table} server all of the servers
function _M.add_hash_node( server )
	
	if #BUCKETS > 0 then
		return
	end

	for i,v in pairs(server) do
		for n=1,math.floor(VIRTUAL_COUNT) do
			local hash_key = v..'-'..(n-1);
			table.insert(VIRTUAL_NODE, {v, crc32(hash_key)});
		end
	end

	-- sorting by 'crc32(hash_key)', it means arg[2]
	table.sort(VIRTUAL_NODE, function (arg1, arg2) 
			return (arg1[2] < arg2[2]);
		end);
	-- sharding
	local slice = math.floor(0xFFFFFFFF / CONSISTENT_BUCKETS);
	for i=1, CONSISTENT_BUCKETS do
		table.insert(BUCKETS, i, hash_find(math.floor(slice * (i -1)), 1, #VIRTUAL_NODE));
	end
	ngx.say(#BUCKETS)
end
 
--- Binary search
-- @param {float} key the value of we are looking for
-- @param {float} lo first index
-- @param {float} hi last index
-- @return {table} the node 
function hash_find(key, lo, hi) 
	
	if key <= VIRTUAL_NODE[lo][2] or key > VIRTUAL_NODE[hi][2] then
		return VIRTUAL_NODE[lo];
	end

	local middle = lo + math.floor((hi - lo) / 2);
	
	if middel == 1 then
		return VIRTUAL_NODE[middle];
	elseif key <=VIRTUAL_NODE[middle][2] and key > VIRTUAL_NODE[middle-1][2] then
		return VIRTUAL_NODE[middle];
	elseif key > VIRTUAL_NODE[middle][2] then
		return hash_find(key, middle+1, hi);
	end
	
	return hash_find(key, lo, middle-1);
end
 
--- get consistent hash value
-- _M.get_upstream( key )
-- @param {string} key 
-- @return {string} node
function _M.get_hash_node( key ) 
    return BUCKETS[( crc32( key ) % CONSISTENT_BUCKETS ) + 1][1];
end

return _M
