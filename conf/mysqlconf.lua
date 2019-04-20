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
    user     = "root",
    password = "123456",
    database = "mobilepay",
    host     = "168.33.211.220",
    port     = "3306",
    max_packet_size = 1024 * 1024,
}


return _M
