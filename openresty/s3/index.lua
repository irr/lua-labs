if ngx.req.get_method() == "GET" then

    local now = ngx.cookie_time(ngx.now())
    local request = string.format("GET\n\n\n%s\n/%s/%s", now, ngx.var.bucket, ngx.var.uri:sub(2))
    local digest = ngx.encode_base64(ngx.hmac_sha1(ngx.var.awssecret, request))

    ngx.req.set_header("Host", string.format("%s.%s", ngx.var.bucket, ngx.var.aws))
    ngx.req.set_header("Date", now)
    ngx.req.set_header("Authorization", string.format("AWS %s:%s", ngx.var.awsid, digest))

    return

elseif ngx.req.get_method() == "PUT" then

    local now = ngx.cookie_time(ngx.now())
    local key = ngx.var.uri:sub(2)
    local headers = ngx.req.get_headers()
    local ctype = headers["Content-Type"] or "application/octet-stream"
    local tosign = string.format("PUT\n\n%s\n%s\n/%s/%s", ctype, now, ngx.var.bucket, key)
    local signature = ngx.encode_base64(ngx.hmac_sha1(ngx.var.awssecret, tosign))

    ngx.req.set_header("Host", string.format("%s.%s", ngx.var.bucket, ngx.var.aws))
    ngx.req.set_header("Date", now)
    ngx.req.set_header("Authorization", string.format("AWS %s:%s", ngx.var.awsid, signature))
    
    return 

elseif ngx.req.get_method() == "DELETE" then

    local now = ngx.cookie_time(ngx.now())
    local key = ngx.var.uri:sub(2)
    local tosign = string.format("DELETE\n\n\n%s\n/%s/%s", now, ngx.var.bucket, key)
    local signature = ngx.encode_base64(ngx.hmac_sha1(ngx.var.awssecret, tosign))

    ngx.req.set_header("Host", string.format("%s.%s", ngx.var.bucket, ngx.var.aws))
    ngx.req.set_header("Date", now)
    ngx.req.set_header("Authorization", string.format("AWS %s:%s", ngx.var.awsid, signature))

    return 

end

ngx.exit(400)

--[[
curl -v http://localhost:8888/s3.txt
curl -v -X PUT -T s3.txt -H "Content-Type: text/plain" http://localhost:8888/s3.txt
curl -v -X DELETE http://localhost:8888/s3.txt
--]]

