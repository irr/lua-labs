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

function load(f)
    local f = io.open(f)
    local s = f:read("*a")
    f:close()
    local t = {}
    for w in string.gmatch(s, "(%w+)") do 
        if #w > 2 then
            t[#t+1] = w:lower()
        end
    end
    return t
end

function test(t)
    local s = ""
    for k, w in pairs(t) do
        t[k] = w:lower()
        s = s .. t[k] .. " "
    end

    print("\n>>> testing: " .. s)

    local scores = query(bayes, t)
    debug(scores.options)
    debug(scores.selected, "\t")

    print()
end

print()

local indexes = {"Doyle", "Dowson", "Beowulf"};

bayes = Bayes.new(indexes)

for _, i in pairs(indexes) do
    local t = load(i .. ".txt")
    print(i .. ": loaded " .. tostring(#t) .. " words...")
    learn(bayes, i, load(i .. ".txt"))
end

test({"adventures", "sherlock", "holmes"})
test({"comedy", "masks"})
test({"hrothgar", "beowulf"})

