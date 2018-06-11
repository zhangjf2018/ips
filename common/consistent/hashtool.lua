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

local con_hash = loadmod("common.consistent.hash")
local con_jhash = loadmod("common.consistent.jhash")

local hash_nodes = {
	'1' , '2', '3', '4', '5', '6', '7', '8', '9','10',
	'11','12','13','14','15','16','17','18','19','20',
	'21','22','23','24','25','26','27','28','29','30',
	'31','32','33','34','35','36','37','38','39','40',
	'41','42','43','44','45','46','47','48','49','50',
	'51','52','53','54','55','56','57','58','59','60',
	'61','62','63','64','65','66','67','68','69','70',
	'71','72','73','74','75','76','77','78','79','80',
	'81','82','83','84','85','86','87','88','89','90',
	'91','92','93','94','95','96','97','98','99','100'
}
--[[
local hash_nodes = {
	'1' , '2', '3', '4', '5', '6', '7', '8', '9','10'
}
]]--

--- hash环
-- @param key 输入参数
-- @return 响应key所对应的hash_nodes
function _M.get_hash_order( key )
	con_hash.add_hash_node( hash_nodes )
	local node = con_hash.get_hash_node( key )
local conf = ngx.shared.conf
	conf:incr(node,1,0)
	return node 
end

--- hash jump
-- @param key 输入参数
-- @return 响应key所对应的 bunkets
function _M.get_jhash_order( key )
	
	local id = con_jhash.get_jhash( key )
	return id
end

return _M
