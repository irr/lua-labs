local cassandra = require "cassandra"

local session = cassandra.new()
session:set_timeout(1000) -- 1000ms timeout

local connected, err = session:connect("127.0.0.1", 9042)

-- test keyspace
local table_created, err = session:execute [[
    CREATE KEYSPACE IF NOT EXISTS irr
        WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 1 };
]]

session:set_keyspace("irr")

-- simple query
local table_created, err = session:execute [[
    CREATE TABLE IF NOT EXISTS rt_series (
        id text,
        ts text,
        val int,
        PRIMARY KEY (id, ts),
    ) WITH CLUSTERING ORDER BY (ts DESC);
]]

-- query with arguments
local lim = 10
local now = os.time()

for i = 1, lim do
    local ts = tostring(now - i)
    local res, err = session:execute([[
        INSERT INTO rt_series (id, ts, val) VALUES (?, ?, ?) USING TTL 10;
    ]], {"rt_id", ts, i * 50})
    print(string.format("inserting data (%02d) from timestamp %s [res=%s][err=%s]",
        i, ts, tostring(res), tostring(err)))
end

-- select statement
local series, err = session:execute(string.format("SELECT id, ts, val FROM rt_series LIMIT %d", lim))

if not err then
    print(string.format("retrieving last %d results...", lim))
    for _, t in pairs(series) do
        if type(t) == "table" then
            if t['ts'] then
                print(string.format("\t%s = [%03d]", tostring(t['ts']), t['val']))
            end
        end
    end
end
