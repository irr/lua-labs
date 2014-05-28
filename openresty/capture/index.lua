-- curl -v --user admin:admin123 http://localhost:8888/api/esm?limit=1
-- curl -v http://localhost:8888/api/esm?limit=1

ngx.req.set_header("Authorization",  "Basic " .. ngx.encode_base64(ngx.var.userpass))

res = ngx.location.capture("/proxy" .. ngx.var.uri, { share_all_vars = true })

for k, v in pairs(res.header) do
    if type(v) == "table" then
        for tk, tv in pairs(v) do
            ngx.say("\t" .. tk .. ": " .. tostring(tv))
        end        
    end
    ngx.say(k .. ": " .. tostring(v))
end

ngx.say("Body(" .. tostring(#res.body) .."): " .. res.body:sub(1,100))
