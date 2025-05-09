local shader = love.graphics.newShader[[
    extern number intensity;

    vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord) {
        float pixelSize = 1.0 + intensity * 10.0;
        vec2 blockCoord = floor(screenCoord / pixelSize) * pixelSize;
        vec2 uv = blockCoord / love_ScreenSize.xy;
        return Texel(tex, uv);
    }
]]

local overlay = {
    intensity = 0.0
}

function overlay.set(val)
    overlay.intensity = val
end

function overlay.update(dt)
    if overlay.intensity > 0 then
        overlay.intensity = overlay.intensity - dt / 10
    end
end

function overlay.increment()
    overlay.intensity = overlay.intensity + .1
end

function overlay.draw(canvas)
    shader:send("intensity", overlay.intensity)
    love.graphics.setShader(shader)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()
end

return overlay