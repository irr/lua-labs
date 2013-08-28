-- redis-cli script load "$(cat script-query.lua)"
-- evalsha SHA 1 bayes tall poor rich dummy nothing

local ns = KEYS[1]
local cls = KEYS[2]

local classes = redis.call('smembers', ns)
local scores = {}
local priors = {}
for i = 1, #classes do
    scores[i] = 0
    priors[i] = 0
end
local sum = 0
for i, v in pairs(classes) do
    local total = redis.call('get', KEYS[1]..':'..v..':_total')
    priors[i] = total
    sum = sum + total
end  
for i = 1, #classes do
    priors[i] = priors[i] / sum
end
sum = 0    
for i, v in pairs(classes) do
    local total = redis.call('get', KEYS[1]..':'..v..':_total')
    local score = priors[i]
    for i = 1, #ARGV do
        local freq = redis.call('get', KEYS[1]..':'..v..':_freqs:'..ARGV[i])
        if not freq then
            score = score * 0.00000000001
        else
            score = score * freq / total             
        end
    end
    scores[i] = score
    sum = sum + score
end
local result = { name = nil, value = -1 }
for i, v in pairs(classes) do
    scores[i] = scores[i] / sum;
    if scores[i] > result.value then
        result.name = v;
        result.value = scores[i];
    end        
end   
return { result.name, tostring(result.value) }