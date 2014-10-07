require "logging.console"

local logger = logging.console()

local threads = require "llthreads2.ex"

local t = threads.new(function(...)
    require "logging.console"
    local logger = logging.console()
    logger:debug("THREAD: slepping for 3 secs...")
    local n, m = ...
    os.execute("sleep 3")
    logger:debug("THREAD: waking up after 3 secs...")
    return n + m, n * m
end, 1000, 2000)

t:start()

while t:alive() do 
  logger:info("...")
  os.execute("sleep 1")
end

local ok, v1, v2 = t:join()
assert(v1 == 3000 and v2 == 2000000)
print(string.format("OK: %d and %d\n", v1, v2))
