package.cpath = package.cpath .. ";" .. ngx.var.basedir .. "/lib/?.so"

local tonum = tonumber
local tostr = tostring
local mfmod = math.fmod
local mfloor = math.floor
local mrandom = math.random
local strsub = string.sub
local strbyte = string.byte
local strchar = string.char
local strrep = string.rep
local strgsub = string.gsub

local aes = require("pycrypto_aes")

module("crypto")

function num2hex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = mfmod(num, 16)
        s = strsub(hexstr, mod+1, mod+1) .. s
        num = mfloor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end

function str2hex(str)
    local hex = ''
    while #str > 0 do
        local hb = num2hex(strbyte(str, 1, 1))
        if #hb < 2 then hb = '0' .. hb end
        hex = hex .. hb
        str = strsub(str, 2)
    end
    return hex
end

function hex2str(str)
    local cipher = ''
    while #str > 0 do
        cipher = cipher .. strchar(tonum(strsub(str, 1, 2), 16))
        str = strsub(str, 3)
    end
    return cipher
end

function pad(s, len, char)
    if char == nil then char = ' ' end
    return s .. strrep(char, len - #s)
end 

function encrypt(key, iv, s)
    local ns = tostr(mrandom(1000, 9999)) .. s
    local crypt = aes.new(key, aes.MODE_CBC, iv)
    local n = mfloor((#ns + 16) / 16) * 16
    return str2hex(crypt:encrypt(pad(ns, n)))
end

function decrypt(key, iv, c)
    local crypt = aes.new(key, aes.MODE_CBC, iv)
    local ns = trim(crypt:decrypt(hex2str(c)))
    return strsub(ns, 5)
end

function trim(s)
    return (strgsub(s, "^%s*(.-)%s*$", "%1"))
end
