worker_processes    4;
worker_cpu_affinity 0001 0010 0100 1000;

error_log $basedir/logs/error.log info;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;    
}

http {
    tcp_nopush on;
    tcp_nodelay on;
    sendfile on;
    reset_timedout_connection on;

    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:!MD5:!aNULL:!eNULL:!NULL:!DH:!EDH:!AESGCM;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

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
