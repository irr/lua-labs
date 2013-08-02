server {
    listen $port default ssl;
    server_name _;

    ssl on;  
    ssl_certificate $certdir/multiple-domains.crt;  
    ssl_certificate_key $certdir/multiple-domains.pem;  
    
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers RC4:!MD5;

    location / {
        content_by_lua_file '$codedir/ssl-router.lua';
    }
}

