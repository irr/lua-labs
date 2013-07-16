#!/usr/bin/env luajit

_ = require "underscore"

local port    = 8443
local certdir = '/home/irocha/lua/openresty/ssl-xca'
local codedir = '/home/irocha/lua/openresty/ssl-xca'

local prologue = [[
worker_processes  1;

error_log logs/error.log info;

events {
    worker_connections 1024;
}

http {

    ssl_ciphers HIGH:!kEDH:@STRENGTH;
    ssl_prefer_server_ciphers on;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_session_cache shared:SSL:10m;

]]

local finale = [[
}
]]

local upstream = [[
    upstream $domain {
$servers    }

]]

local fallback = [[
    server {
        listen $port default ssl;
        server_name _;

        ssl on;  
        ssl_certificate $certdir/multiple-domains.crt;  
        ssl_certificate_key $certdir/multiple-domains.pem;  
        
        ssl_ciphers RC4:!MD5;

        location / {
            content_by_lua_file '$codedir/ssl-router.lua';
        }
    }

]]

local server = [[
    server {
        listen $port ssl;
        server_name $domain;

        ssl on;  
        ssl_certificate $certdir/$domain.crt;
        ssl_certificate_key $certdir/$domain.pem;        

        location / {
            proxy_redirect      off;
            proxy_set_header    Host $host;
            proxy_set_header    X-Real-IP $remote_addr;
            proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header    X-Forwarded-Proto https;
            proxy_pass          http://$domain;
        }
    }

]]

function render_config (values)
    return _.reduce(values.domains, prologue .. fallback:gsub('%$(%w+)', values), 
        function (cfg, domain)
            values.domain = domain
            values.servers = _.reduce(values[domain], '', function (vs, server) 
                return vs .. '        server ' .. server .. ";\n"
            end)
            return cfg .. upstream:gsub('%$(%w+)', values) .. server:gsub('%$(%w+)', values)
        end) .. finale
end

values = { ['myirrlab.org'] = { 'www.uol.com.br', 'www.uol.com.br' },
           ['myirrlab.net'] = { 'www.google.com.br', 'www.google.com.br' },
           domains = { 'myirrlab.org', 'myirrlab.net' }, 
           certdir = certdir, 
           codedir = codedir,
           port = port }

print(render_config(values))