--[[

nginx -s stop; nginx -c /home/irocha/lua/openresty/ssl/nginx-https.conf

http://feeding.cloud.geek.nz/posts/ideal-openssl-configuration-for-apache/

    HIGH:RC4-SHA:!kEDH;
    hack: HIGH:!RC4-SHA:!kEDH;

    disables all weak ciphers and protocols
    disables very slow ciphers that use ephemeral Diffie-Hellman exchanges
    gives priority to the RC4 cipher to minimize CPU usage and defend against the BEAST attack

SNI enabled
    curl -1 --insecure https://myirrlab.org:8443/
SNI disabled
    curl -3 --insecure https://myirrlab.org:8443/

http://aionica.computerlink.ro/2011/08/multiple-domain-selfsigned-ssltls-certificates-for-apache-namebased-ssltls-vhosts/

openssl genrsa -out multidomain-server.key 1024
openssl req -new -key multidomain-server.key -out multidomain-server.csr
echo "subjectAltName=DNS:myirrlab.com,DNS:myirrlab.org,DNS:myirrlab.net" > multidomain-server.ext
openssl x509 -req -in multidomain-server.csr -signkey multidomain-server.key -extfile multidomain-server.ext -out multidomain-server.crt -days 1095

openssl genrsa -out myirrlab.org.key 1024
openssl req -new -key myirrlab.org.key -out myirrlab.org.csr
openssl x509 -req -in myirrlab.org.csr -signkey myirrlab.org.key -out myirrlab.org.crt -days 1095

openssl genrsa -out myirrlab.net.key 1024
openssl req -new -key myirrlab.net.key -out myirrlab.net.csr
openssl x509 -req -in myirrlab.net.csr -signkey myirrlab.net.key -out myirrlab.net.crt -days 1095

cat myirrlab.net.crt myirrlab.org.crt multidomain-server.crt > all-certs.crt

curl -v -1 https://myirrlab.net:8443/ --cacert all-certs.crt
curl -v -3 https://myirrlab.net:8443/ --cacert all-certs.crt

--]]

local server = ngx.var.server_name:sub(#ngx.var.server_name-2):upper()

ngx.say("SSL-DOM = " .. ngx.var.server_name)
ngx.say("SNI-" .. server .. " = " .. (ngx.var.ssl_cipher:find("RC4") and "DISABLED" or "ENABLED"))
ngx.say("SSL-CPH = " .. ngx.var.ssl_cipher)
