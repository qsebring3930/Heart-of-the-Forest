local love = require "love"
local animation = require "Scripts/animation"

function Boss(x, y, player, stage, images)
    local Animation = animation()
    local boss = {
        id = stage, --
        x = x,
        y = -100,
        vx = 0,
        vy = 0,
        size = 75,
        speed = 200,
        health = 100,
        patternIndex = 0,
        patternTimer = 0,
        fireTimer = 0,
        targetY = y,
        target = player,
        angle = 0,
        entering = true,
        projectileModifiers = {},
        projectileBase = .25,
        projectileModes = 0,
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
        },
        images = images,
        sprite = nil,
        spriteScale = 0
    }
    function boss.stage()
        if boss.id == 1 then
            boss.speed = 200
            boss.size = 75
            boss.health = 50
            boss.projectileBase = .5
            boss.projectiles = {
                bomb = false,
                tracking = {2,4},
                zigzag = {0,1,4,5},
                sine = false,
                spiral = false,
                radial = {1,3,5}
            }
            boss.projectileModes = 6
            boss.spriteScale = 2
            boss.sprite = Animation.new(boss.images.zapper, 70, 70, 1, 1)
        elseif boss.id == 2 then
            boss.speed = 200
            boss.size = 50
            boss.health = 350
            boss.projectiles = {
                bomb = {4},
                tracking = false,
                zigzag = {1,7},
                sine = false,
                spiral = {0,2,4,6},
                radial = {1,3,5,7}
            }
            boss.projectileModes = 7
            boss.spriteScale = 1
            boss.sprite = Animation.new(boss.images.cat, 200, 200, 1, 1)
        elseif boss.id == 3 then
            boss.speed = 200
            boss.size = 20
            boss.health = 20
            boss.projectiles = {
                bomb = true,
                tracking = false,
                zigzag = true,
                sine = false,
                spiral = true,
                radial = true
            }
            boss.projectileModes = 7
            boss.spriteScale = 2
            boss.sprite = Animation.new(boss.images.deer, 200, 200, 1, 1)
        elseif boss.id == 4 then
            boss.speed = 200
            boss.size = 20
            boss.health = 20
            boss.projectiles = {
                bomb = {4},
                tracking = false,
                zigzag = {1,7},
                sine = false,
                spiral = {0,2,4,6},
                radial = {1,3,5,7}
            }
            boss.projectileModes = 7
            boss.spriteScale = 2
            boss.sprite = Animation.new(boss.images.mushroom, 200, 200, 1, 1)
        elseif boss.id == 5 then
            boss.speed = 200
            boss.size = 20
            boss.health = 20
            boss.projectiles = {
                bomb = {4},
                tracking = false,
                zigzag = {1,7},
                sine = false,
                spiral = {0,2,4,6},
                radial = {1,3,5,7}
            }
            boss.projectileModes = 7
            boss.spriteScale = 2
            boss.sprite = Animation.new(boss.images.flower, 200, 200, 1, 1)
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
            boss.patternTimer = boss.patternTimer + dt
            if boss.patternTimer >= boss.projectileBase then
                boss.patternIndex = (boss.patternIndex + 1) % boss.projectileModes
                boss.patternTimer = 0

                for k in pairs(boss.timers) do
                    boss.timers[k] = 0
                end
            end
            for k, v in pairs(boss.timers) do
                boss.timers[k] = v - dt
            end
        end
        boss.sprite.update(dt)
    end
    function boss.shoot(projectiles, dt)
        local mode = boss.patternIndex
        if boss.modeAllowed(boss.projectiles.spiral, mode) then
            if boss.timers.spiral <= 0 then
                boss.projectileModifiers.Spiral = true
                boss.projectileCount = 24
                for i = 0, boss.projectileCount - 1 do
                    boss.projectileIndex = i
                    projectiles.spawn(Boss)
                end
                boss.projectileModifiers.Spiral = false
                boss.projectileIndex = nil
                boss.projectileCount = nil
                boss.timers.spiral = boss.projectileBase/8
            end
        end
        if boss.modeAllowed(boss.projectiles.sine, mode) then
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
                boss.timers.sine = boss.projectileBase/4
            end
        end
        if boss.modeAllowed(boss.projectiles.tracking, mode) then
            if boss.timers.tracking <= 0 then
                boss.projectileModifiers.Tracking = true
                projectiles.spawn(Boss)
                boss.projectileModifiers.Tracking = false
                boss.timers.tracking = boss.projectileBase/2
            end
        end
        if boss.modeAllowed(boss.projectiles.bomb, mode) then
            if boss.timers.bomb <= 0 then
                boss.projectileModifiers.Bomb = true
                projectiles.spawn(Boss)
                boss.projectileModifiers.Bomb = false
                boss.timers.bomb = boss.projectileBase * 10
            end
        end
        if boss.modeAllowed(boss.projectiles.zigzag, mode) then
            if boss.timers.zigzag <= 0 then
                local dx = Player.x - boss.x
                local dy = Player.y - boss.y
                local angle = math.atan(dy / dx)
                if dx < 0 then 
                    angle = angle + math.pi
                end
                boss.angle = angle - math.rad(80) / 2
                boss.projectileModifiers.Zigzag = true
                boss.projectileCount = 8
                for i = 0, boss.projectileCount - 1 do
                    boss.projectileIndex = i
                    projectiles.spawn(Boss)
                end
                boss.projectileModifiers.Zigzag = false
                boss.projectileIndex = nil
                boss.projectileCount = nil
                boss.timers.zigzag = boss.projectileBase/2
            end
        end
        if boss.modeAllowed(boss.projectiles.radial, mode) then
            if boss.timers.radial <= 0 then
                boss.projectileModifiers.Radial = true
                boss.projectileCount = 36
                for i = 0, boss.projectileCount - 1 do
                    boss.projectileIndex = i
                    projectiles.spawn(Boss)
                end
                boss.projectileModifiers.Radial = false
                boss.projectileIndex = nil
                boss.projectileCount = nil
                boss.timers.radial = boss.projectileBase/3
            end
        end
    end
    function boss.draw()
        boss.sprite.draw(boss.x, boss.y, boss.spriteScale)
    end
    function boss.modeAllowed(list, mode)
        if list == false then return false end
        for _, m in ipairs(list) do
            if m == mode then return true end
        end
        return false
    end
    return boss
end

return Boss