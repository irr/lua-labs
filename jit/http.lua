--[[
Makefile (LuaJIT)
LDFLAGS=-Wl,-rpath,/usr/local/lib
or
LD_LIBRARY_PATH=/usr/local/lib luajit http.lua
and use
local event = ffi.load("event")
or
local event = ffi.load("/usr/local/lib/libevent.so")
ldconfig -p | grep libevent
readelf -d /usr/local/lib/libevent.so => libevent-2.0.so.5
const char* evhttp_request_get_uri(const struct evhttp_request *req);
or
local event = ffi.load("libevent-1.4.so.2")
const char* evhttp_request_uri(const struct evhttp_request *req);
]] 

local ffi = require("ffi")
local event = ffi.load("libevent-1.4.so.2")

ffi.cdef[[
typedef void (__stdcall *CB)(struct evhttp_request *, void *);
struct event_base* event_init(void);
struct evhttp* evhttp_new(struct event_base *base);
int evhttp_bind_socket(struct evhttp* http, const char* address, int port);
void evhttp_set_gencb(struct evhttp* http, CB cb, void* arg); 
int event_base_dispatch(struct event_base *);
void evhttp_send_reply(struct evhttp_request *req, int code, const char *reason, struct evbuffer *databuf);
struct evbuffer *evbuffer_new(void);
int evbuffer_add_printf(struct evbuffer *buf, const char *fmt, ...);
const char* evhttp_request_uri(const struct evhttp_request *req);
]]

local base = event.event_init();
local httpd = event.evhttp_new(base);
local port = 8081

local cb = ffi.cast("CB", function(req, args)
    local buf = event.evbuffer_new();
    event.evbuffer_add_printf(buf, "Requested: %s\n", event.evhttp_request_uri(req))
    event.evhttp_send_reply(req, 200, "OK", buf)
end)

if event.evhttp_bind_socket(httpd, "0.0.0.0", port) == 0 then
    event.evhttp_set_gencb(httpd, cb, nil);
    print("listening on :"..tostring(port))
    event.event_base_dispatch(base);  
end

