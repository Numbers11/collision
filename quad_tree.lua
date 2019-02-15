MAX_OBJECTS = 15
MAX_LEVELS = 5

local function rectIntersection(r1, r2)
    return r1.x < r2.x + r2.w and
           r2.x < r1.x + r1.w and
           r1.y < r2.y + r2.h and
           r2.y < r1.y + r1.h
end

local QuadTree = {}
local QuadTree_mt = {}
QuadTree_mt.__index = QuadTree


function QuadTree.new(x, y, w, h, level, color)
    return setmetatable(
    {
        x = x,
        y = y,
        w = w,
        h = h,
        children = nil,
        level = level or 0,
        objects = {},
        count = 0,
        color = color,
    }, QuadTree_mt)
end

function QuadTree:clear()
    self.count = 0
    --self.objects = {}
    --self.children = nil

    for k,v in pairs(self.objects) do self.objects[k]=nil end
    if not self.children then return end
    for k,v in pairs(self.children) do
        --v:clear()
        self.children[k] = nil
    end
    self.children = nil
end

function QuadTree:update(e)
    self:remove(e)
    self:insert(e)
end

function QuadTree:remove(e)
    --if not rectIntersection(e, self) then
    --    return
    --end

    --we are not at the bottom level yet
    if self.children then
        self.children[1]:remove(e)
        self.children[2]:remove(e)
        self.children[3]:remove(e)
        self.children[4]:remove(e)
        return
    end    
    if self.objects[e] then
        --remove the rect
        e.quad = nil
        self.objects[e] = nil 
        self.count = self.count - 1
    end
end

function QuadTree:split()
    --print("split!")
    local sw = self.w / 2
    local sh = self.h / 2
    local x = self.x
    local y = self.y
    local slevel = self.level + 1
    self.children = {}
    self.children[1] = QuadTree.new(x + sw, y     , sw, sh, slevel,{1,0,0})
    self.children[2] = QuadTree.new(x     , y     , sw, sh, slevel,{1,0,1})
    self.children[3] = QuadTree.new(x     , y + sh, sw, sh, slevel,{0,0,1})
    self.children[4] = QuadTree.new(x + sw, y + sh, sw, sh, slevel,{0,1,0})
end

function QuadTree:insert(e)
    if not rectIntersection(e, self) then
        return
    end

    --we are not at the bottom level yet
    if self.children then
        self.children[1]:insert(e)
        self.children[2]:insert(e)
        self.children[3]:insert(e)
        self.children[4]:insert(e)
        return
    end

    --insert to the bottom level
    e.quad = self
    self.objects[e] = e 
    self.count = self.count + 1

    --check if we should subdivide
    if self.count > MAX_OBJECTS and self.level < MAX_LEVELS then
        self:split()

        --put the objects in the deeper level & remove from this one
        self.count = 0
        for k, v in pairs(self.objects) do
            self.objects[k] = nil
            self:insert(v)
        end
    end
end     

function QuadTree:collisionCheck(e, func)
    if not rectIntersection(e, self) then
        return
    end

    --we are not at the bottom level yet
    if self.children then
        self.children[1]:collisionCheck(e, func)
        self.children[2]:collisionCheck(e, func)
        self.children[3]:collisionCheck(e, func)
        self.children[4]:collisionCheck(e, func)
        return
    end

    --check for collisions with all other members of this quad
    for _,other in pairs(self.objects) do
        if other ~= e and rectIntersection(e, other) then
            func(e, other)
        end
    end
end

-- function QuadTree:retrieve(e, returnList)
--     if not rectIntersection(e, self) then
-- 
--         return
--     end
--     --we are not at the bottom level yet
--     if self.children then
--         self.children[1]:retrieve(e, returnList)
--         self.children[2]:retrieve(e, returnList)
--         self.children[3]:retrieve(e, returnList)
--         self.children[4]:retrieve(e, returnList)
--         return
--     end    
--     for k,v in pairs(self.objects) do
--         --returnList[#returnList + 1] = v
--         if v ~= e then
--             if rectIntersection(e, v) then
--                 returnList[#returnList + 1] = v
--             end
--         end
--     end
-- end

return QuadTree