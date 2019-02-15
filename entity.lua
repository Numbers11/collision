_id = 0

local Entity = {
    count = 0
}

function Entity.new(values)
    local o = {}
    o.type = "Entity"
    _id = _id + 1
    o.id = _id
    o.dead = false
    o.systems = {}
    o.destroy = Entity.destroy
    for k, v in pairs(values) do
        o[k] = v 
    end
    Entity.count = Entity.count + 1
    return o
end

function Entity.destroy(e)
    e.dead = true
    Entity.count = Entity.count - 1
end

setmetatable( Entity, { __call = function(_, ...) Entity.new(...) end } )
return Entity