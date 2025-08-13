local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")
local Transform = require(_LOVELAY_REQUIRE_PATH..".Utilities.Transform")

---------------------------------------------------------------------

local Base = Class("Lovelay_Base")

function Base:initialize(instance,transform,arguments)
    self.i = instance
    self.t = Transform:new(transform)
    self.a = arguments or {}
    self.s = self.i.currentstyle; self:UpdateStyle()
    self.v = {}
    self.variant = nil

    self.scissor = {x=self.marginx, y=self.marginy, w=-(self.marginx*2), h=-(self.marginy*2), includeself=false}

    self.type = self.type or "Base" -- Don't override existing type
    self.cosmetic = false
    if self.type == "Label" or self.type == "InputLabel" or self.type == "Image" or self.type == "Layout" or self.type == "Panel" then
        self.cosmetic = true
    end
    self.tag = self.a.tag or nil

    self.active = true
    self.visible = true
    self.children = {}
    self.childbeforeparent = false

    if self.Setup then self:Setup() end
    self:BaseModified(true)
end
function Base:UpdateStyle()
    self.marginx = self.a.marginx or self.a.margin or self.s:Get(self,"marginx","margin",0)
    self.marginy = self.a.marginy or self.a.margin or self.s:Get(self,"marginy","margin",0)
    self.paddingx = self.a.paddingx or self.a.padding or self.s:Get(self,"paddingx","padding",0)
    self.paddingy = self.a.paddingy or self.a.padding or self.s:Get(self,"paddingy","padding",0)
    self.allignx = self.newallignx or self.a.allignx or self.s:Get(self,"allignx",nil,"left")
    self.alligny = self.newalligny or self.a.alligny or self.s:Get(self,"alligny",nil,"top")
    self.font = self.s:Get(self,"font",nil,love.graphics.getFont())
end
function Base:BaseModified(onload,dontmodify)
    if not onload then self:UpdateStyle() end
    if self.Modified and (not dontmodify) then self:Modified() end
    if not self.ownchildren then
        Utils.ForEach(self.children, function(child) child.t:Update(self.t); child:BaseModified(nil,dontmodify) end,true)
    end
end

function Base:BaseUpdate(dt,hoverparent)
    local mx,my = Utils:GetMouse()
    if self:IsActive() then
        self.hover = false
        Utils.ForEach(self.children, function(child) if child.childbeforeparent then child:BaseUpdate(dt,self:InsideElement(mx,my)) end end,true)
        if (not self:IsCosmetic()) and ((not self.parent) or (self.parent and hoverparent)) then
            if (not self.i.hover) and self:InsideInteraction(mx,my) then
                self.i:SetHover(self)
                self.hover = self:InsideElement(mx,my)
            end
        end
        if self.Update then self:Update(dt) end
        Utils.ForEach(self.children, function(child) if not child.childbeforeparent then child:BaseUpdate(dt,self:InsideElement(mx,my)) end end,true)
    end
    if (not self.i.hover) and self:InsideElement(mx,my) then
        self.i:SetHover({})
    end
end

function Base:BaseDraw()
    if not self:IsVisible() then return end
    if self.PreDraw then self:PreDraw() end
    if self.scissor.includeself then
        Utils.ScissorPush((self.t.x+self.scissor.x)*_LOVELAY_SETTINGS.scale,(self.t.y+self.scissor.y)*_LOVELAY_SETTINGS.scale,(self.t.w+self.scissor.w)*_LOVELAY_SETTINGS.scale,(self.t.h+self.scissor.h)*_LOVELAY_SETTINGS.scale)
    end
    if self.Draw then self:Draw() end
    Utils.ForEach(self.children, function(child) if child.childbeforeparent then child:BaseDraw() end end)
    if not self.scissor.includeself then
        Utils.ScissorPush((self.t.x+self.scissor.x)*_LOVELAY_SETTINGS.scale,(self.t.y+self.scissor.y)*_LOVELAY_SETTINGS.scale,(self.t.w+self.scissor.w)*_LOVELAY_SETTINGS.scale,(self.t.h+self.scissor.h)*_LOVELAY_SETTINGS.scale)
    end
    Utils.ForEach(self.children, function(child) if not child.childbeforeparent then child:BaseDraw() end end)
    Utils.ScissorPop()
    if self.PostDraw then self:PostDraw() end
end

local debugprint = function(self)
    if #self.children > 0 then
        return tostring(#self.children)
    end
    return ""
end
function Base:DebugDraw()
    if not self:IsVisible() then return end
    love.graphics.setColor(1,0,0,0.5)
    love.graphics.rectangle("line", self.t.x, self.t.y, self.t.w, self.t.h)
    love.graphics.setColor(1,1,0,0.125)
    love.graphics.rectangle("line", self.t.x+self.marginx, self.t.y+self.marginy, self.t.w-(self.marginx*2), self.t.h-(self.marginy*2))
    if self.GetBounds then
        local x,y,w,h = self:GetBounds()
        love.graphics.setColor(0,1,0,0.5)
        love.graphics.rectangle("line", x, y, w, h)
    end
    love.graphics.setColor(1,1,1,0.5)
    love.graphics.print(debugprint(self), self.t.x, self.t.y)
    Utils.ForEach(self.children, function(child) child:DebugDraw() end)
end

function Base:Mousepressed()
    if not self:IsActive() then return end
    if self.hover then
        self.click = true
        if (not self:IsCosmetic()) and (not self.i.focus) then self.i:SetFocus(self) end
        if self.Click then self:Click() end
    end
    Utils.ForEach(self.children, function(child) child:Mousepressed() end,true)
end
function Base:Mousereleased()
    if not self:IsActive() then return end
    if self.hover and self.click and self.Release then
        self:Release()
    end
    self.click = false
    Utils.ForEach(self.children, function(child) child:Mousereleased() end,true)
end
function Base:Wheelmoved(sx,sy)
    if not self:IsActive() then return end
    local mx,my = Utils:GetMouse()
    if ((self.panelscroll and self:InsideElement(mx,my)) or self.hover) and self.Scroll then
        self:Scroll(sx,sy)
    end
    Utils.ForEach(self.children, function(child) child:Wheelmoved(sx,sy) end,true)
end

function Base:Keypressed(key)
    if not self:IsActive() then return end
    if self._focus and self.Input then
        self:Input(key)
    end
    Utils.ForEach(self.children, function(child) child:Keypressed(key) end,true)
end
function Base:Textinput(text)
    if not self:IsActive() then return end
    if self._focus and self.InputText then
        self:InputText(text)
    end
    Utils.ForEach(self.children, function(child) child:Textinput(text) end,true)
end

---------------------------------------------------------------------

function Base:BaseAdd(element)
    table.insert(self.children, element); element.parent = self
    self:BaseModified()
    return self
end
function Base:Add(element) -- Can be overridden, but always keep BaseAdd available
    self:BaseAdd(element)
    return self
end
function Base:Remove(element)
    local idx = Utils.TableContains(self.children,element)
    if idx then
        table.remove(self.children, idx); element.parent = nil
        table.insert(self.children, idx, {_IGNORE=true}) -- Empty list to avoid issues
        self:BaseModified()
    end
end
function Base:Clear(delete)
    for idx = #self.children, 1, -1 do
        local child = self.children[idx]
        table.remove(self.children, idx); child.parent = nil
        table.insert(self.children, idx, {_IGNORE=true}) -- Empty list to avoid issues
        if delete then child:Delete() end
    end
    self:BaseModified()
end

function Base:InsideElement(x,y)
    return self.t:PointInside(x,y)
end
function Base:InsideInteraction(x,y)
    return self:InsideElement(x,y)
end

function Base:GetValue() return nil end

---------------------------------------------------------------------

function Base:Left() self.allignx = "left"; self.newallignx = self.allignx; return self end
function Base:Right() self.allignx = "right"; self.newallignx = self.allignx; return self end
function Base:Middle() self.allignx = "middle"; self.newallignx = self.allignx; return self end

function Base:Top() self.alligny = "top"; self.newalligny = self.alligny; return self end
function Base:Bottom() self.alligny = "bottom"; self.newalligny = self.alligny; return self end
function Base:Center() self.alligny = "center"; self.newalligny = self.alligny; return self end

function Base:SetVariant(variant) self.variant = variant; return self end
function Base:GetVariant()
    if not self.variant then return 1 end
    return self.variant
end

function Base:SetCallback(callback)
    if type(callback) == "function" then
        self.callback = callback
    else
        error("Lovelay.Base: Callback must be a function, received "..type(callback))
    end
    return self
end

function Base:Enable() self.active = true; return self end
function Base:Disable() self.active = false; return self end
function Base:IsActive(forchild)
    if self.parent and (not self.childbeforeparent) then
        return self.parent:IsActive(true)
    end
    if forchild and self.childactive ~= nil then
        return self.childactive
    end
    return self.active
end

function Base:Show() self.visible = true; return self end
function Base:Hide() self.visible = false; return self end
function Base:IsVisible(forchild)
    if self.parent and (not self.childbeforeparent) then
        return self.parent:IsVisible(true)
    end
    if forchild and self.childvisible ~= nil then
        return self.childvisible
    end
    return self.visible
end

function Base:IsCosmetic()
    return self.cosmetic
end

function Base:Link(tag)
    self.linkedtag = tag
    self.linked = self.i:FindFirst({tag=tag})
    return self
end

function Base:Delete()
    self._deleted = true
    if self.parent then
        self.parent:Remove(self)
    end
    if self.children then
        self:Clear(true)
    end
    if self.g then
        self.g:Remove(self)
    end
    self.i:Remove(self)
end

return Base