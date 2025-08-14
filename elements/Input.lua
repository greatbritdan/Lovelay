local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")

---------------------------------------------------------------------

local Input = Class("Lovelay_Input",Base)

function Input:initialize(instance,transform,arguments)
    self.type = "Input"
    Base.initialize(self,instance,transform,arguments)
end
function Input:Setup()
    self.cursor, self.cursorblink = 0, 0

    self.value = self.a.value or ""
    self.placeholder = self.a.placeholder or "enter text..."
    self.limit = self.a.limit or {}
end
function Input:Modified()
    self.v.base = self.s:CreateStyle(self,self.t,{"base"})
    if not self.inputlabel then
        self.inputlabel = true -- Don't make another label
        self:Add(self.i:InputLabel(self.t:Copy(),{allignx=self.allignx}))
    end
end
function Input:Update(dt)
    self.cursorblink = (self.cursorblink + dt) % 1
end

function Input:Draw()
    self.s:DrawBase(self,self.t,self.v.base,self:GetVariant(),self.s:GetState(self))
end

function Input:Focus()
    self.cursor, self.cursorblink = #self.value, 0
    self.oldvalue = self.value
end
function Input:Unfocus()
    if self.validation and self.valid == false then
        self.value = self.oldvalue
        self:CheckValidation()
        return
    end
    if self.callback then self.callback(self) end
end

function Input:Input(key,text)
    local oldcursor, oldvalue = self.cursor, self.value

    if key == "return" then
        self.i:ResetFocus()
    elseif key == "home" then
        self.cursor = 0
    elseif key == "end" then
        self.cursor = #self.value
    elseif key == "right" then
        self.cursor = self.cursor + 1
    elseif key == "left" then
        self.cursor = self.cursor - 1
    elseif key == "backspace" then
        self.value = self.value:sub(1,self.cursor-1)..self.value:sub(self.cursor+1,#self.value)
        self.cursor = self.cursor - 1
    elseif text then
        if (not self.limit.chars) or self.limit.chars:find(text,1,true) then
            self.value = self.value:sub(1,self.cursor)..text..self.value:sub(self.cursor+1,#self.value)
            self.cursor = self.cursor + 1
        else
            return
        end
    end
    if self.cursor < 0 then self.cursor = 0 end
    if self.cursor > #self.value then self.cursor = #self.value end

    if self.limit.length and #self.value > self.limit.length then
        self.cursor, self.value = oldcursor, oldvalue
    elseif oldcursor ~= self.cursor then
        self.cursorblink = 0
        self:CheckValidation()
    end
end
function Input:InputText(text)
    self:Input(nil,text)
end

---------------------------------------------------------------------

function Input:GetValue(idx,display)
    if display and self.limit.password then
        local char = "*"
        if type(self.limit.password) == "string" then char = self.limit.password:sub(1,1) end
        return char:rep(#self.value)
    end
    return self.value
end

function Input:SetValidation(func)
    self.validation = func
    self:CheckValidation()
    return self
end
function Input:CheckValidation()
    if self.validation then
        self.valid = false
        if self.validation(self.value,self) then
            self.valid = true
        end
    end
end

return Input