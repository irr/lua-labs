local BaseClass = {}
BaseClass.__index = BaseClass

setmetatable(BaseClass, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function BaseClass:_init(init)
  self.value = init
end

function BaseClass:set_value(newval)
  self.value = newval
end

function BaseClass:get_value()
  return self.value
end

---

local DerivedClass = {}
DerivedClass.__index = DerivedClass

setmetatable(DerivedClass, {
  __index = BaseClass, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DerivedClass:_init(init1, init2)
  BaseClass._init(self, init1) -- call the base class constructor
  self.value2 = init2
end

function DerivedClass:get_value()
  return self.value + self.value2
end

local i = DerivedClass(1, 2)
print(i:get_value()) --> 3
i:set_value(3)
print(i:get_value()) --> 5

