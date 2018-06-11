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

local micropay  = loadmod("channel.bank.ceb.mobilepayment.micropay")
local chservice = loadmod("channel.chservice")
local process   = chservice.process

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

function _M.process( args, router )
 
	local result = process( "channel.bank.ceb.mobilepayment.native", "native", args, router )
  
	return result
end

return _M