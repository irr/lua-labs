local json = require("cjson")
local pg = require("resty.postgres")

--------------------------------
-- LIBRARIES
--------------------------------

function exit_now(status, msg)
    if status ~= ngx.HTTP_OK then
        ngx.status = status
    end
    if msg then
        ngx.say(json.encode(msg))
    end

    local request_time = (ngx.now() - ngx.req.start_time())
    ngx.log(ngx.INFO, "request time: " .. tostring(request_time))

    ngx.exit(ngx.HTTP_OK)
end

function exit(status, msg)
    if status then
        exit_now(status, msg)
    end
    exit_now(ngx.HTTP_OK, msg)
end

-------------
-- MAIN
-------------

ngx.header.content_type = 'application/json';

local db = pg:new()
db:set_timeout(3000)

local ok, err = db:connect({host="127.0.0.1",port=5432, database=ngx.var.db_database,
                            user=ngx.var.db_user,password=ngx.var.db_pass,compact=false})

if not ok then
    ngx.say(err)
end

local res, err = db:query("SELECT loc_id, loc_name, ST_AsGeoJSON(geog)::json as loc_json FROM locations;")
db:set_keepalive(0, 10)

local r = {}
if not err then
    for i,v in ipairs(res) do
        r[v.loc_id] = { [v.loc_name] = v.loc_json }
    end
    ngx.say(json.encode(r))
    exit()
end

ngx.say(err)
exit(ngx.HTTP_INTERNAL_SERVER_ERROR)


