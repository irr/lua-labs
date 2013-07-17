--[[
nginx -s stop; nginx -c /home/irocha/lua/openresty/ssl-xca/nginx.conf

curl -v -X POST --header 'Content-Type: application/json' http://localhost:8888/ -d@myirrlab.org.json
--]]

local json = require("cjson")

function readfile(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

function savefile(pattern, dir, domain, content)
    local f = io.open(string.format(pattern, dir, domain), 'w+')
    f:write(content)
    f:close()
end

ngx.req.read_body()

if ngx.req.get_headers().content_type:lower() ~= "application/json" then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local ok, data = pcall(json.decode, ngx.req.get_body_data())

if not ok then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local ups = string.format("%s/upstream.tpl", ngx.var.tpltd)
local servers = ''
for _, s in pairs(data.upstream) do
    servers = servers .. string.format('    server %s;\n', s)    
end
local upstream = readfile(ups):gsub('%$(%w+)', { domain = data.domain, servers = servers })

local srv = string.format("%s/server.tpl", ngx.var.tpltd)
local server = readfile(srv):gsub('%$(%w+)', { domain = data.domain, port = data.port, certdir = ngx.var.certd })

local content = upstream .. server

savefile("%s/%s.conf", ngx.var.confd, data.domain, content)
savefile("%s/%s.crt", ngx.var.certd, data.domain, data.crt)
savefile("%s/%s.pem", ngx.var.certd, data.domain, data.key)
