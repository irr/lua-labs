-- example handler

require "string"

function output_filter(r)  
    coroutine.yield("")  
    while bucket do
        local output = bucket:upper()
        coroutine.yield(output)
    end
end

function handle(r)
    r.content_type = "text/html"
    r:puts("<html><head><title>Hello Lua</title></head><body>Hello World!</body></html>\n")
end
