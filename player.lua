local Player = { --200, 0, 10, 32,0,0
    x = 200,
    y = 0,
    w = 14,
    h = 32,
    grounded = false,
    collisionClass = "unit",
    collisionPreSolve = function(item, other)
        --print("colliding yo")
        item.x, item.y, nx, ny = collisionWorld:collisionResolve(item, other)
        --item.vy = item.vy * -1
        if nx == 0 and ny == -1 then -- we landed on something  
            item.grounded = true 
            item.vy = 0
        elseif nx == 0 and ny == 1 then -- we hit our head
            item.vy = 0
        elseif nx ~= 0 and ny == 0 then -- collision to the side
            item.vx = 0
        end
        --print(nx, ny)
    end,
    states = {
        walk = {
            enter = function(from)
                --set animation
            end,
            leave = function(to)
            end,
            update = function(dt)
                --while key pressed, set velocity
                --if jump key or attack key or whatever, do that
            end
        }
    }
}

return Player