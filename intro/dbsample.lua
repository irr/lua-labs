local luasql = require "luasql.sqlite3"

local env = luasql.sqlite3()
local conn = env:connect("../data/symbols.db")
local cursor = assert(conn:execute("select * from symbols limit 10"))
local row = {}

while cursor:fetch(row) do
    print(table.concat(row, '|'))
end

cursor:close()
conn:close()

env:close()
