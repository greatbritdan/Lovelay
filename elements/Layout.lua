local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")

---------------------------------------------------------------------

local Layout = Class("Lovelay_Layout",Base)

function Layout:initialize(instance,transform,arguments)
    self.type = self.type or "Layout"

    self.ownchildren = true
    self.layoutat = {anchor="tl",direction="h"}
    self.layout = {}
    self.layoutoffset = {x=0,y=0,w=0,h=0}
    self.scrolly = 0

    Base.initialize(self,instance,transform,arguments)
end
function Layout:Modified()
    self:Calculate()
end

---------------------------------------------------------------------

function Layout:GetAllignments(anchor)
    local y,x = anchor:sub(1,1):lower(), anchor:sub(2,2):lower()
    local ax,ay = "",""
    if x == "l" then ax = "left" end
    if x == "m" then ax = "middle" end
    if x == "r" then ax = "right" end
    if y == "t" then ay = "top" end
    if y == "c" then ay = "center" end
    if y == "b" then ay = "bottom" end
    return ax,ay
end

function Layout:Calculate(onlyoffset)
    if onlyoffset then
        Utils.ForEach(self.children, function(child)
            if child._layout then
                child.t.x, child.t.y = self.t.x+child._layout.x, self.t.y+child._layout.y+self.scrolly
                child:BaseModified(nil,true)
            end
        end)
        return
    end
    for anchorid,_ in pairs(self.layout) do
        self:CalculatePosition(anchorid)
    end
end
function Layout:CalculatePosition(anchorid)
    local fullwidth, fullheight = 0, 0
    local widths, heights = {}, {}
    for _,row in pairs(self.layout[anchorid]) do
        local totalwidth, maxheight = 0, 0
        for _,col in pairs(row) do
            local w, h = col.t.w, col.t.h
            totalwidth = totalwidth + w + self.paddingx
            maxheight = math.max(maxheight, h)
        end
        fullwidth = math.max(fullwidth, totalwidth - self.paddingx)
        fullheight = fullheight + maxheight + self.paddingy
        table.insert(widths, totalwidth - self.paddingx)
        table.insert(heights, maxheight)
    end
    fullheight = fullheight - self.paddingy

    local anchorhor,anchorver = self:GetAllignments(anchorid)
    local x = self.s:GetAllignX(self.layoutoffset.x,fullwidth, self.t.w+self.layoutoffset.w,anchorhor,self.marginx)
    local y = self.s:GetAllignY(self.layoutoffset.y,fullheight,self.t.h+self.layoutoffset.h,anchorver,self.marginy)

    for rowi,row in pairs(self.layout[anchorid]) do
        local startx = x
        for _,col in pairs(row) do
            local w, h = col.t.w, col.t.h
            local cw, ch = widths[rowi], heights[rowi]
            local cx = self.s:GetAllignX(x,cw,fullwidth,anchorhor,0)
            local cy = self.s:GetAllignY(y,h,ch,anchorver,0)
            col._layout = {x=cx, y=cy}
            col.t.x, col.t.y = self.t.x+cx, self.t.y+cy+self.scrolly
            col:BaseModified(nil,true)
            x = x + w +  self.paddingx
        end
        y = y + heights[rowi] + self.paddingy
        x = startx
    end
    return {fullwidth, fullheight}
end

---------------------------------------------------------------------

function Layout:Add(element)
    if not element then
        error("Lovelay.Base: Cannot add element, type is missing or nil")
    end
    if element.type == "Panel" then
        error("Lovelay.Base: Cannot add Panel inside other elements, Add to group instead")
    end

    if not self.layout[self.layoutat.anchor] then
        self.layout[self.layoutat.anchor] = {{}}
    end
    local length = #self.layout[self.layoutat.anchor]
    if #self.layout[self.layoutat.anchor][length] > 0 and self.layoutat.direction == "v" then
        table.insert(self.layout[self.layoutat.anchor], {})
        length = length + 1
    end
    table.insert(self.layout[self.layoutat.anchor][length],element)
    table.insert(self.children,element); element.parent = self
    if element.Added then element:Added("parent") end
    if self.g then element.g = self.g end
    return self
end
function Layout:End() self:Calculate(); return self end

function Layout:TopLeft() self.layoutat.anchor = "tl"; return self end
function Layout:TopMiddle() self.layoutat.anchor = "tm"; return self end
function Layout:TopRight() self.layoutat.anchor = "tr"; return self end
function Layout:CenterLeft() self.layoutat.anchor = "cl"; return self end
function Layout:CenterMiddle() self.layoutat.anchor = "cm"; return self end
function Layout:CenterRight() self.layoutat.anchor = "cr"; return self end
function Layout:BottomLeft() self.layoutat.anchor = "bl"; return self end
function Layout:BottomMiddle() self.layoutat.anchor = "bm"; return self end
function Layout:BottomRight() self.layoutat.anchor = "br"; return self end

function Layout:Horizontal() self.layoutat.direction = "h"; return self end
function Layout:Vertical() self.layoutat.direction = "v"; return self end

return Layout