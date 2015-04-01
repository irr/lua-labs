print("greedy:")
for v in string.gmatch("ivan/ribeiro/rocha/", "(.*/)") do print("\t"..v) end
print("non-greedy:")
for v in string.gmatch("ivan/ribeiro/rocha/", "(.-/)") do print("\t"..v) end
