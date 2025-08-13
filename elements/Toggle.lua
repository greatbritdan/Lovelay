local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")
local Transform = require(_LOVELAY_REQUIRE_PATH..".Utilities.Transform")

---------------------------------------------------------------------

local Toggle = Class("Lovelay_Toggle",Base)

function Toggle:initialize(instance,transform,arguments)
    self.type = "Toggle"
    Base.initialize(self,instance,transform,arguments)
end
function Toggle:Setup()
    self.value = self.a.value or false
end
function Toggle:Modified()
    local w,h = (self.t.w-(self.marginx*2))/2, self.t.h-(self.marginy*2)
    if self.a.square then w = h end
    self.bulbwidth, self.bulbheight = w, h
    self.bulbgap = (self.t.w-self.marginx-self.bulbwidth) - self.marginx

    self.tb = Transform:new({self.t.x+self.marginx, self.t.y+self.marginy, self.bulbwidth, self.bulbheight})

    self.v.baseoff = self.s:CreateStyle(self,self.t,{"baseoff","base"})
    self.v.bulboff = self.s:CreateStyle(self,self.tb,{"bulboff","bulb","base"})
    self.v.baseon = self.s:CreateStyle(self,self.t,{"baseon","base"})
    self.v.bulbon = self.s:CreateStyle(self,self.tb,{"bulbon","bulb","baseon","base"})
end

function Toggle:Draw()
    if self.value then
        self.s:DrawBase(self,self.t,self.v.baseon,self:GetVariant(),self.s:GetState(self))
        self.s:DrawBase(self,self.tb:Offset({x=self.bulbgap}),self.v.bulbon,self:GetVariant(),self.s:GetState(self))
    else
        self.s:DrawBase(self,self.t,self.v.baseoff,self:GetVariant(),self.s:GetState(self))
        self.s:DrawBase(self,self.tb,self.v.bulboff,self:GetVariant(),self.s:GetState(self))
    end
end

function Toggle:Release()
    self.value = not self.value
    if self.callback then self.callback(self) end
end

---------------------------------------------------------------------

function Toggle:GetValue()
    return self.value
end

return Toggle