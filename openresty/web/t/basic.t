use Test::Nginx::Socket;

plan tests => $Test::Nginx::Socket::RepeatEach * 2 * blocks();

run_tests();

__DATA__

=== TEST 1: basic get
--- config
    location /t {
        set $basedir '/home/irocha/lua/openresty/web/';
        set $db_host '127.0.0.1';
        set $db_port 3306;
        set $db_database 'web';
        set $db_user 'root';
        set $db_crypt 'c6f2200c6d95066c711ce4874b773ee3';
        set $db_max_packet_size 1048576;
        set $db_timeout 10000;
        set $db_max_idle_timeout 0;
        set $db_pool_size 1;

        set $rd_host '127.0.0.1';
        set $rd_port 6379;
        set $rd_max_idle_timeout 0;
        set $rd_pool_size 1;

        content_by_lua_file '/home/irocha/lua/openresty/web/index.lua';
    }
--- request
    GET /t?id=1
--- response_body_like
{"(mysql|redis)":{"name":"root","id":1}}
--- error_code: 200
