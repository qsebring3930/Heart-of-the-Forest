
function love.load()
    InitWindow()
    InitStage()
end

function love.update(dt)
    GetKeys(dt)
    UpdateProjectiles(dt)
    UpdatePlayerTimer(dt)
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
end

function InitBoss()
    Boss = {}
    Boss.x = Width/2
    Boss.y = Height*1/4
    Boss.size = 50
    Boss.health = 100
end

function UpdatePlayerTimer(dt)
    Player.fireTimer = Player.fireTimer - dt
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

end

function WithinBounds()
    if Player.x + 25 < Window.width and Player.x - 25 > 0 and Player.y + 25 < Window.height and Player.y - 25 > 0 then
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

        -- Remove projectile if off-screen
        if p.y < -10 or p.y > Window.height + 10 or p.x < -10 or p.x > Window.width + 10 then
            table.remove(Projectiles, i)
        end
        if CheckCollision(Projectiles[i], Boss) then
            print("Boss was hit!")
            table.remove(Projectiles, i)
            Boss.health = Boss.health - 1
            if Boss.health <= 0 then
                print("Boss Dead")
            end
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
    love.graphics.circle("fill", Player.x, Player.y, Player.size)
end

function DrawBoss()
    love.graphics.circle("fill", Boss.x, Boss.y, Boss.size)
end

function DrawProjectiles()
    for _, p in ipairs(Projectiles) do
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