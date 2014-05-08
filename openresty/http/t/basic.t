use Test::Nginx::Socket;

repeat_each(1);

plan tests => $Test::Nginx::Socket::RepeatEach * 2 * blocks();

run_tests();

__DATA__

=== TEST 1: basic get
--- config
    location /test {
        content_by_lua_file '/home/irocha/lua/openresty/http/index.lua';
    }
--- request
    GET /test?name=alessandra
--- error_code: 200
--- response_body_like
{"name":"alessandra"}

=== TEST 2: basic decrypt
--- config
    location /test {
        content_by_lua_file '/home/irocha/lua/openresty/http/index.lua';
    }
--- more_headers
Content-Type: application/json
--- request eval
"POST /test
name=alessandra\n
\n
"
--- error_code: 200
--- response_body
{"name":"alessandra"}
