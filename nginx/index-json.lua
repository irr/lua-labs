local llth = require 'llthreads'
local json = require 'json'

local args = ngx.req.get_uri_args()
local js = json.encode(args)

local thread_code = [[
	-- http "localhost:8888/json?name=ivan&test=1000"
	local json, args = ...
	local redis = require 'redis'
	local client = redis.connect('127.0.0.1', 6379)
	client:set('args', json)
	client:set('name', args["name"])
]]

local thread = llth.new(thread_code, js, args)
assert(thread:start(true))

ngx.say(js)