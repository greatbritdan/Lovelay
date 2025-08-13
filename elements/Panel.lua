local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")
local Transform = require(_LOVELAY_REQUIRE_PATH..".Utilities.Transform")
local Layout = require(_LOVELAY_REQUIRE_PATH..".elements.Layout")

---------------------------------------------------------------------

local Panel = Class("Lovelay_Panel",Layout)

function Panel:initialize(instance,transform,arguments)
    self.type = "Panel"
    self.panelscroll = true
    Layout.initialize(self,instance,transform,arguments)
end
function Panel:Setup()
    self.moving = false
    self.collapsed = false
end
function Panel:Modified()
    self.v.base = self.s:CreateStyle(self,self.t,{"basepanel","base"})
    self:Calculate()
end

function Panel:Update(dt)
    if self.scroll and self.scroll.opacity > 0 then
        self.scroll.opacity = self.scroll.opacity - (dt*2)
        if self.scroll.opacity <= 0 then self.scroll.opacity = 0 end
    end
    if self.titlebar and self.moveable then
        local mx, my = Utils.GetMouse()
        if self.titlebar.click and (not self.moving) then
            self.moving = {x=mx-self.t.x, y=my-self.t.y}
        elseif self.titlebar.click and self.moving then
            self.t.x, self.t.y = mx-self.moving.x, my-self.moving.y
            if self.titlebar then
                self.titlebar.t.x, self.titlebar.t.y = self.t.x, self.t.y; self.titlebar:BaseModified()
                local x = self.t.x+self.titlebar.t.w
                for i,b in ipairs(self.titlebarbuttons) do
                    b.t.x, b.t.y = x, self.t.y; b:BaseModified()
                    x = x + b.t.w
                end
            end
            if self.scroll then
                local effh = self.t.y
                if self.titlebar then effh = effh + self.titlebar.t.h end
                self.scroll.x, self.scroll.y = self.t.x+self.t.w-self.scroll.w, effh
            end
            self:Calculate(true)
        elseif self.moving then
            self.moving = false
        end
    end
end

function Panel:Draw()
    if self.collapsed then return end
    self.s:DrawBase(self,self.t,self.v.base,self:GetVariant(),self.s:GetState(self,"focus"))
end
function Panel:PostDraw()
    if self.scroll and self.scroll.opacity > 0 then
        local offset = self.scroll.gap*(self.scroll.pos/self.scroll.maxpos)
        local transform = Transform:new({self.scroll.x, self.scroll.y+offset, self.scroll.w, self.scroll.h})
        self.s:DrawBase(self,transform,self.v.bulb,self:GetVariant(),self.s:GetState(self,"base"),self.scroll.opacity)
    end
end

function Panel:Scroll(sx,sy)
    if self.scroll and (not self.collapsed) then
        self.scroll.pos = self.scroll.pos - (-sy*self.scroll.step)
        self.scroll.pos = math.min(0,math.max(self.scroll.pos,self.scroll.maxpos))
        self.scrolly = self.scroll.pos
        self.scroll.opacity = 1.25
        self:Calculate(true)
    end
end

function Panel:Collapse()
    self.collapsed = not self.collapsed
    if self.collapsed then
        self.childactive, self.childvisible = false, false
        self.oldh = self.t.h
        self.t.h = self.titlebar and self.titlebar.t.h or _LOVELAY_SETTINGS.unit
    else
        self.childactive, self.childvisible = true, true
        self.t.h = self.oldh
    end
end

---------------------------------------------------------------------

function Panel:AddTitlebar(bar,height,moveable)
    if (not bar) or (not bar.type) or (bar.type ~= "Button") then
        error("Lovelay.Panel: Titlebar must be a Button element")
    end
    height = height or _LOVELAY_SETTINGS.unit
    self.moveable = true
    if moveable ~= nil then self.moveable = moveable end

    self.titlebar = bar
    self.titlebar.t = Transform:new({self.t.x, self.t.y, self.t.w, height}); bar:BaseModified()
    self.titlebar.childbeforeparent = true
    if not bar.variant then
        bar:SetVariant(self.variant)
    end
    self.titlebarbuttons = {}

    self:BaseAdd(self.titlebar)
    self.layoutoffset.y, self.layoutoffset.h = height, -height
    self.scissor.y, self.scissor.h = self.scissor.y + height, self.scissor.h - height
    return self
end

function Panel:AddTitlebarButton(button,width)
    if not self.titlebar then
        error("Lovelay.Panel: No titlebar found, cannot add titlebar button")
    end
    if (not button) or (not button.type) or (button.type ~= "Button") then
        error("Lovelay.Panel: Titlebar button must be a Button element")
    end
    width = width or self.titlebar.t.h

    self.titlebar.t.w = self.titlebar.t.w - width; self.titlebar:BaseModified()
    for _,b in ipairs(self.titlebarbuttons) do
        b.t.x = b.t.x - width; b:BaseModified()
    end

    button.t = Transform:new({self.t.x+self.t.w-width, self.t.y, width, self.titlebar.t.h}); button:BaseModified()
    button.childbeforeparent = true
    if not button.variant then -- only overwrite if not set
        button:SetVariant(self.variant)
    end
    self:BaseAdd(button)
    table.insert(self.titlebarbuttons, button)
    return self
end

function Panel:AddScroll(barwidth,fullheight,step)
    local effh, starty = self.t.h, self.t.y
    if self.titlebar then effh, starty = effh-self.titlebar.t.h, starty+self.titlebar.t.h end

    fullheight = fullheight or effh*2
    barwidth = barwidth or _LOVELAY_SETTINGS.unit
    step = step or _LOVELAY_SETTINGS.unit
    local barheight = effh * (effh/fullheight)

    self.scroll = {x=self.t.x+self.t.w-barwidth, y=starty, w=barwidth, h=barheight, gap=(effh-barheight), step=step, pos=0, maxpos=(effh-fullheight), opacity=0}
    self.layoutoffset.h = fullheight-self.t.h

    self.v.bulb = self.s:CreateStyle(self,self.scroll,{"scroll","text"})
    return self
end

return Panel