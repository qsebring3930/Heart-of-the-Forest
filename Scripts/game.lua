function Game()
        local direction = {
            Left = "left",
            Right = "right",
            Up = "up",
            Down = "down",
        }
        local color = {
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
        }
        local shade = {
            Dark = "dark",
            Light = "light",
            Neon = "neon",
            NeonTransparent = "NeonTransparent",
        }
        function color.Clear()
            love.graphics.setColor(1, 1, 1, 1)
        end
        function color.Set(inColor, inShade)
            local r, g, b, a = 1, 1, 1, 1

            -- Base color mapping
            if inColor == color.Black then
                r, g, b = 0, 0, 0
            elseif inColor == color.White then
                r, g, b = 1, 1, 1
            elseif inColor == color.Red then
                r, g, b = 1, 0, 0
            elseif inColor == color.Orange then
                r, g, b = 1, 0.5, 0
            elseif inColor == color.Yellow then
                r, g, b = 1, 1, 0
            elseif inColor == color.Green then
                r, g, b = 0, 1, 0
            elseif inColor == color.Blue then
                r, g, b = 0, 0, 1
            elseif inColor == color.Purple then
                r, g, b = 0.5, 0, 1
            elseif inColor == color.Pink then
                r, g, b = 1, 0.3, 0.6
            elseif inColor == color.Brown then
                r, g, b = 0.5, 0.25, 0.1
            end

            -- Shade modifiers
            if inShade == shade.Dark then
                r = r * 0.4
                g = g * 0.4
                b = b * 0.4
            elseif inShade == shade.Light then
                r = r + (1 - r) * 0.5
                g = g + (1 - g) * 0.5
                b = b + (1 - b) * 0.5
            elseif inShade == shade.Neon then
                r = r + (1 - r) * 0.2
                g = g + (1 - g) * 0.2
                b = b + (1 - b) * 0.2
            elseif inShade == shade.NeonTransparent then
                r = r + (1 - r) * 0.2
                g = g + (1 - g) * 0.2
                b = b + (1 - b) * 0.2
                a = .5
            end

            love.graphics.setColor(r, g, b, a)
        end

        local orientation = {
            Center = "center",
            Top = "top",
            Bottom = "bottom",
            Left = "left",
            Right = "right"
        }
        return {
            Color = color,
            Shade = shade,
            Orientation = orientation,
            Direction = direction
        }
    end
return Game