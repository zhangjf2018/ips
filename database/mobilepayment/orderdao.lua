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


local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local mysql   = loadmod("common.mysql.mysql")
local daotool = loadmod("database.daotool")
local daotool_gen_insert_sql = daotool.gen_insert_sql
local daotool_gen_update_sql = daotool.gen_update_sql
local get_conn = daotool.get_conn

local function create_order_table( transdate, db )
	local sql_fmt=[[
CREATE TABLE `order%s` (
	`mch_id` VARCHAR(15) NOT NULL DEFAULT '' COMMENT '商户号',
	`out_trade_no` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '商户订单号',
	`trade_no` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '平台单号',
	`device_info` VARCHAR(32) NULL DEFAULT '' COMMENT '终端号',
	`total_fee` INT(12) NOT NULL DEFAULT '0' COMMENT '订单金额，分单位',
	`refund_fee` INT(12) NULL DEFAULT '0' COMMENT '累计退款金额，分单位',
	`exmch_id` VARCHAR(15) NULL DEFAULT '' COMMENT '机构商户号',
	`channel_id` VARCHAR(15) NULL DEFAULT '' COMMENT '渠道号',
	`bank_ssn` VARCHAR(32) NULL DEFAULT '' COMMENT '渠道流水号',
	`openid` VARCHAR(128) NULL DEFAULT '' COMMENT '第三方id号',
	`time_end` VARCHAR(14) NULL DEFAULT '' COMMENT '订单支付完成时间',
	`transdate` VARCHAR(8) NULL DEFAULT '' COMMENT '交易请求日期',
	`transtime` VARCHAR(6) NULL DEFAULT '' COMMENT '交易请求时间',
	`trade_state` VARCHAR(10) NULL DEFAULT '' COMMENT '订单状态：USERPAYING用户正在付款、SUCCESS 支付成功、PAYERROR支付失败、REFUND 转入退款、NOTPAY 未支付、CLOSED 已关闭、REVOKED已撤销',
	`retcode` VARCHAR(50) NULL DEFAULT '' COMMENT '错误码',
	`is_subscribe` VARCHAR(1) NULL DEFAULT '' COMMENT '用户是否关注子公众账号，Y-关注，N-未关注',
	`trade_type` VARCHAR(16) NULL DEFAULT '' COMMENT '支付类型',
	`attach` VARCHAR(128) NULL DEFAULT '' COMMENT '附加信息',
	`body` VARCHAR(128) NULL DEFAULT '' COMMENT '商品描述',
	`sign_type` VARCHAR(20) NULL DEFAULT '' COMMENT '签名类型',
	`acc_type` VARCHAR(20) NULL DEFAULT '' COMMENT '付款账户类型',
	`notify_url` VARCHAR(256) NULL DEFAULT '' COMMENT '订单后台通知地址',
	UNIQUE INDEX `out_trade_no_mid` (`out_trade_no`, `mch_id`),
	INDEX `trade_no_mch_id` (`trade_no`, `mch_id`)
)
COMMENT='订单表'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]
	local sql = string.format(sql_fmt, transdate )
	db:query(sql)
end

--- 插入数据
-- @param cols 带插入数据库表table类型数据
-- @param transdate 交易日期，表名用到
-- @param _db 数据库连接
-- @return 0 插入成功， 1 数据已存在， 2 数据库操作异常
function _M.insert(cols, transdate )
	
	local tablename = "order"..transdate
	local sql = daotool_gen_insert_sql( tablename, cols )
	
	local db = get_conn( )
	if not db then
		return 2
	end
	local rs, err_, errno  = db:query( sql )
	
	if not rs and errno == 1146 then   -- 表不存在
		log(tostring(err_) .. ":"..tostring(errno))
		create_order_table( transdate, db )
		rs, err_, errno = db:query(sql)    -- 再做一次
	end
	
	if not rs then
		if errno == 1062 then
			--throw(errinfo.DUPLICATE_OUT_TRADE_NO)
			return 1
		end

		log(tostring(err_) .. ":"..tostring(errno))
		return 2
	end
	
	if rs then
		db:close() -- 正常则保存连接
	end
	
	if rs.affected_rows == nil or rs.affected_rows ~= 1 then
		return 2
	end
	return 0
end

function _M.query_order_by( mch_id, out_trade_no, ot_date )
	local order_info
	local sql_fmt = "select total_fee, device_info, body, trade_state, trade_no, out_trade_no, attach from order%s where mch_id='%s' and out_trade_no='%s' limit 1 "
	local sql = string.format( sql_fmt, ot_date, mch_id, out_trade_no )
	local db = get_conn( )
	if not db then
		return order_info, 2
	end
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end

	if not rs then
		log(tostring(err_) .. ":"..tostring(errno))
		return order_info, 2
	end
	order_info = rs[1]
	if not order_info then
		return order_info, 1
	end
	
	return order_info, 0
end

function _M.query_order_detail_by_trade_no( mch_id, trade_no, ot_date )
	local order_info
	local sql_fmt = [[
	select mch_id, total_fee, device_info, body, trade_state, out_trade_no,
	attach, time_end, trade_no, trade_type, is_subscribe, openid, transdate,
	refund_fee from order%s where mch_id='%s' and trade_no='%s' limit 1 
	]]
	local sql = string.format( sql_fmt, ot_date, mch_id, trade_no )
	local db = get_conn( )
	if not db then
		return order_info, 2
	end
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end

	if not rs then
		log(tostring(err_) .. ":"..tostring(errno))
		return order_info, 2
	end

	order_info = rs[1]
	if not order_info then
		return order_info, 1
	end
	
	return order_info, 0
end

function _M.query_order_detail_by_out_trade_no( mch_id, out_trade_no, ot_date )
	local order_info
	local sql_fmt = [[
	select mch_id, total_fee, device_info, body, trade_state, out_trade_no,
	attach, time_end, trade_no, trade_type, is_subscribe, openid, transdate,
	refund_fee from order%s where mch_id='%s' and out_trade_no='%s' limit 1 
	]]
	local sql = string.format( sql_fmt, ot_date, mch_id, out_trade_no )
	local db = get_conn( )
	if not db then
		return order_info, 2
	end
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end

	if not rs then
		log(tostring(err_) .. ":"..tostring(errno))
		return order_info, 2
	end

	order_info = rs[1]
	if not order_info then
		return order_info, 1
	end
	
	return order_info, 0
end

function _M.query_order_by_trade_no_channel_id_exmch_id( trade_no, channel_id, exmch_id, transdate )
	local order_info
	local sql_fmt = [[
	select mch_id, total_fee, device_info, body, trade_state, out_trade_no,
	attach, time_end, trade_no, trade_type, is_subscribe, openid, transdate,
	refund_fee, notify_url from order%s where trade_no='%s' and channel_id='%s' and exmch_id='%s' limit 1 
	]]
	local sql = string.format( sql_fmt, transdate, trade_no, channel_id, exmch_id )
	local db = get_conn( )
	if not db then
		return order_info, 2
	end
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end

	if not rs then
		log(tostring(err_) .. ":"..tostring(errno))
		return order_info, 2
	end

	order_info = rs[1]
	if not order_info then
		return order_info, 1
	end
	
	return order_info, 0
end

function _M.update_order_by( mch_id, out_trade_no, total_fee, transdate, upcols )
	
	local tablename = "order"..transdate
	local condition = {
		mch_id       = mch_id,
		out_trade_no = out_trade_no,
		total_fee    = total_fee,	
	}
	
	local sql = daotool_gen_update_sql( tablename, condition, upcols )
	local db = get_conn( )
	if not db then
		return 2
	end
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end
	if not rs then
		log(tostring(err_) .. ":"..tostring(errno))
		return 2
	end

	if rs.affected_rows == nil or rs.affected_rows ~= 1 then
		return 1
	end

	return 0
end

function _M.update_order_by_con( transdate, condition, upcols )
	
	local tablename = "order"..transdate
	local sql = daotool_gen_update_sql( tablename, condition, upcols )
	local db = get_conn( )
	if not db then
		return 2
	end
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end
	if not rs then
		log(tostring(err_) .. ":"..tostring(errno))
		return 2
	end

	if rs.affected_rows == nil or rs.affected_rows ~= 1 then
		return 1
	end

	return 0
end


return _M

