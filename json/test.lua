local JSON = require "JSON"

local t = {["irr"] = "ale", "100", "200"}
local raw_json_text = JSON:encode(t)
print(raw_json_text)

local pretty_json_text = JSON:encode_pretty(t)
print(pretty_json_text)
