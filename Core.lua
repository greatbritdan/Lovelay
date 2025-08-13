local Style = require(_LOVELAY_REQUIRE_PATH..".Utilities.Style")
local Group = require(_LOVELAY_REQUIRE_PATH..".Utilities.Group")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")

local Base =   require(_LOVELAY_REQUIRE_PATH..".elements.Base")
local Button = require(_LOVELAY_REQUIRE_PATH..".elements.Button")
local Label =  require(_LOVELAY_REQUIRE_PATH..".elements.Label")
local Image =  require(_LOVELAY_REQUIRE_PATH..".elements.Image")
local Cycle =  require(_LOVELAY_REQUIRE_PATH..".elements.Cycle")
local Toggle = require(_LOVELAY_REQUIRE_PATH..".elements.Toggle")
local Slider = require(_LOVELAY_REQUIRE_PATH..".elements.Slider")
local Input =  require(_LOVELAY_REQUIRE_PATH..".elements.Input")
local Layout = require(_LOVELAY_REQUIRE_PATH..".elements.Layout")
local Panel =  require(_LOVELAY_REQUIRE_PATH..".elements.Panel")

local InputLabel = require(_LOVELAY_REQUIRE_PATH..".elements.InputLabel")

----------------------------------------------------------------

local Core = {}

function Core:initialize()
    self.instances = {}
    self.styles = {}
    self.groups = {}

    self.currentstyle = nil
end

function Core:Update(dt)
    self:ResetHover()
    Utils.ForEach(self.groups,function(group) group:Update(dt) end,true)
end

function Core:Draw(debug)
    local oldfont, oldcolor = love.graphics.getFont(), {love.graphics.getColor()}
    love.graphics.push()
    love.graphics.scale(_LOVELAY_SETTINGS.scale)

    Utils.ForEach(self.groups,function(group) group:Draw(debug) end)

    love.graphics.pop()
    love.graphics.setFont(oldfont)
    love.graphics.setColor(oldcolor)
end

function Core:Mousepressed(_,_,b)
    if b ~= 1 then return end
    self:ResetFocus()
    Utils.ForEach(self.groups,function(group) group:Mousepressed() end,true)
end
function Core:Mousereleased(_,_,b)
    if b ~= 1 then return end
    Utils.ForEach(self.groups,function(group) group:Mousereleased() end,true)
end
function Core:Wheelmoved(sx,sy)
    Utils.ForEach(self.groups,function(group) group:Wheelmoved(sx,sy) end,true)
end

function Core:Keypressed(key)
    Utils.ForEach(self.groups,function(group) group:Keypressed(key) end,true)
end
function Core:Textinput(text)
    Utils.ForEach(self.groups,function(group) group:Textinput(text) end,true)
end

--- Settings ---------------------------------------------------

function Core:SetUnit(unit)
    if not unit then unit = 16 end
    _LOVELAY_SETTINGS.unit = unit
    return _LOVELAY_SETTINGS.unit
end
function Core:SetScale(scale)
    if not scale then scale = 1 end
    _LOVELAY_SETTINGS.scale = scale
    return _LOVELAY_SETTINGS.scale
end

--- Hover & Focus ----------------------------------------------

function Core:ResetHover()
    if self.hover then self.hover._hover = nil end
    self.hover = nil
end
function Core:SetHover(element)
    self.hover = element; element._hover = true
end

function Core:ResetFocus()
    if self.focus then
        if self.focus.Unfocus then self.focus:Unfocus() end
        self.focus._focus = nil
    end
    self.focus = nil
end
function Core:SetFocus(element)
    if element.Focus then element:Focus() end
    self.focus = element; element._focus = true
end

--- Style ------------------------------------------------------

function Core:NewStyle(path,key,setstyle)
    local style = Style:new(path)
    self.styles[key] = style
    if setstyle then
        self:SetStyle(key)
    end
    return style
end
function Core:SetStyle(key)
    local style = self.styles[key]
    if not style then
        error("Lovelay.Core: Style with key '"..key.."' does not exist, use Core:NewStyle(<path>,<key>) to create a new style.")
    end
    self.currentstyle = style
end

--- Group ------------------------------------------------------

function Core:Group()
    local group = Group:new()
    table.insert(self.groups, group)
    return group
end

--- Elements --------------------------------------------------- 

local types = {base=Base, button=Button, label=Label, image=Image, cycle=Cycle, toggle=Toggle, slider=Slider, input=Input, inputlabel=InputLabel, layout=Layout, panel=Panel}
function Core:Element(type,transform,arguments)
    if not self.currentstyle then
        error("Lovelay.Core: No style set, use Core:SetStyle(<key>) to set a style before creating elements.")
    end
    local element = types[type]:new(self,transform,arguments)
    table.insert(self.instances, element)
    return element
end

function Core:Base(transform,arguments)   return self:Element("base",transform,arguments)   end
function Core:Button(transform,arguments) return self:Element("button",transform,arguments) end
function Core:Label(transform,arguments)  return self:Element("label",transform,arguments)  end
function Core:Image(transform,arguments)  return self:Element("image",transform,arguments)  end
function Core:Cycle(transform,arguments)  return self:Element("cycle",transform,arguments)  end
function Core:Toggle(transform,arguments) return self:Element("toggle",transform,arguments) end
function Core:Slider(transform,arguments) return self:Element("slider",transform,arguments) end
function Core:Input(transform,arguments)  return self:Element("input",transform,arguments)  end
function Core:Layout(transform,arguments) return self:Element("layout",transform,arguments) end
function Core:Panel(transform,arguments)  return self:Element("panel",transform,arguments) end

-- INTERNAL USE ONLY!
function Core:InputLabel(transform,arguments)  return self:Element("inputlabel",transform,arguments)  end

function Core:Remove(element)
    local idx = Utils.TableContains(self.instances, element)
    if not idx then return end
    table.remove(self.instances, idx)
    if self.hover == element then self:ResetHover() end
    if self.focus == element then self:ResetFocus() end
end

--- Query ----------------------------------------------------

function Core:QuerySingle(instance,key,value)
    local invert = false
    if key:sub(1,1) == "!" then invert = true; key = key:sub(2) end

    if key == "active" then
        return (instance:IsActive() == value) ~= invert
    elseif key == "visible" then
        return (instance:IsVisible() == value) ~= invert
    elseif key then
        local target = instance
        if key == "x" or key == "y" or key == "w" or key == "h" then
            target = instance.t -- Transform
        end
        if type(value) == "table" then
            return (Utils.TableContainsBoolean(value, target[key])) ~= invert
        else
            return (target[key] == value) ~= invert
        end
    end
end
function Core:Query(query)
    query = query or {}
    local isntances = {}
    Utils.ForEach(self.instances, function(instance)
        local pass = true
        for key,value in pairs(query) do
            if key == "_parent" then
                if not instance.parent then
                    pass = false; break
                end
                for pkey,pvalue in pairs(value) do
                    if not self:QuerySingle(instance.parent,pkey,pvalue) then
                        pass = false; break
                    end
                end
            elseif key == "_children" then
                if not instance.children or #instance.children == 0 then
                    pass = false; break
                end
                for ckey,cvalue in pairs(value) do
                    local found = false
                    Utils.ForEach(instance.children, function(child)
                        if self:QuerySingle(child,ckey,cvalue) then
                            found = true; return true -- break
                        end
                    end)
                    if not found then
                        pass = false; break
                    end
                end
            else
                if not self:QuerySingle(instance,key,value) then
                    pass = false; break
                end
            end
        end
        if pass then
            table.insert(isntances, instance)
        end
    end)
    return isntances
end

function Core:Find(query,findfirst)
    local elements = self:Query(query)
    if findfirst and #elements > 0 then
        return elements[1]
    end
    return elements
end
function Core:FindFirst(query)
    return self:Find(query,true)
end
function Core:Action(query,func)
    if not func then return end
    local elements = self:Query(query)
    Utils.ForEach(elements, function(element)
        func(element)
    end)
end

Core:initialize()
return Core