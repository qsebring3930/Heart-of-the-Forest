local animation = require "Scripts/animation"

function Boss(x, y, player, stage)
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
            spiral2 = 0,
        },
        projectiles = {
            bomb = false,
            tracking = false,
            zigzag = false,
            sine = false,
            spiral = false,
            radial = false,
            spiral2 = false
        },
        sprite = nil,
        spriteScale = 0
    }
    function boss.stage()
        --[[if boss.id == 1 then
            boss.speed = 200
            boss.size = 75
            boss.health = 20 --250
            boss.projectileBase = .5
            boss.projectiles = {
                bomb = {1},
                tracking = {1},
                zigzag = {1},
                sine = {1},
                spiral = {1},
                radial = {1},
                spiral2 = {1}
            }
            boss.projectileModes = 2
            boss.spriteScale = 2
            boss.sprite = Animation.new(BossImages.zapper, 70, 70, 1, 1)--]]
        if boss.id == 1 then
            boss.speed = 200
            boss.size = 75
            boss.health = 200
            boss.projectileBase = .75
            boss.projectiles = {
                bomb = false,
                tracking = {1,5},
                zigzag = {0,2,4},
                sine = false,
                spiral = false,
                radial = {1,3,5},
                spiral2 = false
            }
            boss.projectileModes = 6
            boss.spriteScale = 3
            boss.sprite = Animation.new(BossImages.zapper, 70, 70, 1, 1)
        elseif boss.id == 2 then
            boss.speed =  200
            boss.size = 75
            boss.health = 225 --350
            boss.projectiles = {
                bomb = {1,3,5,7},
                tracking = {0,4},
                zigzag = {0,2,6},
                sine = false,
                spiral = {1,3,5,7},
                radial = {0,4},
                spiral2 = false,
            }
            boss.projectileBase = .6
            boss.projectileModes = 8
            boss.spriteScale = 2
            boss.sprite = Animation.new(BossImages.cat, 200, 200, 1, 1)
        elseif boss.id == 3 then
            boss.speed = 200
            boss.size = 75
            boss.health = 250 --450
            boss.projectiles = {
                bomb = false,
                tracking = false,
                zigzag = false,
                sine = {0,3,4,7},
                spiral = {1,6,7},
                radial = {3,5,8},
                spiral2 = {0,1,6,7}
            }
            boss.projectileBase = .5
            boss.projectileModes = 9
            boss.spriteScale = 3
            boss.sprite = Animation.new(BossImages.deer, 70, 87, 1, 1)
        elseif boss.id == 4 then
            boss.speed = 200
            boss.size = 75
            boss.health = 275 --550
            boss.projectiles = {
                bomb = {3, 7},
                tracking = {1, 4},
                zigzag = {0, 2},
                sine = {2, 4, 6},
                spiral = {2, 4, 6},
                radial = {0, 5},
                spiral2 = false
            }
            boss.projectileBase = .45
            boss.projectileModes = 8
            boss.spriteScale = 1
            boss.sprite = Animation.new(BossImages.mushroom, 200, 200, 1, 1)
        elseif boss.id == 5 then
            boss.speed = 200
            boss.size = 75
            boss.health = 300 --650
            boss.projectiles = {
                bomb = {6},
                tracking = {1, 3, 5, 7, 11},
                zigzag = {0, 2, 4, 6, 8},
                sine = {1, 3, 6, 9},
                spiral = {2, 3, 5, 8, 10, 11},
                radial = {0, 4, 8, 12},
                spiral2 = {3, 7, 11, 13}
            }
            boss.projectileBase = .4
            boss.projectileModes = 14
            boss.spriteScale = 1
            boss.sprite = Animation.new(BossImages.flower, 200, 200, 1, 1)
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
                    projectiles.spawn(boss)
                end
                boss.projectileModifiers.Spiral = false
                boss.projectileIndex = nil
                boss.projectileCount = nil
                boss.timers.spiral = boss.projectileBase/4
            end
        end
        if boss.modeAllowed(boss.projectiles.sine, mode) then
            if boss.timers.sine <= 0 then
                local dx = player.x - boss.x
                local dy = player.y - boss.y
                local angle = math.atan(dy / dx)
                if dx < 0 then
                    angle = angle + math.pi
                end
                boss.angle = angle - math.rad(160) / 2
                boss.projectileModifiers.Sine = true
                boss.projectileCount = 9
                for i = 0, boss.projectileCount - 1 do
                    boss.projectileIndex = i
                    projectiles.spawn(boss)
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
                projectiles.spawn(boss)
                boss.projectileModifiers.Tracking = false
                boss.timers.tracking = boss.projectileBase
            end
        end
        if boss.modeAllowed(boss.projectiles.bomb, mode) then
            if boss.timers.bomb <= 0 then
                boss.projectileModifiers.Bomb = true
                projectiles.spawn(boss)
                boss.projectileModifiers.Bomb = false
                boss.timers.bomb = boss.projectileBase * 5
            end
        end
        if boss.modeAllowed(boss.projectiles.zigzag, mode) then
            if boss.timers.zigzag <= 0 then
                local dx = player.x - boss.x
                local dy = player.y - boss.y
                local angle = math.atan(dy / dx)
                if dx < 0 then
                    angle = angle + math.pi
                end
                boss.angle = angle - math.rad(120) / 2
                boss.projectileModifiers.Zigzag = true
                boss.projectileCount = 9
                for i = 0, boss.projectileCount - 1 do
                    boss.projectileIndex = i
                    projectiles.spawn(boss)
                end
                boss.projectileModifiers.Zigzag = false
                boss.projectileIndex = nil
                boss.projectileCount = nil
                if boss.id == 4 then
                    boss.timers.zigzag = boss.projectileBase
                else
                    boss.timers.zigzag = boss.projectileBase/2
                end
            end
        end
        if boss.modeAllowed(boss.projectiles.radial, mode) then
            if boss.timers.radial <= 0 then
                boss.projectileModifiers.Radial = true
                boss.projectileCount = 24
                for i = 0, boss.projectileCount - 1 do
                    boss.projectileIndex = i
                    projectiles.spawn(boss)
                end
                boss.projectileModifiers.Radial = false
                boss.projectileIndex = nil
                boss.projectileCount = nil
                boss.timers.radial = boss.projectileBase/3
            end
        end
        if boss.modeAllowed(boss.projectiles.spiral2, mode) then
            if boss.timers.spiral2 <= 0 then
                boss.projectileModifiers.Spiral2 = true
                boss.projectileCount = 24
                for i = 0, boss.projectileCount - 1 do
                    boss.projectileIndex = i
                    projectiles.spawn(boss)
                end
                boss.projectileModifiers.Spiral2 = false
                boss.projectileIndex = nil
                boss.projectileCount = nil
                boss.timers.spiral2 = boss.projectileBase/4
            end
        end
    end
    function boss.draw()
        if boss.id ~= 3 then
            boss.sprite.draw(boss.x, boss.y, boss.spriteScale)
        else
            boss.sprite.draw(boss.x + 10, boss.y - 40, boss.spriteScale)
        end
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