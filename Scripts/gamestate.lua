local love = require "love"
local game = require "game"
local button = require "button"

function GameState()
    local Game = game()
    local gamestate = {
        menu = true,
        staged = false,
        gameover = false,
        paused = false,
        running = true,
        buttons = {}
    }
    function gamestate.transition()
        if gamestate.menu then
            gamestate.menu = false
            gamestate.staged = true
        elseif gamestate.staged then
            gamestate.staged = false
            gamestate.gameover = true
        end
        --IMPLEMENT ME
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
                gamestate.buttons.play.draw(200, 200, 200, 200, Game.Orientation.Center, Game.Color.Blue, "Play", GameState.transition)
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