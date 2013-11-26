package.path = package.path .. "/opt/lua/luv/lib/?.lua;;"
package.cpath = package.cpath .. "/opt/lua/luv/?.so;;"

local p = require('utils').prettyPrint

local uv = require('luv')

local function create_server(host, port, on_connection)
  local server = uv.new_tcp()
  
  p("create_server", server)
  
  uv.tcp_bind(server, host, port)
  
  function server:onconnection()
        local client = uv.new_tcp()
        uv.accept(server, client)
        p("server:onconnection", client)
        on_connection(client)
    end

    function server:onclose()
        p("server:onclose", "server closed")
    end

  uv.listen(server)

  return server
end

local server = create_server("0.0.0.0", 12345, function (client)
        p("new client", client, uv.tcp_getsockname(client), uv.tcp_getpeername(client))
        function client:ondata(chunk)
            p("client:ondata", chunk)
            uv.write(client, chunk, function ()
                p("uv.write:client", chunk)
            end)
        end
        function client:onend()
            p("client:onend")
            uv.shutdown(client, function ()
            p("uv.shutdown")
            uv.close(client)
            end)
        end
        function client:onclose()
            p("client:onclose")
        end
        uv.read_start(client)
    end)

local address = uv.tcp_getsockname(server)

p("server", server, address)

repeat
  print("\ntick..")
until uv.run('once') == 0

print("done")
