local aes = require "resty.aes"
local str = require "resty.string"

--local aes_default = aes:new("0f607264fc6318a92b9e13c65db7cd3c",nil,
--aes.cipher(256,"cbc"),{iv = ngx.decode_base64("Jq5cyFTja2vfyjZoSN6muw==")})
              
local aes_default = aes:new("0f607264fc6318a92b9e13c65db7cd3c",nil,
aes.cipher(256,"cbc"),{iv = "8&@Bm*qL9#h8QbC6"})

local ens = "hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡==="

              
local encrypted = aes_default:encrypt(ens)
            
ngx.say("AES-256 ECB SHA1: ", str.to_hex(encrypted))
            
local decrypted = aes_default:decrypt(encrypted)
ngx.say(decrypted == ens)
