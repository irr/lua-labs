--[[
nginx -s stop; nginx -c /home/irocha/lua/openresty/ssl-xca/nginx.conf

curl -v -1 https://myirrlab.org:8443/ --cacert certs/irrlab.crt
curl -v -3 https://myirrlab.org:8443/ --cacert certs/irrlab.crt

openssl s_client -host myirrlab.org -port 8443 -CAfile certs/irrlab.crt
openssl s_client -host myirrlab.org -key certs/myirrlab.org.pem -cert certs/myirrlab.org.crt -port 8443
--]]

ngx.say("SSL-DOMAIN   = " .. ngx.var.server_name)
ngx.say("SSL-CIPHER   = " .. ngx.var.ssl_cipher)
ngx.say("SSL-PROTOCOL = " .. ngx.var.ssl_protocol)
ngx.say("SNI-STATUS   = " .. (ngx.var.ssl_cipher:find("RC4") and "DISABLED" or "ENABLED"))
