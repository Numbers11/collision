local System = require "system"
local GTimer = require "lib.hump.timer"

local Timer = System("Timer")

function Timer:onAdd(e)
    print("added ", self.name, e.name)
    --init necessary values here
    e.timer = GTimer.new()
    if e.ttl then
       e.timer:after(e.ttl, function() print("dead"); e:destroy(e) end)
    end
end

function Timer:onRemove(e)
    print("removed ", self.name, e.name)
    e.timer = nil
end

function Timer:update(dt)
    self:iter(function(e)
        e.timer:update(dt)
    end)
end

function Timer.init()
    --do init stuff for the system here
    return Timer
end

return Timer.init