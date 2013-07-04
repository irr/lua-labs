--[[
nginx -s stop; nginx -c /home/irocha/lua/openresty/ssl-ca/nginx-https.conf

curl -v -1 https://myirrlab.org:8443/ --cacert IRRSigningCA1/signing-ca-1.crt
curl -v -3 https://myirrlab.org:8443/ --cacert IRRSigningCA1/signing-ca-1.crt
--]]

local server = ngx.var.server_name:sub(#ngx.var.server_name-2):upper()

ngx.say("SSL-DOM = " .. ngx.var.server_name)
ngx.say("SNI-" .. server .. " = " .. (ngx.var.ssl_cipher:find("RC4") and "DISABLED" or "ENABLED"))
ngx.say("SSL-CPH = " .. ngx.var.ssl_cipher)
