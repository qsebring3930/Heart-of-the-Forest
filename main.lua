local player = require "Scripts/player"
local game = require "Scripts/game"
local projectile = require "Scripts/projectile"
local boss = require "Scripts/boss"
local gamestate = require "Scripts/gamestate"
local button = require "Scripts/button"
local overlay = require "Scripts/overlay"

function love.load()
    BackgroundMusic = {
        menu = love.audio.newSource("Assets/Sounds/Funnie.mp3", "stream"),
        game = love.audio.newSource("Assets/Sounds/Bipolar hands demo 1.3 Fix.mp3", "stream"),
    }
    BossImages = {
        zapper = love.graphics.newImage("Assets/Sprites/zapper.png"),
        cat = love.graphics.newImage("Assets/Sprites/cat.png"),
        deer = love.graphics.newImage("Assets/Sprites/deer.png"),
        mushroom = love.graphics.newImage("Assets/Sprites/mushroom.png"),
        flower = love.graphics.newImage("Assets/Sprites/flower.png")
    }
    ProjectileImages = {
        ball = love.graphics.newImage("Assets/Sprites/ball.png"),
        drop = love.graphics.newImage("Assets/Sprites/drop.png"),
        tracker = love.graphics.newImage("Assets/Sprites/tracker.png"),
        point = love.graphics.newImage("Assets/Sprites/point.png"),
        fire = love.graphics.newImage("Assets/Sprites/fire.png"),
        bolt = love.graphics.newImage("Assets/Sprites/bolt.png"),
        bomb = love.graphics.newImage("Assets/Sprites/bomb.png"),
        spit = love.graphics.newImage("Assets/Sprites/spit.png"),
    }
    BackgroundImages = {
        menu = love.graphics.newImage("Assets/Backgrounds/2304x1296(2).png"),
        stage1 = love.graphics.newImage("Assets/Backgrounds/Summer1.png"),
        stage2 = love.graphics.newImage("Assets/Backgrounds/Summer7.png"),
        stage3 = love.graphics.newImage("Assets/Backgrounds/2304x1296.png"),
        stage4 = love.graphics.newImage("Assets/Backgrounds/Preview 1.png"),
        stage5 = love.graphics.newImage("Assets/Backgrounds/2304x1296 (1).png")
    }
    ButtonImages = {
        header = love.graphics.newImage("Assets/Buttons/UI_Flat_Banner01a.png"),
        generic = love.graphics.newImage("Assets/Buttons/UI_Flat_Bar07a.png")
    }
    PlayerImage = love.graphics.newImage("Assets/Sprites/moth-ss.png")
    GameFont = love.graphics.newFont("Assets/Fonts/DungeonFont.ttf", 72)
    love.graphics.setFont(GameFont)
    BackgroundMusic.menu:setLooping(true)
    BackgroundMusic.menu:setVolume(0.5)  -- optional volume control
    BackgroundMusic.menu:play()
    GameObject = game()
    GameState = gamestate()
    InitWindow()
    InitStage()
    GameCanvas = love.graphics.newCanvas(Window.width, Window.height)
    Debug = ""
    DebugY = 100
end

function love.update(dt)
    if not GameState.paused then
        overlay.update(dt)
    end
    if GameState.staged and not GameState.paused and not GameState.gameover and not GameState.fading then
        GameState.update(dt)
        GetKeys(dt)
        Projectiles.update(dt, PlayerObject, BossObject)
        BossObject.update(dt)
        BossObject.shoot(Projectiles, dt)
        PlayerObject.update(dt)
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
            PlayerObject.draw()
            Projectiles.draw()
            BossObject.draw()
        end
        if GameState.paused then
            GameObject.Color.Set(GameObject.Color.Yellow, GameObject.Shade.Neon)
            love.graphics.print("PAUSED", Window.width/2 - GameFont:getWidth("PAUSED")/2, Window.height/2 - GameFont:getHeight()/2, 0)
            GameObject.Color.Clear()
        end
    end

    love.graphics.setCanvas()
    love.graphics.clear()
    love.graphics.origin()
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
    PlayerObject = player(Window.width / 2, Window.height * 3 / 4)
    BossObject = boss(Window.width / 2, Window.height * 1 / 4, PlayerObject, GameState.stagenum)
    BossObject.stage()
    Projectiles = projectile()
end

function WithinBounds()
    if PlayerObject.x + 10 <= Window.width and PlayerObject.x - 10 >= 0 and PlayerObject.y + 10 <= Window.height and PlayerObject.y - 10 >= 0 then
        return true
    end
    return false
end

function GetKeys(dt)
    if love.keyboard.isDown('w', 'a', 's', 'd') and WithinBounds() then
        if love.keyboard.isDown("d") then
            if overlay.cur == 3 and overlay.controlsBackwards > 0 then
                PlayerObject.move(GameObject.Direction.Left, dt)
            else
                PlayerObject.move(GameObject.Direction.Right, dt)
            end
        end
        if love.keyboard.isDown("a") then
            if overlay.cur == 3 and overlay.controlsBackwards > 0 then
                PlayerObject.move(GameObject.Direction.Right, dt)
            else
                PlayerObject.move(GameObject.Direction.Left, dt)
            end
        end
        if love.keyboard.isDown("s") then
            PlayerObject.move(GameObject.Direction.Down, dt)
        end
        if love.keyboard.isDown("w") then
            PlayerObject.move(GameObject.Direction.Up, dt)
        end
    else
        PlayerObject.move(GameObject.Direction.None, dt)
    end
    if love.keyboard.isDown("space") and PlayerObject.fireTimer <= 0 then
        if not GameState.transitioning then
            PlayerObject.shoot(Projectiles)
        end
    end
end

function love.keypressed(key)
    if key == "f" then
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
        else
            love.window.setFullscreen(true)
        end
        Width, Height = love.graphics.getDimensions()
        Resize(Width, Height)
    elseif key == "t" then
        --GameState.transition()
    elseif key == "p" or key == "escape" then
        GameState.paused = not GameState.paused
    elseif key == "q" then
        --GameState.quit()
    elseif key == "r" then
        GameState.staged = false
        GameState.transitioning= true
        GameState.gameover = false
        GameState.win = false
        overlay.set(0)
    elseif key == "space" then
        if GameState.transitioning then
            GameState.transition()
        end
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
    love.graphics.origin()
    GameCanvas = love.graphics.newCanvas(w, h)  -- recreate canvas
end

function love.resize (w, h)
	Resize(w, h) -- update new translation and scale
    print("New window size: ", w, h)
end