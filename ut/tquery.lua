
--[[

micropay 小额单元测试

]]--

local uuid     = require("uuid")
local cjson    = require("cjson.safe")
local tools    = loadmod("common.tools.tools")
local noncestr = tools.noncestr
local interface_sign = loadmod("common.sign.sign")
local noncestr = tools.noncestr
local commtool = loadmod("common.tools.commtool")
local conf = loadmod("ut.conf")
local pack = loadmod("common.package.pack")
local logger = loadmod("common.log.log")
log = logger.log 

local function init_data()

	local uid = uuid.new("time")
	local mid = "0100000000"

	local auth_code = "120000000000"

	local data = {
		version   = "1.0",
		sign_type = "HMAC-SHA256",
		charset   = "utf-8",
		nonce_str = noncestr(),
		mch_id    = mid,

		--out_trade_no = tools.gen_ssn(),
		out_trade_no = "20171208101537177284530",
		--out_trade_no = "20171122155710513468370",
		--device_info  = uid:sub(-32),
		--trade_no = "01000000002017120519200002",
	}

	return data
end


local function main()

	local data = init_data( )
	local sign_key = "8d4646eb2d7067126eb08adb0672f7bb"
	local sign = interface_sign.sign( data , sign_key )
	
	data.sign = sign

	local url = conf.HOST .. "/pay/trade/query"
	local body = pack.query_string( data )
log( body )
	local result = commtool.http_send(url, body)
	
	local df = cjson.decode(result)
	if df then
		if df.sign then
			local cf = interface_sign.check_sign( df, sign_key )
			if not cf then
				ngx.say("响应签名验证失败")
			end
		end
		ngx.say(result)
	else
		ngx.say("解析响应数据失败:".. tostring(result))
	end
end

main()
