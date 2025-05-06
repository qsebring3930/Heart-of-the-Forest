local love = require "love"
local game = require "game"

function Projectile(owner)
    local projectiles = {} 
    function spawn(owner, vx, vy)
        local p = {
            x = owner.x,
            y = owner.y,
            spawnX = owner.x,
            vx = vx,
            vy = vy,
            radius = 3,
            wiggly = owner.projectileModifiers.Wiggly
        }
        table.insert(projectiles, p)
    end
    return {
        list = projectiles,
        spawn = spawn
    }
end

return Projectile