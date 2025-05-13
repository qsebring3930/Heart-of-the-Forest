local game = require "Scripts/game"
local overlay = require "Scripts/overlay"
local animation = require "Scripts/animation"

function Player(x, y)
    local Game = game()
    local Animation = animation()
    local player = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        size = 5,
        speed = 200,
        fireCooldown = 0.1,
        fireTimer = 0,
        projectileModifiers = {
            isPlayer = true,
        },
        anim = Animation.new(PlayerImage, 162, 79, 4, 0.1)
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
        player.projectileCount = 3
        local baseAngle = math.rad(-90)
        local spread = math.rad(30)

        for i = 0, player.projectileCount - 1 do
            local t = (player.projectileCount == 1) and 0.5 or (i / (player.projectileCount - 1))
            player.projectileIndex = i
            player.angle = baseAngle - spread / 2 + spread * t
            projectiles.spawn(player)
        end
        player.fireTimer = player.fireCooldown
        Sounds.player:play()
    end
    function player.update(dt)
        player.fireTimer = player.fireTimer - dt
        player.anim.update(dt)
    end
    function player.draw()
        player.anim.draw(player.x, player.y, 0.3)
        Game.Color.Set(Game.Color.Red, Game.Shade.Light)
        love.graphics.circle("fill", player.x, player.y, player.size)
        Game.Color.Clear()
        if GameState.stagenum == 3 and overlay.intensity > 0 then
            Game.Color.Set(Game.Color.Green, Game.Shade.NeonTransparent)
            love.graphics.circle("fill", player.x, player.y, 20 + (30 * overlay.intensity))
            Game.Color.Clear()
        end
    end
    function player.hit()
        overlay.increment()
        Sounds.hit:play()
    end
    return player
end

return Player
