local love = require "love"
local player = require "Scripts/player"
local game = require "Scripts/game"
local projectile = require "Scripts/projectile"
local boss = require "Scripts/boss"
local gamestate = require "Scripts/gamestate"
local button = require "Scripts/button"
local overlay = require "Scripts/overlay"




function love.load()
    backgroundMusic = love.audio.newSource("Assets/Sounds/Menu.wav", "stream")
    backgroundMusic:setLooping(true)
    backgroundMusic:setVolume(0.5)  -- optional volume control
    backgroundMusic:play()
    Game = game()
    GameState = gamestate()
    love.graphics.setBackgroundColor(0.36, 0, .64, 0)
    InitWindow()
    InitStage()
    GameCanvas = love.graphics.newCanvas(Window.width, Window.height)
    Debug = ""
    DebugY = 100
end

function love.update(dt)
    if GameState.staged and not GameState.paused and not GameState.gameover then
        overlay.update(dt)
        GetKeys(dt)
        Projectiles.update(dt, Player, Boss)
        Boss.update(dt)
        Boss.shoot(Projectiles, dt)
        Player.update(dt)
    end
end

function love.draw()
    -- draw game to canvas
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear()

    love.graphics.translate(Window.translateX, Window.translateY)
    love.graphics.scale(Window.scale)
    love.graphics.print(Debug, 100, DebugY)

    if GameState.running then
        GameState.draw()
        if GameState.staged then 
            Player.draw()
            Projectiles.draw()
            Boss.draw()
        end
    end

    love.graphics.setCanvas()

    -- draw pixelated canvas
    overlay.draw(GameCanvas)
end

function InitWindow()
    Window = {translateX = 40, translateY = 40, scale = 1, width = 1280, height = 720}
    love.window.setMode(Window.width, Window.height, {resizable=false, borderless=false})
    Width, Height = love.graphics.getDimensions()
    Resize(Width, Height) -- update new translation and scale
end

function InitStage()
    local bossImages = {
        zapper = love.graphics.newImage("Assets/Sprites/zapper.png"),
        cat = love.graphics.newImage("Assets/Sprites/cat.png"),
        deer = love.graphics.newImage("Assets/Sprites/deer.png"),
        mushroom = love.graphics.newImage("Assets/Sprites/mushroom.png"),
        flower = love.graphics.newImage("Assets/Sprites/flower.png")
    }
    local projectileImages = {
        ball = love.graphics.newImage("Assets/Sprites/ball.png"),
        drop = love.graphics.newImage("Assets/Sprites/drop.png"),
        tracker = love.graphics.newImage("Assets/Sprites/tracker.png"),
        point = love.graphics.newImage("Assets/Sprites/point.png"),
        fire = love.graphics.newImage("Assets/Sprites/fire.png"),
        bolt = love.graphics.newImage("Assets/Sprites/bolt.png"),
        bomb = love.graphics.newImage("Assets/Sprites/bomb.png"),
        spit = love.graphics.newImage("Assets/Sprites/spit.png"),
    }
    Player = player(Width / 2, Height * 3 / 4, love.graphics.newImage("Assets/Sprites/moth-ss.png"))
    Boss = boss(Width / 2, Height * 1 / 4, Player, GameState.stagenum, bossImages)
    Boss.stage()
    Projectiles = projectile(projectileImages)
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
        overlay.set(0)
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
    local w1, h1 = Window.width, Window.height
    local scale = math.min(w / w1, h / h1)
    Window.translateX = (w - w1 * scale) / 2
    Window.translateY = (h - h1 * scale) / 2
    Window.scale = scale
    GameCanvas = love.graphics.newCanvas(w, h)  -- recreate canvas
end

function love.resize (w, h)
	Resize(w, h) -- update new translation and scale
    print("New window size: ", w, h)
end