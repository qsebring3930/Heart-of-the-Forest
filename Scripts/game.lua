local love = require "love"

function Game()
    return {
        Direction = {
            Left = "left",
            Right = "right",
            Up = "up",
            Down = "down",
        },
        
        Color = {
            Red = "red",
            Orange = "orange",
            Yellow = "yellow",
            Green = "green",
            Blue = "blue",
            Purple = "purple",
            Pink = "pink",
            Brown = "brown",
            White = "white",
            Black = "black",
            Clear = function()
                love.graphics.setColor(1, 1, 1, 1)
            end,
        },
        
        Shade = {
            Dark = "dark",
            Light = "light",
            Neon = "neon",
        }
    }
end

return Game