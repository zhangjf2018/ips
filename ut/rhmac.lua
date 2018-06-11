
local crypto = require("crypto")
local evp = crypto.evp
local hmac = crypto.hmac
local encrypt = crypto.encrypt
local decrypt = crypto.decrypt
local str = require("resty.string")
local rhmac = require("resty.hmac")



local s = "mch_id=100570000241&nonce_str=a92d8bf5ffe4a48c&op_user_id=100570000241&out_refund_no=20171010145258&out_trade_no=130986450120171010145016&refund_fee=1&service=unified.trade.refund&sign_agentno=075020000001&total_fee=1&transaction_id=100570000241201710103255943626"



local hmac_sha1 = rhmac:new("b165cc9b1c287096d86c42fc", rhmac.ALGOS.SHA256)
    if not hmac_sha1 then
        ngx.say("failed to create the hmac_sha1 object")
        return
    end
local ok = hmac_sha1:update( s )
    if not ok then
        ngx.say("failed to add data")
        return
    end

    local mac = hmac_sha1:final()
    ngx.say("hmac_sha1: ", str.to_hex(mac))
        -- output: "hmac_sha1: aee4b890b574ea8fa4f6a66aed96c3e590e5925a"

    -- dont forget to reset after final!
    if not hmac_sha1:reset() then
        ngx.say("failed to reset hmac_sha1")
        return
    end

