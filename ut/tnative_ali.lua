
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
		
	--	out_trade_no = mid .. os.date("%Y%m%d%H%M%S"),
		out_trade_no = tools.gen_ssn(),
	--	out_trade_no = "20171101174207363956342",
		--device_info  = uid:sub(-32),
		device_info = "4998-bee8-11e7-bc06-000c29770d18",
		body         = "拉姆齐 - 购物公园店",
		total_fee    = 1,
		notify_url     = "http://127.0.0.1/callback",
		mch_create_ip  = "127.0.0.1",
		--time_start    = os.date("%Y%m%d%H%M%S"),
		--time_expire   = os.date("%Y%m%d%H%M%S", os.time() + 5 * 60),
		--attach        = "123",
	}

	return data
end


local function main()

	local data = init_data( )
	local sign_key = "8d4646eb2d7067126eb08adb0672f7bb"
	local sign = interface_sign.sign( data , sign_key )
	
	data.sign = sign

	local url = conf.HOST .. "/pay/alipay/native"
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
