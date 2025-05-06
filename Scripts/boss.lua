local love = require "love"

function Boss(x, y, player)
    local boss = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        size = 50,
        speed = 500,
        health = 50,
        fireCooldown = 0.5, -- seconds between shots
        fireTimer = 0,
        target = player,
        angle = 0,
        projectileModifiers = {}
    }
    function boss.shoot(projectiles, dt)
        Boss.fireTimer = Boss.fireTimer - dt
        if Boss.fireTimer <= 0 then
            local mode = math.floor(love.timer.getTime()) % 3
            if mode == 0 then
                Boss.projectileModifiers.Radial = true
                Boss.projectileCount = 16
                for i = 0, Boss.projectileCount - 1 do
                    Boss.projectileIndex = i
                    projectiles.spawn(Boss)
                end
                Boss.projectileModifiers.Radial = false
                Boss.projectileIndex = nil
                Boss.projectileCount = nil
            elseif mode == 1 then
                local dx = Player.x - Boss.x
                local dy = Player.y - Boss.y
                local angle = math.atan(dy / dx)
                if dx < 0 then 
                    angle = angle + math.pi
                end
                Boss.angle = angle - math.rad(120) / 2
                Boss.projectileModifiers.Sine = true
                Boss.projectileCount = 5
                for i = 0, Boss.projectileCount - 1 do
                    Boss.projectileIndex = i
                    projectiles.spawn(Boss)
                end
                Boss.projectileModifiers.Sine = false
                Boss.projectileIndex = nil
                Boss.projectileCount = nil
            elseif mode == 2 then
                Boss.projectileModifiers.Tracking = true
                projectiles.spawn(Boss)
                Boss.projectileModifiers.Tracking = false
            end
            Boss.fireTimer = Boss.fireCooldown
        end
    end
    return boss
end

return Boss