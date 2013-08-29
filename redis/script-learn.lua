-- redis-cli script load "$(cat script-learn.lua)"
-- evalsha SHA 2 bayes good tall handsome rich

local key = KEYS[1]..':'..KEYS[2]..':_freqs'
local total = KEYS[1]..':'..KEYS[2]..':_total'

for i = 1, #ARGV do
    local word = key..':'..ARGV[i]
    redis.call('setnx', word, '0')
    redis.call('incr', word)
    redis.call('incr', total)
end

return #ARGV
