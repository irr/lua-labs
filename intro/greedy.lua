print("greedy:")
for k, v in string.gmatch("ivan/ribeiro/rocha/", "(.*/)") do print("\t",k,v) end
print("non-greedy:")
for k, v in string.gmatch("ivan/ribeiro/rocha/", "(.-/)") do print("\t",k,v) end
