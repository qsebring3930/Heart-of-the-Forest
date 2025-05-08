local love = require "love"
local game = require "game"

function Player(x, y)
    local Game = game()
    local player = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        size = 10,
        speed = 200,
        health = 5,
        fireCooldown = 0.1,
        fireTimer = 0,
        projectileModifiers = {}
    }
    function player.move(direction, dt)
        local dx, dy = 0, 0
        local magnitude = player.speed * dt
        if direction == Game.Direction.Left then
            dx = dx - 1
        end
        if direction == Game.Direction.Right then
            dx = dx + 1
        end
        if direction == Game.Direction.Up then
            dy = dy - 1
        end
        if direction == Game.Direction.Down then
            dy = dy + 1
        end
        if direction == Game.Direction.None then
            dx = 0
            dy = 0
        end
        if dx ~= 0 or dy ~= 0 then
            local len = math.sqrt(dx * dx + dy * dy)
            dx = dx / len
            dy = dy / len
        end
    
        player.vx = dx * magnitude/dt
        player.vy = dy * magnitude/dt
    
        player.x = player.x + player.vx * dt
        player.y = player.y + player.vy * dt
    
        player.x = math.max(player.size, math.min(Window.width - player.size, player.x))
        player.y = math.max(player.size, math.min(Window.height - player.size, player.y))
    end
    function player.shoot(projectiles)
        projectiles.spawn(player)
        player.fireTimer = player.fireCooldown
    end
    function player.update(dt)
        player.fireTimer = player.fireTimer - dt
    end
    function player.draw()
        Game.Color.Set(Game.Color.Green, Game.Shade.Neon)
        if Player.health <= 0 then
            Game.Color.Set(Game.Color.Red, Game.Shade.Dark)
        end
        love.graphics.rectangle("fill", Player.x - Player.size, Player.y - Player.size, Player.size * 2, Player.size * 2)
        Game.Color.Clear()
    end
    return player
end

return Player
    