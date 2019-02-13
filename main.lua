local QuadTree = require "quad_tree"
PAUSE = false


local entities = {}

function newEnt(x,y,w,h,vx,vy)
    return {
        x = x,
        y = y,
        w = w,
        h = h,
        vx = vx,
        vy = vy
    }
end


function love.load()
    love.window.setMode(1280,1024)
    screenWidth, screenHeight, _ = love.window.getMode()

    for i = 1, 2000 do
        entities[#entities + 1] = newEnt(math.random(screenWidth), math.random(screenHeight), math.random(10, 30), math.random(10, 30), math.random(-40, 40), math.random(-40, 40))
    end

    quadtree = QuadTree.new(0,0,screenWidth,screenHeight, 0, {1,1,1})
end


function love.update(dt)
    if PAUSE then return end
    quadtree:clear()

    for _,e in ipairs(entities) do
        e.x = e.x + e.vx * dt
        e.y = e.y + e.vy * dt
        
        if e.x + e.w > screenWidth or e.x < 0 then
            e.vx = e.vx * -1
        end
        if e.y + e.h > screenHeight or e.y < 0 then
            e.vy = e.vy * -1
        end  
        
        quadtree:insert(e)
    end
    --local ret = {}
    --quadtree:retrieve(entities[1], ret)
    --print(#ret)
    for _,e in ipairs(entities) do
        e.marked = nil
        quadtree:collisionCheck(e, function(item, other) item.marked = true; other.marked = true end)
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

function love.draw()
    drawChildren(quadtree)

    for _,e in ipairs(entities) do
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
    love.graphics.print(love.timer.getFPS() .. "\n" .. collectgarbage("count") / 1024)
end

function love.keypressed(key, scancode, isrepeat )
    if key == "space" then
        PAUSE = not PAUSE
    end
    if key == "f" then
        if #entities == 0 then print("empty"); return end
        quadtree:remove(table.remove(entities, math.random(#entities)))
    end
end