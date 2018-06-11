---------------------------------- 
-- @author  zhangjifeng
-- @time    2015-12-13 16:33:00
-- @version 1.0.0
-- @email   414512194@qq.com
---------------------------------- 

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

-- default mysql db config
_M.options = {
    host = "127.0.0.1",
    port = "6379",
}


return _M
