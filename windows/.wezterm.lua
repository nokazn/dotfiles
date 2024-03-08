local wezterm = require 'wezterm';

-- use CTRL or CMD key
local COMMAND_MODS_KEY = "CTRL"

-- domains for WSL environments
local WSL_DOMAINS = {
  {
    name = "WSL:Arch",
    distribution = "Arch",
    default_cwd = "~"
  },
  {
    name = "WSL:Debian",
    distribution = "Debian",
    default_cwd = "~"
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

-- spawn commands for Windows or macOS/Linux environments
local function generate_spawn_commands()
  local wsl_spawn_commands = {}
  for _, v in ipairs(WSL_DOMAINS) do
    table.insert(wsl_spawn_commands, {
      label = v.distribution,
      args = { "wsl.exe", v.default_cwd, "-d", v.distribution },
    })
  end
  -- WSL spawn commands & Windows spawn commands
  return utils.merge_lists(wsl_spawn_commands, {
    {
      label = "NuShell",
      args = { "nu.exe" },
      cwd = "~"
    },
    {
      label = "PowerShell",
      args = { "powershell.exe", "-NoLogo" },
      cwd = "~"
    },
    {
      label = "Command Prompt",
      args = { "cmd.exe" },
      cwd = "~"
    }
  })
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
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.ShowLauncher
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
    key = "c",
    mods = utils.merge_mods_with_commands("ALT"),
    action = wezterm.action.ActivateCopyMode
  },
  {
    key = "Space",
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
    mods = utils.merge_mods_with_commands(),
    action = wezterm.action.SpawnWindow
  },
  -- Tab
  {
    key = "PageUp",
    mods = utils.merge_mods_with_commands(),
    action = wezterm.action({ ActivateTabRelative = -1 })
  },
  {
    key = "PageDown",
    mods = utils.merge_mods_with_commands(),
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
  {
    key = "-",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } })
  },
  {
    key = "-",
    -- CTRL + SHIFT + "-" does not work on Windows
    mods = utils.merge_mods_with_commands("ALT"),
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
  -- Debug
  {
    key = "d",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action.ShowDebugOverlay
  },
}

local spawn_commands = generate_spawn_commands()

return {
  -- font
  font = wezterm.font(
    "HackGen Console",
    {
      weight = "Regular",
      stretch = "Normal",
      italic = false
    }
  ),
  font_size = 12.5,
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
    generate_spawn_tab_key_bindings(spawn_commands)
  ),
  disable_default_key_bindings = true,

  -- Multiplexing
  launch_menu = spawn_commands,
  wsl_domains = WSL_DOMAINS,
  default_prog = spawn_commands[1].args
}
