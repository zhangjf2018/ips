-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-19 23:24
-- Last modified: 2016-09-20 02:10
-- description:   
-------------------------------------------------

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }


_M.define = {
	[1]   = {name="uri",          maxlen=30},
	[2]   = {name="mch_id",       maxlen=15},
	[3]   = {name="out_trade_no", maxlen=32},
	[4]   = {name="trade_no",     maxlen=32},
	[5]   = {name="total_fee",    maxlen=12},
	[6]   = {name="trade_type",   maxlen=10},
	[7]   = {name="exmch_id",     maxlen=19},
	[8]   = {name="channel_id",   maxlen=10},
	[9]   = {name="retcode",      maxlen=20},
	[10]  = {name="retmsg",       maxlen=200},

}

return _M
