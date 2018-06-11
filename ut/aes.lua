local aes = require "resty.aes"
local str = require "resty.string"
--local aes_default = aes:new(ngx.decode_base64("Xr4ilOzQ4PCOq3aQ0qbuaQ=="),nil,
--aes.cipher(128,"cbc"),
--{iv = ngx.decode_base64("Jq5cyFTja2vfyjZoSN6muw==")})
function to_bin( str )
	return ( { str:gsub( "..", function(x) return string.char( tonumber(x, 16) ) end) } )[1]
end

local aes_default = aes:new(to_bin("0f607264fc6318a92b9e13c65db7cd3c"),nil,
aes.cipher(128,"cbc"),
{iv = "8&@Bm*qL9#h8QbC6"})

--[[
local aes_default = aes:new("0000000000000000",nil,
aes.cipher(128,"cbc"),
{iv ="0000000000000000" })
]]--
local key = ngx.decode_base64("Xr4ilOzQ4PCOq3aQ0qbuaQ==")
local iv = ngx.decode_base64("Jq5cyFTja2vfyjZoSN6muw==")
ngx.say(str.to_hex(key))
ngx.say(str.to_hex(iv))
ngx.say(#key)
ngx.say(#iv)
local ens = "hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡==="
local encrypted = aes_default:encrypt( ens )
ngx.say("AES-128 CBC (custom keygen) MD5: ", str.to_hex(encrypted))
local decrypted = aes_default:decrypt(encrypted)
ngx.say(decrypted == ens)
local aes_check = aes:new("secret")
local encrypted_check = aes_check:encrypt("hello")
ngx.say(encrypted_check == encrypted)
