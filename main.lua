
function love.load()
    window = {translateX = 40, translateY = 40, scale = 2, width = 1920, height = 1080}
	width, height = love.graphics.getDimensions ()
	love.window.setMode (width, height, {resizable=true, borderless=false})
	resize (width, height) -- update new translation and scale

    Player = {}
    Player.x = width/2
    Player.y = height*3/4
    Player.speed = 300

    Projectiles = {}
end

function love.update(dt)
    local mx = math.floor ((love.mouse.getX()-window.translateX)/window.scale+0.5)
	local my = math.floor ((love.mouse.getY()-window.translateY)/window.scale+0.5)
    if love.keyboard.isDown("d") and Player.x + 25 < window.width then
        Player.x = Player.x + Player.speed * dt
    end
    if love.keyboard.isDown("a") and Player.x - 25 > 0 then
        Player.x = Player.x - Player.speed * dt
    end
    if love.keyboard.isDown("s") and Player.y + 25 < window.height then
        Player.y = Player.y + Player.speed * dt
    end
    if love.keyboard.isDown("w") and Player.y - 25 > 0 then
        Player.y = Player.y - Player.speed * dt
    end
    if love.keyboard.isDown("f") then
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
            window.scale = 1
        else
            love.window.setFullscreen(true)
            window.scale = 4
        end
    end
    if love.keyboard.isDown("space") then
        spit(dt)
    end
end

function spit(dt)

end


function love.draw()
    -- first translate, then scale
	love.graphics.translate (window.translateX, window.translateY)
	love.graphics.scale (window.scale)
	-- your graphics code here, optimized for fullHD
	love.graphics.rectangle('line', 0, 0, 1920, 1080)
    love.graphics.circle("fill", Player.x, Player.y, 20)
end

function resize(w, h)
    local w1, h1 = window.width, window.height -- target rendering resolution
	local scale = math.min (w/w1, h/h1)
	window.translateX, window.translateY, window.scale = (w-w1*scale)/2, (h-h1*scale)/2, scale
end

function love.resize (w, h)
	resize (w, h) -- update new translation and scale
    print("New window size: ", w, h)
end