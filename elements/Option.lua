local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Base = require(_LOVELAY_REQUIRE_PATH..".elements.Base")

---------------------------------------------------------------------

local Option = Class("Lovelay_Option",Base)

function Option:initialize(instance,transform,arguments)
    self.type = "Option"
    Base.initialize(self,instance,transform,arguments)
end
function Option:Setup()
    self.optiongroup = self.a.group or "default"
    self.optionvalue = self.a.value or nil
    if self.a.default then
        self.optiondefault = true
    end
end
function Option:Modified()
    self.v.base = self.s:CreateStyle(self,self.t,{"base"})
end
function Option:Added()
    if self.optiondefault then
        self:SetValue()
    end
end

function Option:Draw()
    local state = self.s:GetState(self)
    if self.optionvalue == self:GetValue() then state = 3 end
    self.s:DrawBase(self,self.t,self.v.base,self:GetVariant(),state)
end

function Option:Release()
    self:SetValue()
    if self.callback then self.callback(self) end
end

function Option:SetValue()
    if self.parent then
        if not self.parent.optiongroups then
            self.parent.optiongroups = {}
        end
        self.parent.optiongroups[self.optiongroup] = self.optionvalue
    elseif self.g then
        if not self.g.optiongroups then
            self.g.optiongroups = {}
        end
        self.g.optiongroups[self.optiongroup] = self.optionvalue
    end
end

function Option:GetValue()
    if self.parent and self.parent.optiongroups then
        return self.parent.optiongroups[self.optiongroup]
    elseif self.g and self.g.optiongroups then
        return self.g.optiongroups[self.optiongroup]
    end
    return nil
end

return Option