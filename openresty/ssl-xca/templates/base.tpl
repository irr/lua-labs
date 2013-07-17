worker_processes    4;
worker_cpu_affinity 0001 0010 0100 1000;

error_log $basedir/logs/error.log info;

events {
    worker_connections 1024;
}

http {

    ssl_ciphers HIGH:!kEDH:@STRENGTH;
    ssl_prefer_server_ciphers on;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_session_cache shared:SSL:10m;

    include $confdir/*.conf;

    server {
        listen 8888 default;
        server_name _admin;

        location / {
            set $certd "$certdir";
            set $confd "$confdir";
            set $tpltd "$tpltdir";
            content_by_lua_file '$codedir/config.lua';
        }
    }
}
