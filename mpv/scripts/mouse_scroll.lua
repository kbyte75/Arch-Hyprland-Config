-- mpv script: scroll changes volume or brightness depending on screen side

local mp = require 'mp'
local osc = require 'mp.options'

local width = nil

mp.observe_property("osd-width", "native", function(_, val)
    width = val
end)

mp.add_forced_key_binding("WHEEL_UP", "scroll_up", function()
    if width then
        local x, _ = mp.get_mouse_pos()
        if x > (width / 2) then
            mp.command("add volume +5")      -- right side = volume
        else
            mp.command("add brightness +1")  -- left side = brightness
        end
    end
end)

mp.add_forced_key_binding("WHEEL_DOWN", "scroll_down", function()
    if width then
        local x, _ = mp.get_mouse_pos()
        if x > (width / 2) then
            mp.command("add volume -5")
        else
            mp.command("add brightness -1")
        end
    end
end)
