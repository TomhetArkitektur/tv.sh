local timer = nil
local alpha = 255
local step = 10

-- create overlay
local ov = mp.create_osd_overlay("ass-events")

function set_text(current_alpha, text)
    -- convert opacity to hex
    local hex_alpha = string.format("%02X", current_alpha)
    
    ov.data = string.format("{\\1a&H%s&\\4a&H%s&\\opaquebox1}%s", hex_alpha, hex_alpha, text)
    ov:update()
end

function fade_out(text)
    if timer then timer:stop() end
    timer = mp.add_periodic_timer(0.05, function()
        alpha = alpha + step
        if alpha >= 255 then
            alpha = 255
            timer:stop()
            ov:remove()
        end
        set_text(alpha, text)
    end)
end

function fade_in(text, display_time)
    if timer then timer:stop() end
    alpha = 255
    -- ov:remove() -- remove old overlay
    
    timer = mp.add_periodic_timer(0.03, function()
        alpha = alpha - step
        if alpha <= 0 then
            alpha = 0
            timer:stop()
            -- mp.add_timeout(display_time / 1000, function() fade_out(text) end)
        end
        set_text(alpha, text)
    end)
end

mp.register_script_message("show-fade-text", function(text, duration)
    local d = tonumber(duration) or 2000
    ov:remove()
    fade_in(text or "", d)
end)
