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

refund_id     = { fmt = "^.{1,32}$",             mandatory = false  },
out_refund_no = { fmt = "^.{1,32}$",             mandatory = false  },
trade_no      = { fmt = "^.{1,32}$",             mandatory = false  },
out_trade_no  = { fmt = "^.{1,32}$",             mandatory = false  },

}



return _M

