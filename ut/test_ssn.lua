-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-11-15 10:47
-- Last modified: 2016-11-15 10:47
-- description:   
-------------------------------------------------


local db = mysql:new()
--[[
local sql = "select * from test;"
local res = db:query(sql)
--db:close()
log(res[1].name)
--]]

local t = tools.gen_ssn()
local sql = "insert into orders(orderno) values('"..t.."')"
local p,e = db:query(sql)
if not p then
	log(e)
end
db:close()
--]]--

--[[
local conn = redis.get_conn()

conn:set(t,t)
local name = conn:get(t)
redis.close(conn)
local sp = name

local redis = require("resty.redis")

local red = redis:new()
red:set_timeout(1000)
local ok,err = red:connect("127.0.0.1","6379")
if not ok then
	log("err:" .. err)
end
ok, err = red:set(t, t)
if not ok then
	log("set err:"..err)
end
local sp, err = red:get(t)
--red:close()
ok, err = red:set_keepalive(10000, 1000)

sp = string.format(":%30s:",sp)
ngx.say(sp)
log(sp)

local p = ngx.null
ngx.say(type(p))
]]--
--ngx.say(package.path)

