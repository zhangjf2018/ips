local cjson = require "cjson"
local mysql = require "resty.mysql"

local db = mysql:new()
local ok, err, errcode, sqlstate = db:connect({
   user = "root",
    password = "123456",
    database = "mobilepay",
    host = "168.33.211.220",
    port = "3306",
    max_packet_size = 1024 * 1024
    })

if not ok then
    ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return ngx.exit(500)
end

res, err, errcode, sqlstate = db:query("select 1; select 2; select 3;")
if not res then
    ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errcode, ": ", sqlstate, ".")
    return ngx.exit(500)
end

ngx.say("result #1: ", cjson.encode(res))

local i = 2
while err == "again" do
    res, err, errcode, sqlstate = db:read_result()
    if not res then
        ngx.log(ngx.ERR, "bad result #", i, ": ", err, ": ", errcode, ": ", sqlstate, ".")
        return ngx.exit(500)
    end

    ngx.say("result #", i, ": ", cjson.encode(res))
    i = i + 1
end

local ok, err = db:set_keepalive(10000, 50)
if not ok then
    ngx.log(ngx.ERR, "failed to set keepalive: ", err)
    ngx.exit(500)
end