ngx.header.content_type = 'application/json'

-- curl -v --user admin:admin123 http://localhost:8888/api/esm?limit=1
-- curl -v --header "Authorization: Basic YWRtaW46YWRtaW4xMjM=" http://localhost:8888/api/esm?limit=1
-- curl -v http://localhost:8888/api/esm?limit=1

ngx.req.set_header("Authorization", ngx.var.basic)

res = ngx.location.capture("/proxy" .. ngx.var.uri, { share_all_vars = true })
ngx.print(res.body)
