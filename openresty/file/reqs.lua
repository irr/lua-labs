lines = {}

for line in io.lines(ngx.var.file) do 
    lines[#lines + 1] = line
end

ngx.say(lines[1])