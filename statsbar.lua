local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local vicious = require("vicious")

local naughty = require("naughty")

local statsbar = {}

-- Colors and things
local header_color = "#bfbfbf"

--{{{ CPU widget

local cputext = wibox.widget {
    widget = wibox.widget.textbox,
    markup = '<span color="'.. header_color ..'">  C   P   U</span>',
    align  = "left",
}

local cpugrid = wibox.widget {
    homogeneous     = false,
    spacing         = 3,
    forced_num_cols = 4,
    forced_num_rows = 4,
    forced_width    = 92,
    layout          = wibox.layout.grid,
    orientation     = "vertical"
}

local num_cpus = 8
local cpugraphs = {}
local cpubars = {}
for cpu = 1,num_cpus do
    cpugraphs[cpu] = wibox.widget {
        widget = wibox.widget.graph,
        width = 40,
        height = 20,
        max_value = 100,
        step_width = 2,
        color = "#5f819d",
        border_color = "#606060"
    }
    cpubars[cpu] = wibox.widget {
        {
            widget = wibox.widget.progressbar,
            -- I don't really know what's going on here. The widget can return values up to 3100,
            -- but the graphs don't scale properly unless this is 31. I'll investigate further,
            -- eventually.
            max_value = 31,
            border_width = 0,
        },
        forced_height = 20,
        forced_width = 2,
        direction = "east",
        layout = wibox.container.rotate
    }
    cpugrid:add(cpubars[cpu])
    cpugrid:add(cpugraphs[cpu])
end

vicious.register(cpugrid, vicious.widgets.cpu,
function (widget, args)
    for cpu = 1,num_cpus do
        cpugraphs[cpu]:add_value(args[cpu + 1], 0)
    end
end, 1)

vicious.cache(vicious.widgets.cpufreq)
for cpu = 1,num_cpus do
    cpuid = string.format("cpu%d", cpu - 1)
    vicious.register(cpubars[cpu].widget, vicious.widgets.cpufreq, "$1", 5, cpuid)
end

--}}} end CPU widget

--{{{ RAM widget

local ramtext = wibox.widget {
    widget = wibox.widget.textbox,
    markup = '<span color="'.. header_color ..'">  R   A   M</span>',
    align  = "left",
}

local rambox = wibox.widget.textbox()
local rambar = wibox.widget {
        widget = wibox.widget.progressbar,
        max_value = 100,
        forced_height = 8,
}
local ram = wibox.widget {
    rambox,
    rambar,
    layout = wibox.layout.fixed.horizontal
}
vicious.register(rambox, vicious.widgets.mem,
function (widget, args)
    rambar:set_value(args[1])
    return string.format("<span font='DejaVu Sans Mono 7'>%.2fGB </span>", args[2]/1000, args[3])
end, 2)

--}}} end RAM widget

--{{{ Disk widget

local disktext = wibox.widget {
    widget = wibox.widget.textbox,
    markup = '<span color="'.. header_color ..'">  D   I   S   K</span>',
    align  = "left",
}

local diskgrid = wibox.widget {
    homogeneous     = false,
    spacing         = 3,
    forced_num_cols = 2,
    forced_num_rows = 3,
    forced_width    = 92,
    layout          = wibox.layout.grid,
    orientation     = "vertical"
}

local disk_usage = wibox.widget.textbox()
local disk_bar = wibox.widget {
    widget = wibox.widget.progressbar,
    max_value = 100,
    forced_height = 8
}
vicious.register(disk_usage, vicious.widgets.fs,
function (widget, args)
    disk_bar:set_value(args["{/ used_p}"])
    return string.format("<span font='DejaVu Sans Mono 7'>%.1fGB</span>", args["{/ used_gb}"])
end, 7)

diskgrid:add(disk_usage)
diskgrid:add(disk_bar)

local disk_write = wibox.widget {
    widget = wibox.widget.graph,
    width = 44,
    height = 20,
    scale = true,
    step_width = 4,
    color = "#a54242",
    border_color = "#606060"
}
local disk_read = wibox.widget {
    widget = wibox.widget.graph,
    width = 44,
    height = 20,
    scale = true,
    step_width = 4,
    color = "#8c9440",
    border_color = "#606060"
}
local disk_write_text = wibox.widget {
    widget = wibox.widget.textbox,
    align = "left"
}
local disk_read_text = wibox.widget {
    widget = wibox.widget.textbox,
    align = "right"
}
vicious.register(disk_write, vicious.widgets.dio,
function (widget, args)
    disk_write:add_value(tonumber(args["{sda write_kb}"]), 0)
    disk_write_text:set_markup_silently(string.format("<span font='DejaVu Sans Mono 7'>%.1f</span>", args["{sda write_kb}"]))
    disk_read:add_value(tonumber(args["{sda read_kb}"]), 0)
    disk_read_text:set_markup_silently(string.format("<span font='DejaVu Sans Mono 7'>%.1f</span>", args["{sda read_kb}"]))
end, 2)
diskgrid:add(disk_write_text)
diskgrid:add(disk_read_text)
diskgrid:add(disk_write)
diskgrid:add(disk_read)

--}}} end Disk widget

--{{{ Net widget

local nettext = wibox.widget {
    widget = wibox.widget.textbox,
    markup = '<span color="'.. header_color ..'">  N   E   T</span>',
    align  = "left",
}


--}}} end Net widget

local line = wibox.widget.separator({ orientation = "horizontal", forced_height = 10 })
local space = wibox.widget.separator({ orientation = "horizontal", forced_height = 20, thickness = 0 })
function statsbar.init(s)
    local bar = awful.wibar({
        position = "left",
        screen = s,
        width = 92,
        border_width = 4,
        border_color = "#1a1a1add",
        bg = "#1a1a1ac8",
    })
    bar:setup {
        layout = wibox.layout.fixed.vertical,
        cputext,
        line,
        cpugrid,
        space,
        ramtext,
        line,
        ram,
        space,
        disktext,
        line,
        diskgrid,
        space,
        nettext,
        line,
    }
end

return statsbar
