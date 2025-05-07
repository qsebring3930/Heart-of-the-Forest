local love = require "love"

function Boss(x, y, player)
    local boss = {
        x = x,
        y = -100,
        vx = 0,
        vy = 0,
        size = 50,
        speed = 200,
        health = 50,
        fireCooldown = 0.15,
        fireTimer = 0,
        targetY = y,
        target = player,
        angle = 0,
        entering = true,
        projectileModifiers = {}
        
    }
    function boss.update(dt)
        if boss.entering then
            boss.y = boss.y + boss.speed * dt
            if boss.y >= boss.targetY then
                boss.y = boss.targetY
                boss.entering = false
            end
        elseif not boss.entering then
            boss.fireTimer = boss.fireTimer - dt
        end
    end
    function boss.shoot(projectiles, dt)
        if boss.fireTimer <= 0 then
            local mode = math.floor(love.timer.getTime() * 16) % 4
            local mode2 = math.floor(love.timer.getTime() * 16) % 5
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
                boss.angle = angle - math.rad(135) / 2
                boss.projectileModifiers.Sine = true
                boss.projectileCount = 8
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
            elseif mode == 3 and mode2 == 0 then
                boss.projectileModifiers.Bomb = true
                projectiles.spawn(Boss)
                boss.projectileModifiers.Bomb = false
            end
            boss.fireTimer = boss.fireCooldown
        end
    end
    function boss.draw()
        Game.Color.Set(Game.Color.Blue, Game.Shade.Neon)
        if Boss.health <= 0 then
            Game.Color.Set(Game.Color.Red, Game.Shade.Dark)
        end
        love.graphics.circle("fill", Boss.x, Boss.y, Boss.size)
        Game.Color.Clear()
    end
    return boss
end

return Boss