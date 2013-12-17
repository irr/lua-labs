require("socket")
local ssl = require("ssl")

-- TLS/SSL client parameters (omitted)
local params = {
  mode = "client",
  protocol = "tlsv1",
  verify = "none",
  options = "all",
}

local conn = socket.tcp()
conn:connect("www.google.com", 443)

-- TLS/SSL initialization
conn = ssl.wrap(conn, params)
conn:dohandshake()

conn:send("GET / HTTP/1.1\n\n")

local line, err = conn:receive("*l")
print(err or line)

conn:close()
