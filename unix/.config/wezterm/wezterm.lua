local wezterm = require 'wezterm';

local TARGET_TRIPLE = wezterm.target_triple
local MAC_OS = TARGET_TRIPLE:find("darwin")

-- use CTRL or CMD key
local COMMAND_MODS_KEY = "CTRL"
if MAC_OS then
  COMMAND_MODS_KEY = "CMD"
end

-- spawn commands for macOS/Linux environments
local SPAWN_COMMANDS = {
  {
    label = "Zsh",
    args = { "zsh", "-l" },
    cwd = "~"
  },
  {
    label = "Bash",
    args = { "bash", "-l" },
    cwd = "~"
  },
}

----------------------------------------------------------------------------------------------------
-- utility functions

local utils = {}

function utils.merge_lists(...)
  local args = { ... };
  local lists = {}

  for _, t in ipairs(args) do
    for _, v in ipairs(t) do
      table.insert(lists, v)
    end
  end
  return lists
end

function utils.merge_mods_with_commands(...)
  local args = { ... }
  local mods = COMMAND_MODS_KEY
  if args == nil then
    return mods
  end
  for _, v in ipairs(args) do
    mods = mods .. "|" .. v
  end
  return mods
end

----------------------------------------------------------------------------------------------------

-- move active tab by CTRL/CMD + 1 ~ 9
local function generate_active_tab_key_bindings()
  local keys = {}
  for i = 1, 9 do
    -- use 1 ~ 9 keys
    table.insert(keys, {
      key = tostring(i),
      mods = COMMAND_MODS_KEY,
      action = wezterm.action({ ActivateTab = i - 1 }),
    })
    -- use F1 ~ F9 keys
    table.insert(keys, {
      key = "F" .. tostring(i),
      mods = COMMAND_MODS_KEY,
      action = wezterm.action({ ActivateTab = i - 1 }),
    })
  end
  return keys
end

-- spawn a new tab by CTRL/CMD + ALT + 1 ~ 9
local function generate_spawn_tab_key_bindings(spawn_commands)
  local keys = {}
  for i, v in ipairs(spawn_commands) do
    if (v.args ~= nil) then
      table.insert(keys, {
        key = tostring(i),
        mods = utils.merge_mods_with_commands("ALT"),
        action = wezterm.action({ SpawnCommandInNewTab = { args = v.args } })
      })
    end
  end
  return keys
end

-- custom font
local function generate_font()
  if MAC_OS then
    return wezterm.font(
      "HackGen Console",
      {
        weight = "Regular",
        stretch = "Normal",
        italic = false
      }
    )
  end
  return nil
end

-- font size
local function generate_font_size()
  if MAC_OS then
    return 16
  end
  return 13
end

----------------------------------------------------------------------------------------------------

-- common key bindings
local defaukt_key_bindings = {
  {
    key = "r",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.ReloadConfiguration
  },
  {
    key = "p",
    mods = utils.merge_mods_with_commands(),
    action = wezterm.action.ShowLauncher
  },
  {
    key = "p",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.ActivateCommandPalette
  },
  -- Select & Copy & Paste
  {
    key = "c",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ CopyTo = "Clipboard" })
  },
  {
    key = "v",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ PasteFrom = "Clipboard" })
  },
  {
    key = "Insert",
    mods = "SHIFT",
    action = wezterm.action({ PasteFrom = "PrimarySelection" })
  },
  {
    key = "Space",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.ActivateCopyMode
  },
  {
    key = "s",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.QuickSelect
  },
  -- Font Size
  {
    key = "0",
    mods = utils.merge_mods_with_commands(),
    action = wezterm.action.ResetFontSize
  },
  {
    key = ";",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.DecreaseFontSize
  },
  {
    key = ";",
    mods = utils.merge_mods_with_commands(),
    action = wezterm.action.IncreaseFontSize
  },
  {
    key = "-",
    mods = utils.merge_mods_with_commands(),
    action = wezterm.action.DecreaseFontSize
  },
  -- Window
  {
    key = "n",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.SpawnWindow
  },
  {
    key = "q",
    mods = utils.merge_mods_with_commands(),
    action = wezterm.action.QuitApplication
  },
  -- Tab
  {
    key = "PageUp",
    mods = "CTRL",
    action = wezterm.action({ ActivateTabRelative = -1 })
  },
  {
    key = "PageDown",
    mods = "CTRL",
    action = wezterm.action({ ActivateTabRelative = 1 })
  },
  {
    key = "LeftArrow",
    mods = utils.merge_mods_with_commands("ALT"),
    action = wezterm.action({ ActivateTabRelative = -1 })
  },
  {
    key = "RightArrow",
    mods = utils.merge_mods_with_commands("ALT"),
    action = wezterm.action({ ActivateTabRelative = 1 })
  },
  {
    key = "t",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ SpawnTab = "CurrentPaneDomain" })
  },
  {
    key = "w",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ CloseCurrentTab = { confirm = true } })
  },
  -- Pane
  -- ENキーボード用
  {
    key = "_",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } })
  },
  -- JISキーボード用
  {
    key = "=",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } })
  },
  {
    key = "|",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } })
  },
  {
    key = "z",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.TogglePaneZoomState
  },
  {
    key = "LeftArrow",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action { ActivatePaneDirection = "Left" }
  },
  {
    key = "RightArrow",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ ActivatePaneDirection = "Right" })
  },
  {
    key = "UpArrow",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ ActivatePaneDirection = "Up" })
  },
  {
    key = "DownArrow",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ ActivatePaneDirection = "Down" })
  },
  {
    key = "x",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ CloseCurrentPane = { confirm = true } })
  },
  {
    key = "}",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ RotatePanes = "Clockwise" })
  },
  {
    key = "{",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ RotatePanes = "CounterClockwise" })
  },
  -- Search
  {
    key = "f",
    mods = utils.merge_mods_with_commands(),
    action = wezterm.action.Search { CaseInSensitiveString = "" }
  },
  {
    key = "f",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.Search { Regex = "" }
  },
  -- Debug
  {
    key = "d",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.ShowDebugOverlay
  },
}

return {
  -- font
  font = generate_font(),
  font_size = generate_font_size(),
  use_ime = true,

  -- window
  window_background_opacity = 0.90,
  window_padding = {
    left = 2,
    right = 2,
    top = 0,
    bottom = 0,

  },
  enable_scroll_bar = false,
  color_scheme = "Vaughn",
  -- https://wezfurlong.org/wezterm/config/lua/config/skip_close_confirmation_for_processes_named.html
  skip_close_confirmation_for_processes_named = { "" },

  -- Key Bindings
  keys = utils.merge_lists(
    defaukt_key_bindings,
    generate_active_tab_key_bindings(),
    generate_spawn_tab_key_bindings(SPAWN_COMMANDS)
  ),
  quick_select_patterns = {
    -- URL
    "https?://[\\w/:%#\\$&\\?\\(\\)~\\.=\\+\\-]+",
    -- IPv4
    "((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])",
    -- IPv6
    "((([0-9a-f]{1,4}:){7}([0-9a-f]{1,4}|:))|(([0-9a-f]{1,4}:){6}(:[0-9a-f]{1,4}|((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3})|:))|(([0-9a-f]{1,4}:){5}(((:[0-9a-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3})|:))|(([0-9a-f]{1,4}:){4}(((:[0-9a-f]{1,4}){1,3})|((:[0-9a-f]{1,4})?:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9a-f]{1,4}:){3}(((:[0-9a-f]{1,4}){1,4})|((:[0-9a-f]{1,4}){0,2}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9a-f]{1,4}:){2}(((:[0-9a-f]{1,4}){1,5})|((:[0-9a-f]{1,4}){0,3}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9a-f]{1,4}:){1}(((:[0-9a-f]{1,4}){1,6})|((:[0-9a-f]{1,4}){0,4}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(:(((:[0-9a-f]{1,4}){1,7})|((:[0-9a-f]{1,4}){0,5}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:)))(%.+)?\\s*$"
  },
  disable_default_key_bindings = true,

  -- Multiplexing
  launch_menu = SPAWN_COMMANDS,
  default_prog = SPAWN_COMMANDS[1].args
}
