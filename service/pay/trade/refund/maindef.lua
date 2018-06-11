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

_M.define = {

out_trade_no  = { fmt = "^.{1,32}$",             mandatory = false  },
trade_no      = { fmt = "^.{1,32}$",             mandatory = false  },
out_refund_no = { fmt = "^.{1,32}$",             mandatory = true   },
total_fee     = { fmt = "^\\d{1,12}$",           mandatory = true   },
refund_fee    = { fmt = "^\\d{1,12}$",           mandatory = true   },
refund_reason = { fmt = "^.{1,128}$",            mandatory = false  },
operator_id   = { fmt = "^.{1,32}$",             mandatory = false  },

}



return _M

