--[[
curl -v -H "Content-Type: application/json" -X POST -d '{"id":"none", "data": {"name": "luma"}}' http://localhost:8080
--]]

local json = require "cjson"

local ctx = ngx.ctx
if ctx.buffers == nil then
    ctx.buffers = {}
    ctx.nbuffers = 0
end

local data = ngx.arg[1]
local eof = ngx.arg[2]
local next_idx = ctx.nbuffers + 1

if not eof then
    if data then
        ctx.buffers[next_idx] = data
        ctx.nbuffers = next_idx
        -- Send nothing to the client yet.
        ngx.arg[1] = nil
    end
    return
elseif data then
    ctx.buffers[next_idx] = data
    ctx.nbuffers = next_idx
end

-- Yes, we have read the full body.
-- Make sure it is stored in our buffer.
assert(ctx.buffers)
assert(ctx.nbuffers ~= 0, "buffer must not be empty")

-- Modify body content!
local data = json.decode(table.concat(ngx.ctx.buffers))
data["modified"] = "OK"

-- And send a new body
ngx.arg[1] = json.encode(data)
