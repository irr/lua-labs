#!/usr/bin/env lua

require("luarocks.loader")

local _ = require("underscore")

function readfile(dir, file)
    local f = io.open(dir .. "/" .. file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

local port    = 8443
local certdir = '/home/irocha/lua/openresty/ssl-xca/certs'
local codedir = '/home/irocha/lua/openresty/ssl-xca'
local confdir = '/home/irocha/lua/openresty/ssl-xca/includes'
local tpltdir = '/home/irocha/lua/openresty/ssl-xca/templates'
local basedir = '/opt/openresty/nginx'

local base = readfile(tpltdir, 'base.tpl')

local upstream = readfile(tpltdir, 'upstream.tpl')

local fallback = readfile(tpltdir, 'fallback.tpl')

local server = readfile(tpltdir, 'server.tpl')

function render_config (values)
    local ngxconf, incconf = "$codedir/nginx.conf", "$confdir/default.conf"
    local config = { [ngxconf:gsub('%$(%w+)', values)] = 
                        base:gsub('%$(%w+)', values),
                     [incconf:gsub('%$(%w+)', values)] =  
                        fallback:gsub('%$(%w+)', values) }
    return _.reduce(values.domains, config, 
        function (config, domain)
            values.domain = domain
            values.servers = _.reduce(values[domain], '', function (servers, server) 
                return servers .. string.format('    server %s;\n', server)
            end)
            local dconf = "$confdir/" .. domain .. ".conf" 
            config[dconf:gsub('%$(%w+)', values)] = upstream:gsub('%$(%w+)', values) .. server:gsub('%$(%w+)', values)
            return config
        end)
end

values = { ['myirrlab.org'] = { 'www.uol.com.br', 'www.uolhost.com.br' },
           ['myirrlab.net'] = { 'www.google.com', 'www.google.com.br' },
           domains = { 'myirrlab.org', 'myirrlab.net' },
           basedir = basedir, 
           certdir = certdir, 
           codedir = codedir,
           confdir = confdir,
           tpltdir = tpltdir,
           port = port }

local config = render_config(values)

_.each(_.keys(config), function (name)
        file = io.open(name, 'w+')
        file:write(config[name])
        file:close()
    end)

