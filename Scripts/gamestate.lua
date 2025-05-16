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
        fading = false,
        timer = 0,
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
            BackgroundMusic.menu:play()

        elseif gamestate.transitioning then
            if gamestate.stagenum <= 5 then
                print("going to stage")
                gamestate.transitioning = false
                gamestate.staged = true
                love.audio.pause()
                BackgroundMusic.game:setLooping(true)
                BackgroundMusic.game:setVolume(0.4)
                BackgroundMusic.game:play()
                InitStage()
            end

        elseif gamestate.staged then
            if gamestate.stagenum < 5 then
                print("going to transition")
                local bgm = BackgroundMusic["transition" .. gamestate.stagenum]
                gamestate.win = false
                gamestate.stagenum = gamestate.stagenum + 1
                gamestate.staged = false
                gamestate.transitioning = true
                overlay.transition()
                love.audio.pause()
                if bgm then
                    bgm:setLooping(true)
                    bgm:setVolume(0.4)
                    bgm:play()
                end
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
    function gamestate.update(dt)
        gamestate.timer = gamestate.timer + dt
    end
    function gamestate.getTimer()
        local seconds = gamestate.timer
        local minutes = math.floor(seconds / 60)
        local prettySeconds
        if seconds > 1 then
            prettySeconds = math.floor(seconds % 60)
        else
            prettySeconds = 1
        end
        return minutes, prettySeconds
    end
    function gamestate.draw()
        local font = love.graphics.getFont()
        if gamestate.menu then
            love.graphics.draw(BackgroundImages.menu, 0, 0, 0, Window.width / BackgroundImages.menu:getWidth(), Window.height / BackgroundImages.menu:getHeight())
            gamestate.buttons.title = button()
            gamestate.buttons.play = button()
            gamestate.buttons.quit = button()
            --love.event.quit()
            local w, h = love.graphics.getDimensions()
            gamestate.buttons.title.draw(Window.width/2, Window.height/2 - 200, 600, 150, Game.Orientation.Center, Game.Color.White, "Heart of the Forest", nil, .75, false)
            gamestate.buttons.play.draw(Window.width/2, Window.height/2 + 50, 150, 75, Game.Orientation.Center, Game.Color.Blue, "Play", gamestate.transition, .5, true)
            gamestate.buttons.quit.draw(Window.width/2, Window.height/2 + 150, 150, 75, Game.Orientation.Center, Game.Color.Blue, "Quit", gamestate.quit, .5, true)
            Game.Color.Clear()
        elseif gamestate.staged then
            local bg = BackgroundImages["stage" .. gamestate.stagenum]
            if bg then
                love.graphics.draw(bg, 0, 0, 0, Window.width / bg:getWidth(), Window.height / bg:getHeight())
            end
            local minutes, seconds = gamestate.getTimer()
            local timeString = string.format("%02d:%02d", minutes, seconds)
            Game.Color.Set(Game.Color.White, Game.Shade.Neon)
            love.graphics.print("Time: " .. timeString, 50, 50, 0, 0.5, 0.5)
            Game.Color.Clear()
        elseif gamestate.transitioning then
            if gamestate.stagenum == 1 then
                Game.Color.Set(Game.Color.White, Game.Shade.Neon)
                love.graphics.print("You begin where light once meant safety.\nThe buzz you hear is familiar - but wrong.\nIt's Cold.\nIt's Flickering.\nA guardian waits for you,\ncrackling with fury.\n\n\n[Space]", 50, 375, 0, .5, .5)
            elseif gamestate.stagenum == 2 then
                Game.Color.Set(Game.Color.White, Game.Shade.Neon)
                love.graphics.print("Beyond the porch lies the tall grass,\nwaving in a wind that doesn't blow.\nYou remember chasing shadows here.\nNow one chases you.\n\n\n[Space]", 50, 450, 0, .5, .5)
                Game.Color.Clear()
            elseif gamestate.stagenum == 3 then
                Game.Color.Set(Game.Color.White, Game.Shade.Neon)
                love.graphics.print("The canopy thickens. Every branch looks alive.\nThen you see it - not moving, not breathing, not blinking.\nIt doesn't attack. It doesn't need to.\nThe forest distorts around it.\n\n\n[Space]", 50, 450, 0, .5, .5)
                Game.Color.Clear()
            elseif gamestate.stagenum == 4 then
                Game.Color.Set(Game.Color.White, Game.Shade.Neon)
                love.graphics.print("You descend, and the walls breathe with you.\nColors bloom without light.\nMusic echoes without sound.\nEvery step feels like it's already happened.\n\n\n[Space]", 50, 450, 0, .5, .5)
                Game.Color.Clear()
            elseif gamestate.stagenum == 5 then
                Game.Color.Set(Game.Color.White, Game.Shade.Neon)
                love.graphics.print("You are home, somewhere that remembers you.\nThe bloom opens.\nYou see yourself in the petals.\nYou hear your name in the roots.\n\n\n[Space]", 50, 450, 0, .5, .5)
                Game.Color.Clear()
            end
        elseif gamestate.gameover then
            if not gamestate.win then
                Game.Color.Set(Game.Color.Red, Game.Shade.Neon)
                love.graphics.print("GAME OVER", Window.width/2 - font:getWidth("GAME OVER"), Window.height/2 - font:getHeight(), 0, 2, 2)
                love.graphics.print("\n\n\n\n\n\n[Press R to restart]", 50, 450, 0, .5, .5)
                Game.Color.Clear()
            else
                Game.Color.Set(Game.Color.White, Game.Shade.Neon)
                love.graphics.print("YOU WIN!", Window.width/2 - font:getWidth("YOU WIN!"), Window.height/2 - font:getHeight(), 0, 2, 2)
                local minutes, seconds = gamestate.getTimer()
                local timeString = string.format("%02d:%02d", minutes, seconds)
                love.graphics.print("You became the heart of the forest in: " .. timeString, Window.width/2 - font:getWidth("You became the Heart of the Forest in: 02:02")/6, Window.height/2 - font:getHeight()/6 + 100, 0, 0.33, 0.33)
                love.graphics.print("\n\n\n\n\n\n[Press R to return to menu]", 50, 450, 0, .5, .5)
                Game.Color.Clear()
            end
        end
    end

    return gamestate
end

return Gamestate