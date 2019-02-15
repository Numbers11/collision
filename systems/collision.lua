local System = require "system"

local Collision = System("Collision")

function Collision.init(cw)
    --do init stuff for the system here
    Collision.cw = cw
    return Collision
end

function Collision:onAdd(e)
    print("added ", self.name, e.name)
    --init necessary values here
    self.cw:add(e)
end

function Collision:onRemove(e)
    print("removed ", self.name, e.name)
    self.cw:remove(e)
end

function Collision:update(dt)
    self.cw:update(dt)
end

return Collision.init