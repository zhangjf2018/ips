---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local redis  = require("resty.redis")
local logger = loadmod("common.log.log")
local redis_conf = loadmod("conf.redisconf")
local log    = logger.log

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local TIME_OUT = 10 * 1000

function _M.get_conn(config, timeout  )
    local red, err = redis:new()
    if not red then
		log("new redis:"..err)
        return nil , "failed to instantiate redis"
    end
    
    TIME_OUT = timeout or TIME_OUT
    red:set_timeout( TIME_OUT ) -- 10 second
    local options = config or redis_conf.options
    local ok, err = red:connect( options.host, options.port )
    if not ok then
		log("connect redis error!")
        return nil,"fail connect:"..(err or "nil")
    end
    return red
end

-- 放回连接池
function _M.close( conn )

    -- with 10 seconds max idle timeout
    -- put it into the connection pool of size 100,
    local ok, err = conn:set_keepalive( 10000, 200 )
    if not ok then
        log( "failed to set keepalive: " .. err )
    end
end

return _M

