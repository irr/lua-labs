#!/usr/bin/env lua

require "luarocks.loader"

if arg == nil then
    os.exit(1)
end

local iconv = require("iconv")

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function split(str, sep)
    local s = str..sep
    return s:match((s:gsub('[^'..sep..']*'..sep, '([^'..sep..']*)'..sep)))
end

function trim(s)
  return s:match '^%s*(.-)%s*$'
end

local source = tostring(arg[1])
local _, charset = split(os.capture('file -bi ' .. source, true), "=")

local file = io.open(source, 'rb')
local content = file:read('*all')
file:close()

if charset ~= 'iso-8859-1' then
    local cd = iconv.open('ISO885915//TRANSLIT', charset)
    local nstr, err = cd:iconv(content)
    if not err then
        content = nstr        
    end
end

local patterns = { '<%p?%s*i>', '<%p?%s*I>', '<%p?%s*b>', '<%p?%s*B>', '<%p?%s*u>', '<%p?%s*U>' }

for _, v in pairs(patterns) do
    content = content:gsub(v, "")
end

file = io.open(source, 'w+')
file:write(content)
file:close()
