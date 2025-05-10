local love = require "love"
local game = require "Scripts/game"
local button = require "Scripts/button"
local overlay = require "Scripts/overlay"

function GameState()
    local Game = game()
    local Width, Height = 0,0
    local gamestate = {
        menu = true,
        staged = false,
        gameover = false,
        win = false,
        paused = false,
        running = true,
        stagenum = 0,
        buttons = {},
    }
    function gamestate.transition()
        if gamestate.menu then
            gamestate.menu = false
            gamestate.staged = true
            gamestate.stagenum = 1
            gamestate.win = false
            backgroundMusic.menu:pause()
            backgroundMusic.game:setLooping(true)
            backgroundMusic.game:setVolume(0.5)
            backgroundMusic.game:play()
            InitStage()
        elseif gamestate.staged then
            if gamestate.stagenum < 5 then
                gamestate.stagenum = gamestate.stagenum + 1
                overlay.transition()
                gamestate.win = false
                backgroundMusic.game:setLooping(true)
                backgroundMusic.game:setVolume(0.5)
                backgroundMusic.game:play()
            else
                gamestate.staged = false
                gamestate.gameover = true
                gamestate.win = true
            end
        end
        --IMPLEMENT ME
    end
    function gamestate.update(dt)
        Width, Height = love.graphics.getDimensions()
    end
    function gamestate.quit()
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
            Window.scale = 1
        end
        love.event.quit()
    end
    function gamestate.draw()
        local font = love.graphics.getFont()
        if gamestate.paused then
            Game.Color.Set(Game.Color.Red, Game.Shade.Neon)
            love.graphics.circle("fill", 10, 10, 10)
            love.graphics.print("PAUSED", Width/2 - font:getWidth("PAUSED")/2, Height/2 - font:getHeight()/2, 0)
            Game.Color.Clear()
        else
            if gamestate.menu then
                Game.Color.Set(Game.Color.Blue, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("MENU", 50, 50)
                gamestate.buttons.play = button()
                gamestate.buttons.settings = button()
                gamestate.buttons.credits = button()
                gamestate.buttons.quit = button()
                --love.event.quit()
                local w, h = love.graphics.getDimensions()
                gamestate.buttons.play.draw(Width/2, 300, 150, 75, Game.Orientation.Center, Game.Color.Blue, "Play", GameState.transition, .5)
                gamestate.buttons.quit.draw(Width/2, 400, 150, 75, Game.Orientation.Center, Game.Color.Blue, "Quit", GameState.quit, .5)
                --gamestate.buttons.play.draw(Height/2, Width/2, 100, 30, Game.Orientation.Center, Game.Color.Blue, "Play", GameState.transition)
                --gamestate.buttons.play.draw(Height/2, Width/2, 100, 30, Game.Orientation.Center, Game.Color.Blue, "Play", GameState.transition)
            elseif gamestate.staged then
                Game.Color.Set(Game.Color.Pink, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("STAGED", 50, 50)
                Game.Color.Clear()
            elseif gamestate.gameover then
                if not gamestate.win then
                    Game.Color.Set(Game.Color.Yellow, Game.Shade.Neon)
                    love.graphics.circle("fill", 10, 10, 10)
                    love.graphics.print("GAME OVER", 475, 300, 0)
                    Game.Color.Clear()
                else
                    Game.Color.Set(Game.Color.White, Game.Shade.Neon)
                    love.graphics.circle("fill", 10, 10, 10)
                    love.graphics.print("YOU WIN!", 475, 300, 0)
                    Game.Color.Clear()
                end
            end
                
        end
    end

    return gamestate
end

return GameState