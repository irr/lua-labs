`sockproc /tmp/shell.sock`;

use Test::Nginx::Socket;

repeat_each(1);

plan tests => $Test::Nginx::Socket::RepeatEach * 2 * blocks();

run_tests();

__DATA__

=== TEST 1: basic get
--- config
    location /test {
            content_by_lua '
                local shell = require("resty.shell")
                local status, out, err = shell.execute("/bin/uname -a")
                local body = out:gsub("%s+", " ")
                ngx.say(string.sub(body,1,12))
           ';
    }     
--- request
    GET /test
--- error_code: 200
--- response_body_like
Linux irrlab
