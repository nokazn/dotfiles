local wezterm = require 'wezterm';

local utils = {}

function utils.merge_lists(t1, t2)
  local lists = {}
  for _, v in pairs(t1) do
    table.insert(lists, v)
  end
  for _, v in pairs(t2) do
    table.insert(lists, v)
  end
  return lists
end

----------------------------------------------------------------------------------------------------

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local user_title = tab.active_pane.user_vars.panetitle
  if user_title ~= nil and #user_title > 0 then
    return {
      { Text = tab.tab_index + 1 .. ":" .. user_title },
    }
  end

  local title = wezterm.truncate_right(utils.basename(tab.active_pane.foreground_process_name), max_width)
  if title == "" then
    -- local uri = utils.convert_home_dir(tab.active_pane.current_working_dir)
    -- local basename = utils.basename(uri)
    -- if basename == "" then
    -- 	basename = uri
    -- end
    -- title = wezterm.truncate_right(basename, max_width)
    local dir = string.gsub(tab.active_pane.title, "(.*[: ])(.*)", "%2")
    title = wezterm.truncate_right(dir, max_width)
  end
  return {
    { Text = tab.tab_index + 1 .. ":" .. title },
  }
end)

----------------------------------------------------------------------------------------------------

local function generate_tab_key_bindings()
  local keys = {}
  for i = 1, 9 do
    table.insert(keys, {
      key = tostring(i),
      mods = "CTRL",
      action = wezterm.action { ActivateTab = i - 1 },
    })
    table.insert(keys, {
      key = "F" .. tostring(i),
      mods = "CTRL",
      action = wezterm.action { ActivateTab = i - 1 },
    })
  end
  return keys
end

local defaukt_key_bindings = {
  {
    key = "r",
    mods = "CTRL|SHIFT",
    action = "ReloadConfiguration"
  },
  {
    key = "P",
    mods = "CTRL|SHIFT",
    action = "ShowLauncher"
  },
  -- Select & Copy & Paste
  {
    key = "c",
    mods = "CTRL|SHIFT",
    action = wezterm.action({ CopyTo = "Clipboard" })
  },
  {
    key = "v",
    mods = "CTRL|SHIFT",
    action = wezterm.action({ PasteFrom = "Clipboard" })
  },
  {
    key = "Insert",
    mods = "SHIFT",
    action = wezterm.action({ PasteFrom = "PrimarySelection" })
  },
  {
    key = "c",
    mods = "CTRL|ALT",
    action = "ActivateCopyMode"
  },
  {
    key = "Space",
    mods = "CTRL|SHIFT",
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
    mods = "CTRL|SHIFT",
    action = wezterm.action({ SpawnTab = "CurrentPaneDomain" })
  },
  {
    key = "W",
    mods = "CTRL|SHIFT",
    action = wezterm.action({ CloseCurrentTab = { confirm = false } })
  },
  -- Pane
  {
    key = "=",
    mods = "CTRL|SHIFT",
    action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } })
  },
  {
    key = "|",
    mods = "CTRL|SHIFT",
    action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } })
  },
  {
    key = "x",
    mods = "CTRL|SHIFT|ALT",
    action = wezterm.action({ CloseCurrentPane = { confirm = false } })
  },
  -- TODO: 操作が安定板で有効になったら設定する
  -- {
  --   key = "N",
  --   mods = "CTRL|SHIFT",
  --   action = wezterm.action({ RotatePanes = "Clockwise" })
  -- },
  -- {
  --   key = "P",
  --   mods = "CTRL|SHIFT",
  --   action = wezterm.action({ RotatePanes = "CounterClockwise" })
  -- },
}

local launch_menu = {
  {
    label = "Distrod",
  },
  {
    label = "Ubuntu",
    args = { "wsl.exe", "~", "-d", "Ubuntu" },
    cwd = "~"
  },
  {
    label = "NuShell",
    args = { "nu.exe" },
    cwd = "~"
  },
  {
    label = "PowerShell",
    args = { "powershell.exe" },
    cwd = "~"
  },
  {
    label = "Command Prompt",
    args = { "cmd.exe" },
    cwd = "~"
  }
}

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
  font_size = 12,
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
  keys = utils.merge_lists(defaukt_key_bindings, generate_tab_key_bindings()),
  disable_default_key_bindings = true,

  -- Menu
  launch_menu = launch_menu,
  default_prog = {
    "wsl.exe",
    "~",
    "-d",
    "Distrod",
  },
}
