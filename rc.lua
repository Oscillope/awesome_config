-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local vicious = require("vicious")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local quake = require("quake")
local pavuctl = require("quake")

local revelation = require("revelation")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/powerarrow-darker/theme.lua")

-- Revelation init
revelation.init()

-- {{{ Autostart
function run_once(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
         findme = cmd:sub(0, firstspace-1)
    end
    awful.spawn.with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

run_once("conky")
run_once("picom --experimental-backends")
run_once("xscreensaver -no-splash")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.magnifier,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mypowermenu = {
   { "reboot", "systemctl reboot" },
   { "shut down", "systemctl poweroff" }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "power", mypowermenu },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()
local month_calendar = awful.widget.calendar_popup.month({opacity = 60, bg = "#00000000"})
month_calendar:attach( mytextclock, "tr", {on_hover=true})

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, nil, false)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local function take_screenshot(opts)
    local date = os.date("%F_%H:%M:%S")
    local fname = os.getenv("HOME") .. "/sshot_" .. date .. ".png"
    awful.spawn.easy_async("maim " .. (function (s) if s then return s else return "" end end)(opts) .. " -qu " .. fname,
        function (stdout, stderr, reason, code)
            if code == 0 then
                naughty.notify({ title = "Screenshot Captured", text = "Saved to: " .. fname })
            else
                naughty.notify({ title = "Screenshot Failed!", text = stderr, preset = naughty.presets.critical })
            end
        end
    )
end

-- Volume widget
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
volumewidget = wibox.widget.textbox()
oldvol = 0
vicious.register(volumewidget, vicious.widgets.volume,
function (widget, args)
    if (args[2] == "♩") then volicon:set_image(beautiful.widget_vol_mute)
    elseif (args[1] == 0) then volicon:set_image(beautiful.widget_vol_no)
    elseif (args[1] <= 50) then  volicon:set_image(beautiful.widget_vol_low)
    else volicon:set_image(beautiful.widget_vol)
    end
    if (args[1] ~= oldvol) then
      if (args[1] > 0) then
        volcolor = string.format('color="#%02x%02x%02x"', math.ceil(255 * 4*((args[1] - 50) / 100)^2), math.ceil(255 * -(args[1] / 100)^8) + 255, math.ceil(255 * -(args[1] / 100)^0.3)+255)
      end
      else volcolor = ""
      oldvol = args[1]
    end
    return '<span font="' .. beautiful.font .. '" ' .. volcolor .. '>' .. args[1] .. ' </span>'
end, 1, "Master")

-- Layout info widget
function update_layout_info(t)
  t.screen.mylayoutinfo.text = string.format('Cols: %u Masters: %u ', t.column_count, t.master_count)
end

-- Spotify widget
status_cmd = "qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlaybackStatus"
metadata_cmd = "qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Metadata"
spotiwidget = awful.widget.watch(status_cmd, 8,
function (widget, stdout, stderr, exitreason, exitcode)
    if exitcode == 0 and stdout:match("Playing") then
        local artist = nil
        local title = nil
        local album = nil
        -- This stuff runs asynchronously, so the parent widget function can't expect to do anything with its output
        -- (as it will have returned by then). But it still can use the local variables above. Scoping is weird, huh?
        awful.spawn.with_line_callback(metadata_cmd, {
            -- Called on every line of output. Parses dbus metadata and finds the correct strings.
            stdout = function (line)
                temp = line:match("^xesam:artist: (.*)")
                if temp then
                    artist = temp
                    return
                end
                temp = line:match("^xesam:title: (.*)")
                if temp then
                    title = temp
                    return
                end
                temp = line:match("^xesam:album: (.*)")
                if temp then
                    album = temp
                    return
                end
            end,
            -- Called when qdbus stops outputting. Writes the strings to the widget.
            output_done = function ()
                widget:set_markup_silently(
                    string.format('<span foreground="#00ff00"> ᐅ</span> %s | %s | %s ', title, artist, album))
            end
        })
    else
        widget:set_markup_silently('<span foreground="#ff6600"> ❚❚ </span>')
    end
end, spotitext)
spotify_scroller = wibox.widget {
    layout = wibox.container.scroll.horizontal,
    max_size = 420,
    step_function = wibox.container.scroll.step_functions
                    .waiting_nonlinear_back_and_forth,
    speed = 50,
    { widget = spotiwidget }
}

-- Separators
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)
arrr = wibox.widget.imagebox()
arrr:set_image(beautiful.arrr)
arrr_dl = wibox.widget.imagebox()
arrr_dl:set_image(beautiful.arrr_dl)
arrr_ld = wibox.widget.imagebox()
arrr_ld:set_image(beautiful.arrr_ld)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1 + s.index])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist({screen=s, filter=awful.widget.taglist.filter.all, buttons=taglist_buttons})

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, type = "panel" })

    -- Create the quake term
    s.quake = quake({ app = terminal, screen = s })
    s.pavuctl = pavuctl({ app = "pavucontrol-qt", screen = s, name = "pavucontrol-qt", argname = "" })

    -- Create a layout info widget
    s.mylayoutinfo = wibox.widget.textbox()
    update_layout_info(s.selected_tag)
    awful.tag.attached_connect_signal(s, "property::master_count", update_layout_info)
    awful.tag.attached_connect_signal(s, "property::column_count", update_layout_info)
    awful.tag.attached_connect_signal(s, "property::selected", update_layout_info)

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            arrr_ld,
            s.mytaglist,
            s.mypromptbox,
            arrr,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            arrl,
            awful.widget.only_on_screen(
                wibox.widget {
                    layout = wibox.layout.fixed.horizontal,
                        spotify_scroller,
                        arrl,
                        volicon,
                        volumewidget,
                        arrl,
                        wibox.widget.systray(),
                        arrl,
                },
                "primary"
            ),
            mytextclock,
            arrl,
            s.mylayoutinfo,
            arrl_ld,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "F1",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab", revelation,
              {description = "show all clients", group = "client"}),
    awful.key({ modkey, "Shift"    }, "Tab", function () revelation({curr_tag_only=true}) end,
              {description = "show clients on current tag", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    -- Custom program
    awful.key({ }, "XF86AudioRaiseVolume", function ()
                                               awful.spawn("amixer set Master playback 1%+")
                                               vicious.force({ volumewidget })
                                           end, {description = "volume up", group = "sound"}),
    awful.key({ }, "XF86AudioLowerVolume", function ()
                                               awful.spawn("amixer set Master playback 1%-")
                                               vicious.force({ volumewidget })
                                           end, {description = "volume down", group = "sound"}),
    awful.key({ modkey,        }, "a",      function () awful.spawn("qutebrowser") end,
              {description = "open a web browser", group = "launcher"}),
    awful.key({ modkey,        }, "s",      function () awful.spawn("rofi -show gvim -modi gvim:~/Code/vimSelect.sh") end,
              {description = "open a gvim session", group = "launcher"}),
    awful.key({ modkey,        }, "d",      function () awful.spawn("thunar") end,
              {description = "browse files", group = "launcher"}),
    awful.key({ modkey,        }, "z",      function () awful.spawn("sonos-linein") end,
              {description = "switch sonos to play linein", group = "sound"}),

    awful.key({ modkey, "Control"  }, "Escape",function () awful.spawn("xscreensaver-command -activate") end,
              {description = "lock screen", group = "launcher"}),

    awful.key({ }, "Print",         function () take_screenshot() end,
              {description = "take screenshot", group = "screen"}),
    awful.key({ "Shift" }, "Print", function () take_screenshot("-s") end,
              {description = "take partial screenshot", group = "screen"}),

    awful.key({ modkey, }, "'", function () awful.screen.focused().quake:toggle() end,
              {description = "dropdown terminal", group = "launcher"}),
    awful.key({ modkey, }, "/", function () awful.screen.focused().pavuctl:toggle() end,
              {description = "dropdown mixer", group = "launcher"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.spawn("rofi -show combi") end,
              {description = "rofi prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "o",      function (c) c:move_to_screen(c.screen.index-1) end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- View tag on other screen.
        awful.key({ modkey, "Mod1" }, "#" .. i + 9,
                  function ()
                        -- jump to screen
                        awful.screen.focus_relative(1)
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i.." on other screen", group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Move client to tag on other screen.
        awful.key({ modkey, "Mod1", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          client.focus:move_to_screen()
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i.." on other screen", group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false,
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer",
          "zoom"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    { rule_any = {type = { "dialog" }},
      properties = {
              opacity = 0.8
      }
    },

    { rule_any = {role = {"browser-window"}},
      properties = {
              opacity = 0.9,
      }
    },

    { rule_any = {role = { "browser-window" }, class = { "Thunar" }},
      properties = {
              opacity = 0.9,
      }
    },

    { rule_any = {class = { "Gvim" }},
      properties = {
              opacity = 0.9,
      }
    },

    { rule_any = {class = {"Conky"}},
      properties = {
              border_width = 0,
              sticky = true,
              focusable = false,
              floating = true,
              size_hints_honor = true
              }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    c.screen.mywibox.bg = "linear:0,0:0,24:0,#D6A6FFA0:8,#1A1A1AC8"
    end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
    c.screen.mywibox.bg = beautiful.wibar_bg
    end)
client.connect_signal("property::urgent",
    function(c)
        if (c.urgent) then
          naughty.notify({ bg = "#A76FFFC8",
                           timeout = 10,
                           title = "Ding ding!",
                           run = function(n)
                                   c.first_tag:view_only()
                                   naughty.destroy(n, naughty.notificationClosedReason.dismissedByUser)
                                 end,
                           text = string.format("Client %s (tag %s) wants your attention!", c.name, c.first_tag.name)
                         })
        end
    end)
-- }}}
