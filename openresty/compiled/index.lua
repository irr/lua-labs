-- ngs; luajit -b index.lua index.luac && ngr nginx.conf
-- curl -v -d "name=ivan" localhost:3000/

--------------------------------
-- TEST
--------------------------------
--[=[
curl -v --data "name=ivan" "http://localhost:3000/test"
curl -v "http://localhost:3000/test?name=alessandra"
lua get.lua
lua post.lua
--]=]

--------------------------------
-- LIBRARIES
--------------------------------

local json = require "cjson" 

--------------------------------
-- FUNCTIONS
--------------------------------

function exit_now(status, msg)
    if status ~= ngx.HTTP_OK then
        ngx.status = status
    end

    if msg then
        ngx.say(msg)
    end

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

local keys = {}

if ngx.req.get_method() == "POST" then
    ngx.req.read_body()
    keys["parameters"] = ngx.req.get_post_args()
elseif ngx.req.get_method() == "GET" then
    keys["parameters"] = ngx.req.get_uri_args()
end

ngx.say(json.encode(keys))
exit()
