local System = {
    
}

function System:new(name)
    local o = {}
    o.entities = {}
    o.name = name
    o.add = System.add
    o.remove = System.remove
    o.iter = System.iter
    o.removeAll = System.removeAll
    return o
end

function System:add(ent)
    ent.systems[self] = true
    self.entities[ent.id] = ent
    if self.onAdd then
        self:onAdd(ent)
    end
end

function System:removeAll()
    self:iter(function(e) 
        self:remove(e)
    end)
end

function System:remove(ent)
    ent.systems[self] = nil
    self.entities[ent.id] = nil
    if self.onRemove then
        self:onRemove(ent)
    end    
end

function System:iter(func)
    for _,e in pairs(self.entities) do
        if e.dead then
            print("shits dead yo")
            for s, _ in pairs(e.systems) do
                s:remove(e)
            end
        else
            func(e)
        end
    end
end


setmetatable( System, { __call = System.new } )
return System