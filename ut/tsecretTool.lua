
local secret_tool = loadmod("public.secret_tool")
local aes = loadmod("common.secret.aes")
local cjson = require("cjson")

local key = "0f607264fc6318a92b9e13c65db7cd3c"

--local ens = "hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡==="

local ens = {
mername = "战狼",
amt = "100.00",
out_trade_no = "128391283712736",	
}
ngx.say(cjson.encode(ens))
local res = aes.aes_cbc_128_encrypt( key,  cjson.encode(ens))

ngx.say( res )
local m = {
	enc_type = "AES128",	
	biz_content = res,
}
local s  =  secret_tool.decrypt(m, key)
s = s or " 解密失败 "
ngx.say("::::" .. cjson.encode(m))

local dec = aes.aes_cbc_128_decrypt(key, res )

ngx.say(dec)


local res = aes.aes_cbc_256_encrypt( key, cjson.encode(ens) )

ngx.say( res )

local m = {
	enc_type = "AES256",	
	biz_content = res,
	am = "密码",
}
local s  =  secret_tool.decrypt(m, key)
s = s or " 解密失败 "
ngx.say("::::" .. cjson.encode(m ))


local dec = aes.aes_cbc_256_decrypt(key, res )

ngx.say(dec)
