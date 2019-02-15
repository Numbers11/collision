PAUSE = false

local System = require "system"
local Entity = require "entity"
local Collisions = require "collisions"
local Timer = require "lib.hump.timer"
local Input = require "input"
local Player = require "player"
new = Entity.new
local entities = {}


local function initSystems()
    systems = {
        Movement = require "systems.movement"(),
        Timer = require "systems.timer"(),
        Collision = require "systems.collision"(collisionWorld)
    }

    orderedSystems = {
        systems.Movement,
        systems.Timer,
        systems.Collision
    }
end

local function initPlayer()
    player = new(Player)
    entities[player] = player
    systems.Timer:add(player)
    systems.Movement:add(player)
    systems.Collision:add(player)
end

function love.load()
    love.window.setMode(1280,1024)
    screenWidth, screenHeight, _ = love.window.getMode()
    collisionWorld = Collisions.new(0,0,screenWidth,screenHeight)

    --init static world
    collisionWorld:addCollider(100, 500, 300, 60)
    collisionWorld:addCollider(300, 500, 400, 60)
    collisionWorld:addCollider(100, 0,   60, 600)

    initSystems()

    initPlayer()
    --collisionWorld:setEntityTable(entities)
    --for i = 1, 50 do
    --   entities[#entities + 1] = newEnt(math.random(screenWidth), math.random(screenHeight), math.random(10, 30), math.random(10, 30), math.random(-40, 40), math.random(-40, 40))
    --end
end


function love.update(dt)
    if PAUSE then return end
    Input:update(dt)

    for _,s in ipairs(orderedSystems) do
        if s.update then
            s:update(dt)
        end
    end
    -- --player update
    if Input.dirX ~= 0 then
        local diff = Input.dirX * 250 - player.vx --add to the velocity if we are below our wanted speed. avoids using setVelocity
        player.vx = player.vx + diff
    end

    if love.keyboard.isDown("space") and player.grounded and not player.jumping then
        print("yo")
        --wants to jump
        player.grounded = false
        player.vy = -600
        player.jumping = true
    elseif player.jumping and player.vy < 0 and not player.grounded and not love.keyboard.isDown("space") then
        print("oy")
        --early jump key release, aka the super meat boy jump
        player.vy = 0
        player.jumping = false
    end
    if not player.grounded and player.vy > 0 then --we are falling now
        player.jumping = false
    end
end

function love.draw()
    collisionWorld:draw()
    love.graphics.print(love.timer.getFPS() .. "\n" .. collectgarbage("count") / 1024  .. "\n" .. player.vx .. "/" .. player.vy .. " - " .. tostring(player.grounded)  .. "\n" .. Input.dirX .. "/" .. Input.dirY)
end

function love.keypressed(key, scancode, isrepeat )
    if key == "f1" then
        PAUSE = not PAUSE
    end
    if key == "f" then
        if #entities == 0 then print("empty"); return end
        quadtree:remove(table.remove(entities, math.random(#entities)))
    end
end