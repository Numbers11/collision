local Input = {
    name = "Input"
}

function Input:update(dt)
    self.dirX = 0
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.dirX = self.dirX - 1
    end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.dirX = self.dirX + 1
    end

    self.dirY = 0
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        self.dirY = self.dirY - 1
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        self.dirY = self.dirY + 1
    end

    --maybe also put jumpInput here?
end

return Input