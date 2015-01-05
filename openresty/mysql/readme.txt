how to support mysql transaction?
No milestone
No one is assigned

I want to use transaction in mysql sql.

such as:

START TRANSACTION;
SELECT @A:=SUM(salary) FROM table1 WHERE type=1;
UPDATE table2 SET summary=@A WHERE type=1;
COMMIT;

2 participants
agentzh commented 9 months ago

Just use the whole as a single query and feed it into the "send_query" method. and then call the "read_result" method until no "again" error is returned. if you have troubles, just paste your sample code and the error details.

local provisioning_n = [[
SET @@AUTOCOMMIT=0;
START TRANSACTION;
SELECT @C:=alloc.cod_cluster, @I:=alloc.cod_id,
       map.num_ipfloat, map.num_ipmaster, map.num_ipbackup,
       alloc.N FROM map 
    JOIN (
        SELECT allocation.*, count(*) AS N FROM allocation
        GROUP BY allocation.cod_cluster, allocation.cod_id, allocation.ind_type 
        HAVING allocation.ind_type = %s
    ) alloc
    ON map.cod_cluster = alloc.cod_cluster
    WHERE alloc.N < 99
    ORDER BY alloc.N
    LIMIT 1 FOR UPDATE;
INSERT INTO allocation VALUES (%s, @C, @I, %s);
SELECT * FROM allocation INNER JOIN map 
    ON allocation.cod_cluster = map.cod_cluster AND 
       allocation.cod_id = map.cod_id AND 
       allocation.nam_domain = %s;
COMMIT;
]]

...
function results(db, sql)
    local bytes, err = db:send_query(sql)
    if not err then
        local body, res, err, errno, sqlstate = {}
        repeat
            res, err, errno, sqlstate = db:read_result()
            
            if errno then
                if errno == 1048 then
                    exit(db, ngx.HTTP_NOT_FOUND)
                else
                    exit(db, ngx.HTTP_INTERNAL_SERVER_ERROR, 
                            string.format("results error: %s: %s %s", 
                                tostring(err), tostring(errno), tostring(sqlstate)))
                end
            else
                if type(res) == "table" then
                    if type(res[1]) == "table" then
                        body = res[1]
                    end
                end
            end

        until err ~= "again"

        return json.encode(body)
    else
        exit(db, ngx.HTTP_INTERNAL_SERVER_ERROR, 
             string.format("results error: " .. tostring(err)))
    end    
end

function query(db, sql, empty)
    local res, err, errno, sqlstate = db:query(sql)
    if errno then
         exit(db, ngx.HTTP_INTERNAL_SERVER_ERROR, 
                string.format("check error: %s: %s %s", 
                    tostring(err), tostring(errno), tostring(sqlstate)))
    elseif not empty and (not res or #res == 0) then
        exit(db, ngx.HTTP_NOT_FOUND)
    end
    return res
end
...

ngx.header.content_type = 'application/json';

local db, err = mysql:new()

if not db then
    exit(db, ngx.HTTP_INTERNAL_SERVER_ERROR, 
         "failed to instantiate mysql: " .. tostring(err))
end

db:set_timeout(ngx.var.db_timeout) 

local ok, err, errno, sqlstate = db:connect{
    host = ngx.var.db_host,
    port = ngx.var.db_port,
    database = ngx.var.db_database,
    user = ngx.var.db_user,
    password = crypt.decrypt(key, iv, ngx.var.db_crypt),
    max_packet_size = tonumber(ngx.var.db_max_packet_size) }

if not ok then
    exit(db, ngx.HTTP_INTERNAL_SERVER_ERROR, 
         string.format("failed to connect: %s: %s %s", 
                       tostring(err), tostring(errno), tostring(sqlstate)))
end


ngx.say(results(db, string.format(p, t, d, t, d)))

