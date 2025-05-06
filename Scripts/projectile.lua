local love = require "love"
local game = require "game"

function Projectile(owner)
    local projectiles = {} 
    function spawn(owner)
        local p = {
            owner = owner,
            x = owner.x,
            y = owner.y,
            spawnX = owner.x,
            vx = owner.vx or 0,
            vy = owner.vy or 0,
            radius = 5,
            speed = 500,
            angularVelocity = 0,
            angle = 0,
            wiggly = owner.projectileModifiers.Wiggly or nil,
            radial = owner.projectileModifiers.Radial or nil,
            tracking = owner.projectileModifiers.Tracking or nil,
            sine = owner.projectileModifiers.Sine or nil
        }
        if p.radial then
            p.angularVelocity = 1
            if owner.projectileIndex and owner.projectileCount then
                p.angle = (owner.projectileIndex / owner.projectileCount) * 2 * math.pi
            else
                p.angle = love.timer.getTime() * 4 * math.pi  -- fallback
            end
        end
        if p.tracking and owner.target then
            local dx = owner.target.x - owner.x
            local dy = owner.target.y - owner.y
            local len = math.sqrt(dx * dx + dy * dy)
            p.vx = (dx / len) * p.speed
            p.vy = (dy / len) * p.speed
        end
        if p.sine then 
            local angle = owner.angle + (owner.projectileIndex / (owner.projectileCount - 1)) * math.rad(120)
            p.vx = math.cos(angle) * p.speed
            p.vy = math.sin(angle) * p.speed
            local perpX = -math.sin(angle)
            local perpY = math.cos(angle)
            p.wiggleTime = 0
            p.wiggleDirX = perpX
            p.wiggleDirY = perpY
        end
        if owner == Player then
            p.radius = 3
            p.vx = owner.vx * .5
            p.vy = -900 + owner.vy * 0.3
        end
        table.insert(projectiles, p)
    end
    return {
        list = projectiles,
        spawn = spawn
    }
end

return Projectile