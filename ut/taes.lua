
local aes = loadmod("common.secret.aes")

local key = "0f607264fc6318a92b9e13c65db7cd3c"

local ens = "hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡==="
local res = aes.aes_cbc_128_encrypt( key, ens )

ngx.say( res )

local dec = aes.aes_cbc_128_decrypt(key, res )

ngx.say(dec)


local res = aes.aes_cbc_256_encrypt( key, ens )

ngx.say( res )

local dec = aes.aes_cbc_256_decrypt(key, res )

ngx.say(dec)
