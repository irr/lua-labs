local net = require('net')

local client
client = net.createConnection(8080, '127.0.0.1', function (err)
  if err then error(err) end

  print("Connected...")

  -- Send stdin to the server
  process.stdin:readStart()
  process.stdin:pipe(client)

  -- Send the server's response to stdout
  client:pipe(process.stdout)

end)
