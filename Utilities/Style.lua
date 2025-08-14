local Class = require(_LOVELAY_REQUIRE_PATH..".3rdparty.middleclass")
local Utils = require(_LOVELAY_REQUIRE_PATH..".Utilities.Utilities")

---------------------------------------------------------------------

local Style = Class("Lovelay_Style")

function Style:initialize(path)
    local success, dataorerror = pcall(function() return love.filesystem.load(path) end)
    if not success then
        error("Failed to load style file '"..path.."': "..dataorerror)
    end
    self.style = dataorerror()
end

function Style:Get(element,key,subkey,default)
    local typ = (element.parent and element:IsCosmetic()) and element.parent.type:lower() or element.type:lower()
    local elementtable = self.style[typ]
    local basetable = self.style.base
    if key == "_style" then
        if elementtable and elementtable.styles and elementtable.styles[subkey] then return elementtable.styles[subkey] end
        if basetable and basetable.styles and basetable.styles[subkey] then return basetable.styles[subkey] end
    else
        if elementtable and elementtable[key] then return elementtable[key] end
        if subkey and elementtable and elementtable[subkey] then return elementtable[subkey] end
        if basetable and basetable[key] then return basetable[key] end
        if subkey and basetable and basetable[subkey] then return basetable[subkey] end
    end
    return default
end

function Style.GenerateStyle(path,cs)
    if (not path) then
        error("Lovelay.Style: No image path provided")
    end
    local image = love.graphics.newImage(path)
    if not image then
        error("Lovelay.Style: Failed to load image from path '"..path.."'")
    end
    local iw,ih = image:getWidth(), image:getHeight()
    cs = cs or 1
    local qs = 1+cs*2
    local hqs, vqs = iw/qs, ih/qs

    local createquadgroup = function(sx,sy)
        return {
            tl = love.graphics.newQuad(sx,      sy,      cs, cs, iw, ih),
            tm = love.graphics.newQuad(sx+cs,   sy,      1,  cs, iw, ih),
            tr = love.graphics.newQuad(sx+cs+1, sy,      cs, cs, iw, ih),
            cl = love.graphics.newQuad(sx,      sy+cs,   cs, 1,  iw, ih),
            cm = love.graphics.newQuad(sx+cs,   sy+cs,   1,  1,  iw, ih),
            cr = love.graphics.newQuad(sx+cs+1, sy+cs,   cs, 1,  iw, ih),
            bl = love.graphics.newQuad(sx,      sy+cs+1, cs, cs, iw, ih),
            bm = love.graphics.newQuad(sx+cs,   sy+cs+1, 1,  cs, iw, ih),
            br = love.graphics.newQuad(sx+cs+1, sy+cs+1, cs, cs, iw, ih),
        }
    end

    local quads = {}
    for x = 1, hqs do
        quads[x] = {} -- variants
        for y = 1, 4 do
            if y > vqs then
                quads[x][y] = Utils.Deepcopy(quads[x][vqs])
            else
                quads[x][y] = createquadgroup((x-1)*qs, (y-1)*qs) -- states
            end
        end
    end
    return {image=image, quads=quads, cornersize=cs}
end

function Style:CreateStyle(element,transform,keys)
    local data = {}
    for _,key in ipairs(keys) do
        data = self:Get(element,"_style",key,nil)
        if data then break end
    end
    if not data then return end

    if not data.image then
        return {type="color", variants=data}
    end

    local image,quads,cs = data.image,data.quads,data.cornersize
    local x,y,w,h = 0, 0, transform.w, transform.h

    local batches = {}
    for v = 1, #quads do
        batches[v] = {}
        for s = 1, #quads[v] do
            local quad = quads[v][s]
            batches[v][s] = love.graphics.newSpriteBatch(image,9)
            batches[v][s]:add(quad.tl, x,      y)
            batches[v][s]:add(quad.tm, x+cs,   y,      0, w-cs*2, 1)
            batches[v][s]:add(quad.tr, x+w-cs, y)
            batches[v][s]:add(quad.cl, x,      y+cs,   0, 1,      h-cs*2)
            batches[v][s]:add(quad.cm, x+cs,   y+cs,   0, w-cs*2, h-cs*2)
            batches[v][s]:add(quad.cr, x+w-cs, y+cs,   0, 1,      h-cs*2)
            batches[v][s]:add(quad.bl, x,      y+h-cs)
            batches[v][s]:add(quad.bm, x+cs,   y+h-cs, 0, w-cs*2, 1)
            batches[v][s]:add(quad.br, x+w-cs, y+h-cs)
        end
    end
    return {type="image", variants=batches}
end

local states = {"base","hover","focus","disabled"}
function Style:GetState(element,forcestate)
    if element.parent and element:IsCosmetic() then
        return self:GetState(element.parent,forcestate)
    elseif not element:IsActive() then
        return 4
    elseif forcestate then
        local idx = Utils.TableContains(states,forcestate)
        if idx then return idx end
        return forcestate
    elseif --[[element.hover and]] element.click then
        return 3
    elseif element.hover then
        return 2
    else
        return 1
    end
end

--- Text & Image ----------------------------------------------------

function Style:GetAllignX(x,w,fullw,allign,margin,force)
    if ((not force) and (w > fullw-(margin*2))) or allign == "left" then
        return x + margin
    elseif allign == "right" then
        return x + fullw-margin-w
    elseif allign == "middle" then
        return x + ((fullw/2) - (w/2))
    end
    return x
end
function Style:GetAllignY(y,h,fullh,allign,margin)
    if allign == "top" then
        return y + margin
    elseif allign == "bottom" then
        return y + fullh-margin-h
    elseif allign == "center" then
        return y + ((fullh/2) - (h/2))
    end
    return y
end
function Style:LineCount(element,text)
    local _,lines = element.font:getWrap(text,99e99)
    return #lines
end

function Style:GetSizeText(element,transform,text)
    local w,h = self:GetWidthText(element,text), self:GetHeightText(element,text)
    local x = self:GetAllignX(transform.x, w, transform.w, element.allignx, element.marginx)
    local y = self:GetAllignY(transform.y, h, transform.h, element.alligny, element.marginy)
    return x,y,w,h
end
function Style:GetWidthText(element,text)
    return element.font:getWidth(text)-1
end
function Style:GetHeightText(element,text)
    return (element.font:getHeight()*self:LineCount(element,text))-1
end

function Style:GetSizeImage(element,transform,image,quad)
    local w,h
    if quad then
        local _,_,qw,qh = quad:getViewport(); w,h = qw,qh
    else
        w,h = image:getWidth(), image:getHeight()
    end
    local x = self:GetAllignX(transform.x, w, transform.w, element.allignx, element.marginx)
    local y = self:GetAllignY(transform.y, h, transform.h, element.alligny, element.marginy)
    return x,y,w,h
end

--- Drawing ---------------------------------------------------------

function Style:GetColor(element,color,opacity)
    local r,g,b,a = unpack(color)
    if element.color then
        r,g,b,a = unpack(element.color)
    end
    a, opacity = a or 1, opacity or 1
    a = a*opacity
    return r,g,b,a
end

function Style:DrawBase(element,transform,data,varient,state,opacity)
    if (not data.variants) then return end
    if (not data.variants[varient]) then varient = 1 end
    if (not data.variants[varient]) then return end

    if data.type == "color" then
        local cornersize, cornersegments = self:Get(element,"cornersize",nil,0), self:Get(element,"cornersegments",nil,0)
        love.graphics.setColor(self:GetColor(element,data.variants[varient][state],opacity))
        love.graphics.rectangle("fill", transform.x, transform.y, transform.w, transform.h, cornersize, cornersize, cornersegments)
    elseif data.type == "image" then
        local batch = data.variants[varient][state]
        love.graphics.setColor(self:GetColor(element,{1,1,1,1},opacity))
        love.graphics.draw(batch, transform.x, transform.y)
    end
end

function Style:DrawText(element,transform,data,varient,state,text,opacity)
    if (not data.variants) then return end
    if (not data.variants[varient]) then varient = 1 end
    if (not data.variants[varient]) then return end

    if data.type == "color" then
        love.graphics.setFont(element.font)
        love.graphics.setColor(self:GetColor(element,data.variants[varient][state],opacity))
        local x,y,_,_ = self:GetSizeText(element,transform,text)
        love.graphics.print(text, x, y)
    elseif data.type == "image" then
        return -- Not supported
    end
end

function Style:DrawImage(element,transform,data,varient,state,image,quad,opacity)
    if (not data.variants) then return end
    if (not data.variants[varient]) then varient = 1 end
    if (not data.variants[varient]) then return end

    if data.type == "color" then
        love.graphics.setColor(self:GetColor(element,data.variants[varient][state],opacity))
        local x,y,_,_ = self:GetSizeImage(element,transform,image,quad)
        if quad then
            love.graphics.draw(image, quad, x, y)
        else
            love.graphics.draw(image, x, y)
        end
    elseif data.type == "image" then
        return -- Not supported
    end
end

return Style