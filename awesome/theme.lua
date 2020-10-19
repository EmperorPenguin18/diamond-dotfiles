---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.font          = "Determination Mono 10"

theme.bg_normal     = "#000000"
theme.bg_focus      = theme.bg_normal
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#FFFFFF"
theme.fg_focus      = theme.fg_normal
theme.fg_urgent     = theme.fg_normal
theme.fg_minimize   = theme.fg_normal

theme.useless_gap   = dpi(0)
theme.border_width  = dpi(1)
theme.border_normal = "#FFFFFF"
theme.border_focus  = theme.border_normal
theme.border_marked = theme.border_normal

theme.wallpaper = "/home/sebastien/wallpaper.jpg"

--theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
--theme.layout_max = themes_path.."default/layouts/maxw.png"
--theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
--theme.layout_tile = themes_path.."default/layouts/tilew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

return theme
