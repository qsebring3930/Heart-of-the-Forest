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
            Set = function(color, shade)
                local r, g, b, a = 1, 1, 1, 1
            
                -- Base color mapping
                if color == Game.Color.Black then
                    r, g, b = 0, 0, 0
                elseif color == Game.Color.White then
                    r, g, b = 1, 1, 1
                elseif color == Game.Color.Red then
                    r, g, b = 1, 0, 0
                elseif color == Game.Color.Orange then
                    r, g, b = 1, 0.5, 0
                elseif color == Game.Color.Yellow then
                    r, g, b = 1, 1, 0
                elseif color == Game.Color.Green then
                    r, g, b = 0, 1, 0
                elseif color == Game.Color.Blue then
                    r, g, b = 0, 0, 1
                elseif color == Game.Color.Purple then
                    r, g, b = 0.5, 0, 1
                elseif color == Game.Color.Pink then
                    r, g, b = 1, 0.3, 0.6
                elseif color == Game.Color.Brown then
                    r, g, b = 0.5, 0.25, 0.1
                end
            
                -- Shade modifiers
                if shade == Game.Shade.Dark then
                    r = r * 0.4
                    g = g * 0.4
                    b = b * 0.4
                elseif shade == Game.Shade.Light then
                    r = r + (1 - r) * 0.5
                    g = g + (1 - g) * 0.5
                    b = b + (1 - b) * 0.5
                elseif shade == Game.Shade.Neon then
                    r = r + (1 - r) * 0.2
                    g = g + (1 - g) * 0.2
                    b = b + (1 - b) * 0.2
                end
            
                love.graphics.setColor(r, g, b, a)
            end
        },
        
        Shade = {
            Dark = "dark",
            Light = "light",
            Neon = "neon",
        },

        Orientation = {
            Center = "center",
            Top = "top",
            Bottom = "bottom",
            Left = "left",
            Right = "right"
        }
    }
end

return Game