local System = require "system"

local Movement = System("Movement")

function Movement.init()
    --do init stuff for the system here
    return Movement
end

function Movement:onAdd(e)
    print("added ", self.name, e.name)
    --init necessary values here
    e.vx = e.vx or 0
    e.vy = e.vy or 0
end

function Movement:onRemove(e)
    print("removed ", self.name, e.name)
    e.vx = 0
    e.vy = 0
end

function Movement:update(dt)
    self:iter(function(e)
        e.vy = e.vy + 20 -- gravity

        --friction
        if e.grounded then
            e.vx = e.vx * 0.85
        end

        --cutoff
        e.vx = (math.abs(e.vx) < 5) and 0 or e.vx

        --update based on velocity
        e.x = e.x + e.vx * dt
        e.y = e.y + e.vy * dt
        
        if e.x + e.w > screenWidth or e.x < 0 then
            e.x = screenwidth - e.w
            e.vx = e.vx * -1
        end
        if e.y + e.h > screenHeight or e.y < 0 then
            e.y = screenHeight - e.h
            e.vy = e.vy * -1
        end          
    end)
end

return Movement.init