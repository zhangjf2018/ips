
local uuid = require("uuid")

local u=uuid.new("time")

ngx.say(string.format("%012d",ngx.crc32_long(u)))

htpqwklvynl=pojqhnulnxu

ngx.say(ngx.crc32_long("1htpqwklvynl"))
ngx.say(ngx.crc32_long("2pojqhnulnxu"))
