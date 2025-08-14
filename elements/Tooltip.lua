local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")

---------------------------------------------------------------------

local Tooltip = Class("Lovelay_Tooltip",Base)

function Tooltip:initialize(instance,transform,arguments)
    self.type = "Tooltip"
    Base.initialize(self,instance,transform,arguments)
end
function Tooltip:Setup()
    self.text = ""
    self.queuetext = nil
    self.timer = false
    self.opacity = 0
end
function Tooltip:Modified()
    local _,_,w,h = self:GetBounds()
    self.t.w, self.t.h = w+(self.marginx*2), h+(self.marginy*2)
    self.v.base = self.s:CreateStyle(self,self.t,{"base"})
    self.v.text = self.s:CreateStyle(self,self.t,{"text"})
end

function Tooltip:Update(dt)
    if self.timer then
        self.timer = self.timer + (2*dt)
        if self.timer > 1 then
            if self.queuetext then
                self.text = self.queuetext
                self.queuetext = nil
                self:BaseModified()
            end
            self.opacity = math.max(0, math.min(self.timer-1, 1))
        end
    end
    if ((not self.timer) or self.queuetext) and self.opacity > 0 then
        self.opacity = self.opacity - (2*dt)
        if self.opacity < 0 then self.opacity = 0 end
    end

    if self.opacity > 0 then
        self.t.x, self.t.y = Utils.GetMouse()
    end
end

function Tooltip:Draw()
    if self.opacity > 0 then
        self.s:DrawBase(self,self.t,self.v.base,self:GetVariant(),self.s:GetState(self),self.opacity)
        self.s:DrawText(self,self.t,self.v.text,self:GetVariant(),self.s:GetState(self),self.text,self.opacity)
    end
end

function Tooltip:GetBounds()
    return self.s:GetSizeText(self,self.t,self.text)
end

return Tooltip