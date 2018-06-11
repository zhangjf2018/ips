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

local chservice = loadmod("channel.chservice")
local process   = chservice.process

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

function _M.process( args, router )
 
	local result = process( "channel.bank.ceb.mobilepayment.refundquery", "refundquery", args, router )
  
  -- 银行流水记录
  
	return result
end

return _M