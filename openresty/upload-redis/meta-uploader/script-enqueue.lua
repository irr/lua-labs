-- redis-cli script load "$(cat script-enqueue.lua)"
-- evalsha SHA 2 <queue> <key>  "...."

local ok = redis.call('setnx', KEYS[2], ARGV[1])
if ok == 1 then
    return redis.call('lpush', KEYS[1], KEYS[2]) 
end
return 0
