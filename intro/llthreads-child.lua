local num_threads, path, cpath = ...

package.path = path
package.cpath = cpath
    
print("CHILD: received from ROOT params:", ...)    
print("SUB-PATH: ", package.path)
print("SUB-CPATH: ", package.cpath)

local llthreads = require "llthreads2" -- need to re-declare this under this scope
local t = {} -- thread storage table

-- create a new child sub-thread execution code - it requires level 1 literal string [=[ ]=] enclosures, level 2 would be [==[ ]==]
local executed_child_code = [=[ 
    return "Hello from child sub-thread, new input params:", ... 
]=]

-- create 1000 sub-threads - which creates an incremental 30% / 20% utilization spike on the two AMD cpu cores
print("CHILD: Create sub threads:", num_threads)
for i=1,num_threads do
    -- create child sub-thread with code to execute and the input parmeters
    local thread = llthreads.new(executed_child_code , "number:", 1000 + i, "nil:", nil, "bool:", true) 
    assert(thread:start()) -- start new child sub-thread
    table.insert(t, thread) -- append the thread at the end of the thread table
end

-- wait (block) for all child sub-threads to complete before returning to ROOT
while true do
    -- always wait on the first element, since order is not important        
    print("CHILD: sub-thread returned: ", t[1]:join()) 
    table.remove(t,1) -- always remove the first element
    if (#t == 0) then break end
end

return ...  -- return the parents' input params back to the root
