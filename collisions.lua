local QuadTree = require "quad_tree"

local Collisions = {}
local Collisions_mt = {}
Collisions_mt.__index = Collisions

function Collisions.new(x, y, w, h)
    return setmetatable(
    {
        x = x,
        y = y,
        w = w,
        h = h,
        entities = {},
        staticColliders = {},
        quadtree = QuadTree.new(x,y,w,h, 0, {1,1,1})
    }, Collisions_mt)
end

function Collisions:addCollider(x,y,w,h)
    self.staticColliders[#self.staticColliders + 1]  = {
        x = x,
        y = y,
        w = w,
        h = h,
    }
end

function Collisions:setEntityTable(table)
    self.entities = table
end

function Collisions:add(e)
    self.entities[e] = e
end

function Collisions:remove(e)
    self.entities[e] = nil
end

function Collisions:collisionCheck(e, func)
    self.quadtree:collisionCheck(e, func)
end

function Collisions:collisionResolve(item, other)
    local abs = math.abs

    -- Returns 1 if number is positive, -1 if it's negative, or 0 if it's 0.
    local function sign(n) return n>0 and 1 or n<0 and -1 or 0 end

    local function nearest(x, a, b)
        if abs(a - x) < abs(b - x) then return a else return b end
    end
    
    local function rect_getNearestCorner(x,y,w,h, px, py)
        return nearest(px, x, x+w), nearest(py, y, y+h)
    end
    
    -- Calculates the minkowski difference between 2 rects, which is another rect
    local function rect_getDiff(x1,y1,w1,h1, x2,y2,w2,h2)
      return x2 - x1 - w1,
             y2 - y1 - h1,
             w1 + w2,
             h1 + h2
    end

    local x,y,w,h     = rect_getDiff(item.x,item.y,item.w,item.h, other.x,other.y,other.w,other.h)
    local px, py    = rect_getNearestCorner(x,y,w,h, 0, 0)
    if abs(px) < abs(py) then py = 0 else px = 0 end
    local tx, ty = item.x + px, item.y + py
    return tx, ty, sign(px), sign(py)
end

function Collisions:update(dt)
    self.quadtree:clear()
    for _,e in ipairs(self.staticColliders) do
        self.quadtree:insert(e)
    end
    for _,e in ipairs(self.entities) do
        self.quadtree:insert(e)
    end

    for _,e in pairs(self.entities) do
        e.marked = nil
        local func = function(item, other)
            item.marked = true
            --other.marked = true
            item.x, item.y = collisionWorld:collisionResolve(item, other)
        end


        collisionWorld:collisionCheck(e, e.collisionPreSolve or func)
    end
end



local function drawChildren(quad)
    --print(#quad.objects)
    love.graphics.rectangle("line", quad.x, quad.y, quad.w, quad.h)
    if not quad.children then return end
    for k,v in ipairs(quad.children) do
        drawChildren(v)
    end
end

function Collisions:draw()
    drawChildren(self.quadtree)
    for _,e in ipairs(self.staticColliders) do
        love.graphics.rectangle("line", e.x, e.y, e.w, e.h)
    end
    for _,e in pairs(self.entities) do
        if e.quad and e.quad.color then
            love.graphics.setColor(e.quad.color)
        end
        local mode = "line"
        if e.marked then
            mode = "fill"
        end
        love.graphics.rectangle(mode, e.x, e.y, e.w, e.h)        
        
        love.graphics.setColor(1,1,1,1)
    end    
end

return Collisions