--[[
CREATE KEYSPACE IF NOT EXISTS irr
        WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 1 };

select id, ts, toUnixTimestamp(ts), val from rt_series;
--]]

local cluster = require 'resty.cassandra.cluster'

local session, err = cluster.new {
    shm = 'cassandra', -- defined by the lua_shared_dict directive
    contact_points = {'127.0.0.1'},
    keyspace = 'irr'
}

if not session then
  ngx.log(ngx.ERR, "could not create cluster: ", err)
  return ngx.exit(500)
end

-- simple query
local table_created, err = session:execute [[
    CREATE TABLE IF NOT EXISTS rt_series (
        id text,
        ts timeuuid,
        val int,
        PRIMARY KEY (id, ts),
    ) WITH CLUSTERING ORDER BY (ts DESC);
]]

-- query with arguments
local lim = 99

for i = 1, lim do
    local now = (os.time() * 1000)
    local res, err = session:execute([[
        INSERT INTO rt_series (id, ts, val) VALUES (?, now(), ?) USING TTL 100;
    ]], {"rt_id", i * 50})
    print(string.format("inserting data (%02d) at %s [res=%s][err=%s]",
        i, tostring(now - now % 1), tostring(res), tostring(err)))
end

function gmtime(t)
    return os.date("!%c UTC", math.floor(t/1000))
end

-- select statement
local series, err = session:execute(
    string.format("SELECT id, toUnixTimestamp(ts) as ts, val FROM rt_series LIMIT %d", lim))

if not err then
    print(string.format("retrieving last %d results...", lim))
    for _, t in pairs(series) do
        if type(t) == "table" then
            if t['id'] then
                print(string.format("\t%s (%s) = [%03d]", tostring(t['ts']), gmtime(t['ts']), t['val']))
            end
        end
    end
end
