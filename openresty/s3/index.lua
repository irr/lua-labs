if ngx.req.get_method() == "GET" then
    local headers = ngx.req.get_headers()
    if headers.authorization ~= nil then
        ngx.exit(403)
    end
    
    local args = ngx.req.get_uri_args()
    for k, _ in pairs(args) do
        if k:lower() == "awsaccesskeyid" then
            ngx.exit(403)
        end
    end

    local now = ngx.cookie_time(ngx.now())
    local request = string.format("GET\n\n\n%s\n/%s/%s", now, ngx.var.bucket, ngx.var.uri:sub(2))
    local digest = ngx.encode_base64(ngx.hmac_sha1(ngx.var.awssecret, request))

    ngx.req.set_header("Host", string.format("%s.%s", ngx.var.bucket, ngx.var.aws))
    ngx.req.set_header("Date", now)
    ngx.req.set_header("Authorization", string.format("AWS %s:%s", ngx.var.awsid, digest))

    return
end

