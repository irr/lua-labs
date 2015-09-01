-- Geohash
-- (c) 2015 Ivan Ribeiro Rocha (ivan.ribeiro@gmail.com)

bit = require("bit")

local BITS = { 16, 8, 4, 2, 1 }

local BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"

local NEIGHBORS = { right  = { even = "bc01fg45238967deuvhjyznpkmstqrwx" },
                    left   = { even =  "238967debc01fg45kmstqrwxuvhjyznp" },
                    top    = { even =  "p0r21436x8zb9dcf5h7kjnmqesgutwvy" },
                    bottom = { even = "14365h7k9dcfesgujnmqp0r2twvyx8zb" } }

local BORDERS = { right  = { even = "bcfguvyz" },
                  left   = { even = "0145hjnp" },
                  top    = { even = "prxz" },
                  bottom = { even = "028b" } }

NEIGHBORS.bottom.odd = NEIGHBORS.left.even
NEIGHBORS.top.odd = NEIGHBORS.right.even
NEIGHBORS.left.odd = NEIGHBORS.bottom.even
NEIGHBORS.right.odd = NEIGHBORS.top.even

BORDERS.bottom.odd = BORDERS.left.even
BORDERS.top.odd = BORDERS.right.even
BORDERS.left.odd = BORDERS.bottom.even
BORDERS.right.odd = BORDERS.top.even

function refine_interval(interval, cd, mask)
    if bit.band(cd, mask) > 0 then
        interval[1] = (interval[1] + interval[2]) / 2
    else
        interval[2] = (interval[1] + interval[2]) / 2
    end
end

function calculate_adjacent(srcHash, dir)
    srcHash = srcHash:lower()
    local lenHash = #srcHash
    local lastChr = srcHash:sub(lenHash, lenHash);
    local t = ((math.mod(lenHash,2) == 0) and 'even') or 'odd'
    local base = srcHash:sub(1, lenHash - 1)
    if BORDERS[dir][t]:find(lastChr) then
        base = calculate_adjacent(base, dir)
    end
    local n = NEIGHBORS[dir][t]:find(lastChr)
    return base..BASE32:sub(n, n)
end

function decode(geohash)
    local is_even = true;
    local lat = { -90.0, 90.0, 0 }
    local lon = { -180.0, 180.0, 0 }
    local lat_err, lon_err = 90.0, 180.0;

    for i = 1, #geohash do
        local c = geohash:sub(i, i)
        local cd = BASE32:find(c)
        for j = 1, 5 do
            mask = BITS[j]
            if is_even then
                lon_err = lon_err / 2
                refine_interval(lon, cd - 1, mask)
            else
                lat_err = lat_err / 2
                refine_interval(lat, cd - 1, mask)
            end
            is_even = not is_even
        end
    end

    lat[3] = (lat[1] + lat[2]) / 2
    lon[3] = (lon[1] + lon[2]) / 2

    return { latitude = lat, longitude = lon}

end

function encode(latitude, longitude, precision)
    local is_even = true
    local i = 0
    local lat = { -90.0, 90.0 }
    local lon = { -180.0, 180.0 }
    local b = 0
    local ch =0
    local precision = precision or 12
    local geohash = "";

    while #geohash < precision do
        if is_even then
            mid = (lon[1] + lon[2]) / 2
            if longitude > mid then
                ch = bit.bor(ch, BITS[b + 1])
                lon[1] = mid
            else
                lon[2] = mid
            end
        else
            mid = (lat[1] + lat[2]) / 2
            if (latitude > mid) then
                ch = bit.bor(ch, BITS[b + 1])
                lat[1] = mid;
            else
                lat[2] = mid;
            end
        end

        is_even = not is_even;
        if b < 4 then
            b = b + 1
        else
            geohash = geohash..BASE32:sub(ch + 1, ch + 1);
            b = 0
            ch = 0
        end
    end
    return geohash
end

function neighbors(geohash)
    local neighbors = { top = calculate_adjacent(geohash, 'top'),
                        bottom = calculate_adjacent(geohash, 'bottom'),
                        right = calculate_adjacent(geohash, 'right'),
                        left = calculate_adjacent(geohash, 'left') }
    neighbors['topleft'] = calculate_adjacent(neighbors['left'], 'top');
    neighbors['topright'] = calculate_adjacent(neighbors['right'], 'top');
    neighbors['bottomleft'] = calculate_adjacent(neighbors['left'], 'bottom');
    neighbors['bottomright'] = calculate_adjacent(neighbors['right'], 'bottom');
    return neighbors
end

function test()
    print("\nencoding", "lat/long (42.6, -5.6)")
    local h = encode(42.6, -5.6, 12)
    print("result/decode", h, "\n")
    local t = decode(h)
    for _, l in pairs({'latitude', 'longitude'}) do
        print(l)
        for k, v in pairs(t[l]) do
            print("\t", k, v)
        end
    end
    print("\n")
    for k, v in pairs(neighbors(h)) do
        print(string.format("%10s\t%s", k, v))
    end
    print("\n")
end
