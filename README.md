# Zolar Library v1.1 Documentation

---

## 🚀 Loading the Library

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/0ko0/Gui2/refs/heads/main/test.txt"))()
```

---

## 🪟 Creating a Window

```lua
local Window = Library:Window({
    Name = "Zolar Hub",
    Icon = "layers",
    Accent = Color3.fromRGB(179, 165, 255)
})
```

### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"ZOLAR"` | The title text displayed in the header and Dynamic Island. |
| `Icon` | `string \| number` | `"layers"` | Lucide icon name or Roblox asset ID (`rbxassetid://...`). |
| `Accent` | `Color3` | `Color3.fromRGB(179, 165, 255)` | Overrides the primary global accent color. |

### Built-in Window Features
- **Universal Search Bar:** Type into the header search input to filter items across all tabs and sections in real-time.
- **Dynamic Island (Minimize):** Clicking the minimize icon collapses the window into an iOS-style Dynamic Island pill at the top of the screen. Dragging or clicking it restores the window.
- **Profile Popover:** Clicking the user avatar opens an interactive profile card featuring:
  - Account info, Avatar, DisplayName, Username.
  - One-click User ID copy to clipboard.
  - **Interface Scale:** Live interactive slider from 50% to 150%.
  - **Menu Keybind Picker:** Quick toggle keybind change.
  - **Hide Info Switch:** Anonymizes the user's name, ID, and avatar in the UI.
  - **Unload Button:** Safely tears down and unloads the library.
- **Mobile Touch Support:** On mobile devices, a floating draggable toggle button (`Zolar_MobileToggle`) appears automatically. Viewport scaling is adjusted to avoid screen clipping.

### Window Methods
```lua
Window:SetOpen(true)    -- Toggles window visibility (true/false)
Window:Center()         -- Recalculates and centers the window on screen
Window:PlayIntro()      -- Replays the smooth opening transition
```

---

## 📑 Tabs and SubTabs

The window layout is split into primary vertical **Rail Tabs** (left) and horizontal **SubTabs** (bottom bar).

### Creating a Tab
```lua
local MainTab = Window:Tab({
    Name = "Combat",
    Icon = "swords"
})

-- Selecting a tab programmatically
MainTab:Select()
```

### Creating a SubTab
```lua
local AimbotSub = MainTab:SubTab({
    Name = "Aimbot",
    Icon = "crosshair"
})
```

---

## 📦 Sections

Sections group elements inside a SubTab. Each SubTab has a dual-column layout (`Left` / `1` or `Right` / `2`).

```lua
local LeftSection = AimbotSub:Section({
    Name = "Legit Aimbot",
    Side = "Left" -- "Left" (1) or "Right" (2)
})
```

---

## 🔘 Checkbox Toggle

A toggle switch with smooth pill-knob animations.

```lua
local MyToggle = LeftSection:Toggle({
    Name = "Enable Aimbot",
    Description = "Automatically locks onto target heads",
    Default = false,
    Risky = false,
    Disabled = false,
    Flag = "Aimbot_Enabled",
    Callback = function(Value)
        print("Toggle state:", Value)
    end
})
```

### Toggle Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Toggle"` | Title of the toggle. |
| `Description` | `string` | `""` | Optional subtitle description below the title. |
| `Default` | `bool` | `false` | Initial boolean state. |
| `Risky` | `bool` | `false` | Displays a warning alert badge before the label. |
| `Disabled` | `bool` | `false` | Prevents user interaction when true. |
| `Flag` | `string` | `nil` | Identifier used for saving/loading configs. |
| `Callback` | `function` | `function(Value) end` | Executed when state changes. |

### Toggle Methods
```lua
MyToggle:Set(true)            -- Sets toggle value (triggers callback unless silent)
local state = MyToggle:Get()  -- Returns current boolean state
MyToggle:SetDisabled(true)    -- Enables or disables the toggle control
MyToggle:SetVisible(false)    -- Shows or hides the toggle row
```

### Attaching Nested Sub-Components to a Toggle
You can nest inline pickers and flyout panels directly beside the toggle:

```lua
-- 1. Attach an inline Colorpicker
MyToggle:Colorpicker({
    Default = Color3.fromRGB(255, 60, 60),
    Transparency = 0,
    Rainbow = false,
    Flag = "Aimbot_Color",
    Callback = function(Color, Alpha, Rainbow)
        print(Color, Alpha, Rainbow)
    end
})

-- 2. Attach an inline Keybind with activation mode selection
MyToggle:Keybind({
    Default = Enum.KeyCode.E,
    Mode = "Hold", -- "Toggle" | "Hold" | "Always"
    Flag = "Aimbot_Key"
})

-- 3. Attach a Flyout Extra Panel
local Extra = MyToggle:Extra({ Width = 220 })
Extra:Slider({ Name = "Smoothness", Min = 1, Max = 10, Default = 5 })

-- 4. Direct Shorthands (Automatically mounts into the Toggle's Extra panel)
MyToggle:Slider({ Name = "FOV Radius", Min = 10, Max = 500, Default = 90 })
MyToggle:Dropdown({ Name = "Target Part", Options = {"Head", "Torso"}, Default = "Head" })
MyToggle:Textbox({ Name = "Custom Priority", Placeholder = "Player..." })
MyToggle:RangeSlider({ Name = "Distance Range", Min = 0, Max = 1000, Default = {50, 400} })
MyToggle:Toggle({ Name = "Check Visibility", Default = true })
```

---

## 🎚️ Sliders

Supports drag-to-adjust, direct text input, mouse-wheel scrolling (`Shift` accelerates by 5x), and mobile touch tooltips.

```lua
local MySlider = LeftSection:Slider({
    Name = "Target FOV",
    Min = 0,
    Max = 360,
    Default = 90,
    Step = 1,
    Decimals = 0,
    Prefix = "",
    Suffix = "°",
    DisplayFormat = nil,
    Disabled = false,
    Flag = "Aimbot_FOV",
    Callback = function(Value)
        print("FOV:", Value)
    end
})
```

### Slider Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Slider"` | Title of the slider. |
| `Min` | `number` | `0` | Minimum allowed value. |
| `Max` | `number` | `100` | Maximum allowed value. |
| `Default` | `number` | `Min` | Starting value. |
| `Step` | `number` | `1 / (10 ^ Decimals)` | Precision increment when sliding. |
| `Decimals` | `number` | `0` | Number of decimal places to round to. |
| `Prefix` | `string` | `""` | Text prepended to the value display. |
| `Suffix` | `string` | `""` | Text appended to the value display. |
| `DisplayFormat` | `function` | `nil` | Custom formatter function `function(v) return "Val: "..v end`. |
| `Disabled` | `bool` | `false` | Disables interaction if true. |
| `Flag` | `string` | `nil` | Identifier for config saving. |
| `Callback` | `function` | `function(Value) end` | Fires when the value changes. |

### Slider Methods
```lua
MySlider:Set(120)                       -- Sets value
local val = MySlider:Get()              -- Returns current value
MySlider:SetMin(20)                     -- Changes minimum limit
MySlider:SetMax(500)                    -- Changes maximum limit
MySlider:SetStep(5)                     -- Changes step precision
MySlider:SetDisabled(true)              -- Enables/disables slider
MySlider:SetVisible(false)              -- Shows/hides slider
MySlider:SetCallback(function(v) end)   -- Updates callback function
```

---

## 📏 Range Slider

A dual-knob slider designed for intervals and min/max ranges.

```lua
local MyRange = LeftSection:RangeSlider({
    Name = "Distance Range",
    Min = 0,
    Max = 1000,
    Default = {100, 600},
    MinDistance = 50,
    Step = 5,
    Decimals = 0,
    Prefix = "",
    Suffix = " studs",
    Disabled = false,
    Flag = "Target_Distance",
    Callback = function(Value)
        print("Min:", Value.Min, "Max:", Value.Max)
    end
})
```

### Range Slider Controls
- **Mouse Drag:** Dragging picks the closest knob automatically.
- **Mouse Wheel:** Wheel adjusts `Min`; holding `Ctrl` + Wheel adjusts `Max`; `Shift` accelerates.
- **Text Box Input:** You can type ranges directly into the text box (e.g. `100 600` or `100 - 600`).

### Range Slider Methods
```lua
MyRange:Set(50, 450)                 -- Sets range via two numbers or a table {50, 450}
local range = MyRange:Get()          -- Returns table: { Min = 50, Max = 450, Low = 50, High = 450 }
MyRange:SetMin(0)                    -- Updates minimum limit
MyRange:SetMax(2000)                 -- Updates maximum limit
MyRange:SetDisabled(true)            -- Enables/disables control
MyRange:SetVisible(false)            -- Shows/hides row
MyRange:SetCallback(function(v) end) -- Updates callback
```

---

## 🔽 Dropdown Menu

Interactive dropdown supporting single/multi selection, quick search filtering, icons, and action headers.

```lua
local MyDropdown = LeftSection:Dropdown({
    Name = "Target Priority",
    Description = "Select parts in priority order",
    Options = {
        "Head",
        "Torso",
        { Name = "HumanoidRootPart", Value = "HRP", Icon = "box", Desc = "Center root part" }
    },
    Default = "Head",
    Multi = false,
    Max = nil,
    Search = true,
    Placeholder = "Select a target...",
    Disabled = false,
    Flag = "Target_Priority",
    Callback = function(Selected)
        print("Selected:", Selected)
    end
})
```

### Dropdown Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Dropdown"` | Label text. |
| `Description` | `string` | `""` | Description text. |
| `Options` | `table` | `{}` | Array of strings or tables `{ Name, Value, Icon, Desc }`. |
| `Default` | `string \| table` | `nil` | Default selected value (table if `Multi = true`). |
| `Multi` | `bool` | `false` | Enables multiple selections. |
| `Max` | `number` | `nil` | Selection count limit when `Multi = true`. |
| `Search` | `bool` | `auto` | Forces the search bar on (auto-enabled if options > 8). |
| `Placeholder` | `string` | `"Select option..."`| Placeholder when nothing is selected. |
| `Disabled` | `bool` | `false` | Disables dropdown interaction. |
| `Flag` | `string` | `nil` | Config identifier. |
| `Callback` | `function` | `function(Selected) end` | Fires on selection update. |

### Dropdown Methods
```lua
MyDropdown:Set("Torso")                     -- Sets current value
local current = MyDropdown:Get()            -- Returns selected value(s)
MyDropdown:Refresh({"Option A", "Option B"}, false) -- Refreshes options list (false = clear selection)
MyDropdown:AddOption("Legs")                -- Adds a new option
MyDropdown:RemoveOption("Legs")             -- Removes an existing option
MyDropdown:SelectAll()                      -- Selects all items (Multi = true)
MyDropdown:Clear()                          -- Deselects everything
MyDropdown:SetDisabled(true)                -- Disables/enables dropdown
MyDropdown:SetVisible(false)                -- Shows/hides row
MyDropdown:SetCallback(function(v) end)     -- Updates callback
```

---

## 🖱️ Button

Action buttons with ripple sweeps, confirmation dialogs, hold timers, and optional keybind slots.

```lua
local MyButton = LeftSection:Button({
    Name = "Crash Server",
    Description = "Attempts to overload network traffic",
    Icon = "flame",
    Risky = true,
    Disabled = false,
    Confirm = true,
    ConfirmText = "Click again to confirm!",
    HoldTime = 0,
    Callback = function()
        print("Action confirmed!")
    end
})

-- Attach a keybind trigger to the button
MyButton:Keybind({
    Default = Enum.KeyCode.K,
    Flag = "Crash_Bind"
})
```

### Button Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Button"` | Button label. |
| `Description` | `string` | `""` | Description subtitle. |
| `Icon` | `string \| number` | `nil` | Lucide icon name or asset ID. |
| `Risky` | `bool` | `false` | Displays a red hazard warning badge. |
| `Disabled` | `bool` | `false` | Disables button interactions. |
| `Confirm` | `bool` | `false` | Requires a second click within 3s before executing. |
| `ConfirmText` | `string` | `"Are you sure?"` | Warning label during confirmation. |
| `HoldTime` | `number` | `0` | Seconds to hold down before executing (0 = instant). |
| `Callback` | `function` | `function() end` | Callback function executed on click. |

### Button Methods
```lua
MyButton:Press()                            -- Triggers the button programmatically
MyButton:SetText("New Label")               -- Updates label text
MyButton:SetDescription("New description")  -- Updates subtitle
MyButton:SetIcon("zap")                     -- Updates icon
MyButton:SetDisabled(true)                  -- Disables or enables button
MyButton:SetVisible(false)                  -- Shows or hides button
MyButton:SetCallback(function() end)        -- Updates callback
```

---

## ⌨️ Textbox

Adaptive input box supporting numeric constraints, min/max limits, clipboard actions, and custom triggers.

```lua
local MyTextbox = LeftSection:Textbox({
    Name = "Teleport Coordinates",
    Description = "Enter target X Y Z vector",
    Default = "0, 50, 0",
    Placeholder = "e.g. 100, 20, -50",
    Finished = false,
    ClearOnFocus = false,
    Numeric = false,
    Min = nil,
    Max = nil,
    MaxCharacters = 64,
    Icon = "map-pin",
    ClearButton = true,
    CopyButton = true,
    Disabled = false,
    Flag = "TP_Coords",
    Callback = function(Text)
        print("Text changed:", Text)
    end,
    OnFocus = function()
        print("Input focused")
    end,
    OnFocusLost = function(EnterPressed)
        print("Focus lost. Enter pressed:", EnterPressed)
    end
})
```

### Textbox Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Textbox"` | Label text. |
| `Description` | `string` | `""` | Subtitle text. |
| `Default` | `string` | `""` | Initial input value. |
| `Placeholder` | `string` | `"..."` | Placeholder text. |
| `Finished` | `bool` | `false` | If true, only triggers callback when Enter is pressed or focus is lost. |
| `ClearOnFocus` | `bool` | `false` | Clears text when user clicks inside. |
| `Numeric` | `bool` | `false` | Restricts characters to numbers and decimal points. |
| `Min` / `Max` | `number` | `nil` | Enforces minimum/maximum numerical limits if `Numeric = true`. |
| `MaxCharacters` | `number` | `nil` | Maximum text character length limit. |
| `Icon` | `string \| number` | `nil` | Leading icon inside the textbox. |
| `ClearButton` | `bool` | `false` | Adds a quick clear (`x`) button. |
| `CopyButton` | `bool` | `false` | Adds a quick copy button to clipboard. |
| `Disabled` | `bool` | `false` | Disables editing. |
| `Flag` | `string` | `nil` | Config identifier. |
| `Callback` | `function` | `function(Text) end` | Fires when input changes. |
| `OnFocus` | `function` | `function() end` | Fires when input is clicked. |
| `OnFocusLost` | `function` | `function(EnterPressed) end` | Fires when focus is released. |

### Textbox Methods
```lua
MyTextbox:Set("New Vector")                 -- Sets text programmatically
MyTextbox:Clear()                           -- Clears text
local val = MyTextbox:Get()                 -- Returns current string value
MyTextbox:SetPlaceholder("Search...")       -- Changes placeholder
MyTextbox:SetTitle("Coordinates")           -- Updates label
MyTextbox:SetDescription("World position")  -- Updates description
MyTextbox:SetDisabled(true)                 -- Disables/enables control
MyTextbox:SetVisible(false)                 -- Shows/hides row
MyTextbox:SetCallback(function(txt) end)    -- Updates callback
```

---

## 🎮 Keybind

Dedicated keybinding row that supports Keyboard keys, Mouse buttons (`MB1`, `MB2`, `MB3`), hold/toggle states, and **floating touch widgets on mobile**.

```lua
local MyBind = LeftSection:Keybind({
    Name = "Fly Toggle",
    Default = Enum.KeyCode.F,
    Mode = "Toggle", -- "Toggle" | "Hold" | "Always"
    Flag = "Fly_Keybind",
    Callback = function(KeyOrState)
        print("Keybind triggered:", KeyOrState)
    end
})
```

### Keybind Methods
```lua
MyBind:Set(Enum.KeyCode.X)  -- Sets bound key programmatically
local key = MyBind:Get()    -- Returns current bound KeyCode / UserInputType
```

> **📱 Mobile Behavior:** When bound on a touch device, Zolar automatically spawns a draggable floating button on the screen (`Zolar_KeybindWidget`) displaying the bound key name. Tapping it activates the keybind callback directly.

---

## 🎨 Colorpicker

Full-featured color editor with HSV field, alpha bar, hex input, copy/paste buttons, rainbow mode, and quick palette swatches.

```lua
local MyColor = LeftSection:Colorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(120, 132, 255),
    Transparency = 0.2,
    Rainbow = false,
    Flag = "ESP_Color",
    Callback = function(Color, Alpha, Rainbow)
        print("Color:", Color, "Alpha:", Alpha, "Rainbow:", Rainbow)
    end
})
```

### Colorpicker Methods
```lua
MyColor:Set(Color3.fromRGB(255, 0, 0), 0, false) -- Updates Color, Alpha (0-1), Rainbow (bool)
local color, alpha, rainbow = MyColor:Get()     -- Returns Color3, Alpha, Rainbow
```

---

## 🏷️ Label

Informative text row with multi-line wrap, icons, and right-aligned tags.

```lua
local MyLabel = LeftSection:Label({
    Name = "Player Status",
    Description = "Connected to Frankfurt Server",
    Icon = "shield-check",
    Color = "Text",
    DescColor = "DimText",
    RightText = "SECURE",
    RightColor = "Accent",
    RichText = false,
    Align = Enum.TextXAlignment.Left,
    Wrap = false
})
```

### Label Methods
```lua
MyLabel:SetText("Connection Status")  -- Updates label text
MyLabel:SetDescription("Ping: 24ms")  -- Updates description text
MyLabel:SetRightText("ONLINE")        -- Updates right tag text
MyLabel:SetColor("Accent")            -- Updates color ("Accent", "Text", or Color3)
MyLabel:SetIcon("wifi")               -- Updates icon
MyLabel:SetVisible(false)             -- Shows or hides label
```

---

## 📝 Paragraph

Content block designed for documentation, multi-line changelogs, and copyable text.

```lua
local MyParagraph = LeftSection:Paragraph({
    Title = "Version 1.1 Changelog",
    Content = "- Added Universal Search\n- Mobile floating widgets\n- New range slider\n- Config auto-load system",
    TitleColor = "Text",
    ContentColor = "DimText",
    TitleSize = 15,
    ContentSize = 13,
    Icon = "info",
    IconColor = "Accent",
    RichText = false,
    Align = Enum.TextXAlignment.Left,
    CopyButton = true
})
```

### Paragraph Methods
```lua
MyParagraph:SetTitle("Patch Notes")                -- Updates title
MyParagraph:SetContent("Bug fixes applied.")       -- Updates content
MyParagraph:SetText("Title", "Content")            -- Updates both
MyParagraph:SetTitleColor("Accent")                -- Updates title color
MyParagraph:SetContentColor("DimText")             -- Updates content color
MyParagraph:SetIcon("file-text")                   -- Updates icon
MyParagraph:RecalculateHeight()                    -- Recalculates canvas layout
MyParagraph:SetVisible(false)                      -- Shows or hides paragraph
```

---

## ➖ Divider

Visual separator that can be either an uppercase title divider or a simple thin line.

```lua
-- 1. Centered header divider
local TextDivider = LeftSection:Divider("Extra Options")

-- 2. Clean horizontal separator line
local LineDivider = LeftSection:Divider()

-- Visibility control
TextDivider:SetVisible(false)
```

---

## 📊 ProgressBar

Live animated progress bar with percentage readout.

```lua
local MyBar = LeftSection:ProgressBar({
    Name = "Download Progress",
    Default = 35 -- Percentage (0 - 100)
})

-- Update progress
MyBar:Set(80)

-- Visibility control
MyBar:SetVisible(false)
```

---

## 🔔 Notifications

Slide-in notification toasts featuring timers, sound effects, action buttons, and automatic stacking.

```lua
Library:Notification({
    Name = "Update Available",
    Description = "A new script revision is available. Would you like to update?",
    Icon = "bell-ring",
    Duration = 6, -- Seconds (0 = stays open until dismissed)
    Type = "Info", -- "Info" | "Success" | "Warning" | "Error"
    SoundId = 4590662766,
    SoundVolume = 0.6,
    RichText = false,
    Width = 320,
    Buttons = {
        {
            Text = "Update Now",
            Primary = true,
            CloseOnClick = true,
            Callback = function()
                print("Updating...")
            end
        },
        {
            Text = "Dismiss",
            Primary = false,
            CloseOnClick = true
        }
    },
    OnClose = function()
        print("Notification closed")
    end
})

-- Clear all active notifications
Library:ClearNotifications()
```

---

## 🧭 Watermark

Draggable on-screen HUD bar displaying Game title, real-time FPS counter, Ping (ms), and system clock.

```lua
local Watermark = Library:Watermark({
    Name = "Zolar Hub v1.1",
    Icon = "layers"
})

-- Watermark Methods
Watermark:SetName("Zolar Private")  -- Updates title text
Watermark:SetVisible(false)         -- Toggles watermark visibility
```

---

## 💾 Theme & Config System

Zolar features a built-in interactive Config and Theme Manager page that can be mounted into any SubTab with a single call.

```lua
local SettingsTab = Window:Tab({ Name = "Settings", Icon = "settings" })
local ConfigSub = SettingsTab:SubTab({ Name = "Configurations", Icon = "folder" })

-- Mounts the full theme and configuration page
ConfigSub:ThemeConfig()
```

### Config Page Features
- **Config Management:** Create, save, overwrite, delete, and copy raw config JSON to clipboard.
- **Import from Clipboard:** Paste valid JSON from clipboard directly into the library.
- **Autoload (⚡):** Clicking the Zap icon sets that config to automatically execute on script startup.
- **Config Metadata Card:** Displays Config Version, Compatibility check, Creation date, Creator username, and Saved flag count.
- **Theme Presets:** One-click presets: `Default`, `Azure`, `Emerald`, `Ocean`, and `Rose`.
- **Palette Editor:** Interactive color pickers for `Background`, `Section`, `Element`, `Light`, `Text`, `DimText`, and `Accent`.

---

## 🚩 How Flags Work

Flags uniquely identify element values across configs, scripts, and runtime lookups.

```lua
-- Register a flag on any element
LeftSection:Toggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "Farm_Enabled"
})

-- 1. Read current value
local isFarming = Library.Flags["Farm_Enabled"]

-- 2. Modify value programmatically (triggers visual and callback)
Library.SetFlags["Farm_Enabled"](true)
```

---

## ⚙️ Global Library Methods & Properties

```lua
-- UI Scaling
Library:SetUIScale(1.0)                         -- Scales entire interface (0.5 to 1.5)

-- Theme Management
Library:SetAccent(Color3.fromRGB(96, 150, 255)) -- Sets global accent color
Library:SetThemeColor("Section", Color3.fromRGB(25, 25, 30)) -- Overrides a specific theme key
Library:SetTheme("Azure")                       -- Applies preset: "Default" | "Azure" | "Emerald" | "Ocean" | "Rose"
Library:ApplyThemeInstant()                     -- Forces immediate recoloring of all active elements

-- Config Management
Library:SaveConfigFile("Legit")                 -- Saves current flags to file
Library:LoadConfigFile("Legit")                 -- Loads configuration from file
Library:LoadConfig(jsonString)                  -- Loads raw JSON string
local raw = Library:GetConfig()                 -- Generates current config JSON string
local files = Library:ListConfigs()             -- Returns array of config file names
Library:ResetConfig()                           -- Resets all registered flags to defaults

-- Autoload Management
Library:SetAutoload("Legit")                    -- Sets startup config name
local auto = Library:GetAutoload()              -- Returns current autoload name
Library:CheckAutoload()                         -- Triggers autoload check

-- Popups & Cleanup
Library:CloseAllPopups()                        -- Closes any active dropdown/picker menus
Library:ClearNotifications()                    -- Dismisses all active notifications
Library:Unload()                                -- Completely destroys UI, signals, and background threads
```

---

## 🧹 Destroying the Interface

To safely disconnect all events, kill render loops, destroy UI containers, and clear global variables:

```lua
Library:Unload()
```
