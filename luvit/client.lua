local http = require('http')

local req = http.request({
  host = "localhost",
  port = 8080,
  path = "/"
}, function (res)
  res:on('data', function (chunk)
    p("ondata", {chunk=chunk})
  end)
  res:on("end", function ()
    res:destroy()
  end)
end)
req:done()
