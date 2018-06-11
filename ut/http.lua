
local ctool = loadmod "common.tools.commtool"


local url = "http://127.0.0.1:8088/sequence/next"
local body = "moduleName=MC&keyName=FLOW"

local result = ctool.http_send(url, body)
ngx.say(result)
