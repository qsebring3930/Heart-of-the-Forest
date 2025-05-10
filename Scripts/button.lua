local love = require "love"
local game = require "Scripts/game"

function Button()
    local Game = game()
    local button = {
        text = text,
        x = 0,
        y = 0,
        textX = 0,
        textY = 0,
        width = 0,
        height = 0,
        func = nil,
    }
    function button.draw(x, y, width, height, orientation, color, text, onclick, scale)
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
            button.textY = button.y + (height - textHeight) / 2
        end

        Game.Color.Set(color)
        love.graphics.rectangle("fill", button.x, button.y, width, height)
        Game.Color.Clear()

        Game.Color.Set(Game.Color.Black)
        love.graphics.print(text, button.textX, button.textY, 0, scale, scale)
        Game.Color.Clear()
    end 
    function button.checkClick(mx, my) 
        if mx >= button.x and mx <= button.x + button.width and 
            my >= button.y and my <= button.y + button.height and
            button.func then
                button.func()
        end
    end
    return button
end

return Button