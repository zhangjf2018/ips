local resty_sha256 = require("resty.sha256")
local iconv = require("iconv")
local strs = require('resty.string')

function gbk_to_u8( s )
	return iconv.new( "utf-8", "gbk" ):iconv(s)
end

function u8_to_gbk( s )
	return iconv.new( "gbk", "utf-8" ):iconv(s)
end

--local s = "sfsdf=1236%EW世纪东方款12312313开发上点击121京东方时间及AKJKFS"
--s = "01234567890123456789012345678901"

--s= "appid=wxd930ea5d5a258f4f&body=test&device_info=1000&mch_id=10000100&nonce_str=ibuaiVcKdpRxkhJA&key=192006250b4c09247ec02edce69f6a2d"
s = "appid=wxd930ea5d5a258f4f&body=test&device_info=1000&mch_id=10000100&nonce_str=ibuaiVcKdpRxkhJA&key=192006250b4c09247ec02edce69f6a2d=*时代峰峻……&1232"
local shap = resty_sha256:new()
shap:update( s )
local p = shap:final()
ngx.say(strs.to_hex( p  ))

