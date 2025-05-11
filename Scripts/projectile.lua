local game = require "Scripts/game"
local overlay = require "Scripts/overlay"
local animation = require "Scripts/animation"

function Projectile()
    local projectiles = {}
    local Game = game()
    local Animation = animation()
    function Spawn(owner)
        local p = {
            owner = owner,
            x = owner.x,
            y = owner.y,
            spawnX = owner.x,
            vx = owner.vx or 0,
            vy = owner.vy or 0,
            radius = 2.5,
            speed = 400,
            angularVelocity = 0,
            angle = 0,
            color = Game.Color.White,
            shade = Game.Color.Light,
            wiggly = owner.projectileModifiers.Wiggly or nil,
            spiral = owner.projectileModifiers.Spiral or nil,
            tracking = owner.projectileModifiers.Tracking or nil,
            sine = owner.projectileModifiers.Sine or nil,
            bomb = owner.projectileModifiers.Bomb or nil,
            split = owner.projectileModifiers.Split or nil,
            zigzag = owner.projectileModifiers.Zigzag or nil,
            radial = owner.projectileModifiers.Radial or nil,
            spiral2 = owner.projectileModifiers.Spiral2 or nil,
            isplayer = owner.projectileModifiers.isPlayer or nil,
            sprite = nil,
            spriteScale = 0
        }
        if p.spiral then
            p.speed = 150
            p.color = Game.Color.Pink
            p.shade = Game.Color.Light
            p.angularVelocity = .4
            if owner.projectileIndex and owner.projectileCount then
                p.angle = (owner.projectileIndex / owner.projectileCount) * 2 * math.pi
            else
                p.angle = love.timer.getTime() * 4 * math.pi  -- fallback
            end
            p.sprite = Animation.new(ProjectileImages.point, 29, 30, 1, 1)
            p.spriteScale = 1
        end
        if p.tracking and owner.target then
            p.speed = 150
            p.color = Game.Color.Yellow
            p.shade = Game.Shade.Neon
            local dx = owner.target.x - owner.x
            local dy = owner.target.y - owner.y
            local len = math.sqrt(dx * dx + dy * dy)
            p.vx = (dx / len) * p.speed
            p.vy = (dy / len) * p.speed
            p.sprite = Animation.new(ProjectileImages.tracker, 37, 38, 1, 1)
            p.spriteScale = 1
        end
        if p.sine then
            p.speed = 135
            p.color = Game.Color.Orange
            p.shade = Game.Shade.Neon
            local angle = owner.angle + (owner.projectileIndex / (owner.projectileCount - 1)) * math.rad(160)
            p.vx = math.cos(angle) * p.speed
            p.vy = math.sin(angle) * p.speed
            local perpX = -math.sin(angle)
            local perpY = math.cos(angle)
            p.wiggleTime = 0
            p.wiggleDirX = perpX
            p.wiggleDirY = perpY
            p.sprite = Animation.new(ProjectileImages.drop, 45, 57, 1, 1)
            p.spriteScale = 1
        end
        if p.bomb and owner.target then
            p.color = Game.Color.Purple
            p.shade = Game.Color.Dark
            p.radius = 15
            p.lifetime = 50
            p.speed = 150
            p.targetX = owner.target.x
            p.targetY = owner.target.y
            local dx = owner.target.x - owner.x
            local dy = owner.target.y - owner.y
            local len = math.sqrt(dx * dx + dy * dy)
            p.vx = (dx / len) * p.speed
            p.vy = (dy / len) * p.speed
            p.sprite = Animation.new(ProjectileImages.bomb, 26, 28, 1, 1)
            p.spriteScale = 1
        end
        if p.zigzag then
            p.speed = 110
            local angle = owner.angle + (owner.projectileIndex / (owner.projectileCount - 1)) * math.rad(120)
            p.vx = math.cos(angle) * p.speed
            p.vy = math.sin(angle) * p.speed
            p.color = Game.Color.Blue
            p.shade = Game.Shade.Light
            p.zigzagDir = -1
            p.zigzagTimer = 10
            p.sprite = Animation.new(ProjectileImages.bolt, 43, 45, 1, 1)
            p.spriteScale = 1
        end
        if p.radial then
            p.speed = 135
            p.color = Game.Color.Red
            p.shade = Game.Color.Light
            if owner.projectileIndex and owner.projectileCount then
                p.angle = (owner.projectileIndex / owner.projectileCount) * 2 * math.pi
            else
                p.angle = love.timer.getTime() * 4 * math.pi  -- fallback
            end
            p.sprite = Animation.new(ProjectileImages.ball, 40, 41, 1, 1)
            p.spriteScale = 1
        end
        if p.spiral2 then
            p.speed = 150
            p.color = Game.Color.Pink
            p.shade = Game.Color.Light
            p.angularVelocity = .4
            if owner.projectileIndex and owner.projectileCount then
                p.angle = (owner.projectileIndex / owner.projectileCount) * 2 * math.pi
            else
                p.angle = love.timer.getTime() * 4 * math.pi  -- fallback
            end
            p.sprite = Animation.new(ProjectileImages.fire, 47, 59, 1, 1)
            p.spriteScale = .5
        end
        if p.isplayer then
            p.speed = 600
            p.radius = 3
            p.vx = owner.vx * .5
            p.vy = -900 + owner.vy * 0.3
            p.sprite = Animation.new(ProjectileImages.spit, 45, 35, 1, 1)
            p.spriteScale = .5
        end
        table.insert(projectiles, p)
    end
    function UpdateProjectiles(dt, Player, Boss)
        for i = #Projectiles.list, 1, -1 do
            local p = Projectiles.list[i]
            if p then
                if p.wiggly then
                    p.x = p.spawnX + math.sin(p.y * 0.05) * 30
                    p.y = p.y + p.vy * dt
                elseif p.spiral then
                    p.angle = p.angle + (p.angularVelocity or 0) * dt
                    local dx = math.cos(p.angle) * (p.speed or 0) * dt
                    local dy = math.sin(p.angle) * (p.speed or 0) * dt
                    p.x = p.x + dx
                    p.y = p.y + dy
                elseif p.sine then
                    p.wiggleTime = (p.wiggleTime or 0) + dt
                    local offset = math.sin(p.wiggleTime * 15) * .75
                    local forwardX = p.vx * dt
                    local forwardY = p.vy * dt
                    local perpX = p.wiggleDirX * offset
                    local perpY = p.wiggleDirY * offset
                    p.x = p.x + forwardX + perpX
                    p.y = p.y + forwardY + perpY
                elseif p.bomb then
                    local dx = p.targetX - p.x
                    local dy = p.targetY - p.y
                    local distance = math.sqrt(dx * dx + dy * dy)
                    if distance >= 5 then
                        p.x = p.x + p.vx * dt
                        p.y = p.y + p.vy * dt
                    else
                        p.lifetime = p.lifetime - 1
                        if p.lifetime == 0 then
                            local split = {
                                x = p.x,
                                y = p.y,
                                vx = p.vx,
                                vy = p.vy,
                                projectileModifiers = {
                                    Tracking = true,
                                    Split = true
                                },
                                target = Player,
                                owner = Boss
                            }
                            Projectiles.spawn(split)
                            table.remove(Projectiles.list, i)
                        end
                    end
                elseif p.zigzag then
                    p.zigzagTimer = (p.zigzagTimer or 0) + dt
                    local interval = 1
                    if p.zigzagTimer >= interval then
                        p.zigzagDir = -(p.zigzagDir or -1)
                        p.zigzagTimer = 0
                    end
                    local dx = p.vx * dt
                    local dy = p.vy * 1.25 * dt
                    local zigzagX = (p.zigzagDir or -1) * 100 * dt
                    p.x = p.x + dx + zigzagX
                    p.y = p.y + dy
                elseif p.radial then
                    local dx = math.cos(p.angle) * (p.speed or 0) * dt
                    local dy = math.sin(p.angle) * (p.speed or 0) * dt
                    p.x = p.x + dx
                    p.y = p.y + dy
                elseif p.spiral2 then
                    p.angle = p.angle - (p.angularVelocity or 0) * dt
                    local dx = math.cos(p.angle) * (p.speed or 0) * dt
                    local dy = math.sin(p.angle) * (p.speed or 0) * dt
                    p.x = p.x + dx
                    p.y = p.y + dy
                else
                    p.x = p.x + p.vx * dt
                    p.y = p.y + p.vy * dt
                end
                p.radius = p.radius + 1.25 * dt
                if p.sprite then
                    p.sprite.update(dt)
                end
                local isBossProjectile = (p.owner == Boss) or (p.split)
                local hitBoss = p.owner == Player and CheckCollision(p, Boss)
                local hitPlayer = isBossProjectile and CheckCollision(p, Player)

                local outOfBounds = p.y < -10 or p.y > Window.height + 10 or p.x < -10 or p.x > Window.width + 10

                if hitBoss or hitPlayer or outOfBounds then
                    if hitBoss then
                        print("Boss was hit!")
                        Boss.health = Boss.health - 1
                        if Boss.health <= 0 and not GameState.fading then
                            GameState.transition()
                            overlay.set(0)
                        end
                        table.remove(Projectiles.list, i)
                    elseif hitPlayer then
                        Player.hit()
                        table.remove(Projectiles.list, i)
                        if overlay.intensity >= 2 then
                            GameState.staged = false
                            GameState.gameover = true
                            overlay.set(0)
                        end
                    else
                        table.remove(Projectiles.list, i)
                    end
                end
            end
        end
    end
    function CheckCollision(a, b)
        local dx = a.x - b.x
        local dy = a.y - b.y
        local distance = math.sqrt(dx * dx + dy * dy)
        return distance < (a.size or a.radius) + (b.size or b.radius)
    end
    function DrawProjectiles()
        for _, p in ipairs(Projectiles.list) do
            if p.sprite then
                p.sprite.draw(p.x, p.y, p.spriteScale)
            end
        end
    end
    return {
        list = projectiles,
        spawn = Spawn,
        update = UpdateProjectiles,
        draw = DrawProjectiles
    }
end

return Projectile