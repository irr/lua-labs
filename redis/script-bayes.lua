-- redis-cli script load "$(cat script-bayes.lua)"
-- evalsha SHA 1 bayes good bad neutral

for i = 1, #ARGV do
    redis.call('sadd', KEYS[1], ARGV[i])
    local total = KEYS[1]..':'..ARGV[i]..':_total'
    redis.call('set', total, '0')
end
return redis.call('scard', KEYS[1])
