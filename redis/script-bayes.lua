-- redis-cli script load "$(cat script-bayes.lua)"
-- evalsha SHA 1 bayes good bad neutral

local i = 1
while ARGV[i] do
    redis.call('sadd', KEYS[1], ARGV[i])
    local total = KEYS[1]..':'..ARGV[i]..':_total'
    redis.call('set', total, '0')
    i = i + 1
end
return i
