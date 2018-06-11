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
local get_conn = daotool.get_conn

local function create_refund_table( transdate, db )
	local sql_fmt=[[
CREATE TABLE `refund%s` (
	`mch_id` VARCHAR(15) NOT NULL DEFAULT '' COMMENT '商户号',
	`operator_id` VARCHAR(15) NOT NULL DEFAULT '' COMMENT '操作员ID',
	`out_trade_no` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '原商户订单号',
	`out_refund_no` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '商户退款单号',
	`trade_no` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '原平台单号',
	`refund_id` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '平台退款单号',
	`device_info` VARCHAR(32) NULL DEFAULT '' COMMENT '终端号',
	`total_fee` INT(12) NOT NULL DEFAULT '0' COMMENT '订单金额，分单位',
	`refund_fee` INT(12) NULL DEFAULT '0' COMMENT '退款金额',
	`refund_success_time` VARCHAR(14) NULL DEFAULT '' COMMENT '退款完成时间',
	`refund_channel` VARCHAR(15) NULL DEFAULT '' COMMENT '退款渠道：ORIGINAL 原路退款 BALANCE 退回到余额 OTHER_BALANCE 原账户异常退到其他余额账户 OTHER_BANKCARD 原银行卡异常退到其他银行卡',
	`refund_status` VARCHAR(15) NULL DEFAULT '' COMMENT '状态：PROCESSING 退款处理中 REFUNDCLOSE 退款关闭 SUCCESS 已退款 CHANGE 退款异常 FAIL 退款失败 START 初始退款',
	`refund_reason` VARCHAR(128) NULL DEFAULT '' COMMENT '退款原因',
	`trade_type` VARCHAR(16) NULL DEFAULT '' COMMENT '交易类型',
	`txtrade_type` VARCHAR(16) NULL DEFAULT '' COMMENT '原交易类型',
	`txtransdate` VARCHAR(8) NULL DEFAULT '' COMMENT '原交易日期',
	`transdate` VARCHAR(8) NULL DEFAULT '' COMMENT '退款请求日期',
	`transtime` VARCHAR(6) NULL DEFAULT '' COMMENT '退款请求时间',
	`exmch_id` VARCHAR(15) NULL DEFAULT '' COMMENT '机构商户号',
	`channel_id` VARCHAR(15) NULL DEFAULT '' COMMENT '渠道号',
	`bank_ssn` VARCHAR(32) NULL DEFAULT '' COMMENT '渠道流水号',
	`retcode` VARCHAR(50) NULL DEFAULT '' COMMENT '错误码',
	INDEX `refund_id_mch_id` (`refund_id`, `mch_id`),
	UNIQUE INDEX `out_refund_no_mch_id` (`out_refund_no`, `mch_id`)
)
COMMENT='退款冲正表'
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
	
	transdate = transdate:sub(1,6)
	local tablename = "refund"..transdate
	local sql = daotool.gen_insert_sql( tablename, cols )
	
	local db = get_conn( )
	if not db then
		return 2
	end
	local rs, err_, errno  = db:query( sql )
	
	if not rs and errno == 1146 then   -- 表不存在
		log(tostring(err_) .. ":"..tostring(errno))
		create_refund_table( transdate, db )
		rs, err_, errno = db:query(sql)    -- 再做一次
	end
	
	if rs then
		db:close() -- 正常则保存连接
	end
	
	if not rs then
		if errno == 1062 then
			--throw(errinfo.DUPLICATE_OUT_TRADE_NO)
			return 1
		end
		log(tostring(err_) .. ":"..tostring(errno))
		return 2
	end
	
	if rs.affected_rows == nil or rs.affected_rows ~= 1 then
		return 2
	end
	return 0
end

function _M.query_refund_by( mch_id, out_refund_no, ot_date )
	local refund_info
	local sql_fmt = "select total_fee, refund_fee, refund_status, refund_id from refund%s where mch_id='%s' and out_refund_no='%s' limit 1 "
	local sql = string.format( sql_fmt, ot_date, mch_id, out_refund_no )
	local db = get_conn( )
	if not db then
		return refund_info, 2
	end
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end

	if not rs then
		log(tostring(err_) .. ":"..tostring(errno))
		return order_info, 2
	end
	refund_info = rs[1]
	if not refund_info then
		return refund_info,1
	end
	
	return refund_info,0
end

function _M.query_refund_detail_by_refund_id( mch_id, refund_id, ot_date )
	local refund_info
	local ot_date = ot_date:sub(1,6)
	local sql_fmt = [[select mch_id, operator_id, out_trade_no, out_refund_no, trade_no, refund_id, 
	device_info, total_fee, refund_fee, refund_success_time, refund_channel, refund_status,
  refund_reason, trade_type, bank_ssn, txtrade_type  from refund%s where mch_id='%s' and refund_id='%s' limit 1 
	]]
	local sql = string.format( sql_fmt, ot_date, mch_id, refund_id )
	local db = get_conn( )
	if not db then
		return refund_info, 2
	end
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end

	if not rs then
		log(tostring(err_) .. ":"..tostring(errno))
		return order_info, 2
	end

	refund_info = rs[1]
	if not refund_info then
		return refund_info, 1
	end
	
	return refund_info, 0
end

function _M.query_refund_detail_by_out_refund_no( mch_id, out_refund_no, ot_date )
	local refund_info
	local ot_date = ot_date:sub(1,6)
	local sql_fmt = [[select mch_id, operator_id, out_trade_no, out_refund_no, trade_no, refund_id, 
	device_info, total_fee, refund_fee, refund_success_time, refund_channel, refund_status,
  refund_reason, trade_type, bank_ssn, txtrade_type  from refund%s where mch_id='%s' and out_refund_no='%s' limit 1 
	]]
	local sql = string.format( sql_fmt, ot_date, mch_id, out_refund_no )
	local db = get_conn( )
	if not db then
		return refund_info, 2
	end
	local rs, err_, errno  = db:query( sql )
	if rs then
		db:close() -- 正常则保存连接
	end

	if not rs then
		log(tostring(err_) .. ":"..tostring(errno))
		return order_info, 2
	end

	refund_info = rs[1]
	if not refund_info then
		return refund_info, 1
	end
	
	return refund_info, 0
end

function _M.update_refund_by( mch_id, out_refund_no, refund_fee, t_date, upcols )
	local transdate = t_date:sub(1,6)
	local tablename = "refund"..transdate
	local condition = {
		mch_id        = mch_id,
		out_refund_no = out_refund_no,
		refund_fee    = refund_fee,	
	}
	
	local sql = daotool.gen_update_sql( tablename, condition, upcols )
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

