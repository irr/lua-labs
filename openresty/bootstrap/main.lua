local cjson = require "cjson"
ngx.say(cjson.encode({ status = true }))
return ngx.exit(ngx.HTTP_OK)
