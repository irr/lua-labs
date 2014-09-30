--[[
test = require "testmod"
test.info(1,2,"a",{a=100})
]]

local modname = ...

local _M = {
    _VERSION = '1.00'
}

_G[modname] = _M
package.loaded[modname] = _M

local print = print
local type = type
local tostring = tostring
local pairs = pairs

setfenv(1, _M)

local function debug(args)
    for k, v in pairs(args) do
        print(tostring(k)..":["..tostring(v).."] type of "..type(v))
    end
end

function _M.info(...)  
    print("testmod v" .._M._VERSION)
    debug({...})
end

return _M