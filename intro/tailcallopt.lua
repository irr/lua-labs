function sum2(accu, n)
  if n > 0 then
    accu.value = accu.value + n
    return sum2(accu, n-1)
  end
end

local accu = {value = 0}
sum2(accu, 1000000)

print(accu.value)
