
function love.load()
    InitWindow()
    InitStage()
end

function love.update(dt)
    GetKeys(dt)
    UpdateProjectiles(dt)
    UpdateEntities(dt)
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
    InitPlayer()
    InitHelpers()
    InitBoss()
    InitEntities()
end

function InitHelpers()
    Direction = {}
    Direction.Left = "left"
    Direction.Right = "right"
    Direction.Up = "up"
    Direction.Down = "down"
    Colors = {}
    Colors.Red = "red"
    Colors.Orange = "orange"
    Colors.Yellow = "yellow"
    Colors.Green = "green"
    Colors.Blue = "blue"
    Colors.Purple = "purple"
    Colors.Pink = "pink"
    Colors.Brown = "brown"
    Colors.White = "white"
    Colors.Black = "black"

    Shades = {}
    Shades.Dark = "dark"
    Shades.Light = "light"
    Shades.Neon = "neon"

end

function InitPlayer()
    Player = {}
    Player.x = Width/2
    Player.y = Height*3/4
    Player.vx = 0
    Player.vy = 0
    Player.size = 10
    Player.speed = 300
    Player.fireCooldown = 0.05 -- seconds between shots
    Player.fireTimer = 0
    Player.projectileModifiers = {}
end

function InitEntities()
    Projectiles = {}
    BossProjectiles = {}
end

function InitBoss()
    Boss = {}
    Boss.x = Width/2
    Boss.y = Height*1/4
    Boss.size = 50
    Boss.health = 10
    Boss.fireCooldown = 0.5  -- seconds between shots
    Boss.fireTimer = 0
    Boss.SpiralAngle = 0
end

function UpdateTimers(dt)
    Player.fireTimer = Player.fireTimer - dt
    Boss.fireTimer = Boss.fireTimer - dt
end

function UpdateEntities(dt)
    UpdateBoss(dt)
end

function UpdateBoss(dt)
    Boss.fireTimer = Boss.fireTimer - dt
    if Boss.fireTimer <= 0 then
        local mode = math.floor(love.timer.getTime()) % 3

        if mode == 0 then
            FireRadialProjectiles()
        elseif mode == 1 then
            FireSineProjectiles()
        elseif mode == 2 then
            FireAimedProjectile(Player)
        end

        Boss.fireTimer = Boss.fireCooldown
    end
end

function FireRadialProjectiles()
    local bullets = 16
    local baseAngle = love.timer.getTime() * 2  -- constantly shifting starting point

    for i = 0, bullets - 1 do
        local angle = baseAngle + (i / bullets) * 2 * math.pi
        local speed = 500
        local p = {
            x = Boss.x,
            y = Boss.y,
            radius = 5,
            spiral = true,
            angle = angle,
            speed = speed,
            angularVelocity = 1 -- radians per second
        }
        table.insert(BossProjectiles, p)
    end
end

function FireSineProjectiles()
    local bullets = 5
    local spread = math.rad(50) -- total cone angle
    local dx = Player.x - Boss.x
    local dy = Player.y - Boss.y
    local baseAngle = math.atan(dy / dx)
    if dx < 0 then baseAngle = baseAngle + math.pi end

    local startAngle = baseAngle - spread / 2

    for i = 0, bullets - 1 do
        local angle = startAngle + (i / (bullets - 1)) * spread
        local speed = 500
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        local perpX = -math.sin(angle)
        local perpY = math.cos(angle)

        local p = {
            x = Boss.x,
            y = Boss.y,
            vx = vx,
            vy = vy,
            radius = 5,
            wiggly = true,
            wiggleTime = 0,
            wiggleDirX = perpX,
            wiggleDirY = perpY
        }

        table.insert(BossProjectiles, p)
    end
end

function FireAimedProjectile(target)
    local dx = target.x - Boss.x
    local dy = target.y - Boss.y
    local len = math.sqrt(dx * dx + dy * dy)
    local speed = 500
    local vx = (dx / len) * speed
    local vy = (dy / len) * speed
    SpawnBossProjectile(Boss.x, Boss.y, vx, vy)
end


function MovePlayer(direction, dt)
    local dx, dy = 0, 0
    local magnitude = Player.speed * dt
    if direction == Direction.Left then
        dx = dx - 1
    end
    if direction == Direction.Right then
        dx = dx + 1
    end
    if direction == Direction.Up then
        dy = dy - 1
    end
    if direction == Direction.Down then
        dy = dy + 1
    end
    if direction == Direction.None then
        dx = 0
        dy = 0
    end
    if dx ~= 0 or dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        dx = dx / len
        dy = dy / len
    end

    Player.vx = dx * magnitude/dt
    Player.vy = dy * magnitude/dt

    Player.x = Player.x + Player.vx * dt
    Player.y = Player.y + Player.vy * dt

    Player.x = math.max(Player.size, math.min(Window.width - Player.size, Player.x))
    Player.y = math.max(Player.size, math.min(Window.height - Player.size, Player.y))

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
            MovePlayer(Direction.Right, dt)
        end
        if love.keyboard.isDown("a") and WithinBounds() then
            MovePlayer(Direction.Left, dt)
        end
        if love.keyboard.isDown("s") and WithinBounds() then
            MovePlayer(Direction.Down, dt)
        end
        if love.keyboard.isDown("w") and WithinBounds() then
            MovePlayer(Direction.Up, dt)
        end
    else
        MovePlayer(Direction.None, dt)
    end
    if love.keyboard.isDown("f") then
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
            Window.scale = 1
        else
            love.window.setFullscreen(true)
            Window.scale = 4
        end
    end
    if love.keyboard.isDown("space") and Player.fireTimer <= 0 then
        SpawnProjectile(Player.x, Player.y, Player.vx, Player.vy)
        Player.fireTimer = Player.fireCooldown
    end
end


function UpdateProjectiles(dt)
    for i = #Projectiles, 1, -1 do
        local p = Projectiles[i]
        p.y = p.y + p.vy * dt
        if p.wiggly then
            p.x = p.spawnX + math.sin(p.y * 0.05) * 30
        else
            p.x = p.x + p.vx * dt
        end

        local hitBoss = CheckCollision(p, Boss)
        local outOfBounds = p.y < -10 or p.y > Window.height + 10 or p.x < -10 or p.x > Window.width + 10

        if hitBoss or outOfBounds then
            if hitBoss then
                print("Boss was hit!")
                Boss.health = Boss.health - 1
            end
            table.remove(Projectiles, i)
        end
    end

    for i = #BossProjectiles, 1, -1 do
        local p = BossProjectiles[i]

        if p.wiggly then
            p.wiggleTime = (p.wiggleTime or 0) + dt
            local offset = math.sin(p.wiggleTime * 15) * 2
            local forwardX = p.vx * dt
            local forwardY = p.vy * dt
            local perpX = p.wiggleDirX * offset
            local perpY = p.wiggleDirY * offset
            p.x = p.x + forwardX + perpX
            p.y = p.y + forwardY + perpY
        elseif p.spiral then
            p.angle = p.angle + (p.angularVelocity or 0) * dt
            local dx = math.cos(p.angle) * (p.speed or 0) * dt
            local dy = math.sin(p.angle) * (p.speed or 0) * dt
            p.x = p.x + dx
            p.y = p.y + dy
        else
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
        end

        -- Remove if off-screen
        local hitPlayer = CheckCollision(p, Player)
        local outOfBounds = p.y < -10 or p.y > Window.height + 10 or p.x < -10 or p.x > Window.width + 10

        if hitPlayer or outOfBounds then
            if hitPlayer then
                print("Player was hit!")
            end
            table.remove(BossProjectiles, i)
        end
    end
end

function love.keypressed(key)
    if key == "p" then
        Player.projectileModifiers.Wiggly = not Player.projectileModifiers.Wiggly
    end
end

function CheckCollision(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < (a.size or a.radius) + (b.size or b.radius)
end

function SpawnProjectile(x, y, vx, vy)
    local p = {
        x = x,
        y = y,
        spawnX = x,
        vx = vx * .5,
        vy = -900 + vy * .3,
        radius = 3,
        wiggly = false
    }
    ProjectileModifiers(p)
    table.insert(Projectiles, p)
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
    Color(Colors.Green, Shades.Neon)
    love.graphics.circle("fill", Player.x, Player.y, Player.size)
    ResetColor()
end

function DrawBoss()
    Color(Colors.Blue, Shades.Neon)
    if Boss.health <= 0 then
        Color(Colors.Red, Shades.Dark)
    end
    love.graphics.circle("fill", Boss.x, Boss.y, Boss.size)
    ResetColor()
end

function DrawProjectiles()
    for _, p in ipairs(Projectiles) do
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
    if color == Colors.Black then
        r, g, b = 0, 0, 0
    elseif color == Colors.White then
        r, g, b = 1, 1, 1
    elseif color == Colors.Red then
        r, g, b = 1, 0, 0
    elseif color == Colors.Orange then
        r, g, b = 1, 0.5, 0
    elseif color == Colors.Yellow then
        r, g, b = 1, 1, 0
    elseif color == Colors.Green then
        r, g, b = 0, 1, 0
    elseif color == Colors.Blue then
        r, g, b = 0, 0, 1
    elseif color == Colors.Purple then
        r, g, b = 0.5, 0, 1
    elseif color == Colors.Pink then
        r, g, b = 1, 0.3, 0.6
    elseif color == Colors.Brown then
        r, g, b = 0.5, 0.25, 0.1
    end

    -- Shade modifiers
    if shade == Shades.Dark then
        r = r * 0.4
        g = g * 0.4
        b = b * 0.4
    elseif shade == Shades.Light then
        r = r + (1 - r) * 0.5
        g = g + (1 - g) * 0.5
        b = b + (1 - b) * 0.5
    elseif shade == Shades.Neon then
        r = r + (1 - r) * 0.2
        g = g + (1 - g) * 0.2
        b = b + (1 - b) * 0.2
    end

    love.graphics.setColor(r, g, b, a)
end

function ResetColor()
    love.graphics.setColor(1, 1, 1, 1)
end