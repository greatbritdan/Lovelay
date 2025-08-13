local Utils = {}

function Utils.ForEach(table,func,reverse)
    if type(table) ~= "table" or #table == 0 then return end
    if reverse then
        for i = #table, 1, -1 do
            if not table[i]._IGNORE then
                func(table[i])
            end
        end
    else
        for i = 1, #table do
            if not table[i]._IGNORE then
                func(table[i])
            end
        end
    end
end

function Utils:GetMouse()
    local x,y = love.mouse.getPosition()
    return x/_LOVELAY_SETTINGS.scale, y/_LOVELAY_SETTINGS.scale
end

function Utils.Deepcopy(table)
    if type(table) ~= "table" then return table end
    local copy = {}
    for k,v in pairs(table) do
        copy[k] = Utils.Deepcopy(v)
    end
    return copy
end

function Utils.TableContains(table, value)
    for i,v in ipairs(table) do
        if v == value then
            return i
        end
    end
    return nil
end
function Utils.TableContainsBoolean(table, value)
    return Utils.TableContains(table, value) ~= nil
end

function Utils.SetAutoscroll(size,fullsize)
    if size > fullsize then
        return {dist=size-fullsize, pos=0, stage="wait_r", timer=0}
    else
        return {dist=0, pos=0}
    end
end

function Utils.UpdateAutoscroll(a,dt)
    if a.dist == 0 then return 0 end
    a.timer = a.timer + dt
    if a.stage == "wait_r" and a.timer > 2 then
        a.stage, a.timer = "scroll_r", 0
    elseif a.stage == "scroll_r" then
        a.pos = math.min(a.pos + _LOVELAY_SETTINGS.unit * dt, a.dist)
        if a.pos >= a.dist then
            a.stage, a.timer = "wait_l", 0
        end
    elseif a.stage == "wait_l" and a.timer > 2 then
        a.stage, a.timer = "scroll_l", 0
    elseif a.stage == "scroll_l" then
        a.pos = math.max(a.pos - _LOVELAY_SETTINGS.unit * dt, 0)
        if a.pos <= 0 then
            a.stage, a.timer = "wait_r", 0
        end
    end
    return a.pos
end

Utils.scissorstack = {}
function Utils.ScissorPush(x,y,w,h)
    local x1,x2,y1,y2 = x, x+w, y, y+h
    local ox,oy,ow,oh = love.graphics.getScissor()
    ox,oy,ow,oh = ox or 0, oy or 0, ow or love.graphics.getWidth(), oh or love.graphics.getHeight()
    local ox1,ox2,oy1,oy2 = ox, ox+ow, oy, oy+oh
    if x1 < ox1 then x1 = ox1 end
    if y1 < oy1 then y1 = oy1 end
    if x2 > ox2 then x2 = ox2 end
    if y2 > oy2 then y2 = oy2 end
    local fx,fy,fw,fh = x1,y1,math.max(0,x2-x1),math.max(0,y2-y1)
    table.insert(Utils.scissorstack, {fx,fy,fw,fh})
    love.graphics.setScissor(fx,fy,fw,fh)
end
function Utils.ScissorPop()
    table.remove(Utils.scissorstack)
    if #Utils.scissorstack == 0 then
        love.graphics.setScissor()
    else
        local x,y,w,h = unpack(Utils.scissorstack[#Utils.scissorstack])
        love.graphics.setScissor(x,y,w,h)
    end
end

return Utils