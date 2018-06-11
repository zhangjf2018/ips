
local crypto = require("crypto")
local evp = crypto.evp
local hmac = crypto.hmac
local encrypt = crypto.encrypt
local decrypt = crypto.decrypt
local str = require("resty.string")

ngx.say("LuaCrypto version: " .. crypto._VERSION)

local s = "mch_id=100570000241&nonce_str=a92d8bf5ffe4a48c&op_user_id=100570000241&out_refund_no=20171010145258&out_trade_no=130986450120171010145016&refund_fee=1&service=unified.trade.refund&sign_agentno=075020000001&total_fee=1&transaction_id=100570000241201710103255943626"

local ret = hmac.digest("sha256", s , "b165cc9b1c287096d86c42fc")

ngx.say(ret)

local key = ngx.decode_base64("Xr4ilOzQ4PCOq3aQ0qbuaQ==")
local iv = ngx.decode_base64("Jq5cyFTja2vfyjZoSN6muw==")
ngx.say(#key)
ngx.say(#iv)

local ens = "hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡===hello{接口上的飞机款：@！000#￥%sdkfkl}=-123skdjf接口上京东方卡积分开31231231卡数据咖啡==="

local encstr = encrypt("aes-128-cbc",ens, key, iv)
ngx.say(str.to_hex(encstr))
ngx.say(ngx.encode_base64(encstr))
ngx.say(decrypt("aes-128-cbc", encstr, key, iv))

ens = "123123"
key = "0000000000000000000000"
local encstr = encrypt("des",ens, key)
ngx.say(str.to_hex(encstr))

local encstr = decrypt("des",encstr, key)
ngx.say( encstr )

ens = "123123你LM"
key = "0000000000000000000000"
local encstr = encrypt("des-ede3",ens, key)
ngx.say(str.to_hex(encstr))

local s = "appid=wxd930ea5d5a258f4f&body=test&device_info=1000&mch_id=10000100&nonce_str=ibuaiVcKdpRxkhJA&key=192006250b4c09247ec02edce69f6a2d"
local ret = hmac.digest("sha256", s , "192006250b4c09247ec02edce69f6a2d")

ngx.say(ret)