-- redis-cli script load "$(cat script-query.lua)"
-- evalsha SHA 1 bayes tall poor rich dummy nothing

local fnt = function (v) 
                return KEYS[1]..':'..v..':_total' 
            end

local fnf = function (v, i) 
                return KEYS[1]..':'..v..':_freqs:'..ARGV[i]
            end

local classes = redis.call('smembers', KEYS[1])

if #ARGV == 0 or #classes == 0 then
    return
end

local scores = {}
local priors = {}
for i = 1, #classes do
    scores[i], priors[i] = 0, 0
end

local sum = 0
for i, v in pairs(classes) do
    local total = redis.call('get', fnt(v))
    priors[i] = total
    sum = sum + total
end  
for i = 1, #classes do
    priors[i] = priors[i] / sum
end

sum = 0    
for i, v in pairs(classes) do
    local total = redis.call('get', fnt(v))
    local score = priors[i]
    for i = 1, #ARGV do
        local freq = redis.call('get', fnf(v, i))
        score = freq and (score * freq / total) or (score * 0.00000000001)
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