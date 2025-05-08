local love = require "love"
local game = require "game"
local button = require "button"

function GameState()
    local Game = game()
    local Width, Height = love.graphics.getDimensions()
    local gamestate = {
        menu = true,
        staged = false,
        gameover = false,
        paused = false,
        running = true,
        stagenum = 0,
        buttons = {},
        backgroundColor = Game.Color.Purple
    }
    function gamestate.transition()
        if gamestate.menu then
            gamestate.menu = false
            gamestate.staged = true
            gamestate.stagenum = 1
            InitStage()
        elseif gamestate.staged then
            if gamestate.stagenum < 5 then
                gamestate.stagenum = gamestate.stagenum + 1
            end
        end
        --IMPLEMENT ME
    end
    function gamestate.quit()
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
            Window.scale = 1
        end
        love.event.quit()
    end
    function gamestate.draw()
        if gamestate.paused then
            Game.Color.Set(Game.Color.Red, Game.Shade.Neon)
            love.graphics.circle("fill", 10, 10, 10)
            love.graphics.print("PAUSED", 50, 50)
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
                gamestate.buttons.play.draw(575, 300, 150, 75, Game.Orientation.Center, Game.Color.Blue, "Play", GameState.transition, 2)
                gamestate.buttons.quit.draw(575, 400, 150, 75, Game.Orientation.Center, Game.Color.Blue, "Quit", GameState.quit, 2)
                --gamestate.buttons.play.draw(Height/2, Width/2, 100, 30, Game.Orientation.Center, Game.Color.Blue, "Play", GameState.transition)
                --gamestate.buttons.play.draw(Height/2, Width/2, 100, 30, Game.Orientation.Center, Game.Color.Blue, "Play", GameState.transition)
            elseif gamestate.staged then
                Game.Color.Set(Game.Color.Pink, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("STAGED", 50, 50)
                Game.Color.Clear()
            elseif gamestate.gameover then
                Game.Color.Set(Game.Color.Yellow, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("GAME OVER", 50, 50)
                Game.Color.Clear()
            end
                
        end
    end

    return gamestate
end

return GameState