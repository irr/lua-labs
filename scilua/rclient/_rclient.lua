--------------------------------------------------------------------------------
-- A client for Rserve (http://rforge.net/Rserve/).
--
-- Copyright (C) 2011-2014 Stefano Peluchetti. All rights reserved.
--
-- Features, documentation and more: http://www.scilua.org .
--
-- This file is part of the Rclient library, which is released under the MIT
-- license: full text in file LICENSE.TXT in the library's root folder.
--------------------------------------------------------------------------------

-- TODO: Implement byte swapping for different endianness.
-- TODO: Remove limitation of not-nested list and data.frames.
-- TODO: Consider whether to allow exchanging more kinds of data.
-- TODO: Speedup all the arrays, work directly on buffer.

local ffi  = require "ffi"
local bit  = require "bit"
local xsys = require "xsys"
local sok  = require "socket"

if not ffi.abi("le") then
  error("NYI: only little endian architectures are supported")
end

local split, trim = xsys.string.split, xsys.string.trim
local br = bit.rshift
local bl = bit.lshift
local bo = bit.bor
local ba = bit.band
local tobit = bit.tobit

local function rerr(code, msg)
  error("R["..code.."]: "..tostring(msg))
end

-- String serialization format for any command (size here limited to 4GB, it
-- follows data_size[56] is never used):
-- | cmd_head[16] | head[4 or 8] | data[?] |
-- | cmd_head[16] | = | cmd_type[4]  | head_data_size[4] | 0[8] |
-- | head[4 or 8] | = | data_type[1] | data_size[3 or 7] |
-- if data_type[1] == DT.SEXP (always for transmitted values) then:
--   | data[?] |    = | xt_head[4 or 8] | xt_data[?] |
--   | xt_head[?] | = | xt_type[1]      | xt_size[3 or 7] |
-- For more info see C headers from Rserve.

-- From Rserve header ----------------------------------------------------------

local CMD = {
  eval       = 0x003, -- string -> encoded SEXP
  setSEXP    = 0x020, -- string(name), REXP -> -
  assignSEXP = 0x021, -- string(name), REXP -> -
}

-- TODO: Add all error types.
local RESP = {
  ANY = 0x10000,
  OK  = bo(0x10000, 0x0001),
  ERR = bo(0x10000, 0x0002),
}

local RRE = {
  auth_failed    = 0x41,
  conn_broken    = 0x42,
  inv_cmd        = 0x43,
  inv_par        = 0x44,
  Rerror         = 0x45,
  IOerror        = 0x46,
  notOpen        = 0x47,
  accessDenied   = 0x48,
  unsupportedCmd = 0x49,
  unknownCmd     = 0x4a,
  data_overflow  = 0x4b,
  object_too_big = 0x4c,
  out_of_mem     = 0x4d,
  ctrl_closed    = 0x4e,
  session_busy   = 0x50,
  detach_failed  = 0x51,
}

local DT = {
  INT          = 1,  -- N int
  STRING       = 4,  -- Y 0 terminated string
  BYTESTREAM   = 5,  -- N stream of bytes (unlike STRING may contain 0)
  SEXP         = 10, -- Y encoded SEXP
}
-- REMARK: We limit to 4gb size.

local XT = {
  NULL         = 0,  -- data: [0]
  STR          = 3,  -- data: [n]char null-term. string
  S4           = 7,  -- [NO!] data: [0]
  VECTOR       = 16, -- data: [?]REXP,REXP,..
  CLOS         = 18, -- [NO!] X formals, X body  (closure; since 0.1-5)
  SYMNAME      = 19, -- same as STR (since 0.5)
  LIST_NOTAG   = 20, -- same as VECTOR (since 0.5)
  LIST_TAG     = 21, -- X tag, X val, Y tag, Y val, ... (since 0.5)
  LANG_NOTAG   = 22, -- same as VECTOR (since 0.5)
  LANG_TAG     = 23, -- same as LIST_TAG (since 0.5)
  VECTOR_EXP   = 26, -- same as VECTOR (since 0.5)
  ARRAY_INT    = 32, -- data: [n*4]int,int,..
  ARRAY_DOUBLE = 33, -- data: [n*8]double,double,..
  ARRAY_STR    = 34, -- data: string,string,.. (string=byte,byte,...,0)
                     --       padded with '\01'
  ARRAY_BOOL   = 36, -- data: int(n),byte,byte,...
  RAW          = 37, -- data: int(n),byte,byte,...
  ARRAY_CPLX   = 38, -- data: [n*16]double,double,... (Re,Im,Re,Im,...)
  UNKNOWN      = 48, -- data: [4]int - SEXP type (as from TYPEOF(x))
}

local LARGE    = 64 -- if this flag is set then the length of the object
  -- is coded as 56-bit integer enlarging the header by 4 bytes

local HAS_ATTR = 128 -- flag; if set, the following REXP is the	attribute
  -- the use of attributes and vectors results in recursive storage of REXPs

--------------------------------------------------------------------------------

-- Debugging.
local function print_bytes(s)
  local o = {}
  for i=1,#s do
    o[#o+1] = bit.tohex(string.byte(s, i)):sub(7,8)
  end
  print(table.concat(o,","))
end

local TX = {}
for k,v in pairs(XT) do TX[v] = k end

local ERR = {}
for k,v in pairs(RRE) do ERR[v] = k end

local bool1_ct   = ffi.typeof("bool[1]")
local int1_ct    = ffi.typeof("int32_t[1]")
local double1_ct = ffi.typeof("double[1]")
local chara_ct   = ffi.typeof("char[?]")
local complex_ct = ffi.typeof("complex")

-- Encode to string.
local enc = {
  bool = function(x)
    return ffi.string(bool1_ct(x), 1)
  end,
  int = function(x)
    return ffi.string(int1_ct(x), 4)
  end,
  double = function(x)
    return ffi.string(double1_ct(x), 8)
  end,
  byte = function(x)
    return string.char(x)
  end,
  int24 = function(x) -- TODO: Is it always ok? (char sign...)
    return string.char(ba(x, 0xff), ba(br(x, 8), 0xff), ba(br(x, 16), 0xff))
  end,
  int56 = function(x) -- TODO: Is it always ok? (char sign...)
    -- Ensure 32 bits limit.
    assert(x < 2^32 - 1)
    return string.char(ba(x, 0xff), ba(br(x, 8), 0xff), ba(br(x, 16), 0xff),
                       ba(br(x, 24), 0xff), 0, 0, 0)
  end
}

-- Decode from a string / char[?].
local dec = {
  bool = function(s)
    return ffi.cast("bool*", s)[0]
  end,
  int = function(s)
    return ffi.cast("int32_t*", s)[0]
  end,
  double = function(s)
    return ffi.cast("double*", s)[0]
  end,
  byte = function(s)
    return s:byte(1)
  end,
  int24 = function(s) -- TODO: Is it always ok? (char sign...)
    return bo(s:byte(1), bl(s:byte(2), 8), bl(s:byte(3), 16))
  end,
  int56 = function(s) -- TODO: Is it always ok? (char sign...)
    -- Ensure 32 bits limit.
    assert(s:byte(5) == 0 and s:byte(6) == 0 and s:byte(7) == 0)
    return ffi.cast("int32_t*", s)[0]
  end
}

-- Remark: head must all be trans as whole.
local function enc_cmd_head(command, length) -- 16 bytes.
  assert(length < 2^32 -1)
  return enc.int(command)..enc.int(length)..enc.int(0)..enc.int(0)
end
local function dec_cmd_head(s)
  local command = dec.int(s:sub(1, 4))
  local length  = dec.int(s:sub(5, 8))
  assert(dec.int(s:sub(9,  12)) == 0)
  assert(dec.int(s:sub(13, 16)) == 0)
  return command, length
end

local function enc_head(t, l, hasatt)
  assert(ba(t, LARGE) == 0)
  assert(ba(t, HAS_ATTR) == 0)
  if hasatt then
    t = bo(t, HAS_ATTR)
    assert(ba(t, HAS_ATTR) ~= 0)
  end
  if l > 0xfffff0 then -- Large.
    return enc.byte(bo(t, LARGE)) .. enc.int56(l)
  else
    return enc.byte(t) .. enc.int24(l)
  end
end

local function dec_head(s)
  local t = dec.byte(s:sub(1, 1))
  local first, last = 0, 0
  if not (ba(t, LARGE) ~= 0) then
    first = 5
    last = first + dec.int24(s:sub(2, 4)) - 1
  else
    first = 9
    last = first + dec.int56(s:sub(2, 8)) - 1
  end
  return t, first, last
end

local attr_cache = setmetatable({}, { __mode = "k" })

local function attributes(x)
  return attr_cache[x]
end

local xt_decode = {}

setmetatable(xt_decode, { __index = function(self, k)
  error("unsupported decoding of XT: "..(TX[k] or k)) end
})

local xt_encode = {}

setmetatable(xt_encode, { __index = function(self, k)
  error("unsupported encoding of XT: "..(TX[k] or k)) end
})

local function iscomplex(x)
  return ffi.istype(complex_ct, x)
end

local function isatom(x)
  local t = type(x)
  return t == "nil" or t == "number" or t == "string" or t =="boolean" or 
         iscomplex(x)
end

local int_mt = { }

local function isint(x)
  return type(x) == "table" and getmetatable(x) == int_mt
end

local function asint(x)
  return setmetatable({ x }, int_mt)
end

local vec_mt = {}

local function asvec(x)
  return setmetatable({ x }, vec_mt)
end

local function isvec(x)
  return type(x) == "table" and getmetatable(x) == vec_mt
end

local attr_mt = {}

local function with(attr, x)
  return setmetatable({ attr, x }, attr_mt)
end

local function iswith(x)
  return type(x) == "table" and getmetatable(x) == attr_mt
end

local pli_mt = {}

local function aspairlist(x)
  return setmetatable({ x }, pli_mt)
end

local function ispairlist(x)
  return type(x) == "table" and getmetatable(x) == pli_mt
end

-- On the R implementation side we have the following primitive data structures, 
-- correspondence primitive --> underlying data representation:
-- NULL                    = nothing
-- STR                     = char[?] ('\00'-terminated '\01'-4bytes-padded)
-- ARRAY_{INT,DOUBLE,CPLX} = type[?]
-- ARRAY_BOOL              = n, bool[n]
-- ARRAY_STR               = STR[?]
-- VECTOR                  = REXP[?]
-- LIST_TAG                = (tag, val)[?]

-- On the R language side:
-- Null                    = NULL
-- c() homogeneous, single = ARRAY_*
-- matrix()                = ARRAY_* + attr: dim[2]
-- array()                 = ARRAY_* + attr: dim[?]
-- c() heterogeneous       = VECTOR
-- list()                  = VECTOR  + attr: (col)names
-- data.frame()            = VECTOR  + attr: (col)names, row.names, class
-- pairlist() (deprecated) = LIST_TAG

local function data_xt(data)
  if type(data) ~= "table" then
    data = { data }
  end
  if isint(data) then
    return data[1], XT.ARRAY_INT
  elseif isvec(data) then
    return data[1], XT.VECTOR
  elseif ispairlist(data) then
    return data[1], XT.LIST_TAG
  end
  local t = type(data[1])
  if not isatom(data[1]) then
    error("unsupported atomic type "..tostring(t))
  end
  if t == "nil" then
    return nil, XT.NULL
  elseif t == "number" then
    return data, XT.ARRAY_DOUBLE
  elseif t == "string" then
    return data, XT.ARRAY_STR
  elseif t == "boolean" then
    return data, XT.ARRAY_BOOL
  elseif iscomplex(data[1]) then
    return data, XT.ARRAY_CPLX
  end
end

local function decode_sexp(xt_t, s)
  local attr = ba(xt_t, HAS_ATTR) ~= 0
  xt_t = ba(xt_t, 63)
  if attr then
    --print("Beg decode attr ")
    local attr_t, attr_f, attr_l = dec_head(s)
    local attr = decode_sexp(attr_t, s:sub(attr_f, attr_l))
    --print("End encode attr ")
    --print("Decode: "..(TX[xt_t] or xt_t))
    local o = xt_decode[xt_t](s:sub(attr_l + 1, #s))
    if o then
      attr_cache[o] = attr
    end
    return o
  else
    --print("Decode: "..(TX[xt_t] or xt_t))
    return xt_decode[xt_t](s)
  end
end

local function encode_sexp(x)
  if iswith(x) then
    -- Only place where pairlist is actually used:
    local a, a_sexp = data_xt(aspairlist(x[1])) -- Attribute.
    local a_v       = xt_encode[a_sexp](a)
    local a_h       = enc_head(a_sexp, #a_v)
    local d, d_sexp = data_xt(x[2]) -- Data.
    local d_v       = xt_encode[d_sexp](d)
    local d_h       = enc_head(d_sexp, #d_v + #a_h + #a_v, true)
    return d_h..a_h..a_v..d_v
  else
    local x, x_sexp = data_xt(x)
    local x_v       = xt_encode[x_sexp](x)
    local x_h       = enc_head(x_sexp, #x_v)
    return x_h..x_v
  end
end

xt_decode[XT.NULL] = function(s)
  return nil
end

xt_decode[XT.STR] = function(s)
  -- Remove padding and trailing \0.
  return s:gsub(string.char(01), ''):gsub('%z', '')
end
xt_decode[XT.SYMNAME] = xt_decode[XT.STR]

xt_decode[XT.VECTOR] = function(s)
  local o = {}
  local off = 0
  while off < #s do
    local t, f, l = dec_head(s:sub(off + 1, math.min(#s, off + 8)))
    o[#o+1] = decode_sexp(t, s:sub(off + f, off + l))
    off = off + l
  end
  return o
end
xt_decode[XT.LIST_NOTAG] = xt_decode[XT.VECTOR]
xt_decode[XT.LANG_NOTAG] = xt_decode[XT.VECTOR]
xt_decode[XT.VECTOR_EXP] = xt_decode[XT.VECTOR]

xt_decode[XT.LIST_TAG] = function(s)
  local o = {}
  local off = 0
  while off < #s do
    local tag_t, tag_f, tag_l = dec_head(s:sub(off + 1, math.min(#s, off + 8)))
    local tag = decode_sexp(tag_t, s:sub(off + tag_f, off + tag_l))
    off = off + tag_l

    local val_t, val_f, val_l = dec_head(s:sub(off + 1, math.min(#s, off + 8)))
    local val = decode_sexp(val_t, s:sub(off + val_f, off + val_l))
    off = off + val_l

    if val == nil then
      if o[0] == nil then o[0] = {} end
      table.insert(o[0], tag)
    else
      assert(o[val] == nil) -- Avoid collisions.
      o[val] = tag -- I am using the naming from the documentation.
    end
  end
  return o
end
xt_decode[XT.LANG_TAG] = xt_decode[XT.LIST_TAG]

xt_decode[XT.ARRAY_INT] = function(s) -- It's of "int": signed 32bit integer.
  local o = {}
  for i=1,#s/4 do o[i] = dec.int(s:sub((i-1)*4+1, i*4)) end
  return o
end

xt_decode[XT.ARRAY_DOUBLE] = function(s)
  local o = {}
  for i=1,#s/8 do o[i] = dec.double(s:sub((i-1)*8+1, i*8)) end
  return o
end

xt_decode[XT.ARRAY_STR] = function(s)
  -- Removes padding, and split over \0.
  return xsys.string.split(s:gsub(string.char(01),''), '%z')
end

xt_decode[XT.ARRAY_BOOL] = function(s)
  local o = {}
  local n = dec.int(s:sub(1, 4))
  for i=1,n do o[i] = dec.bool(s:sub(4+i, 4+i)) end
  return o
end

xt_decode[XT.RAW] = function(s)
  local n = dec.int(s:sub(1, 4))
  return s:sub(5, #s)
end

xt_decode[XT.ARRAY_CPLX] = function(s)
  local o = {}
  for i=1,#s/16 do
    local off = (i-1)*16
    local re = dec.double(s:sub(off + 1, off + 8 ))
    local im = dec.double(s:sub(off + 9, off + 16))
    o[i] = complex_ct(re, im)
  end
  return o
end

xt_decode[XT.UNKNOWN] = function(s)
  return TX[dec.int(s)]
end

xt_encode[XT.NULL] = function()
  return ""
end

xt_encode[XT.STR] = function(x)
  local trail = (4 - (#x + 1)%4)%4 -- 4 bytes alignement.
  return x..string.char(00)..string.rep(string.char(01), trail)
end

xt_encode[XT.ARRAY_INT] = function(x)
  local ca = chara_ct(#x*4)
  for i=1,#x do ffi.copy(ca + (i-1)*4, enc.int(x[i]), 4) end
  return ffi.string(ca, #x*4)
end

xt_encode[XT.ARRAY_DOUBLE] = function(x)
  local ca = chara_ct(#x*8)
  for i=1,#x do ffi.copy(ca + (i-1)*8, enc.double(x[i]), 8) end
  return ffi.string(ca, #x*8)
end

xt_encode[XT.ARRAY_CPLX] = function(x)
  local o = {}
  for i=1,#x do
    o[i] = enc.double(x[i].re)..enc.double(x[i].im)
  end
  return table.concat(o)
end

xt_encode[XT.ARRAY_STR] = function(x)
  local s = table.concat(x, string.char(00))..string.char(00)
  local trail = (4 - (#s)%4)%4
  return s..string.rep(string.char(01), trail)
end

xt_encode[XT.ARRAY_BOOL] = function(x)
  local o = {enc.int(#x)}
  for i=1,#x do o[i+1] = enc.bool(x[i]) end
  return table.concat(o)
end

xt_encode[XT.RAW] = function(x)
  local trail = (4 - (#x[i])%4)%4 -- 4 bytes alignement.
  return enc.int(#x)..x..string.rep(string.char(01), trail)
end

xt_encode[XT.VECTOR] = function(x)
  local o = {}
  for i=1,#x do
    o[i] = encode_sexp(x[i])
  end
  return table.concat(o)
end

xt_encode[XT.LIST_TAG] = function(x)
  local o = {}
  for k,v in pairs(x) do
    assert(type(k) == "string")
    local k_v = xt_encode[XT.STR](k)
    local k_h = enc_head(XT.SYMNAME, #k_v)
    table.insert(o, encode_sexp(v)..k_h..k_v) -- TODO: Why switch?
  end
  return table.concat(o)
end

-- TODO: Binary data.
local function sexp_type(x)
  if x == nil then return XT.NULL end
  local t = type(x[1])
  assert(t ~= "nil")
  if     t == "number"   then return XT.ARRAY_DOUBLE
  elseif t == "string"   then return XT.ARRAY_STR
  elseif t == "boolean"  then return XT.ARRAY_BOOL
  elseif iscomplex(x[1]) then return XT.ARRAY_CPLX
  else   error("unsupported Lua type "..tostring(t))
  end
end

local function resp(sconn)
  local cmd_h = sconn:receive(16)
  local resp, length = dec_cmd_head(cmd_h)
  if not (resp == RESP.OK) then rerr(ERR[br(resp, 24)], "no details") end
  if length > 0 then
    local data = sconn:receive(length)
    local dt_t, dt_f, dt_l = dec_head(data)
    dt_t = ba(dt_t, 63) -- Cannot have HAS_ATTR, only LARGE.
    assert(dt_t == DT.SEXP)
    local xt_t, xt_f, xt_l = dec_head(data:sub(dt_f, math.min(#data, dt_f + 7)))
    return decode_sexp(xt_t, data:sub(xt_f + dt_f - 1, xt_l + dt_f - 1))
  end
  return nil
end

local function eval(sconn, s)
  local dt_h = enc_head(DT.STRING, #s)
  local cmd_h = enc_cmd_head(CMD.eval, #dt_h + #s)
  sconn:send(cmd_h..dt_h..s)
  return resp(sconn)
end

local function try_eval(sconn, s)
  local trys = 'try(eval(parse(text="' .. s .. '")),silent=TRUE)'
  local o = eval(sconn, trys)
  local attr = attributes(o)
  if attr and attr.class and attr.class[1] == "try-error" then
    rerr("eval", o[1])
  end
  return o
end

local rconn_mt = {}

function rconn_mt:__call(s, out)
  out = out or print
  local sp = split(s, "\n")
  for i=1,#sp do
    local caps = 'capture.output('..sp[i]..')'
    local o = try_eval(self._sconn, caps)
    if #o > 0 then
      out(table.concat(o, "\n"))
    end
  end
end

local function tomatrix(x)
  local nrow, ncol = attributes(x).dim[1], attributes(x).dim[2]
  local o = { }
  for r=1,nrow do
    o[r] = { }
    for c=1,ncol do
      o[r][c] = x[r + (c-1)*nrow] -- In R storage is col-major.
    end
  end
  return o
end

local function tolist(x)
  local names = attributes(x).names
  for i=1,#names do
    x[names[i]] = x[i]
  end
  x[0] = { names }
  return x
end

local function todataframe(x)
  x = tolist(x)
  x[0][2] = attributes(x)["row.names"]
  return x
end

local has = { }

local R_attr = {
  { tomatrix,      
    1, { dim = has } },
  { tolist,        
    1, { names = has } },
  { todataframe,   
    3, { names = has, ["row.names"] = has, class = "data.frame" } },
}

local function agrees(expect, n, attr)
  local i = 0
  for k,v in pairs(attr) do
    if not expect[k] then 
      return false 
    end
    if expect[k] ~= has and expect[k] ~= v[1] then
      return false
    end
    i = i + 1
  end
  return i == n
end

-- TODO: In theory it's possible to construct objects on R side that will get 
-- TODO: miss-classified here, as I'm checking the top-level attributes only.
local function tolua(self, k)
  local v = try_eval(self._sconn, k)
  if type(v) == "nil" then -- NULL
    return v 
  elseif not attributes(v) then -- Flat generic vector or array.
    return v 
  else -- Other supported types.
    local attr = attributes(v)
    for i=1,#R_attr do
      if agrees(R_attr[i][3], R_attr[i][2], attr) then
        return R_attr[i][1](v)
      end
    end
  end
  error("unsupported R object")
end

function rconn_mt:__index(k)
  return tolua(self, k)
end

function rconn_mt:__newindex(k, v)
  local data1 = xt_encode[XT.STR](k)
  local dt1_h = enc_head(DT.STRING, #data1)
  local ntot1 = #dt1_h + #data1

  local v_enc = encode_sexp(v)
  local dt2_h = enc_head(DT.SEXP, #v_enc)
  local ntot2 = #dt2_h + #v_enc

  local cmd_h = enc_cmd_head(CMD.assignSEXP, ntot1 + ntot2)

  self._sconn:send(cmd_h)
  self._sconn:send(dt1_h..data1)
  self._sconn:send(dt2_h)
  self._sconn:send(v_enc)
  resp(self._sconn)
end

connect = function(address, port)
  address = address or "localhost"
  port = port or 6311
  local sconn, serr = sok.connect(address, port)
  if not sconn then
    error(serr)
  end
  local id, serr = sconn:receive(32)
  if not id then
    error(serr)
  end
  id = id:sub(1, 12)
  if not (id == "Rsrv0103QAP1") then
    error("expected version Rsrv0103QAP1, got "..id)
  end
  local r = setmetatable({ _sconn = sconn }, rconn_mt)
  local luaexec = os.getenv("LUA_EXEC")
  if luaexec then
    if jit.os == "Windows" then
      -- On windows paths use \ instead of /, interpreted here as escapes.
      luaexec = luaexec:gsub([[\]], [[/]])
    end
    local _ = r["setwd('"..luaexec.."')"]
  end
  return r
end

local function asmatrix(data)
  local o = { }
  local nrow = #data
  local ncol = #data[1]
  local i = 0
  for c=1,ncol do
    for r=1,nrow do
      i = i + 1
      o[i] = data[r][c]
    end
  end
  return with({ dim = asint{ nrow, ncol } }, o) -- Array, not generic R vector.
end

local function defaultnames(n)
  local o = { }
  for i=1,n do
    o[i] = "X"..tostring(i)
  end
  return o
end

local function defaultrownames(n)
  local o = { }
  for i=1,n do
    o[i] = tostring(i)
  end
  return o
end

local function aslist(data, names)
  names = names or defaultnames(#data)
  if #names ~= #data then
    error("#names: "..(#names).." ~= #data: "..(#data))
  end
  return with({ names = names }, asvec(data))
end

local function asdataframe(data, names, rownames)
  names    = names    or defaultnames(#data)
  rownames = rownames or defaultrownames(isatom(data[1]) and 1 or #data[1])
  if #names ~= #data then
    error("#names: "..(#names).." ~= #data: "..(#data))
  end
  local nrow = #rownames
  for i=1,#data do
    local n = isatom(data[i]) and 1 or #data[i]
    if nrow ~= n then
      error("number of elements must be equal in each column, got "..nrow..
            " and "..n)
    end
  end
  return with({ names = names, ["row.names"] = rownames, class = "data.frame" },
    asvec(data))
end

return {
  connect     = connect,
  asmatrix    = asmatrix,
  aslist      = aslist,
  asdataframe = asdataframe,
  -- attributes  = attributes,
  -- with        = with,
  -- aspairlist  = aspairlist,
  -- asint       = asint,
  -- asvec       = asvec,
}
