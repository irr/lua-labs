local threads = require "llthreads2.ex"

local t = threads.new(function(...)
    local n = ...
    os.execute("sleep 3")
    return n + 1
end, 1000)

t:start()

while t:alive() do 
  print("...")
  os.execute("sleep 1")
end

local ok, v = t:join()
assert(v == 1001)
print(string.format("OK: %d\n", v))
