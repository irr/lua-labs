-- https://github.com/nanomsg/luajit-nanomsg

local nn = require 'nanomsg-ffi'

-- nn.C exposes all of the nanomsg C API functions
print( "nn.C.nn_errno(): " .. tostring(nn.C.nn_errno() ))

-- But there is a friendlier API available directly from nn:
print( "nn.errno(): " .. tostring(nn.errno() ))
print( "nn.EAGAIN: " .. tostring(nn.EAGAIN ))

-- For convenience, names for errno's are available in nn.E
assert( nn.E[ nn.EAGAIN ] == 'EAGAIN' )

-- Use the nn.socket class rather than the functions in nn.C
local req, id, rc, err

req, err = nn.socket( nn.REQ )
print("req: " .. tostring(req) .. " and err: " .. tostring(err))
assert( req, nn.strerror(err) )

id, err = req:connect( "tcp://127.0.0.1:555" )
print("id: " .. tostring(id) .. " and err: " .. tostring(err))
assert( id, nn.strerror(err) )

local msg = "hello world"
rc, err = req:send( msg, #msg )
print("rc: " .. tostring(rc) .. " and err: " .. tostring(err))
assert( rc > 0, nn.strerror(err) )