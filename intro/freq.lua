-- lua freq.lua < freq.lua

local count = {}

--local t = io.read("*all")
--for w in string.gmatch(t, "%w+") do
--    count[w] = (count[w] or 0) + 1
--end

for line in io.lines() do
  for w in string.gmatch(line, "%w+") do
      count[w] = (count[w] or 0) + 1
  end
end

local words = {}

for w in pairs(count) do
    words[#words + 1] = w
end

table.sort(words, function (a,b) return count[a] > count[b] end)

for i=1, (arg[1] or 10) do
    print(words[i], count[words[i]])
end
