local love = require "love"
local player = require "player"
local game = require "game"
local projectile = require "projectile"
local boss = require "boss"
local gamestate = require "gamestate"
local button = require "button"


function love.load()
    Game = game()
    GameState = gamestate()
    InitWindow()
    InitStage()
    Debug = ""
    DebugY = 100
end

function love.update(dt)
    GetKeys(dt)
    if GameState.staged and not GameState.paused and not GameState.gameover then
        Projectiles.update(dt, Player, Boss)
        Boss.update(dt)
        Boss.shoot(Projectiles, dt)
        Player.update(dt)
    end
end

function love.draw()
    -- first translate, then scale
	love.graphics.translate (Window.translateX, Window.translateY)
	love.graphics.scale (Window.scale)
	love.graphics.rectangle('line', 0, 0, 1920, 1080)

    love.graphics.print(Debug, 100, DebugY)

    if GameState.running then
        GameState.draw()
        if GameState.staged and not GameState.paused and not GameState.gameover then 
            Player.draw()
            Projectiles.draw() 
            Boss.draw() 
        end
    end
end

function InitWindow()
    Window = {translateX = 40, translateY = 40, scale = 1, width = 1280, height = 720}
    love.window.setMode(Window.width, Window.height, {resizable=false, borderless=false})
    Width, Height = love.graphics.getDimensions()
    Resize(Width, Height) -- update new translation and scale
end

function InitStage()
    Player = player(Width / 2, Height * 3 / 4)
    Boss = boss(Width / 2, Height * 1 / 4, Player, GameState.stagenum)
    Debug = GameState.stagenum
    Boss.stage()
    Projectiles = projectile()
end

function WithinBounds()
    if Player.x + 10 <= Window.width and Player.x - 10 >= 0 and Player.y + 10 <= Window.height and Player.y - 10 >= 0 then
        return true
    end
    return false
end

function GetKeys(dt)
    if love.keyboard.isDown('w', 'a', 's', 'd') and WithinBounds() then
        if love.keyboard.isDown("d") then
            Player.move(Game.Direction.Right, dt)
        end
        if love.keyboard.isDown("a") then
            Player.move(Game.Direction.Left, dt)
        end
        if love.keyboard.isDown("s") then
            Player.move(Game.Direction.Down, dt)
        end
        if love.keyboard.isDown("w") then
            Player.move(Game.Direction.Up, dt)
        end
    else
        Player.move(Game.Direction.None, dt)
    end
    if love.keyboard.isDown("space") and Player.fireTimer <= 0 then
        Player.shoot(Projectiles)
    end
end

function love.keypressed(key)
    if key == "z" then
        Player.projectileModifiers.Wiggly = not Player.projectileModifiers.Wiggly
    elseif key == "f" then
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
            Window.scale = 1
        else
            love.window.setFullscreen(true)
            Window.scale = 4
        end
    elseif key == "t" then
        GameState.transition()
    elseif key == "p" or key == "escape" then
        GameState.paused = not GameState.paused
    elseif key == "r" then
        GameState.staged = true
        GameState.stagenum = 1
        GameState.gameover = false
        InitStage()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and GameState.buttons then
        local scaledX = (x - Window.translateX) / Window.scale
        local scaledY = (y - Window.translateY) / Window.scale

        for _, b in pairs(GameState.buttons) do
            b.checkClick(scaledX, scaledY)
        end
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