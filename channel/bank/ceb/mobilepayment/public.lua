-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-17 19:31
-- Last modified: 2016-09-27 22:18
-- description:   
-------------------------------------------------

--bugfix: 

--[[

--]]

local tools = loadmod("common.tools.tools")
local load_lua = tools.load_lua
local noncestr = tools.noncestr
local cebtool  = loadmod("channel.bank.ceb.mobilepayment.cebtool")
local cebsign  = cebtool.sign
local cebcheck_sign = cebtool.checksign
local xmltool  =  loadmod("common.tools.xmltool")
local xmlpack  = xmltool.pack
local commtool =  loadmod("common.tools.commtool")
local xmlparse = xmltool.parse
local http_send_no_exception = commtool.http_send_no_exception
local iniparser = loadmod("common.parser.iniparser")

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- 光大统一通讯函数 含自动签名及验签
--  status=0时,必须验签
-- @param data 待组包数据
-- @return 通讯结果
local ini  = iniparser.get("../ips/conf/mobileceb.ini")
function _M.comm( data, router )

	local conf = ini.mobilepayment

	local APIKEY = router.api_key
	local URL    = conf.url

	-- 签名
	local sign = cebsign( data, APIKEY )
	data.sign = sign
	
	local packxml = xmlpack( data )

	-- 发送数据包
	local body, _err = http_send_no_exception( URL, packxml )
--body='<xml><appid><![CDATA[wx1f87d44db95cba7a]]></appid><charset><![CDATA[UTF-8]]></charset><code_img_url><![CDATA[https://pay.swiftpass.cn/pay/qrcode?uuid=weixin%3A%2F%2Fwxpay%2Fbizpayurl%3Fpr%3D5st9Ybm]]></code_img_url><code_url><![CDATA[weixin://wxpay/bizpayurl?pr=5st9Ybm]]></code_url><device_info><![CDATA[10000008]]></device_info><mch_id><![CDATA[100570000241]]></mch_id><nonce_str><![CDATA[51a552a9983267a4]]></nonce_str><result_code><![CDATA[0]]></result_code><sign><![CDATA[426B5D09AC388B6B5D714D76CA1BE475]]></sign><sign_agentno><![CDATA[075020000001]]></sign_agentno><sign_type><![CDATA[MD5]]></sign_type><status><![CDATA[0]]></status><uuid><![CDATA[133d7b8c32fa658441f2a869a50547cea]]></uuid><version><![CDATA[2.0]]></version></xml>'

-- wx 成功报文
--body='<xml><appid><![CDATA[wx1f87d44db95cba7a]]></appid><attach><![CDATA[att]]></attach><bank_type><![CDATA[CFT]]></bank_type><cash_fee><![CDATA[1]]></cash_fee><cash_fee_type><![CDATA[CNY]]></cash_fee_type><charset><![CDATA[UTF-8]]></charset><device_info><![CDATA[10000008]]></device_info><fee_type><![CDATA[CNY]]></fee_type><is_subscribe><![CDATA[N]]></is_subscribe><mch_id><![CDATA[100570000241]]></mch_id><nonce_str><![CDATA[2cb724e274d6156c]]></nonce_str><openid><![CDATA[oywgtuLERnkH31SPGKq2UKvJGNIk]]></openid><out_trade_no><![CDATA[44030110000110000008506324530]]></out_trade_no><out_transaction_id><![CDATA[4200000022201709254168000479]]></out_transaction_id><pay_result><![CDATA[0]]></pay_result><promotion_detail><![CDATA[{}]]></promotion_detail><result_code><![CDATA[0]]></result_code><sign><![CDATA[0E9982E6A906D74CF9BAC7D824668E85]]></sign><sign_agentno><![CDATA[075020000001]]></sign_agentno><sign_type><![CDATA[MD5]]></sign_type><status><![CDATA[0]]></status><sub_appid><![CDATA[wxce38685bc050ef82]]></sub_appid><sub_is_subscribe><![CDATA[N]]></sub_is_subscribe><sub_openid><![CDATA[oHmbkt4WES82fyOS-lGt5aT6jECk]]></sub_openid><time_end><![CDATA[20170925152851]]></time_end><total_fee><![CDATA[1]]></total_fee><trade_type><![CDATA[pay.weixin.micropay]]></trade_type><transaction_id><![CDATA[100570000241201709252118643941]]></transaction_id><uuid><![CDATA[1715c05273aac03e1ffb08dca0831fa40]]></uuid><version><![CDATA[2.0]]></version></xml>'

--body = '<xml><charset><![CDATA[UTF-8]]></charset><err_code><![CDATA[INVALID_REQUEST]]></err_code><err_msg><![CDATA[201 商户订单号重复]]></err_msg><mch_id><![CDATA[199500046436]]></mch_id><need_query><![CDATA[Y]]></need_query><nonce_str><![CDATA[06fdb10ba89f8f62]]></nonce_str><result_code><![CDATA[1]]></result_code><sign><![CDATA[E0B307CAF153D50437D16C762CA4AE01]]></sign><sign_agentno><![CDATA[105580000119]]></sign_agentno><sign_type><![CDATA[MD5]]></sign_type><status><![CDATA[0]]></status><version><![CDATA[2.0]]></version></xml>'
-- zfb 成功报文
--body = '<xml><appid><![CDATA[2016072501663823]]></appid><attach><![CDATA[att]]></attach><bank_type><![CDATA[ALIPAYACCOUNT]]></bank_type><buyer_logon_id><![CDATA[181****3760]]></buyer_logon_id><buyer_pay_amount><![CDATA[40.90]]></buyer_pay_amount><buyer_user_id><![CDATA[2088312680058753]]></buyer_user_id><charset><![CDATA[UTF-8]]></charset><device_info><![CDATA[22400001]]></device_info><fee_type><![CDATA[CNY]]></fee_type><fund_bill_list><![CDATA[[{"amount":"40.90","fundChannel":"ALIPAYACCOUNT"}]]]></fund_bill_list><invoice_amount><![CDATA[40.90]]></invoice_amount><mch_id><![CDATA[100560024114]]></mch_id><nonce_str><![CDATA[7a97c17ff4b44c6c]]></nonce_str><openid><![CDATA[2088312680058753]]></openid><out_trade_no><![CDATA[20171009102106C17817044109100027]]></out_trade_no><out_transaction_id><![CDATA[2017100921001004750257006853]]></out_transaction_id><pay_result><![CDATA[0]]></pay_result><point_amount><![CDATA[0.00]]></point_amount><receipt_amount><![CDATA[40.90]]></receipt_amount><result_code><![CDATA[0]]></result_code><sign><![CDATA[87BCF4D407388C1AA0E6C44E47A69514]]></sign><sign_agentno><![CDATA[105580000119]]></sign_agentno><sign_type><![CDATA[MD5]]></sign_type><status><![CDATA[0]]></status><time_end><![CDATA[20171009102109]]></time_end><total_fee><![CDATA[4090]]></total_fee><trade_type><![CDATA[pay.alipay.micropay]]></trade_type><transaction_id><![CDATA[100560024114201710098200483696]]></transaction_id><uuid><![CDATA[2e6de54f7d2c78154998236e5ad56c877]]></uuid><version><![CDATA[2.0]]></version></xml>'

--body = '<xml><appid><![CDATA[wx1f87d44db95cba7a]]></appid><attach><![CDATA[att]]></attach><bank_type><![CDATA[CFT]]></bank_type><charset><![CDATA[UTF-8]]></charset><device_info><![CDATA[10000008]]></device_info><fee_type><![CDATA[CNY]]></fee_type><is_subscribe><![CDATA[N]]></is_subscribe><mch_id><![CDATA[100570000241]]></mch_id><nonce_str><![CDATA[e2446367232d7a9e]]></nonce_str><openid><![CDATA[oywgtuOa-bu0a1Nf9lJjdLcESg7E]]></openid><out_trade_no><![CDATA[44030110000110000008510206954]]></out_trade_no><out_transaction_id><![CDATA[4200000013201711093457046930]]></out_transaction_id><result_code><![CDATA[0]]></result_code><sign><![CDATA[90679A120CFFC26C845259007B17D682]]></sign><sign_agentno><![CDATA[075020000001]]></sign_agentno><sign_type><![CDATA[MD5]]></sign_type><status><![CDATA[0]]></status><sub_appid><![CDATA[wxce38685bc050ef82]]></sub_appid><sub_is_subscribe><![CDATA[N]]></sub_is_subscribe><sub_openid><![CDATA[oHmbkt4E5e92unwxbM600Ady1oLY]]></sub_openid><time_end><![CDATA[20171109135658]]></time_end><total_fee><![CDATA[1]]></total_fee><trade_state><![CDATA[SUCCESS]]></trade_state><trade_type><![CDATA[pay.weixin.native]]></trade_type><transaction_id><![CDATA[100570000241201711092180297907]]></transaction_id><version><![CDATA[2.0]]></version></xml>'
	
--refund
--body = '<xml><charset><![CDATA[UTF-8]]></charset><mch_id><![CDATA[101520000465]]></mch_id><nonce_str><![CDATA[6184bb0bbb51208f]]></nonce_str><out_refund_no><![CDATA[44030110000110000008510216140]]></out_refund_no><out_trade_no><![CDATA[44030110000110000008510216052]]></out_trade_no><out_transaction_id><![CDATA[2017110921001004905393714406]]></out_transaction_id><refund_channel><![CDATA[ORIGINAL]]></refund_channel><refund_fee><![CDATA[1]]></refund_fee><refund_id><![CDATA[101520000465201711096280433281]]></refund_id><result_code><![CDATA[0]]></result_code><sign><![CDATA[F3681D3B0DBC0D33F417109C1017A6E6]]></sign><sign_type><![CDATA[MD5]]></sign_type><status><![CDATA[0]]></status><trade_type><![CDATA[pay.alipay.micropay]]></trade_type><transaction_id><![CDATA[101520000465201711095126804067]]></transaction_id><version><![CDATA[2.0]]></version></xml>'

-- refundquery
--body = '<xml><appid><![CDATA[2016081701760348]]></appid><charset><![CDATA[UTF-8]]></charset><mch_id><![CDATA[101520000465]]></mch_id><nonce_str><![CDATA[3edd9d21b034c689]]></nonce_str><out_refund_no_0><![CDATA[44030110000110000008510216140]]></out_refund_no_0><out_trade_no><![CDATA[44030110000110000008510216052]]></out_trade_no><out_transaction_id><![CDATA[2017110921001004905393714406]]></out_transaction_id><refund_channel_0><![CDATA[ORIGINAL]]></refund_channel_0><refund_count><![CDATA[1]]></refund_count><refund_fee_0><![CDATA[1]]></refund_fee_0><refund_id_0><![CDATA[101520000465201711096280433281]]></refund_id_0><refund_status_0><![CDATA[SUCCESS]]></refund_status_0><refund_time_0><![CDATA[20171109162903]]></refund_time_0><result_code><![CDATA[0]]></result_code><sign><![CDATA[CBDD55E17470C1527D70049AF8055232]]></sign><sign_type><![CDATA[MD5]]></sign_type><status><![CDATA[0]]></status><total_fee><![CDATA[1]]></total_fee><trade_type><![CDATA[pay.alipay.micropay]]></trade_type><transaction_id><![CDATA[101520000465201711095126804067]]></transaction_id><version><![CDATA[2.0]]></version></xml>'
	-- 解析数据
	local pxml = {}

	if #body == 0 then
		log("ceb 通讯超时")
		return nil
	else
		pxml = xmlparse( body )
		if not pxml then
			log("ceb xml 响应报文解析失败")
			return nil
		end

		-- 通讯status = 0 必须验证签名,保证业务系统安全性
		if pxml.status == "0" then
			local is_ok = cebcheck_sign( pxml, APIKEY )
			if not is_ok then
				return nil
			end
		end
	end
	return pxml
end

return _M
