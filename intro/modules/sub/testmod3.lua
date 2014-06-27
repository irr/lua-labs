--[[
-- call from parent directory
test = require "sub.testmod3"
test.info(1,2,"a",{a=100})
]]

local print = print
local type = type
local tostring = tostring
local pairs = pairs

module('sub.testmod3')

_VERSION = '1.00'

local function debug(args)
    for k, v in pairs(args) do
        print(tostring(k)..":["..tostring(v).."] type of "..type(v))
    end
end

function info(...)  
    print("testmod3 v" .._VERSION)
    debug({...})
end
