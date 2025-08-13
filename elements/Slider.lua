local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")
local Transform = require(_LOVELAY_REQUIRE_PATH..".Utilities.Transform")

---------------------------------------------------------------------

local Slider = Class("Lovelay_Slider",Base)

function Slider:initialize(instance,transform,arguments)
    self.type = "Slider"
    Base.initialize(self,instance,transform,arguments)
end
function Slider:Setup()
    self._ew = self.t.w-(self.marginx*2) -- effective width
    self._eh = self.t.h-(self.marginy*2) -- effective height

    self.dir = self.a.dir or "hor"
    self.limit = self.a.limit or {min=0,max=100,step=1,scroll=10}
    self.value = self.a.value or self.limit.min
    local fill = self.a.fill or 0.25
    if self.dir == "hor" then
        self.fill = (fill > 1) and math.min(fill,self._ew) or self._ew*fill
        if self.a.square then self.fill = self._eh end
    else
        self.fill = (fill > 1) and math.min(fill,self._eh) or self._eh*fill
        if self.a.square then self.fill = self._ew end
    end
end
function Slider:Modified()
    if self.dir == "hor" then
        self.tb = Transform:new({self.t.x+self.marginx, self.t.y+self.marginy, self.fill, self._eh})
    else
        self.tb = Transform:new({self.t.x+self.marginx, self.t.y+self.marginy, self._ew, self.fill})
    end

    self.v.base = self.s:CreateStyle(self,self.t,{"base"})
    self.v.bulb = self.s:CreateStyle(self,self.tb,{"bulb","base"})
end

function Slider:Update(dt)
    if self.click then
        local mx,my = Utils.GetMouse()
        local oldvalue = self.value
        if self.dir == "hor" then
            local offset = mx-self.t.x -self.marginx-(self.fill/2)
            self.value = self.limit.min + (offset / (self._ew-self.fill)) * (self.limit.max-self.limit.min)
        else
            local offset = my-self.t.y -self.marginy-(self.fill/2)
            self.value = self.limit.min + (offset / (self._eh-self.fill)) * (self.limit.max-self.limit.min)
        end
        self:Clamp()
        if oldvalue ~= self.value and self.callback then self.callback(self) end
    end
end

function Slider:Draw()
    self.s:DrawBase(self,self.t,self.v.base,self:GetVariant(),self.s:GetState(self))
    if self.dir == "hor" then
        local offset = ((self.value - self.limit.min) / (self.limit.max-self.limit.min) * (self._ew-self.fill))
        self.s:DrawBase(self,self.tb:Offset({x=offset}),self.v.bulb,self:GetVariant(),self.s:GetState(self))
    else
        local offset = ((self.value - self.limit.min) / (self.limit.max-self.limit.min) * (self._eh-self.fill))
        self.s:DrawBase(self,self.tb:Offset({y=offset}),self.v.bulb,self:GetVariant(),self.s:GetState(self))
    end
end

function Slider:Scroll(sx,sy)
    self.value = self.value + (-sy * self.limit.scroll)
    self:Clamp()
    if self.callback then self.callback(self) end
end

---------------------------------------------------------------------

function Slider:Clamp()
    self.value = math.max(self.limit.min, math.min(self.value, self.limit.max))
    self.value = math.floor((self.value - self.limit.min) / self.limit.step + 0.5) * self.limit.step + self.limit.min
end

function Slider:GetValue()
    return self.value
end

return Slider