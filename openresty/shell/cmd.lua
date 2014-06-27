local shell = require("resty.shell")
local status, out, err = shell.execute("/bin/uname -a")
local body = out:gsub("%s+", " ")
ngx.say(body)
