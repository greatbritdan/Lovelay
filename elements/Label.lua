local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")

---------------------------------------------------------------------

local Label = Class("Lovelay_Label",Base)

function Label:initialize(instance,transform,arguments)
    self.type = "Label"
    Base.initialize(self,instance,transform,arguments)
    self.scissor.includeself = true
end
function Label:Setup()
    self.text = self.a.text or self.a[1] or "no text"
end
function Label:Modified()
    self.v.text = self.s:CreateStyle(self,self.t,{"text"})

    local _,_,w,_ = self.s:GetSizeText(self,self.t,self.text)
    self.autoscroll = Utils.SetAutoscroll(w,(self.t.w-(self.marginx*2)))
end

function Label:Update(dt)
    if self.linked then
        local oldtext = self.text
        self.text = self.linked:GetValue(nil,true)
        if oldtext ~= self.text then
            self:Modified()
        end
    end
    self.scrollx = Utils.UpdateAutoscroll(self.autoscroll,dt)
end

function Label:Draw()
    self.s:DrawText(self,self.t:Offset({x=-self.scrollx}),self.v.text,self:GetVariant(),self.s:GetState(self),self.text)
end

function Label:GetBounds()
    local x,y,w,h = self.s:GetSizeText(self,self.t,self.text)
    return x-self.scrollx,y,w,h
end

return Label