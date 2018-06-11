
local cjson = require "cjson"

local m = {
retcode = "1234",
retmsg = "cskdf"
}
ngx.sleep( math.random(0,2))
ngx.say(cjson.encode(m))
