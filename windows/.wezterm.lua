local wezterm = require 'wezterm';

local TARGET_TRIPLE = wezterm.target_triple
local MAC_OS = TARGET_TRIPLE:find("darwin")
local WINDOWS = TARGET_TRIPLE:find("windows")
local LINUX = TARGET_TRIPLE:find("linux")

-- use CTRL or CMD key
local COMMAND_MODS_KEY = "CTRL"
if MAC_OS then
  COMMAND_MODS_KEY = "CMD"
end

-- domains for WSL environments
local WSL_DOMAINS = {
  {
    name = "WSL:Distrod",
    distribution = "Distrod",
    default_cwd = "~"
  },
  {
    name = "WSL:Ubuntu",
    distribution = "Ubuntu",
    default_cwd = "~"
  },
}

----------------------------------------------------------------------------------------------------
-- utility functions

local utils = {}

function utils.merge_lists(t1, t2)
  local lists = {}
  for _, v in ipairs(t1) do
    table.insert(lists, v)
  end
  for _, v in ipairs(t2) do
    table.insert(lists, v)
  end
  return lists
end

function utils.merge_mods_with_commands(...)
  local args = { ... }
  local mods = "CTRL"
  if MAC_OS then
    mods = "CMD"
  end

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
  local spawn_commands = {}
  if WINDOWS then
    local wsl_spawn_commands = {}
    for _, v in ipairs(WSL_DOMAINS) do
      table.insert(wsl_spawn_commands, {
        label = v.distribution,
        args = { "wsl.exe", v.default_cwd, "-d", v.distribution },
      })
    end
    -- WSL spawn commands & Windows spawn commands
    spawn_commands = utils.merge_lists(wsl_spawn_commands, {
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
  elseif MAC_OS or LINUX then
    spawn_commands = {
      {
        label = "Zsh",
        args = { "zsh", "-l" },
        cwd = "~"
      },
      {
        label = "Bash",
        args = { "bash", "-l" },
        cwd = "~"
      }
    }
  end
  return spawn_commands
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
    action = "ReloadConfiguration"
  },
  {
    key = "P",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = "ShowLauncher"
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
    action = "ActivateCopyMode"
  },
  {
    key = "Space",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = "QuickSelect"
  },
  -- Font Size
  {
    key = "0",
    mods = "CTRL",
    action = "ResetFontSize"
  },
  {
    key = ";",
    mods = "CTRL",
    action = "IncreaseFontSize"
  },
  {
    key = "-",
    mods = "CTRL",
    action = "DecreaseFontSize"
  },
  -- Window
  {
    key = "n",
    mods = "CTRL",
    action = "SpawnWindow"
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
    key = "T",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ SpawnTab = "CurrentPaneDomain" })
  },
  {
    key = "W",
    mods = utils.merge_mods_with_commands("SHIFT"),
    action = wezterm.action({ CloseCurrentTab = { confirm = true } })
  },
  -- Pane
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
    key = "x",
    mods = utils.merge_mods_with_commands("SHIFT", "ALT"),
    action = wezterm.action({ CloseCurrentPane = { confirm = false } })
  },
  -- TODO: 操作が安定板で有効になったら設定する
  -- {
  --   key = "N",
  --   mods = utils.merge_mods_with_commands("SHIFT"),
  --   action = wezterm.action({ RotatePanes = "Clockwise" })
  -- },
  -- {
  --   key = "P",
  --   mods = utils.merge_mods_with_commands("SHIFT"),
  --   action = wezterm.action({ RotatePanes = "CounterClockwise" })
  -- },
}

local spawn_commands = generate_spawn_commands()

return {
  -- font
  font = wezterm.font(
    "HackGenNerd Console",
    {
      weight = "Regular",
      stretch = "Normal",
      italic = false
    }
  ),
  font_size = 12.5,
  use_ime = true,

  -- window
  window_background_opacity = 0.95,
  window_padding = {
    left = 2,
    right = 2,
    top = 0,
    bottom = 0,

  },
  enable_scroll_bar = false,
  color_scheme = "Sublette",

  -- Key Bindings
  keys = utils.merge_lists(
    defaukt_key_bindings,
    utils.merge_lists(generate_active_tab_key_bindings(), generate_spawn_tab_key_bindings(spawn_commands))
  ),
  disable_default_key_bindings = true,

  -- Multiplexing
  launch_menu = spawn_commands,
  wsl_domains = WSL_DOMAINS,
  default_prog = spawn_commands[1].args
}
