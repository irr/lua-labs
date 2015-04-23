bit = require "bit"

function highest(mask, n)
    local j = 0
    for i = 13, 0, -1 do
        j = j + bit.band(bit.rshift(mask, i), 1)
        if j == n then
            return bit.lshift(bit.rshift(mask, i), i)
        end
    end
    return 0
end

function lowest(mask)
    for i = 0, 12 do
        if bit.band(mask, bit.lshift(1LL, i)) > 0 then
            return bit.lshift(1LL, i)
        end
    end
    return 0
end

function nbits(mask)
    local result = 0
    while mask > 0 do
        result = result + bit.band(mask, 1)
        mask = bit.rshift(mask, 1)
    end
    return result
end

inds, high1, high2, high3, high5, low, nbit, straight, unique, flush = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}

for i = 0, math.pow(2, 13) do
    inds[#inds + 1] = i
end

for _, i in pairs(inds) do
    high1[#high1 + 1] = 0LL + highest(i, 1)
    high2[#high2 + 1] = 0LL + highest(i, 2)
    high3[#high3 + 1] = 0LL + highest(i, 3)
    high5[#high5 + 1] = 0LL + highest(i, 5)
    low[#low + 1] = 0LL + lowest(i)
    nbit[#nbit + 1] = 0LL + nbits(i)
    straight[#straight + 1] = 0LL
    unique[#unique + 1] = 0LL
    flush[#flush + 1] = 0LL
end

for _, i in pairs(inds) do
    local mask = bit.lshift(1LL, 12) + bit.lshift(1LL, 0) + bit.lshift(1LL, 1) + bit.lshift(1LL, 2) + bit.lshift(1LL, 3)
    if bit.band(i, mask) == mask then
        straight[i + 1] = bit.lshift(1LL, 3)
    end
    for j = 0, 9 do
        mask = bit.lshift(1LL, j) + bit.lshift(1LL, (j + 1)) + bit.lshift(1LL, (j + 2)) + bit.lshift(1LL, (j + 3)) + bit.lshift(1LL, (j + 4))
        if bit.band(i, mask) == mask then
            straight[i + 1] = bit.lshift(1LL, (j + 4))
        end
    end
end

for _, i in pairs(inds) do
    if straight[i + 1] > 0 then
        unique[i + 1] = bit.bor(bit.lshift(4LL, 26), straight[i + 1])
    else
        unique[i + 1] = high5[i + 1]
    end
end

for _, i in pairs(inds) do
    if straight[i + 1] > 0 then
        flush[i + 1] = bit.bor(bit.lshift(8LL, 26), straight[i + 1])
    else
        flush[i + 1] = bit.bor(bit.lshift(5LL, 26), high5[i + 1])
    end
end

