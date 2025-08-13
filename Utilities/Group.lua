local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")

---------------------------------------------------------------------

local Group = Class("Lovelay_Group")

function Group:initialize()
    self.elements = {}
    self.active = true
end

function Group:Update(dt)
    if not self.active then return end
    Utils.ForEach(self.elements,function(element) element:BaseUpdate(dt) end,true)
end

function Group:Draw(debug)
    if not self.active then return end
    Utils.ForEach(self.elements,function(element) element:BaseDraw() end)
    if debug then
        Utils.ForEach(self.elements,function(element) element:DebugDraw() end)
    end
end

function Group:Mousepressed()
    if not self.active then return end
    Utils.ForEach(self.elements,function(element) element:Mousepressed() end,true)
end
function Group:Mousereleased()
    if not self.active then return end
    Utils.ForEach(self.elements,function(element) element:Mousereleased() end,true)
end
function Group:Wheelmoved(sx,sy)
    if not self.active then return end
    Utils.ForEach(self.elements,function(element) element:Wheelmoved(sx,sy) end,true)
end

function Group:Keypressed(key)
    if not self.active then return end
    Utils.ForEach(self.elements,function(element) element:Keypressed(key) end,true)
end
function Group:Textinput(text)
    if not self.active then return end
    Utils.ForEach(self.elements,function(element) element:Textinput(text) end,true)
end

--- Elements --------------------------------------------------------

function Group:Add(element)
    if element.g then
        element.g:Remove(element)
    end
    table.insert(self.elements, element); element.g = self
    return self
end
function Group:Remove(element)
    local idx = Utils.TableContains(self.elements, element)
    if idx then
        table.remove(self.elements, idx); element.g = nil
    end
end

function Group:PopAndPush(element)
    local idx = Utils.TableContains(self.elements, element)
    if idx then
        table.remove(self.elements, idx)
        table.insert(self.elements, element)
    end
end

--- Other -----------------------------------------------------------

function Group:Enable() self.active = true; return self end
function Group:Disable() self.active = false; return self end

return Group