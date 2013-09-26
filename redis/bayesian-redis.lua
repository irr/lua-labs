redis = require 'redis'
client = redis.connect('127.0.0.1', 6379)

function debug(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end

function k(ns, cls, s)
    return ns..":"..cls..":_"..s
end

function fr(k, w)
    return k..":"..w
end

function bayes(ns, classes)    
    for _, v in pairs(classes) do
        client:sadd(ns, v)
        client:set(k(ns, v, "total"), "0")
    end
end

function learn(ns, cls, docs)
    local key = k(ns, cls, "freqs")
    local tot = k(ns, cls, "total")
    local options = { watch = tot, cas = true, retry = 10 }
    local replies = client:transaction(options, function(t)
        t:multi()
        for _, d in pairs(docs) do
            local w = fr(key, d)
            t:setnx(w, "0")
            t:incr(w)
            t:incr(tot)
        end
    end)
end

function query(ns, docs)
    local classes = client:smembers(ns)
    local scores = {}
    local priors = {}
    for i = 1, #classes do
        scores[i] = 0
        priors[i] = 0
    end
    local sum = 0
    for i, v in pairs(classes) do
        local total = client:get(k(ns, v, "total"))
        priors[i] = total
        sum = sum + total
    end  
    for i = 1, #classes do
        priors[i] = priors[i] / sum
    end
    sum = 0    
    for i, v in pairs(classes) do
        local total = client:get(k(ns, v, "total"))
        local score = priors[i]
        for _, d in pairs(docs) do
            local freq = client:get(fr(k(ns, v, "freqs"), d))
            if not freq then
                score = score * 0.000000000000001
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
    return result
end

client:flushall()

bayes("bayes", {"good", "bad", "neutral"})

learn("bayes", "good", {"tall", "handsome", "rich"});
learn("bayes", "bad", {"bald", "poor", "ugly", "bitch"});
learn("bayes", "neutral", {"none", "nothing", "maybe"});

result = query("bayes", {"tall", "poor", "rich", "dummy", "nothing"});

debug(result)