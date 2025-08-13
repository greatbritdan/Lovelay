local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")

---------------------------------------------------------------------

local Transform = Class("Lovelay_Transform")

function Transform:initialize(transform)
    self.x, self.y, self.w, self.h = 0, 0, _LOVELAY_SETTINGS.unit, _LOVELAY_SETTINGS.unit
    self:Update(transform)
end

function Transform:Update(transform)
    transform = transform or {}
    if #transform == 2 then
        self.x, self.y = 0, 0
        self.w = transform.w or transform[1] or self.w
        self.h = transform.h or transform[2] or self.h
    else
        self.x = transform.x or transform[1] or self.x
        self.y = transform.y or transform[2] or self.y
        self.w = transform.w or transform[3] or self.w
        self.h = transform.h or transform[4] or self.h
    end
end

function Transform:Copy()
    return Transform:new({self.x,self.y,self.w,self.h})
end

function Transform:Offset(offsets)
    offsets = offsets or {}
    local x,y,w,h = self.x, self.y, self.w, self.h
    x = x + (offsets.x or offsets[1] or 0)
    y = y + (offsets.y or offsets[2] or 0)
    w = w + (offsets.w or offsets[3] or 0)
    h = h + (offsets.h or offsets[4] or 0)
    return Transform:new({x,y,w,h})
end

function Transform:PointInside(x,y)
    return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h
end

return Transform