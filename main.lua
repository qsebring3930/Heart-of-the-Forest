
function love.load()
    Window = {translateX = 40, translateY = 40, scale = 2, width = 1920, height = 1080}
	Width, Height = love.graphics.getDimensions ()
	love.window.setMode (Width, Height, {resizable=true, borderless=false})
	Resize (Width, Height) -- update new translation and scale

    Player = {}
    Player.x = Width/2
    Player.y = Height*3/4
    Player.speed = 300
    Player.fireCooldown = 0.1 -- seconds between shots
    Player.fireTimer = 0

    Projectiles = {}
end

function love.update(dt)
    local mx = math.floor ((love.mouse.getX()-Window.translateX)/Window.scale+0.5)
	local my = math.floor ((love.mouse.getY()-Window.translateY)/Window.scale+0.5)

    GetKeys(dt)
    UpdateProjectiles(dt)
    UpdatePlayer(dt)
end

function UpdatePlayer(dt)
    Player.fireTimer = Player.fireTimer - dt
end

function GetKeys(dt)
    if love.keyboard.isDown("d") and Player.x + 25 < Window.width then
        Player.x = Player.x + Player.speed * dt
    end
    if love.keyboard.isDown("a") and Player.x - 25 > 0 then
        Player.x = Player.x - Player.speed * dt
    end
    if love.keyboard.isDown("s") and Player.y + 25 < Window.height then
        Player.y = Player.y + Player.speed * dt
    end
    if love.keyboard.isDown("w") and Player.y - 25 > 0 then
        Player.y = Player.y - Player.speed * dt
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
        SpawnProjectile(Player.x, Player.y)
        Player.fireTimer = Player.fireCooldown
    end
end


function UpdateProjectiles(dt)
    for i = #Projectiles, 1, -1 do
        local p = Projectiles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt

        -- Remove projectile if off-screen
        if p.y < -10 or p.y > Window.height + 10 or p.x < -10 or p.x > Window.width + 10 then
            table.remove(Projectiles, i)
        end
    end
end

function SpawnProjectile(x, y)
    local p = {
        x = x,
        y = y,
        vx = 0,
        vy = -500,
        radius = 5
    }
    table.insert(Projectiles, p)
end

function DrawEntities()
    DrawPlayer()
    DrawProjectiles()
end

function DrawPlayer()
    love.graphics.circle("fill", Player.x, Player.y, 20)
end

function DrawProjectiles()
    for _, p in ipairs(Projectiles) do
        love.graphics.circle("fill", p.x, p.y, p.radius)
    end
end

function love.draw()
    -- first translate, then scale
	love.graphics.translate (Window.translateX, Window.translateY)
	love.graphics.scale (Window.scale)
	-- your graphics code here, optimized for fullHD
	love.graphics.rectangle('line', 0, 0, 1920, 1080)
    DrawEntities()
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