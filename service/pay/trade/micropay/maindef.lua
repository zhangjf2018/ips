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
device_info   = { fmt = "^.{1,32}$",             mandatory = false  },
body          = { fmt = "^.{1,128}$",            mandatory = true   },
attach        = { fmt = "^.{1,128}$",            mandatory = false  },
total_fee     = { fmt = "^\\d{1,12}$",           mandatory = true   },
auth_code     = { fmt = "^\\d{10,32}$",          mandatory = true   },
--notify_url    = { fmt = "^.{1,255}$",            mandatory = true  },
--time_start    = { fmt = "^.{1,14}$",             mandatory = false  },
--time_expire   = { fmt = "^.{1,14}$",             mandatory = false  },
goods_tag     = { fmt = "^.{1,32}$",             mandatory = false  },

}



return _M

