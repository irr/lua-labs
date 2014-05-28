-- curl -v --user admin:admin123 http://localhost:8888/api/esm?limit=1
-- curl -v --header "Authorization: Basic YWRtaW46YWRtaW4xMjM=" http://localhost:8888/api/esm?limit=1
-- curl -v http://localhost:8888/api/esm?limit=1

-- curl -v --header "Authorization: Basic YWRtaW46YWRtaW4xMjM=" http://esm/api/esm

ngx.req.set_header("Authorization", ngx.var.basic)

res = ngx.location.capture("/proxy" .. ngx.var.uri, { share_all_vars = true })

for k, v in pairs(res.header) do
    if type(v) == "table" then
        for tk, tv in pairs(v) do
            ngx.say("\t" .. tk .. ": " .. tostring(tv))
        end        
    end
    ngx.say(k .. ": " .. tostring(v))
end

ngx.say("Body: " .. res.body:sub(1, 100) .. "...")
