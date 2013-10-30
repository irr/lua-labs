--------------------------------
-- LIBRARIES
--------------------------------

local _ = require("underscore")

local crypt = require("crypto")
local json = require("cjson")
local mysql = require("resty.mysql")

--------------------------------
-- CONSTs
--------------------------------

local key = "c6bef73b51e2f696"
local iv  = "aa90025f918a9696"

--------------------------------
-- SQLs
--------------------------------
-- mysql -u root -p < db/db.sql

local INSERT = [[
START TRANSACTION;
SELECT @I:=users.id, @N:=users.name FROM users ORDER BY users.id DESC LIMIT 1;
INSERT INTO users VALUES (@I + 1, %s);
SELECT * FROM users WHERE users.id = @I + 1;
COMMIT;
]]

local SELECT = [[
SELECT users.id FROM users WHERE users.id = %s;
]]

local DELETE = [[
START TRANSACTION;
DELETE FROM users WHERE users.id = %s;
COMMIT;
]]

--------------------------------
-- FUNCTIONS
--------------------------------

function exit_now(status, msg)
    ngx.status = status
    if msg then
        ngx.say(json.encode(msg))
    end
    ngx.exit(ngx.HTTP_OK)
end

function exit(db, status, msg)
    if db then
        db:set_keepalive(tonumber(ngx.var.db_max_idle_timeout), 
                         tonumber(ngx.var.db_pool_size))
    end
    if status then
        exit_now(status, msg)
    end
    exit_now(ngx.HTTP_OK, msg)
end

function split(str, sep)
    local s = str..sep
    return s:match((s:gsub('[^'..sep..']*'..sep, '([^'..sep..']*)'..sep)))
end

function results(db, sql)
    local bytes, err = db:send_query(sql)
    if not err then
        local body, res, err, errno, sqlstate = {}
        repeat
            res, err, errno, sqlstate = db:read_result()
            
            if errno then
                if errno == 1048 then
                    exit(db, ngx.HTTP_NOT_FOUND)
                else
                    exit(db, ngx.HTTP_INTERNAL_SERVER_ERROR, 
                            string.format("results error: %s: %s %s", 
                                tostring(err), tostring(errno), tostring(sqlstate)))
                end
            else
                if type(res) == "table" then
                    if type(res[1]) == "table" then
                        body = res[1]
                    end
                end
            end

        until err ~= "again"

        return json.encode(body)
    else
        exit(db, ngx.HTTP_INTERNAL_SERVER_ERROR, 
             string.format("results error: " .. tostring(err)))
    end    
end

function check(db, id)
    local res, err, errno, sqlstate = db:query(string.format(SELECT, id))
    if errno then
         exit(db, ngx.HTTP_INTERNAL_SERVER_ERROR, 
                string.format("check error: %s: %s %s", 
                    tostring(err), tostring(errno), tostring(sqlstate)))
    elseif not res or #res == 0 then
        exit(db, ngx.HTTP_NOT_FOUND)
    else
        return res
    end
end

-------------
-- MAIN
-------------

ngx.header.content_type = 'application/json';

local db, err = mysql:new()

if not db then
    exit(db, ngx.HTTP_INTERNAL_SERVER_ERROR, 
         "failed to instantiate mysql: " .. tostring(err))
end

db:set_timeout(ngx.var.db_timeout) 

local ok, err, errno, sqlstate = db:connect{
    host = ngx.var.db_host,
    port = ngx.var.db_port,
    database = ngx.var.db_database,
    user = ngx.var.db_user,
    password = ngx.var.db_pass or crypt.decrypt(key, iv, ngx.var.db_crypt),
    max_packet_size = tonumber(ngx.var.db_max_packet_size) }

if not ok then
    exit(db, ngx.HTTP_INTERNAL_SERVER_ERROR, 
         string.format("failed to connect: %s: %s %s", 
                       tostring(err), tostring(errno), tostring(sqlstate)))
end

--[[
curl -v -X POST --header 'Content-Type: application/json' http://localhost:8000/ -d "{\"encrypt\":\"mysql\"}"
curl -v -X POST --header 'Content-Type: application/json' http://localhost:8000/ -d "{\"decrypt\":\"b2662427f814cacb39db1b4412efd685\"}"
curl -v -X POST --header 'Content-Type: application/json' http://localhost:8000/ -d "{\"method\":\"insert\", \"name\":\"irr\"}"
curl -v -X DELETE http://localhost:8000/?id=2
curl -v http://localhost:8000/?id=1
--]]

if ngx.req.get_method() == "POST" then

    ngx.req.read_body()

    if ngx.req.get_headers().content_type:lower() ~= "application/json" then
        exit(db, ngx.HTTP_BAD_REQUEST)
    end

    local ok, data = pcall(json.decode, ngx.req.get_body_data())

    if not ok then
        exit(db, ngx.HTTP_BAD_REQUEST)
    end

    local fn = (data["encrypt"] and {"encrypt", ngx.unescape_uri(data["encrypt"])}) or 
               (data["decrypt"] and {"decrypt", ngx.unescape_uri(data["decrypt"])})

    if fn then
        local ok, cr = pcall(crypt[fn[1]], key, iv, fn[2])
        if ok then
            ngx.say("\""..cr.."\"")
            exit()
        else
            exit(db, ngx.HTTP_BAD_REQUEST)   
        end
    end

    local method = ngx.var['arg_method'] or data["method"]

    if method == "insert" then

        local n = ngx.quote_sql_str(data["name"])
        ngx.say(results(db, string.format(INSERT, n)))
        
        exit()
    end

    exit(db, ngx.HTTP_METHOD_NOT_IMPLEMENTED)

elseif ngx.req.get_method() == "DELETE" then

    if not ngx.var['arg_id'] then
        exit(db, ngx.HTTP_BAD_REQUEST)
    end

    local id = ngx.unescape_uri(ngx.var['arg_id'])

    if tonumber(id) <= 1 then
        exit(db, ngx.HTTP_FORBIDDEN)
    end

    check(db, ngx.quote_sql_str(id))

    ngx.say(results(db, string.format(DELETE, id)))
    exit()

elseif ngx.req.get_method() == "GET" then

    local id = ngx.unescape_uri(ngx.var['arg_id'])
    local res = check(db, ngx.quote_sql_str(id))
    ngx.say(json.encode(res[1]))
    exit()

else
    exit(db, ngx.HTTP_BAD_REQUEST)
end