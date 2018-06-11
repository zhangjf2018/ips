---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local mysql  = require("resty.mysql")
local logger = loadmod("common.log.log")
local mysql_conf = loadmod("conf.mysqlconf")
local log    = logger.log

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local TIME_OUT = 10 * 1000

function _M.new( self, db_config, timeout  )
    local db, err = mysql:new()
    if not db then
		log("failed to instantiate mysql")
        return nil , "failed to instantiate mysql"
    end
    
    TIME_OUT = timeout or TIME_OUT
    db:set_timeout( TIME_OUT ) -- 10 second
    local options = db_config or mysql_conf.options
    local ok, err, errno, sqlstate = db:connect( options )
    if not ok then
		log("connect mysql error!")
        return nil,"fail connect:"..(err or "nil")..",errno:"..(errno or "nil")..",sqlstate:"..(sqlstate or "nil")
    end
    local sql = "SET NAMES utf8"
    local res, err, errno, sqlstate = db:query( sql )

    if not res then
        return nil, "fail query:" .. (err or "nil")..", errno:"..(errno or "nil")..", sqlstate:"..(sqlstate or "nil")
    end
    return setmetatable({ db = db }, mt)
end

-- 放回连接池
function _M.close( self )

    local conn = self.db
		if not conn then
			return 1
		end
    -- with 10 seconds max idle timeout
    -- put it into the connection pool of size 100,
    local ok, err = conn:set_keepalive( 60*1000, 200 )
    if not ok then
        log( "failed to set keepalive: " .. err )
    end
end

--- 执行查询
-- @param  sql sql查询语句
-- @return res 查询结果
function _M.query( self, sql )
    
    local conn = self.db
    
    if not conn then
        return nil, "conn is nil"
    end
    
    if not sql then
        return nil, "sql str is nil"
    end

    log ( "sql : " .. sql )
    
    local res, err, errno, sqlstate = conn:query( sql )
  
    if not res then
        local errmsg = "query fail:"..(err or "nil")..", errno:"..(errno or "nil")..", sqlstate:"..(sqlstate or "nil")
        return nil, errmsg , errno
    end
    return res
end

return _M

