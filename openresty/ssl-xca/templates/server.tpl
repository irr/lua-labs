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

