local game = require "Scripts/game"
local button = require "Scripts/button"
local overlay = require "Scripts/overlay"

function Gamestate()
    local Game = game()
    local gamestate = {
        menu = true,
        staged = false,
        transitioning = false,
        gameover = false,
        win = false,
        paused = false,
        running = true,
        stagenum = 0,
        transnum = 0,
        buttons = {},
        fading = false
    }
    function gamestate.transition()
        if gamestate.fading then return end
        print("we fading out")
        gamestate.fading = true
        overlay.fadeTo(1, gamestate.completeTransition)
    end

    function gamestate.completeTransition()
        gamestate.fading = false

        if gamestate.menu then
            print("we going to the transition")
            gamestate.menu = false
            gamestate.transitioning = true
            gamestate.stagenum = 1
            BackgroundMusic.menu:pause()

        elseif gamestate.transitioning then
            if gamestate.stagenum <= 5 then
                gamestate.transitioning = false
                gamestate.staged = true
                BackgroundMusic.game:setLooping(true)
                BackgroundMusic.game:setVolume(0.5)
                BackgroundMusic.game:play()
                InitStage()
            end

        elseif gamestate.staged then
            if gamestate.stagenum < 5 then
                gamestate.win = false
                gamestate.stagenum = gamestate.stagenum + 1
                gamestate.staged = false
                gamestate.transitioning = true
                overlay.transition()
                BackgroundMusic.game:pause()
            else
                gamestate.staged = false
                gamestate.gameover = true
                gamestate.win = true
            end

        end
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
        if gamestate.menu then
            love.graphics.draw(BackgroundImages.menu, 0, 0, 0, Window.width / BackgroundImages.menu:getWidth(), Window.height / BackgroundImages.menu:getHeight())
            Game.Color.Set(Game.Color.Blue, Game.Shade.Neon)
            love.graphics.circle("fill", 10, 10, 10)
            love.graphics.print("MENU", 50, 50)
            gamestate.buttons.play = button()
            gamestate.buttons.settings = button()
            gamestate.buttons.credits = button()
            gamestate.buttons.quit = button()
            --love.event.quit()
            local w, h = love.graphics.getDimensions()
            gamestate.buttons.play.draw(Window.width/2, Window.height/2 - 50, 150, 75, Game.Orientation.Center, Game.Color.Blue, "Play", gamestate.transition, .5)
            gamestate.buttons.quit.draw(Window.width/2, Window.height/2 + 50, 150, 75, Game.Orientation.Center, Game.Color.Blue, "Quit", gamestate.quit, .5)
        elseif gamestate.staged then
            local bg = BackgroundImages["stage" .. gamestate.stagenum]
            if bg then
                love.graphics.draw(bg, 0, 0, 0, Window.width / bg:getWidth(), Window.height / bg:getHeight())
            end
            Game.Color.Set(Game.Color.Pink, Game.Shade.Neon)
            love.graphics.circle("fill", 10, 10, 10)
            love.graphics.print("STAGED", 50, 50)
            Game.Color.Clear()
        elseif gamestate.transitioning then
            if gamestate.stagenum == 1 then
                Game.Color.Set(Game.Color.Pink, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("blah blah you are a moth\n trying to return to the forest", 50, 50)
                Game.Color.Clear()
            elseif gamestate.stagenum == 2 then
                Game.Color.Set(Game.Color.Pink, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("blah blah you must cross the\n field to the forests edge", 50, 50)
                Game.Color.Clear()
            elseif gamestate.stagenum == 3 then
                Game.Color.Set(Game.Color.Pink, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("blah blah you must defeat the\n guardian of the forests edge", 50, 50)
                Game.Color.Clear()
            elseif gamestate.stagenum == 4 then
                Game.Color.Set(Game.Color.Pink, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("blah blah you're nearing the\n heart of the forest", 50, 50)
                Game.Color.Clear()
            elseif gamestate.stagenum == 5 then
                Game.Color.Set(Game.Color.Pink, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("blah blah you must defeat the\n heart of the forest", 50, 50)
                Game.Color.Clear()
            end
        elseif gamestate.gameover then
            if not gamestate.win then
                Game.Color.Set(Game.Color.Red, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("GAME OVER", Window.width/2 - font:getWidth("GAME OVER")/2, Window.height/2 - font:getHeight()/2, 0)
                Game.Color.Clear()
            else
                Game.Color.Set(Game.Color.White, Game.Shade.Neon)
                love.graphics.circle("fill", 10, 10, 10)
                love.graphics.print("YOU WIN!", Window.width/2 - font:getWidth("YOU WIN!")/2, Window.height/2 - font:getHeight()/2, 0)
                Game.Color.Clear()
            end
        end
        if gamestate.paused then
            Game.Color.Set(Game.Color.Yellow, Game.Shade.Neon)
            love.graphics.circle("fill", 10, 10, 10)
            love.graphics.print("PAUSED", Window.width/2 - font:getWidth("PAUSED")/2, Window.height/2 - font:getHeight()/2, 0)
            Game.Color.Clear()
        end
    end

    return gamestate
end

return Gamestate