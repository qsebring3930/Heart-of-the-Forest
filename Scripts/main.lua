local love = require "love"
local player = require "player"
local game = require "game"
local projectile = require "projectile"
local boss = require "boss"


function love.load()
    InitWindow()
    InitStage()
end

function love.update(dt)
    GetKeys(dt)
    UpdateProjectiles(dt)
    Boss.shoot(Projectiles, dt)
    UpdateTimers(dt)
end

function love.draw()
    -- first translate, then scale
	love.graphics.translate (Window.translateX, Window.translateY)
	love.graphics.scale (Window.scale)
	-- your graphics code here, optimized for fullHD
	love.graphics.rectangle('line', 0, 0, 1920, 1080)
    DrawEntities()
end

function InitWindow()
    Window = {translateX = 40, translateY = 40, scale = 1, width = 1280, height = 720}
    love.window.setMode(Window.width, Window.height, {resizable=false, borderless=false})
    Width, Height = love.graphics.getDimensions()
    Resize(Width, Height) -- update new translation and scale
end

function InitStage()
    Game = game()
    Player = player(Width / 2, Height * 3 / 4)
    Projectiles = projectile()
    Boss = boss(Width / 2, Height * 1 / 4, Player)
    InitEntities()
end

function InitEntities()
    BossProjectiles = {}
end

function UpdateTimers(dt)
    Player.fireTimer = Player.fireTimer - dt
    Boss.fireTimer = Boss.fireTimer - dt
end

function WithinBounds()
    if Player.x + 10 <= Window.width and Player.x - 10 >= 0 and Player.y + 10 <= Window.height and Player.y - 10 >= 0 then
        return true
    else
        return false
    end
end

function GetKeys(dt)
    if love.keyboard.isDown('w', 'a', 's', 'd') then
        if love.keyboard.isDown("d") and WithinBounds() then
            Player.move(Game.Direction.Right, dt)
        end
        if love.keyboard.isDown("a") and WithinBounds() then
            Player.move(Game.Direction.Left, dt)
        end
        if love.keyboard.isDown("s") and WithinBounds() then
            Player.move(Game.Direction.Down, dt)
        end
        if love.keyboard.isDown("w") and WithinBounds() then
            Player.move(Game.Direction.Up, dt)
        end
    else
        Player.move(Game.Direction.None, dt)
    end
    if love.keyboard.isDown("space") and Player.fireTimer <= 0 then
        Player.shoot(Projectiles)
    end
end


function UpdateProjectiles(dt)
    for i = #Projectiles.list, 1, -1 do
        local p = Projectiles.list[i]
        p.y = p.y + p.vy * dt
        if p.wiggly then
            p.x = p.spawnX + math.sin(p.y * 0.05) * 30
        elseif p.radial then
            p.angle = p.angle + (p.angularVelocity or 0) * dt
            local dx = math.cos(p.angle) * (p.speed or 0) * dt
            local dy = math.sin(p.angle) * (p.speed or 0) * dt
            p.x = p.x + dx
            p.y = p.y + dy
        elseif p.sine then
            p.wiggleTime = (p.wiggleTime or 0) + dt
            local offset = math.sin(p.wiggleTime * 15) * 1.2
            local forwardX = p.vx * dt
            local forwardY = p.vy * dt
            local perpX = p.wiggleDirX * offset
            local perpY = p.wiggleDirY * offset
            p.x = p.x + forwardX + perpX
            p.y = p.y + forwardY + perpY
        else
            p.x = p.x + p.vx * dt
        end

        local hitBoss = p.owner == Player and CheckCollision(p, Boss)
        local hitPlayer = p.owner == Boss and CheckCollision(p, Player)
        local outOfBounds = p.y < -10 or p.y > Window.height + 10 or p.x < -10 or p.x > Window.width + 10

        if hitBoss or hitPlayer or outOfBounds then
            if hitBoss then
                print("Boss was hit!")
                Boss.health = Boss.health - 1
                table.remove(Projectiles.list, i)
            elseif hitPlayer then
                print("Player was hit!")
                Player.health = Player.health - 1
                table.remove(Projectiles.list, i)
            else
                table.remove(Projectiles.list, i)   
            end
        end
    end
end

function love.keypressed(key)
    if key == "p" then
        Player.projectileModifiers.Wiggly = not Player.projectileModifiers.Wiggly
    elseif key == "f" then
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
            Window.scale = 1
        else
            love.window.setFullscreen(true)
            Window.scale = 4
        end
    end
end

function CheckCollision(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < (a.size or a.radius) + (b.size or b.radius)
end

function SpawnBossProjectile(x, y, vx, vy)
    local p = {
        x = x,
        y = y,
        vx = vx or 0,
        vy = vy or 200,
        radius = 5,
        wiggly = false
    }
    table.insert(BossProjectiles, p)
end


function ProjectileModifiers(p)
    if Player.projectileModifiers.Wiggly then
        p.wiggly = true
    end
end

function DrawEntities()
    DrawPlayer()
    DrawBoss()
    DrawProjectiles()
end

function DrawPlayer()
    Color(Game.Color.Green, Game.Shade.Neon)
    if Player.health <= 0 then
        Color(Game.Color.Red, Game.Shade.Dark)
    end
    love.graphics.circle("fill", Player.x, Player.y, Player.size)
    Game.Color.Clear()
end

function DrawBoss()
    Color(Game.Color.Blue, Game.Shade.Neon)
    if Boss.health <= 0 then
        Color(Game.Color.Red, Game.Shade.Dark)
    end
    love.graphics.circle("fill", Boss.x, Boss.y, Boss.size)
    Game.Color.Clear()
end

function DrawProjectiles()
    for _, p in ipairs(Projectiles.list) do
        love.graphics.circle("fill", p.x, p.y, p.radius)
    end
    for _, p in ipairs(BossProjectiles) do
        love.graphics.circle("fill", p.x, p.y, p.radius)
    end
end

function Resize(w, h)
    local w1, h1 = Window.width, Window.height -- target rendering resolution
	local scale = math.min (w/w1, h/h1)
	Window.translateX, Window.translateY, Window.scale = (w-w1*scale)/2, (h-h1*scale)/2, scale
end

function love.resize (w, h)
	Resize(w, h) -- update new translation and scale
    print("New window size: ", w, h)
end

function Color(color, shade)
    local r, g, b, a = 1, 1, 1, 1

    -- Base color mapping
    if color == Game.Color.Black then
        r, g, b = 0, 0, 0
    elseif color == Game.Color.White then
        r, g, b = 1, 1, 1
    elseif color == Game.Color.Red then
        r, g, b = 1, 0, 0
    elseif color == Game.Color.Orange then
        r, g, b = 1, 0.5, 0
    elseif color == Game.Color.Yellow then
        r, g, b = 1, 1, 0
    elseif color == Game.Color.Green then
        r, g, b = 0, 1, 0
    elseif color == Game.Color.Blue then
        r, g, b = 0, 0, 1
    elseif color == Game.Color.Purple then
        r, g, b = 0.5, 0, 1
    elseif color == Game.Color.Pink then
        r, g, b = 1, 0.3, 0.6
    elseif color == Game.Color.Brown then
        r, g, b = 0.5, 0.25, 0.1
    end

    -- Shade modifiers
    if shade == Game.Shade.Dark then
        r = r * 0.4
        g = g * 0.4
        b = b * 0.4
    elseif shade == Game.Shade.Light then
        r = r + (1 - r) * 0.5
        g = g + (1 - g) * 0.5
        b = b + (1 - b) * 0.5
    elseif shade == Game.Shade.Neon then
        r = r + (1 - r) * 0.2
        g = g + (1 - g) * 0.2
        b = b + (1 - b) * 0.2
    end

    love.graphics.setColor(r, g, b, a)
end