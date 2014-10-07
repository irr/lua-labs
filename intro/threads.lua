require "logging.console"

math.randomseed(os.time())

local logger = logging.console()

local threads = require "llthreads2.ex"

local worker = { n = 10 }
for i = 1, worker.n do 
    local t = threads.new(function(...)
        require "logging.console"
        local logger = logging.console()
        local id, n, m = ...
        local wait = math.random(10)
        logger:info(string.format("THREAD(%02d): slepping for %d secs...", id, wait))
        os.execute(string.format("sleep %d", wait))
        logger:info(string.format("THREAD(%02d): waking up after %d secs...", id, wait))
        return n + m, n * m
    end, i, i*1000, i + 1)
    worker[#worker + 1] = t
    t:start()
end

for i = 1, worker.n do
    local ok, v1, v2 = worker[i]:join()
    logger:info(string.format("THREAD(%02d): %d and %d", i, v1, v2))
end
