local resty_sha256 = require "resty.sha256"
            local str = require "resty.string"
            local sha256 = resty_sha256:new()


local s = "appid=wxd930ea5d5a258f4f&body=test&device_info=1000&mch_id=10000100&nonce_str=ibuaiVcKdpRxkhJA&key=192006250b4c09247ec02edce69f6a2d"

            ngx.say(sha256:update(s))
            local digest = sha256:final()
            ngx.say("sha256: ", str.to_hex(digest))
