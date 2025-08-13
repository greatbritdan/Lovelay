local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")

---------------------------------------------------------------------

local InputLabel = Class("Lovelay_InputLabel",Base)

function InputLabel:initialize(instance,transform,arguments)
    self.type = "InputLabel"
    Base.initialize(self,instance,transform,arguments)
    self.scissor.includeself = true
end
function InputLabel:Setup()
    self.text = ""
end
function InputLabel:Modified()
    self.v.text = self.s:CreateStyle(self,self.t,{"text"})
    self.v.place = self.s:CreateStyle(self,self.t,{"placeholder","text"})

    local _,_,w,_ = self.s:GetSizeText(self,self.t,self.text)
    self.autoscroll = Utils.SetAutoscroll(w,(self.t.w-(self.marginx*2)))
end

function InputLabel:Update(dt)
    local oldtext = self.text
    if (not self.parent._focus) and self.parent.value == "" then
        self.text = self.parent.placeholder
    else
        self.text = self.parent.value
    end
    if oldtext ~= self.text then
        self:Modified()
    end
    self.scrollx = Utils.UpdateAutoscroll(self.autoscroll,dt)
end

function InputLabel:Draw()
    self.allignx = self.parent._focus and "left" or self.parent.allignx
    local scrollx = self.scrollx
    if self.parent._focus then
        scrollx = math.max(0, self.s:GetWidthText(self,self.text:sub(1,self.parent.cursor))-((self.t.w-(self.marginx*2))*0.75))
    end

    if (not self.parent._focus) and self.parent.value == "" then
        self.s:DrawText(self,self.t:Offset({x=-scrollx}),self.v.place,self:GetVariant(),self.s:GetState(self),self.text)
    else
        self.s:DrawText(self,self.t:Offset({x=-scrollx}),self.v.text,self:GetVariant(),self.s:GetState(self),self.text)
    end
    if self.parent._focus and self.parent.cursorblink < 0.5 then
        local x,y,_,h = self.s:GetSizeText(self,self.t,self.text)
        local offset = self.s:GetWidthText(self,self.text:sub(1,self.parent.cursor))
        love.graphics.rectangle("fill",x+offset-scrollx,y,2,h)
    end
end

function InputLabel:GetBounds()
    return self.s:GetSizeText(self,self.t,self.text)
end

return InputLabel