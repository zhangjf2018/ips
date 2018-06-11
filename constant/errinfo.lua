---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 
--bugfix: 

--[[

--]]

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }



----------------------------------------------------------------------
--错误码定义
--系统错误码定义
_M.UNKNOWN_ERROR         = { retcode = "8999", retmsg = "通讯错误或超时" }
_M.ARGUMENT_ERROR        = { retcode = "8740", retmsg = "报文格式错，域值非法" }
_M.ARGUMENT_DUPLICATE    = { retcode = "8740", retmsg = "报文格式错，域值非法" }

_M.DB_ERROR              = { retcode = "3163", retmsg = "链接数据库出错" }


--交易错误码定义
_M.AUTH_CODE_INVALID     = { retcode = "1225", retmsg = "支付授权码错误" }
_M.OUT_TRADE_NO_USED     = { retcode = "3162", retmsg = "订单号重复" }
_M.SYSTEM_ERROR          = { retcode = "3162", retmsg = "系统错误" }
_M.PAYMENT_FAIL          = { retcode = "3162", retmsg = "支付失败" } -- 确认失败
_M.ORDER_PAID             = { retcode = "3162", retmsg = "订单已支付" }
_M.ORDER_CLOSED           = { retcode = "3162", retmsg = "订单已关闭" }
_M.ORDER_REVERSED         = { retcode = "3162", retmsg = "订单已撤销" }
_M.ORDER_NOT_EXIST       = { retcode = "3162", retmsg = "此交易订单号不存在" }
_M.QUERY_PARAM_ERROR     = { retcode = "3162", retmsg = "out_trade_no, trade_no 至少存在一个" }
_M.QUERY_MATCH_ERROR     = { retcode = "3162", retmsg = "out_trade_no, trade_no 不匹配，请核实" }

_M.REFUND_FEE_ERROR      = { retcode = "3162", retmsg = "退款金额不能为0" }
_M.REFUND_PARAM_ERROR    = { retcode = "3162", retmsg = "out_trade_no, trade_no 至少存在一个" }

_M.REFUND_TOTAL_FEE_ERROR    = { retcode = "3162", retmsg = "原交易total_fee无效" }
_M.REFUND_FEE_NOT_ENOUGH     = { retcode = "3162", retmsg = "原交易可退款金额不足本次退款金额" }
_M.REFUND_INPROCESS          = { retcode = "3162", retmsg = "该退款单号已受理，请勿重复发起" }
_M.OUT_REFUND_NO_USED        = { retcode = "3162", retmsg = "退款单号重复" }


_M.REFUNDQUERY_PARAM_ERROR   = { retcode = "3162", retmsg = "refund_id, out_refund_no 至少存在一个" }
_M.REFUND_NOT_EXIST          = { retcode = "3162", retmsg = "查询退款的交易不存在" }
_M.REFUND_MATCH_ERROR        = { retcode = "3162", retmsg = "退款查询信息不匹配，请核实" }

_M.HTTP_ERROR          = { retcode = "8999", retmsg = "通讯错误或超时" }
_M.CHECKSIGN_ERROR     = { retcode = "1225", retmsg = "签名校验失败" }
_M.SIGN_ERROR          = { retcode = "1225", retmsg = "签名失败" }
_M.MISS_SERVICE_URI    = { retcode = "1225", retmsg = "接口地址不存在" }
_M.LOAD_SERVICE_ERROR  = { retcode = "1225", retmsg = "业务加载失败" }
_M.URI_FORMAT_ERROR    = { retcode = "9999", retmsg = "接口地址格式错误" }
_M.GET_ARGUMENT_ERROR  = { retcode = "9999", retmsg = "参数为空，获取失败" }
_M.HTTP_METHOD_ERROR   = { retcode = "1002", retmsg = "HTTP Method 为POST或GET" }

_M.SYSTEM_UPDATE       = { retcode = "1225", retmsg = "系统升级" }
_M.INTERFACE_DISABLE   = { retcode = "1225", retmsg = "接口停用" }

_M.DECRYPT_ERROR       = { retcode = "1225", retmsg = "解密失败" }
_M.ENCRYPT_ERROR       = { retcode = "1225", retmsg = "加密失败" }
_M.MISS_PARAM_BIZ_CONTENT = { retcode = "1225", retmsg = "解密失败,参数biz_content不存在" }

----------------------------------------------------------------------
local iniparser = loadmod("common.parser.iniparser")
local ini = iniparser.get("../ips/conf/errmsg.ini")
local errmap = ini.errmap

function _M.get_retmsg( retcode )
	
	if retcode == "0000" then
		-- 0000 不做retmsg 设置
		return nil
	end
	
	local retmsg = errmap[ retcode ] or "其他错误"
	return retmsg 
end

return _M