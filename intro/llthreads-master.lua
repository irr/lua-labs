local llthreads = require "llthreads"

function readFile(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

local num_threads = tonumber(10)
 
print("MAIN-PATH: ", package.path)
print("MAIN-CPATH: ", package.cpath)

-- level 0 string literal enclosure [[  ]] of child execution code
local thread_code = readFile('llthreads-child.lua')

-- create child thread.
local thread = llthreads.new(thread_code, num_threads, package.path, package.cpath, 
    "number:", 1000, "nil:", nil, "bool:", true)
-- start joinable child thread.
assert(thread:start())
-- wait for all child and child sub-threads to finish
print("ROOT: child returned: ", thread:join())
