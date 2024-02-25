function dump(o, s)
  if type(o) == "table" then
      for k, v in pairs(o) do
          if s then
            print("\t",k,v)
          else
            print(k,v)
          end
          if type(v) == "table" then
            dump(v, "xxx")
          end
      end
  else
      print(o)
  end
end


local redis = require("redis")
local client = redis.new()
local info = client:info()
dump(info)
