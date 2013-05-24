-- https://github.com/irr/lua-pycrypto-aes

package.path = package.path .. ';/home/irocha/gitf/lua-pycrypto-aes/?.lua'
package.cpath = package.cpath .. ';/home/irocha/gitf/lua-pycrypto-aes/?.so'

local aes = require "pycrypto_aes"

local key = "ba0113f6b71eb5ce"
local iv = "ba14f4a4d7ecddb6"

function num2hex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end

function str2hex(str)
    local hex = ''
    while #str > 0 do
        local hb = num2hex(string.byte(str, 1, 1))
        if #hb < 2 then hb = '0' .. hb end
        hex = hex .. hb
        str = string.sub(str, 2)
    end
    return hex
end

function hex2str(str)
    local cipher = ''
    while #str > 0 do
        cipher = cipher .. string.char(tonumber(string.sub(str, 1, 2), 16))
        str = string.sub(str, 3)
    end
    return cipher
end

function pad(s, len, char)
    if char == nil then char = ' ' end
    return s .. string.rep(char, len - #s)
end 

function encrypt(key, iv, s)
    local crypt = aes.new(key, aes.MODE_CBC, iv)
    local n = math.floor((#s + 16) / 16) * 16
    return str2hex(crypt:encrypt(pad(s, n)))
end

function decrypt(key, iv, c)
    local crypt = aes.new(key, aes.MODE_CBC, iv)
    return crypt:decrypt(hex2str(c))
end

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local c = encrypt(key, iv, "alessandra")

print("crypt="..c)

local s = decrypt(key, iv, c)

print(#s.."=["..trim(s).."]")