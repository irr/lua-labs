-- redis-cli script load "$(cat script-learn.lua)"
-- evalsha SHA 2 bayes good tall handsome rich

local ns = KEYS[1]
local cls = KEYS[2]
local key = ns..':'..cls..':_freqs'
local total = ns..':'..cls..':_total'

for i = 1, #ARGV do
    local word = key..':'..ARGV[i]
    redis.call('setnx', word, '0')
    redis.call('incr', word)
    redis.call('incr', total)
end

return #ARGV
