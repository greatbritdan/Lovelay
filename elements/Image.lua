local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")

---------------------------------------------------------------------

local Image = Class("Lovelay_Image",Base)

function Image:initialize(instance,transform,arguments)
    self.type = "Image"
    Base.initialize(self,instance,transform,arguments)
    self.scissor.includeself = true
end
function Image:Setup()
    self.image = self.a.image or self.a[1] or "no image"
    self.quad = self.a.quad or self.a[2] or nil
end
function Image:Modified()
    self.v.image = self.s:CreateStyle(self,self.t,{"image"})
end

function Image:Draw()
    self.s:DrawImage(self,self.t,self.v.image,self:GetVariant(),self.s:GetState(self),self.image,self.quad)
end

function Image:GetBounds()
    return self.s:GetSizeImage(self,self.t,self.image,self.quad)
end

return Image