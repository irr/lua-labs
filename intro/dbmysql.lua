luasql = require "luasql.mysql"

env = assert (luasql.mysql())
con = assert (env:connect("mysql", "root", "mysql"))
cur = assert(con:execute "SELECT Host, User FROM user")

print()
row = cur:fetch ({}, "a")
while row do
    print(string.format("Host: %s\nUser: %s\n", row.Host, row.User))
    row = cur:fetch (row, "a")
end

cur:close()
con:close()
env:close()
