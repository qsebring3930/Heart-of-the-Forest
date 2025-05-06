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
        fireCooldown = 0.1,
        fireTimer = 0,
        target = player,
        angle = 0,
        projectileModifiers = {}
    }
    function boss.shoot(projectiles, dt)
        boss.fireTimer = boss.fireTimer - dt
        if boss.fireTimer <= 0 then
            local mode = math.floor(love.timer.getTime()) % 3
            if mode == 0 then
                boss.projectileModifiers.Radial = true
                boss.projectileCount = 16
                for i = 0, boss.projectileCount - 1 do
                    boss.projectileIndex = i
                    projectiles.spawn(Boss)
                end
                boss.projectileModifiers.Radial = false
                boss.projectileIndex = nil
                boss.projectileCount = nil
            elseif mode == 1 then
                local dx = Player.x - boss.x
                local dy = Player.y - boss.y
                local angle = math.atan(dy / dx)
                if dx < 0 then 
                    angle = angle + math.pi
                end
                boss.angle = angle - math.rad(120) / 2
                boss.projectileModifiers.Sine = true
                boss.projectileCount = 5
                for i = 0, boss.projectileCount - 1 do
                    boss.projectileIndex = i
                    projectiles.spawn(Boss)
                end
                boss.projectileModifiers.Sine = false
                boss.projectileIndex = nil
                boss.projectileCount = nil
            elseif mode == 2 then
                boss.projectileModifiers.Tracking = true
                projectiles.spawn(Boss)
                boss.projectileModifiers.Tracking = false
            end
            boss.fireTimer = boss.fireCooldown
        end
    end
    return boss
end

return Boss