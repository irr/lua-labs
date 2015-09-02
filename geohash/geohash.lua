-- Geohash
-- (c) 2015 Ivan Ribeiro Rocha (ivan.ribeiro@gmail.com)

local bit = require("bit")

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

function decode(hash)
    local flip = true;
    local latitude = { -90.0, 90.0 }
    local longitude = { -180.0, 180.0 }

    for i = 1, #hash do
        local c = hash:sub(i, i)
        local cd = BASE32:find(c) - 1
        for j = 1, 5 do
            mask = BITS[j]
            local interval = (flip and longitude) or latitude
            if bit.band(cd, mask) > 0 then
                interval[1] = (interval[1] + interval[2]) / 2
            else
                interval[2] = (interval[1] + interval[2]) / 2
            end
            flip = not flip
        end
    end

    latitude[3] = (latitude[1] + latitude[2]) / 2
    longitude[3] = (longitude[1] + longitude[2]) / 2

    return { lat = latitude, lon = longitude }

end

function encode(latitude, longitude, precision)
    local lat = { -90.0, 90.0 }
    local lon = { -180.0, 180.0 }
    local b, ch, flip = 0, 0, true
    local precision = precision or 12
    local geohash = "";

    while #geohash < precision do
        local tab = flip and lon or lat
        local grd = flip and longitude or latitude

        mid = (tab[1] + tab[2]) / 2

        if grd > mid then
            ch = bit.bor(ch, BITS[b + 1])
            tab[1] = mid
        else
            tab[2] = mid
        end

        flip = not flip;

        if b < 4 then
            b = b + 1
        else
            geohash = geohash..BASE32:sub(ch + 1, ch + 1);
            b, ch = 0, 0
        end
    end

    return geohash
end

function calculate_distance(lat1, lon1, lat2, lon2)
    local R = 6371000
    local r1, r2 = math.rad(lat1), math.rad(lat2)
    local dlat, dlon = math.rad((lat2-lat1)), math.rad((lon2-lon1))
    local a = math.sin(dlat/2) * math.sin(dlat/2) +
              math.cos(r1) * math.cos(r2) *
              math.sin(dlon/2) * math.sin(dlon/2)
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    return R * c
end

function distance(hash1, hash2)
    local t1, t2 = decode(hash1), decode(hash2)
    return calculate_distance(coord(t1).lat, coord(t1).lon,
                              coord(t2).lat, coord(t2).lon)
end

function neighbor(hash, dir)
    hash = hash:lower()
    local len = #hash
    local last = hash:sub(len, len);
    local flip = ((math.mod(len,2) == 0) and 'even') or 'odd'
    local base = hash:sub(1, len - 1)
    if BORDERS[dir][flip]:find(last) then
        base = neighbor(base, dir)
    end
    local n = NEIGHBORS[dir][flip]:find(last)
    return base..BASE32:sub(n, n)
end

function neighbors(hash)
    local neighbors = { top = neighbor(hash, 'top'),
                        bottom = neighbor(hash, 'bottom'),
                        right = neighbor(hash, 'right'),
                        left = neighbor(hash, 'left') }
    neighbors.topleft = neighbor(neighbors.left, 'top');
    neighbors.topright = neighbor(neighbors.right, 'top');
    neighbors.bottomleft = neighbor(neighbors.left, 'bottom');
    neighbors.bottomright = neighbor(neighbors.right, 'bottom');
    return neighbors
end

function coord(t)
    if type(t) == 'table' then
        return { lat = t.lat[3], lon = t.lon[3] }
    end
    return coord(decode(t))
end

function coord_str(t)
    local t = coord(t)
    return string.format("lat: %s and lon: %s", tostring(t.lat), tostring(t.lon))
end

function test()
    local precision = 12
    print("\nencoding", "lat/long (-23.643380, -46.759670)")
    local h1 = encode(-23.643380, -46.759670, precision)
    print("result/decode", h1, "\n")
    local t = decode(h1)
    for _, l in pairs({'lat', 'lon'}) do
        print(l)
        for k, v in pairs(t[l]) do
            print("\t", k, v)
        end
    end
    print("\n")
    local blocks = neighbors(h1)
    for k, v in pairs(blocks) do
        print(string.format("%10s\t%s", k, v))
    end
    print("\n")

    for p = 4, 12 do
        local h1 = encode(-23.643380, -46.759670, p)
        local h2 = encode(-23.569641, -46.691774, p)
        local dist = distance(h1, h2)
        print(string.format("using precision = %d", p))
        print(string.format("distance from %s or %s\n         to   %s or %s\n         = %6.2f meters ~= %2.4f Km\n",
            h1, coord_str(h1), h2, coord_str(h2), dist, dist/1000))
    end
end
