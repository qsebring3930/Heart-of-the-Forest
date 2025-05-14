local game = require "Scripts/game"

function Button(images)
    local Game = game()
    local button = {
        text = "text",
        x = 0,
        y = 0,
        textX = 0,
        textY = 0,
        width = 0,
        height = 0,
        func = nil,
        images = images
    }
    function button.draw(x, y, width, height, orientation, color, text, onclick, scale, generic)
        button.x = x - width/2
        button.y = y - height/2
        button.width = width
        button.height = height
        button.func = onclick

        scale = scale or 1

        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text) * scale
        local textHeight = font:getHeight() * scale

        if orientation == Game.Orientation.Center then
            button.textX = button.x + (width - textWidth) / 2
            if generic then
                button.textY = button.y + (height - textHeight) / 2
            else 
                button.textY = button.y + 3*(height - textHeight) / 4
            end
        end

        Game.Color.Set(color)
        local imgWidth, imgHeight
        if generic then
            imgWidth, imgHeight = ButtonImages.generic:getDimensions()
            love.graphics.draw(ButtonImages.generic, button.x, button.y, 0, width / imgWidth, height / imgHeight)
        else
            imgWidth, imgHeight = ButtonImages.header:getDimensions()
            love.graphics.draw(ButtonImages.header, button.x, button.y, 0, width / imgWidth, height / imgHeight)
        end
        Game.Color.Clear()

        Game.Color.Set(Game.Color.Black)
        love.graphics.print(text, button.textX, button.textY, 0, scale, scale)
        Game.Color.Clear()
    end
    function button.checkClick(mx, my)
        if mx >= button.x and mx <= button.x + button.width and
            my >= button.y and my <= button.y + button.height and
            button.func and GameState.menu then
                button.func()
                print("button clicked!")
        end
    end
    return button
end

return Button