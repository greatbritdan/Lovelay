local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")

---------------------------------------------------------------------

local Cycle = Class("Lovelay_Cycle",Base)

function Cycle:initialize(instance,transform,arguments)
    self.type = "Cycle"
    Base.initialize(self,instance,transform,arguments)
end
function Cycle:Setup()
    self.value = self.a.value or 1
    self.values = self.a.values or {"no values"}
    self.displayvalues = self.a.displayvalues or nil
end
function Cycle:Modified()
    self.v.base = self.s:CreateStyle(self,self.t,{"base"})
end

function Cycle:Draw()
    self.s:DrawBase(self,self.t,self.v.base,self:GetVariant(),self.s:GetState(self))
end

function Cycle:Release()
    self:Cycle(1)
    if self.callback then self.callback(self) end
end

---------------------------------------------------------------------

function Cycle:Cycle(dir)
    self.value = self.value + dir
    if self.value > #self.values then
        self.value = 1
    elseif self.value < 1 then
        self.value = #self.values
    end
end

function Cycle:GetValue(idx,display)
    if idx then return self.value end
    if display and self.displayvalues then return self.displayvalues[self.value] end
    return self.values[self.value]
end

return Cycle