--[[
nginx -s stop; nginx -c /home/irocha/lua/openresty/ssl-xca/nginx.conf

curl -v -1 https://myirrlab.org:8443/ --cacert certs/irrlab.crt

curl -v http://localhost:8888/
curl -v -X POST --header 'Content-Type: application/json' http://localhost:8888/ -d@myirrlab.org.json
curl -v -X DELETE http://localhost:8888/?domain=myirrlab.org
--]]

local _ = require("underscore")
local json = require("cjson")

function readfile(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

function filename(pattern, dir, domain)
    return string.format(pattern, dir, domain)
end 

function savefile(pattern, dir, domain, content)
    local f = io.open(filename(pattern, dir, domain), 'w+')
    f:write(content)
    f:close()
end

function removefile(pattern, dir, domain)
    return os.execute("rm ".. filename(pattern, dir, domain))
end

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function split(str, sep)
    local s = str..sep
    return s:match((s:gsub('[^'..sep..']*'..sep, '([^'..sep..']*)'..sep)))
end

function exit(status)
    if status then
        ngx.status = status
        ngx.say("")    
        ngx.exit(ngx.HTTP_OK)
    end
    if os.execute("nginx -s reload") == 0 then
        exit(ngx.HTTP_OK)
    end
    exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

ngx.header.content_type = 'application/json';

if ngx.req.get_method() == "POST" then

    ngx.req.read_body()

    if ngx.req.get_headers().content_type:lower() ~= "application/json" then
        exit(ngx.HTTP_BAD_REQUEST)
    end

    local ok, data = pcall(json.decode, ngx.req.get_body_data())

    if not ok then
        exit(ngx.HTTP_BAD_REQUEST)
    end

    local ups = string.format("%s/upstream.tpl", ngx.var.tpltd)
    local servers = _.reduce(data.upstream, '', function (srvs, srv) 
                return srvs .. string.format('    server %s;\n', srv)
            end)
    local upstream = readfile(ups):gsub('%$(%w+)', { domain = data.domain, servers = servers })

    local srv = string.format("%s/server.tpl", ngx.var.tpltd)
    local server = readfile(srv):gsub('%$(%w+)', { domain = data.domain, port = data.port, certdir = ngx.var.certd })

    local content = upstream .. server

    savefile("%s/%s.conf", ngx.var.confd, data.domain, content)
    savefile("%s/%s.crt", ngx.var.certd, data.domain, data.crt)
    savefile("%s/%s.pem", ngx.var.certd, data.domain, data.key)

    exit()

elseif ngx.req.get_method() == "DELETE" then

    local domain = ngx.var['arg_domain']
    if not domain then
        exit(ngx.HTTP_BAD_REQUEST)
    end
    local status = removefile("%s/%s.conf", ngx.var.confd, domain) or
                   removefile("%s/%s.crt", ngx.var.certd, domain) or
                   removefile("%s/%s.pem", ngx.var.certd, domain)
    if status == 0 then
        exit()
    else
        if status % 256 == 0 then
            exit(ngx.HTTP_NOT_FOUND) 
        end
        exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

elseif ngx.req.get_method() == "GET" then
    local confs = { split(os.capture("ls " .. ngx.var.confd .. "/"), " ") }
    local cmap = _.reduce(confs, {}, function (cm, name)
            if name == 'default.conf' then
                return cm
            end
            local content = readfile(string.format("%s/%s", ngx.var.confd, name))
            cm[name] = _.reduce(content:gmatch("server ([%w\\.:]+);"), {}, function (m, k)
                    table.insert(m, k)
                    return m
                end)
            return cm
        end)
    ngx.say(json.encode(cmap))
else
    exit(ngx.HTTP_BAD_REQUEST)
end