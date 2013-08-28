Bayes = {}
Bayes.__index = Bayes

function debug(t, s)
    for k, v in pairs(t) do
        print((s or "")..k, v)
    end
end

function Bayes.new(classes)
    local self = setmetatable({}, Bayes)
    self.classes = classes
    self.sets = {}
    for _, v in pairs(classes) do
        self.sets[v] = { freqs = {}, total = 0 };
    end
    return self
end

function learn(c, cls, docs)
    local data = c.sets[cls]
    for _, d in pairs(docs) do
        data.freqs[d] = (data.freqs[d] or 0) + 1
        data.total = data.total + 1
    end
end

function query(c, docs)
    local scores = {}
    local priors = {}
    for i = 1, #c.classes do
        scores[i] = 0
        priors[i] = 0
    end
    local sum = 0
    for i, v in pairs(c.classes) do
        local total = c.sets[v].total
        priors[i] = total
        sum = sum + total
    end    
    for i = 1, #c.classes do
        priors[i] = priors[i] / sum
    end
    sum = 0
    for i, v in pairs(c.classes) do
        local data = c.sets[v]
        local score = priors[i]
        for _, d in pairs(docs) do
            local freq = data.freqs[d]
            if not freq then
                score = score * 0.00000000001
            else
                score = score * freq / data.total                
            end
        end
        scores[i] = score
        sum = sum + score
    end
    local result = { selected = { name = nil, value = -1 },
                    options = {}}
    for i, v in pairs(c.classes) do
        scores[i] = scores[i] / sum;
        result.options[v] = scores[i];
        if scores[i] > result.selected.value then
            result.selected.name = v;
            result.selected.value = scores[i];
        end
    end
    return result
end

bayes = Bayes.new({"good", "bad", "neutral"})

learn(bayes, "good", {"tall", "handsome", "rich"});
learn(bayes, "bad", {"bald", "poor", "ugly", "bitch"});
learn(bayes, "neutral", {"none", "nothing", "maybe"});

scores = query(bayes, {"tall", "poor", "rich", "dummy", "nothing"});

debug(scores.options)
debug(scores.selected, "\t")
