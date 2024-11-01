--[[                                        ]]--
--                                            -
--  Powearrow Darker Awesome WM 3.5.+ theme   --
--        github.com/copycat-killer           --
--                                            -
--[[                                        ]]--


local theme = {}
local gears = require("gears")

themes_dir                                  = os.getenv("HOME") .. "/.config/awesome/themes/powerarrow-darker"
theme.wallpaper                             = "~/Pictures/wallpapers/R0000016.JPG"

theme.master_width_factor                   = 0.6
theme.useless_gap                           = 3
theme.gap_single_client                     = true

theme.font                                  = "DejaVu Sans Mono 9"
theme.fg_normal                             = "#DCDCCC"
theme.fg_focus                              = "#A76FFF"
theme.bg_normal                             = "#1A1A1AC8"
theme.wibar_bg                              = "linear:0,0:0,24:0,#3E3E3EC8:8,#1A1A1AC8"
-- theme.bg_focus                              = "#313131C8"
theme.bg_urgent                             = "#CC6666C8"
theme.border_width                          = "1"
theme.border_normal                         = "#3F3F3F"
theme.border_focus                          = "#A76FFF"
theme.border_marked                         = "#FEC8A6"
theme.titlebar_bg_focus                     = "#FFFFFFC8"
theme.titlebar_bg_normal                    = "#FFFFFFC8"
theme.taglist_fg_focus                      = "#DCDCCC"
--theme.taglist_bg_focus                      = "linear:0,0:0,16:0,#B294BBC8:6,#85678FC8"
theme.taglist_bg_focus                      = "linear:0,0:0,16:0,#D6C8FFC8:6,#A76FFFC8"
theme.taglist_bg_occupied                   = "#D6C8FFC8"
theme.taglist_bg_urgent                     = "#FEC8A666"
theme.tasklist_bg_focus                     = "#1A1A1A00"
theme.tasklist_bg_normal                    = "#31313100"
theme.tasklist_fg_focus                     = "#D6C8FF"
theme.textbox_widget_margin_top             = 1
theme.notification_fg                       = theme.fg_normal
theme.notification_bg                       = theme.bg_normal
theme.notification_border_color             = theme.border_focus
theme.notification_font                     = "DejaVu Sans Mono 12"
theme.prompt_bg                             = theme.bg_normal
theme.awful_widget_height                   = 24
theme.awful_widget_margin_top               = 2
theme.mouse_finder_color                    = "#CC9393"
theme.menu_height                           = "16"
theme.menu_width                            = "140"

theme.graph_bg                              = theme.bg_normal
theme.progressbar_bg                        = theme.bg_normal
theme.progressbar_border_color              = "#606060"
theme.progressbar_border_width              = 1
theme.progressbar_fg                        = theme.fg_normal

theme.awesome_icon                          = themes_dir .. "/icons/awesome.png"

theme.menu_submenu_icon                     = themes_dir .. "/icons/submenu.png"
theme.taglist_spacing                       = 4
theme.taglist_shape                         = gears.shape.powerline
theme.taglist_shape_focus                   = gears.shape.circle
theme.taglist_shape_urgent                  = gears.shape.rounded_rect
--theme.taglist_squares_sel                   = themes_dir .. "/icons/square_sel.png"
--theme.taglist_squares_unsel                 = themes_dir .. "/icons/square_unsel.png"

theme.layout_tile                           = themes_dir .. "/icons/tile.png"
theme.layout_tileleft                       = themes_dir .. "/icons/tileleft.png"
theme.layout_tilebottom                     = themes_dir .. "/icons/tilebottom.png"
theme.layout_tiletop                        = themes_dir .. "/icons/tiletop.png"
theme.layout_fairv                          = themes_dir .. "/icons/fairv.png"
theme.layout_fairh                          = themes_dir .. "/icons/fairh.png"
theme.layout_spiral                         = themes_dir .. "/icons/spiral.png"
theme.layout_dwindle                        = themes_dir .. "/icons/dwindle.png"
theme.layout_max                            = themes_dir .. "/icons/max.png"
theme.layout_fullscreen                     = themes_dir .. "/icons/fullscreen.png"
theme.layout_magnifier                      = themes_dir .. "/icons/magnifier.png"
theme.layout_floating                       = themes_dir .. "/icons/floating.png"

theme.arrl                                  = themes_dir .. "/icons/arrl.png"
theme.arrl_dl                               = themes_dir .. "/icons/arrl_dl.png"
theme.arrl_ld                               = themes_dir .. "/icons/arrl_ld.png"
theme.arrr                                  = themes_dir .. "/icons/arrr.png"
theme.arrr_dl                               = themes_dir .. "/icons/arrr_dl.png"
theme.arrr_ld                               = themes_dir .. "/icons/arrr_ld.png"

theme.widget_ac                             = themes_dir .. "/icons/ac.png"
theme.widget_battery                        = themes_dir .. "/icons/battery.png"
theme.widget_battery_low                    = themes_dir .. "/icons/battery_low.png"
theme.widget_battery_empty                  = themes_dir .. "/icons/battery_empty.png"
theme.widget_mem                            = themes_dir .. "/icons/mem.png"
theme.widget_cpu                            = themes_dir .. "/icons/cpu.png"
theme.widget_temp                           = themes_dir .. "/icons/temp.png"
theme.widget_net                            = themes_dir .. "/icons/net.png"
theme.widget_hdd                            = themes_dir .. "/icons/hdd.png"
theme.widget_music                          = themes_dir .. "/icons/note.png"
theme.widget_music_on                       = themes_dir .. "/icons/note_on.png"
theme.widget_vol                            = themes_dir .. "/icons/vol.png"
theme.widget_vol_low                        = themes_dir .. "/icons/vol_low.png"
theme.widget_vol_no                         = themes_dir .. "/icons/vol_no.png"
theme.widget_vol_mute                       = themes_dir .. "/icons/vol_mute.png"
theme.widget_mail                           = themes_dir .. "/icons/mail.png"
theme.widget_mail_notify                    = themes_dir .. "/icons/mail_notify.png"

theme.tasklist_floating                     = ""
theme.tasklist_maximized_horizontal         = ""
theme.tasklist_maximized_vertical           = "" 

return theme
