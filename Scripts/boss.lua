local animation = require "Scripts/animation"
local game = require "Scripts/game"

function Boss(x, y, player, stage)
    local Animation = animation()
    local Game = game()
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
        spriteScale = 0,
        healthRatio = 0,
        enraged = false,
    }
    function boss.stage()
        if boss.id == 1 then
            boss.init(400, 0.25, {tracking = {1, 5}, zigzag = {0, 2, 4}, radial = {1, 3, 5}}, 6, 3, BossImages.zapper, 70, 70)
        elseif boss.id == 2 then
            boss.init(450, 0.25, {bomb = {1, 3, 5},tracking = {0, 4}, zigzag = {0, 2, 6},spiral = {1, 3, 5, 7},radial = {0, 4}}, 8, 2, BossImages.cat, 200, 200)
        elseif boss.id == 3 then
            boss.init(500, 0.2, {sine = {0, 3, 4, 7},spiral = {1, 6, 7},radial = {3, 5, 8},spiral2 = {0, 1, 6, 7}}, 9, 3, BossImages.deer, 70, 87)
        elseif boss.id == 4 then
            boss.init(550, 0.2, {bomb = {3, 7},tracking = {1, 4},zigzag = {0, 2},sine = {2, 4, 6},spiral = {2, 4, 6},radial = {0, 5}}, 8, 1, BossImages.mushroom, 200, 200)
        elseif boss.id == 5 then
            boss.init(600, 0.2, {bomb = {6},tracking = {1, 3, 5, 7, 11},zigzag = {0, 2, 4, 6, 8},sine = {1, 3, 6, 9},spiral = {2, 3, 5, 8, 10, 11},radial = {0, 4, 8, 12},spiral2 = {3, 7, 11, 13}}, 14, 1, BossImages.flower, 200, 200)
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
                if boss.health / boss.healthRatio <= 0.25 then
                    boss.patternIndex = (boss.patternIndex + 1) % boss.projectileModes
                    if not boss.enraged then
                        boss.projectileBase = boss.projectileBase - .05
                        boss.enraged = true
                    end
                else
                    boss.patternIndex = love.math.random(0, boss.projectileModes - 1)
                end
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
        local dx = player.x - boss.x
        local dy = player.y - boss.y
        local function calcAngle(offset)
            local angle = math.atan(dy / dx)
            if dx < 0 then angle = angle + math.pi end
            return angle - math.rad(offset)
        end

        boss.tryShoot("spiral", "Spiral", function() return love.math.random(2, 5) * 7 end, 35, nil, Sounds.point, projectiles)
        boss.tryShoot("sine", "Sine", function() return love.math.random(1, 3) * 3 end, 9, function() return calcAngle(180 / 2) end, Sounds.drop, projectiles)
        boss.tryShoot("tracking", "Tracking", function() return 1 end, nil, nil, Sounds.tracker, projectiles)
        boss.tryShoot("bomb", "Bomb", function() return 1 end, nil, nil, Sounds.bomb, projectiles)
        boss.tryShoot("zigzag", "Zigzag", function() return love.math.random(2, 6) end, 6, function() return calcAngle(125 / 2) end, Sounds.bolt, projectiles)
        boss.tryShoot("radial", "Radial", function() return love.math.random(2, 5) * 7 end, 35, nil, Sounds.ball, projectiles)
        boss.tryShoot("spiral2", "Spiral2", function() return love.math.random(2, 5) * 7 end, 35, nil, Sounds.fire, projectiles)
    end
    function boss.tryShoot(key, modifierName, countFunc, enrageCount, angleFunc, sound, projectiles)
        if boss.modeAllowed(boss.projectiles[key], boss.patternIndex) then
            if boss.timers[key] <= 0 then
                if angleFunc then
                    boss.angle = angleFunc()
                end
                boss.projectileModifiers[modifierName] = true
                if boss.enraged and enrageCount then
                    boss.projectileCount = enrageCount
                else
                    boss.projectileCount = countFunc()
                end
                for i = 0, boss.projectileCount - 1 do
                    boss.projectileIndex = i
                    projectiles.spawn(boss)
                end
                boss.projectileModifiers[modifierName] = false
                boss.projectileIndex = nil
                boss.projectileCount = nil
                boss.timers[key] = boss.projectileBase
                sound:play()
            end
        end
    end
    function boss.draw()
        if boss.id ~= 3 then
            boss.sprite.draw(boss.x, boss.y, boss.spriteScale)
        else
            boss.sprite.draw(boss.x + 10, boss.y - 40, boss.spriteScale)
        end
        if boss.health / boss.healthRatio <= 0.25 then
            Game.Color.Set(Game.Color.Red, Game.Shade.Neon)
            love.graphics.print("ENRAGED!", Window.width/2 - GameFont:getWidth("ENRAGED!")/8, 20, 0, .25, .25)
        else
            Game.Color.Set(Game.Color.Red, Game.Shade.Dark)
        end
        if boss.healthRatio == 0 then
            boss.healthRatio = boss.health
        end
        local barWidth = Window.width * (boss.health / boss.healthRatio)
        love.graphics.rectangle("fill", (Window.width - barWidth) / 2, 0, barWidth, 20, 5, 5)
        if boss.health < 200 then

        end
        Game.Color.Clear()
    end
    function boss.init(health, projectileBase, modes, projectileModes, spriteScale, spriteImage, frameW, frameH)
        boss.health = health
        boss.healthRatio = health
        boss.projectileBase = projectileBase
        boss.projectiles = {}

        local keys = { "bomb", "tracking", "zigzag", "sine", "spiral", "radial", "spiral2" }
        for _, key in ipairs(keys) do
            boss.projectiles[key] = modes[key] or false
        end

        boss.projectileModes = projectileModes
        boss.spriteScale = spriteScale
        boss.sprite = Animation.new(spriteImage, frameW, frameH, 1, 1)
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