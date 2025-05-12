local shaderPixelate = love.graphics.newShader[[
    extern number intensity;
    vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord) {
        float pixelSize = 1.0 + intensity * 10.0;
        vec2 blockCoord = floor(screenCoord / pixelSize) * pixelSize;
        vec2 uv = blockCoord / love_ScreenSize.xy;
        return Texel(tex, uv);
    }
]]

local shaderRedshift = love.graphics.newShader[[
    extern number intensity;
    extern number time;

    // Pseudo-random generator based on x-coordinate
    float rand(float n) {
        return fract(sin(n) * 43758.5453123);
    }

    vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord) {
        // Get pixel value
        vec4 pixel = Texel(tex, texCoord);

        // Compute a horizontal "column" based on screen x
        float column = floor(screenCoord.x / 10.0);
        float offset = rand(column) * time * 20.0;

        // Apply vertical drip to that column
        texCoord.y += offset * 0.0001 * intensity/2;

        // Re-sample with vertical offset
        pixel = Texel(tex, texCoord);

        // Redshift
        pixel.r += intensity * 0.4;
        pixel.g *= 1.0 - intensity * 0.5;
        pixel.b *= 1.0 - intensity * 0.8;

        // Darken overall tone
        float darkness = 1.0 - 0.45 * intensity;
        pixel.rgb *= darkness;

        return pixel;
    }
]]

local shaderHueWavy = love.graphics.newShader[[
    extern number time;
    extern number intensity;
    vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord) {
        vec2 uv = texCoord;
        float baseAmplitude = 0.01 * intensity;
        float wave = sin(400 + uv.x * 30.0 + time * 3.0);
        uv.y += wave * (baseAmplitude + intensity * 0.04);
        vec4 pixel = Texel(tex, uv);
        float angle = time * 0.3 * intensity;
        float s = sin(angle), c = cos(angle);
        float r = pixel.r * c - pixel.g * s;
        float g = pixel.r * s + pixel.g * c;
        return vec4(r, g, pixel.b, pixel.a);
    }
]]


local randomShader = true


local overlay = {
    cur = 1,
    shaders = {shaderPixelate, shaderRedshift, "controlsBackwards", shaderHueWavy, randomShader},
    intensity = 0.0,
    activeStack = {
        [shaderPixelate] = 0.0,
        [shaderRedshift] = 0.0,
        [shaderHueWavy] = 0.0
    },
    time = 0,
    controlsBackwards = 0.0,
    fade = {
        alpha = 0,
        duration = 1,
        timer = 0,
        active = false,
        dir = 1, -- 1 = fade out, -1 = fade in
        callback = nil
    }
}

function overlay.fadeTo(duration, callback)
    overlay.fade.alpha = 0
    overlay.fade.duration = duration or 1
    overlay.fade.timer = 0
    overlay.fade.active = true
    overlay.fade.dir = 1
    overlay.fade.callback = callback
end

function overlay.set(val)
    overlay.intensity = val
    if overlay.intensity == 0 then
        overlay.controlsBackwards = 0
    end
end

function overlay.update(dt)
    overlay.time = overlay.time + dt
    if overlay.intensity > 0 then
        overlay.intensity = overlay.intensity - dt / 10
        if overlay.intensity < 0 then overlay.intensity = 0 end
    end
    if overlay.cur == 5 then
        for shader, weight in pairs(overlay.activeStack) do
            overlay.activeStack[shader] = math.max(0, weight - dt/10)
        end
    end
    if overlay.cur == 3 then
        overlay.controlsBackwards = math.max(0, overlay.controlsBackwards - dt)
    end
    if overlay.fade.active then
        overlay.fade.timer = overlay.fade.timer + dt * overlay.fade.dir
        local t = overlay.fade.timer / overlay.fade.duration
        overlay.fade.alpha = math.max(0, math.min(1, t))

        if overlay.fade.dir == 1 and overlay.fade.alpha >= 1 then
            print("Fade reached full alpha, calling callback!")
            if overlay.fade.callback then
                overlay.fade.callback()
                overlay.fade.callback = nil
            end
            overlay.fade.dir = -1
        elseif overlay.fade.dir == -1 and overlay.fade.alpha <= 0 then
            overlay.fade.active = false
        end
    end
end

function overlay.increment()
    overlay.intensity = overlay.intensity + 0.1
    if overlay.cur == 3 then
        overlay.controlsBackwards = overlay.controlsBackwards + 1
    end
    if overlay.cur == 5 then
        local keys = {}
        for shader, _ in pairs(overlay.activeStack) do
            table.insert(keys, shader)
        end
        local chosen = keys[math.random(#keys)]
        overlay.activeStack[chosen] = overlay.activeStack[chosen] + 0.1
    end
end

function overlay.transition()
    overlay.cur = (overlay.cur % #overlay.shaders) + 1
    if overlay.cur == 5 then
        for shader, _ in pairs(overlay.activeStack) do
            overlay.activeStack[shader] = 0
        end
    end
end

function overlay.draw(canvas)
    if GameState.staged then
        if overlay.cur == 5 then
            local input = canvas
            local intermediate = love.graphics.newCanvas(canvas:getWidth(), canvas:getHeight())

            for shader, count in pairs(overlay.activeStack) do
                if count > 0 then
                    local intensity
                    if overlay.intensity > 0 then
                        intensity = count
                    else
                        intensity = 0
                    end
                    love.graphics.setCanvas(intermediate)
                    love.graphics.clear()
                    love.graphics.setShader(shader)

                    if shader:hasUniform("intensity") then
                        shader:send("intensity", intensity)
                    end
                    if shader:hasUniform("time") then
                        shader:send("time", overlay.time)
                    end

                    love.graphics.draw(input, 0, 0)
                    love.graphics.setShader()
                    love.graphics.setCanvas()

                    -- Swap input/output for next pass
                    input, intermediate = intermediate, input
                end
            end
            love.graphics.draw(input, 0, 0)
        else
            if overlay.cur ~= 3 and overlay.intensity > 0 then
                local shader = overlay.shaders[overlay.cur]
                love.graphics.setShader(shader)
                shader:send("intensity", overlay.intensity)
                if shader:hasUniform("time") then
                    shader:send("time", overlay.time)
                end
            end
        end
    end
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()
    if overlay.fade.alpha > 0 then
        love.graphics.setColor(0, 0, 0, overlay.fade.alpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return overlay