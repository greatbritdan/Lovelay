local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")

---------------------------------------------------------------------

local Button = Class("Lovelay_Button",Base)

function Button:initialize(instance,transform,arguments)
    self.type = "Button"
    Base.initialize(self,instance,transform,arguments)
end
function Button:Modified()
    self.v.base = self.s:CreateStyle(self,self.t,{"base"})
end

function Button:Draw()
    self.s:DrawBase(self,self.t,self.v.base,self:GetVariant(),self.s:GetState(self))
end

function Button:Release()
    if self.callback then self.callback(self) end
end

return Button