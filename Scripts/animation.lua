local love = require "love"

function Animation()
    local animation = {}

    function animation.new(image, frameWidth, frameHeight, totalFrames, speed)
        local sprite = image
        local frames = {}

        for i = 0, totalFrames - 1 do
            frames[i + 1] = love.graphics.newQuad(
                i * frameWidth, 0,
                frameWidth, frameHeight,
                sprite:getDimensions()
            )
        end

        local anim = {
            sprite = sprite,
            frames = frames,
            frameWidth = frameWidth,
            frameHeight = frameHeight,
            currentFrame = 1,
            animationTimer = 0,
            animationSpeed = speed or 0.1
        }

        function anim.update(dt)
            anim.animationTimer = anim.animationTimer + dt
            if anim.animationTimer >= anim.animationSpeed then
                anim.currentFrame = (anim.currentFrame % totalFrames) + 1
                anim.animationTimer = 0
            end
        end

        function anim.draw(x, y, scale)
            scale = scale or 1
            love.graphics.draw(
                anim.sprite,
                anim.frames[anim.currentFrame],
                x - (anim.frameWidth * scale / 2),
                y - (anim.frameHeight * scale / 2),
                0, scale, scale
            )
        end

        return anim
    end

    return animation
end

return Animation