local love = require "love"

function Boss(x, y, player, stage)
    local boss = {
        id = stage,
        x = x,
        y = -100,
        vx = 0,
        vy = 0,
        size = 75,
        speed = 200,
        health = 100,
        fireCooldown = 0.175,
        patternIndex = 0,
        patternTimer = 0,
        fireTimer = 0,
        targetY = y,
        target = player,
        angle = 0,
        entering = true,
        projectileModifiers = {},
        timers = {
            bomb = 0,
            tracking = 0,
            zigzag = 0,
            sine = 0,
            spiral = 0,
            radial = 0,
        },
        projectiles = {
            bomb = false,
            tracking = false,
            zigzag = false,
            sine = false,
            spiral = false,
            radial = false
        }
    }
    function boss.stage()
        if boss.id == 1 then
            boss.speed = 200
            boss.size = 75
            boss.health = 300
            boss.fireCooldown = 0.15
            boss.projectiles = {
                bomb = false,
                tracking = true,
                zigzag = true,
                sine = false,
                spiral = false,
                radial = true
            }
            boss.projectileTimerScale = 3
        end
    end
    function boss.update(dt)
        if boss.entering then
            boss.y = boss.y + boss.speed * dt
            if boss.y >= boss.targetY then
                boss.y = boss.targetY
                boss.entering = false
            end
        elseif not boss.entering then
            boss.fireTimer = boss.fireTimer - dt
            boss.patternTimer = boss.patternTimer + dt
            if boss.patternTimer >= boss.fireCooldown then
                boss.patternIndex = (boss.patternIndex + 1) % 6
                boss.patternTimer = 0
            end
            for k, v in pairs(boss.timers) do
                boss.timers[k] = v - dt
            end
        end
    end
    function boss.shoot(projectiles, dt)
        if boss.fireTimer <= 0 then
            local mode = boss.patternIndex
            if mode == 0 and boss.projectiles.spiral then
                if boss.timers.spiral <= 0 then
                    boss.projectileModifiers.Spiral = true
                    boss.projectileCount = 12
                    for i = 0, boss.projectileCount - 1 do
                        boss.projectileIndex = i
                        projectiles.spawn(Boss)
                    end
                    boss.projectileModifiers.Spiral = false
                    boss.projectileIndex = nil
                    boss.projectileCount = nil
                    boss.timers.spiral = .1
                end
            elseif mode == 1 and boss.projectiles.sine then
                if boss.timers.sine <= 0 then
                    local dx = Player.x - boss.x
                    local dy = Player.y - boss.y
                    local angle = math.atan(dy / dx)
                    if dx < 0 then 
                        angle = angle + math.pi
                    end
                    boss.angle = angle - math.rad(120) / 2
                    boss.projectileModifiers.Sine = true
                    boss.projectileCount = 6
                    for i = 0, boss.projectileCount - 1 do
                        boss.projectileIndex = i
                        projectiles.spawn(Boss)
                    end
                    boss.projectileModifiers.Sine = false
                    boss.projectileIndex = nil
                    boss.projectileCount = nil
                    boss.timers.sine = .25
                end
            elseif mode == 2 and boss.projectiles.tracking then
                if boss.timers.tracking <= 0 then
                    boss.projectileModifiers.Tracking = true
                    projectiles.spawn(Boss)
                    boss.projectileModifiers.Tracking = false
                    boss.timers.tracking = 5 / boss.projectileTimerScale
                end
            elseif mode == 3 and boss.projectiles.bomb then
                if boss.timers.bomb <= 0 then
                    boss.projectileModifiers.Bomb = true
                    projectiles.spawn(Boss)
                    boss.projectileModifiers.Bomb = false
                    boss.timers.bomb = 10
                end
            elseif mode == 4 and boss.projectiles.zigzag then
                if boss.timers.zigzag <= 0 then
                    local dx = Player.x - boss.x
                    local dy = Player.y - boss.y
                    local angle = math.atan(dy / dx)
                    if dx < 0 then 
                        angle = angle + math.pi
                    end
                    boss.angle = angle - math.rad(80) / 2
                    boss.projectileModifiers.Zigzag = true
                    boss.projectileCount = 3
                    for i = 0, boss.projectileCount - 1 do
                        boss.projectileIndex = i
                        projectiles.spawn(Boss)
                    end
                    boss.projectileModifiers.Zigzag = false
                    boss.projectileIndex = nil
                    boss.projectileCount = nil
                    boss.timers.zigzag = .5
                end
            elseif mode == 5 and boss.projectiles.radial then
                if boss.timers.radial <= 0 then
                    boss.projectileModifiers.Radial = true
                    boss.projectileCount = 18
                    for i = 0, boss.projectileCount - 1 do
                        boss.projectileIndex = i
                        projectiles.spawn(Boss)
                    end
                    boss.projectileModifiers.Radial = false
                    boss.projectileIndex = nil
                    boss.projectileCount = nil
                    boss.timers.spiral = .1
                end
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