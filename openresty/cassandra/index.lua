package.path = package.path .. ";/home/irocha/.luarocks/share/lua/5.1/?.lua;"
package.cpath = package.cpath .. ";/home/irocha/.luarocks/lib/lua/5.1/?.so;"

local apr = require "apr"
local cassandra = require "cassandra"

local session, err = cassandra.spawn_session {
    shm = "cassandra", -- defined by "lua_shared_dict"
    contact_points = {"127.0.0.1"}
}

if err then
  ngx.log(ngx.ERR, "could not spawn session: ", err)
  return ngx.exit(500)
end

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
        ts timeuuid,
        val int,
        PRIMARY KEY (id, ts),
    ) WITH CLUSTERING ORDER BY (ts DESC);
]]

-- query with arguments
local lim = 99

for i = 1, lim do
    local now = (apr.time_now() * 1000)
    local res, err = session:execute([[
        INSERT INTO rt_series (id, ts, val) VALUES (?, now(), ?) USING TTL 10;
    ]], {"rt_id", i * 50})
    print(string.format("inserting data (%02d) at %s [res=%s][err=%s]",
        i, tostring(now - now % 1), tostring(res), tostring(err)))
end

function gmtime(t)
	-- return os.date("!%c UTC", math.floor(t/1000))
    -- return apr.time_explode(t/1000)
    return apr.time_format('rfc822', t/1000)
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

session:set_keep_alive()
