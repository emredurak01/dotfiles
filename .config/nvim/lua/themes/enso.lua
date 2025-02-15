-- EnsoLinux theme

local M = {}

M.base_30 = {
  white = "#C5C9C5",         -- Foreground color
  darker_black = "#0D0C0C",  -- Slightly darker black (Palette color 0)
  black = "#181616",         -- Background color (main nvim background)
  black2 = "#1C1B1B",        -- Slightly lighter black (tweaked)
  one_bg = "#2D4F67",        -- Highlight background color
  one_bg2 = "#3B6D84",       -- Slightly lighter version of `one_bg`
  one_bg3 = "#4B8199",       -- Even lighter version (for balance)
  grey = "#5A6B73",          -- Grey tones, adjusted from palette
  grey_fg = "#63777D",       -- Slightly brighter grey for contrast
  grey_fg2 = "#6F868C",      -- Another step up in brightness
  light_grey = "#7B959C",    -- Lightest grey
  red = "#C4746E",           -- Red (from Palette color 1)
  baby_pink = "#D27E99",     -- Soft pink (from original palette)
  pink = "#C4748F",          -- More intense pink (similar to red but softer)
  line = "#27282E",          -- For lines like vertsplit (a more neutral tone)
  green = "#8A9A7B",         -- Green from Palette (color 2)
  vibrant_green = "#9BAA8B", -- A vibrant version of green
  nord_blue = "#8BA4B0",     -- Blue from Palette color 4
  blue = "#7FB4CA",          -- Light blue from Palette color 12
  yellow = "#C4B28A",        -- Yellow from Palette color 3
  sun = "#E6C384",           -- A brighter yellowish-orange from Palette
  purple = "#A292A3",        -- Magenta (from Palette color 5)
  dark_purple = "#938AA9",   -- A darker shade of purple from original
  teal = "#7AA89F",          -- Teal from Palette color 15
  orange = "#E46876",        -- Vibrant orange
  cyan = "#8EA4A2",          -- Cyan from Palette color 6
  statusline_bg = "#1C1B1B", -- Statusline background color (matching black2)
  lightbg = "#27282E",       -- Light background color, slightly lighter than `black2`
  pmenu_bg = "#A292A3",      -- Popup menu background color (purple/magenta)
  folder_bg = "#8BA4B0",     -- Folder background color (blue)
}

M.base_16 = {
  base00 = "#181616", -- Background color
  base01 = "#2D4F67", -- Highlight background color
  base02 = "#2A2A37", -- Darker accent (similar to original Kanagawa base01)
  base03 = "#727169", -- Soft text
  base04 = "#C8C093", -- Highlight foreground / cursor color 
  base05 = "#C5C9C5", -- Foreground color
  base06 = "#A6A69C", -- Dimmed text color
  base07 = "#363646", -- Accent (neutral tone)
  base08 = "#C4746E", -- Red (Palette color 1)
  base09 = "#E46876", -- Orange (Palette color 9)
  base0A = "#E46876", -- Yellow (Palette color 3)
  base0B = "#8A9A7B", -- Green (Palette color 2)
  base0C = "#8EA4A2", -- Cyan (Palette color 6)
  base0D = "#8BA4B0", -- Blue (Palette color 4)
  base0E = "#A292A3", -- Magenta (Palette color 5)
  base0F = "#7AA89F", -- Additional color (soft green, Palette color 15)
}

M.polish_hl = {
  treesitter = {
    ["@keyword.import"] = { fg = M.base_30.purple },
    ["@uri"] = { fg = M.base_30.blue },
    ["@tag.delimiter"] = { fg = M.base_30.red },
    ["@variable.member.key"] = { fg = M.base_30.white },
    ["@punctuation.bracket"] = { fg = M.base_30.pmenu_bg },
    ["@punctuation.delimiter"] = { fg = M.base_30.white },
  },

  syntax = {
    Number = { fg = M.base_30.baby_pink },
  },
}

M.type = "dark"

M = require("base46").override_theme(M, "kanagawa")

return M
