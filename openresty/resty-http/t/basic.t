use Test::Nginx::Socket;

repeat_each(1);

plan tests => $Test::Nginx::Socket::RepeatEach * 2 * blocks();

$ENV{TEST_NGINX_ERROR_LOG} = "/tmp/test.log";

log_level('warn');

run_tests();

__DATA__

=== TEST 1: basic get
--- config
    location /test {
        set $port 1984;
        content_by_lua_file '/home/irocha/lua/openresty/resty-http/index.lua';
    }
--- request
    GET /test
--- error_code: 200
--- response_body_like
{"b":"2","a":"1"}
