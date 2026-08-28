# Zolar Library

##  Library
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/0ko0/Gui2/refs/heads/main/test.txt"))()
```



## Creating a Window
```lua
local Window = Library:Window({
    Name = "Zolar",
    Icon = "layers",
    Accent = Color3.fromRGB(179, 165, 255)
})

--[[
Name = <string> - The name of the UI.
Icon = <string | number> - Lucide icon name or rbxassetid.
Accent = <color3> - The accent color of the UI.
]]
```

### Window Methods
```lua
Window:SetOpen(false) -- Toggles visibility of the window
Window:Center()       -- Centers the window on the screen
Window:PlayIntro()    -- Plays the opening transition animation
```



## Creating a Tab
```lua
local Tab = Window:Tab({
    Name = "Main",
    Icon = "home"
})

--[[
Name = <string> - The name of the tab.
Icon = <string | number> - Lucide icon name or rbxassetid displayed on the rail.
]]
```

### Selecting a Tab
```lua
Tab:Select()
```



## Creating a SubTab
```lua
local SubTab = Tab:SubTab({
    Name = "Combat",
    Icon = "swords"
})

--[[
Name = <string> - The name of the sub-tab.
Icon = <string | number> - The icon of the sub-tab.
]]
```



## Creating a Section
```lua
local Section = SubTab:Section({
    Name = "Section",
    Side = "Left"
})

--[[
Name = <string> - The name of the section.
Side = <string | number> - The column side of the section ("Left" / 1 or "Right" / 2).
]]
```



## Notifying the user
```lua
Library:Notification({
    Name = "Title!",
    Description = "Notification content... what will it say??",
    Icon = "bell",
    Duration = 5,
    Type = "Info",
    SoundId = 4590662766,
    SoundVolume = 0.5,
    RichText = false,
    Buttons = {
        {
            Text = "Okay",
            Primary = true,
            CloseOnClick = true,
            Callback = function()
                print("pressed okay")
            end
        }
    }
})

--[[
Name = <string> - The title of the notification.
Description = <string> - The content of the notification.
Icon = <string | number> - The icon of the notification.
Duration = <number> - The duration of the notification in seconds (0 = never closes).
Type = <string> - Preset style ("Info", "Success", "Warning", "Error").
SoundId = <number | string> - Sound to play when the notification appears.
SoundVolume = <number> - Volume of the notification sound (0 to 1).
RichText = <bool> - Enables RichText formatting.
Buttons = <table> - Table containing interactive action buttons.
]]
```

### Clearing all active notifications
```lua
Library:ClearNotifications()
```



## Creating a Button
```lua
local CoolButton = Section:Button({
    Name = "Button!",
    Description = "This is a button description",
    Icon = "mouse-pointer",
    Risky = false,
    Disabled = false,
    Confirm = false,
    ConfirmText = "Are you sure?",
    HoldTime = 0,
    Callback = function()
        print("button pressed")
    end    
})

--[[
Name = <string> - The name of the button.
Description = <string> - Additional description text below the title.
Icon = <string | number> - Lucide icon or rbxassetid.
Risky = <bool> - Adds a red warning icon.
Disabled = <bool> - Disables user interaction if true.
Confirm = <bool> - Requires double click to confirm before executing.
ConfirmText = <string> - Confirmation prompt text if Confirm is true.
HoldTime = <number> - Seconds to hold before executing (0 = instant click).
Callback = <function> - The function of the button.
]]
```

### Button Methods
```lua
CoolButton:Press()                       -- Programmatically activates the button
CoolButton:SetText("New Button Name")    -- Updates button title
CoolButton:SetDescription("New desc")    -- Updates button description
CoolButton:SetIcon("zap")                -- Updates button icon
CoolButton:SetDisabled(true)             -- Disables or enables button
CoolButton:SetVisible(false)             -- Toggles button visibility
```

### Adding a Keybind to a Button
```lua
CoolButton:Keybind({
    Default = Enum.KeyCode.F,
    Flag = "ButtonBind"
})
```



## Creating a Checkbox toggle
```lua
local CoolToggle = Section:Toggle({
    Name = "This is a toggle!",
    Description = "Toggle description",
    Default = false,
    Risky = false,
    Disabled = false,
    Flag = "MyToggle",
    Callback = function(Value)
        print(Value)
    end    
})

--[[
Name = <string> - The name of the toggle.
Description = <string> - Additional description text below the title.
Default = <bool> - The default value of the toggle.
Risky = <bool> - Adds a red warning icon.
Disabled = <bool> - Disables user interaction if true.
Flag = <string> - The identifier used for configs and script access.
Callback = <function> - The function of the toggle.
]]
```

### Toggle Methods
```lua
CoolToggle:Set(true)            -- Changes toggle value
local value = CoolToggle:Get()  -- Returns current boolean state
CoolToggle:SetDisabled(true)    -- Disables or enables toggle
```

### Adding nested components to a Toggle
```lua
-- Add a Colorpicker next to the Toggle
CoolToggle:Colorpicker({
    Default = Color3.fromRGB(255, 0, 0),
    Transparency = 0,
    Rainbow = false,
    Flag = "ToggleColor",
    Callback = function(Color, Alpha, Rainbow)
        print(Color, Alpha, Rainbow)
    end
})

-- Add a Keybind next to the Toggle
CoolToggle:Keybind({
    Default = Enum.KeyCode.E,
    Mode = "Toggle", -- "Toggle" | "Hold" | "Always"
    Flag = "ToggleBind"
})

-- Add an Extra flyout panel next to the Toggle
local Extra = CoolToggle:Extra({ Width = 220 })
Extra:Slider({ Name = "Hit Chance", Min = 0, Max = 100, Default = 100, Suffix = "%" })
Extra:Dropdown({ Name = "Target Hitbox", Options = {"Head", "Torso"}, Default = "Head" })
```



## Creating a Slider
```lua
local CoolSlider = Section:Slider({
    Name = "Slider",
    Min = 0,
    Max = 100,
    Default = 20,
    Step = 1,
    Decimals = 0,
    Prefix = "",
    Suffix = " studs",
    DisplayFormat = nil,
    Disabled = false,
    Flag = "MySlider",
    Callback = function(Value)
        print(Value)
    end    
})

--[[
Name = <string> - The name of the slider.
Min = <number> - The minimum value of the slider.
Max = <number> - The maximum value of the slider.
Default = <number> - The default value of the slider.
Step = <number> - The increment step when dragging or scrolling.
Decimals = <number> - Number of decimal places to round to.
Prefix = <string> - Text placed before the value number.
Suffix = <string> - Text placed after the value number.
DisplayFormat = <function> - Custom formatting function (e.g. function(v) return "Val: "..v end).
Disabled = <bool> - Disables user interaction if true.
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the slider.
]]
```

### Slider Methods
```lua
CoolSlider:Set(50)            -- Changes slider value
local value = CoolSlider:Get()-- Returns current value
CoolSlider:SetMin(10)         -- Updates minimum boundary
CoolSlider:SetMax(200)        -- Updates maximum boundary
CoolSlider:SetStep(5)         -- Updates step increment
CoolSlider:SetDisabled(true)  -- Disables or enables slider
CoolSlider:SetVisible(false)  -- Toggles slider visibility
```



## Creating a Range Slider
```lua
local CoolRange = Section:RangeSlider({
    Name = "Range Slider",
    Min = 0,
    Max = 100,
    Default = {20, 80},
    MinDistance = 5,
    Step = 1,
    Decimals = 0,
    Prefix = "",
    Suffix = "s",
    Disabled = false,
    Flag = "MyRange",
    Callback = function(Value)
        print(Value.Min, Value.Max)
    end
})

--[[
Name = <string> - The name of the range slider.
Min = <number> - The minimum boundary.
Max = <number> - The maximum boundary.
Default = <table> - Table containing {Min, Max} initial values.
MinDistance = <number> - Minimum distance maintained between the two knobs.
Step = <number> - Increment step when dragging or scrolling.
Decimals = <number> - Number of decimal places to round to.
Prefix = <string> - Text placed before the value numbers.
Suffix = <string> - Text placed after the value numbers.
Disabled = <bool> - Disables user interaction if true.
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the range slider.
]]
```

### Range Slider Methods
```lua
CoolRange:Set(10, 60)           -- Changes range slider value (or pass {10, 60})
local value = CoolRange:Get()   -- Returns table { Min = 10, Max = 60, Low = 10, High = 60 }
CoolRange:SetMin(0)             -- Updates minimum boundary
CoolRange:SetMax(200)           -- Updates maximum boundary
CoolRange:SetDisabled(true)     -- Disables or enables range slider
CoolRange:SetVisible(false)     -- Toggles range slider visibility
```



## Creating a Dropdown menu
```lua
local CoolDropdown = Section:Dropdown({
    Name = "Dropdown",
    Description = "Dropdown description",
    Options = {
        "Option 1",
        "Option 2",
        { Name = "Option 3", Value = "CustomVal", Icon = "sparkles" }
    },
    Default = "Option 1",
    Multi = false,
    Max = nil,
    Search = true,
    Placeholder = "Select option...",
    Disabled = false,
    Flag = "MyDropdown",
    Callback = function(Value)
        print(Value)
    end    
})

--[[
Name = <string> - The name of the dropdown.
Description = <string> - Additional description text.
Options = <table> - Array of selectable options (strings or tables with Name, Value, Icon).
Default = <string | table> - The default selected value (table if Multi = true).
Multi = <bool> - Allows selecting multiple options.
Max = <number> - Maximum allowed selections if Multi is true.
Search = <bool> - Enables search bar inside dropdown menu.
Placeholder = <string> - Text displayed when no option is selected.
Disabled = <bool> - Disables user interaction if true.
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the dropdown.
]]
```

### Dropdown Methods
```lua
CoolDropdown:Set("Option 2")                       -- Selects an option
CoolDropdown:Refresh({"New 1", "New 2"}, false)    -- Refreshes options (false = clear selection)
CoolDropdown:AddOption("New Option")               -- Adds a single option
CoolDropdown:RemoveOption("New Option")            -- Removes a single option
CoolDropdown:SelectAll()                           -- Selects all items (Multi = true)
CoolDropdown:Clear()                               -- Clears all selections
local selected = CoolDropdown:Get()                -- Returns selected value(s)
CoolDropdown:SetDisabled(true)                     -- Disables or enables dropdown
CoolDropdown:SetVisible(false)                     -- Toggles dropdown visibility
```



## Creating an Adaptive Input
```lua
local CoolTextbox = Section:Textbox({
    Name = "Textbox",
    Description = "Textbox description",
    Default = "default text",
    Placeholder = "Type here...",
    Finished = false,
    ClearOnFocus = false,
    Numeric = false,
    Min = nil,
    Max = nil,
    MaxCharacters = nil,
    Icon = "pencil",
    ClearButton = true,
    CopyButton = true,
    Disabled = false,
    Flag = "MyTextbox",
    Callback = function(Value)
        print(Value)
    end,
    OnFocus = function()
        print("Focused")
    end,
    OnFocusLost = function(EnterPressed)
        print("Focus lost. Enter pressed:", EnterPressed)
    end
})

--[[
Name = <string> - The name of the textbox.
Description = <string> - Additional description text.
Default = <string> - The default value of the textbox.
Placeholder = <string> - Placeholder text when the box is empty.
Finished = <bool> - Only triggers callback on enter/focus lost if true.
ClearOnFocus = <bool> - Clears input field when clicked.
Numeric = <bool> - Restricts inputs to numbers and decimal points only.
Min = <number> - Minimum allowed number (if Numeric = true).
Max = <number> - Maximum allowed number (if Numeric = true).
MaxCharacters = <number> - Maximum character limit.
Icon = <string | number> - Icon displayed on the left side of the input box.
ClearButton = <bool> - Shows a quick clear button.
CopyButton = <bool> - Shows a quick copy button.
Disabled = <bool> - Disables user interaction if true.
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the textbox.
OnFocus = <function> - Triggered when input field is focused.
OnFocusLost = <function> - Triggered when focus is lost.
]]
```

### Textbox Methods
```lua
CoolTextbox:Set("New Text")              -- Changes textbox value
CoolTextbox:Clear()                      -- Clears textbox text
local text = CoolTextbox:Get()           -- Returns current text
CoolTextbox:SetPlaceholder("Search...")  -- Updates placeholder text
CoolTextbox:SetTitle("New Textbox Name") -- Updates textbox title
CoolTextbox:SetDescription("New desc")   -- Updates textbox description
CoolTextbox:SetDisabled(true)            -- Disables or enables textbox
CoolTextbox:SetVisible(false)            -- Toggles textbox visibility
```



## Creating a Keybind
```lua
local CoolBind = Section:Keybind({
    Name = "Bind",
    Default = Enum.KeyCode.E,
    Mode = "Toggle",
    Flag = "MyBind",
    Callback = function(Key)
        print("Pressed:", Key)
    end    
})

--[[
Name = <string> - The name of the bind.
Default = <KeyCode | UserInputType> - The default key or mouse button.
Mode = <string> - Activation mode: "Toggle", "Hold", or "Always".
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the bind.
]]
```

### Keybind Methods
```lua
CoolBind:Set(Enum.KeyCode.F)   -- Changes keybind key
local key = CoolBind:Get()     -- Returns current key
```



## Creating a Color Picker
```lua
local CoolColor = Section:Colorpicker({
    Name = "Colorpicker",
    Default = Color3.fromRGB(255, 0, 0),
    Transparency = 0,
    Rainbow = false,
    Flag = "MyColor",
    Callback = function(Color, Alpha, Rainbow)
        print(Color, Alpha, Rainbow)
    end	  
})

--[[
Name = <string> - The name of the colorpicker.
Default = <color3> - The default color value.
Transparency = <number> - Default transparency value (0 to 1).
Rainbow = <bool> - Enables rainbow mode cycle by default.
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the colorpicker.
]]
```

### Color Picker Methods
```lua
CoolColor:Set(Color3.fromRGB(255, 255, 255), 0, false) -- Sets Color, Alpha, Rainbow
local color, alpha, rainbow = CoolColor:Get()          -- Returns current color values
```



## Creating a Label
```lua
local CoolLabel = Section:Label({
    Name = "Label",
    Description = "Label Description",
    Icon = "info",
    Color = "Text",
    DescColor = "DimText",
    RightText = "Status: OK",
    RightColor = "Accent",
    RichText = false,
    Align = Enum.TextXAlignment.Left,
    Wrap = false
})

--[[
Name = <string> - The title text of the label.
Description = <string> - Subtitle description text.
Icon = <string | number> - Icon displayed on the label.
Color = <string | Color3> - Title color (Theme key or Color3).
DescColor = <string | Color3> - Description color.
RightText = <string> - Text aligned to the right side.
RightColor = <string | Color3> - Color of the right-aligned text.
RichText = <bool> - Enables RichText formatting.
Align = <TextXAlignment> - Text alignment.
Wrap = <bool> - Wraps long text across multiple lines.
]]
```

### Label Methods
```lua
CoolLabel:SetText("New Label Title")      -- Updates label title
CoolLabel:SetDescription("New Subtitle")  -- Updates description
CoolLabel:SetRightText("Active")          -- Updates right text
CoolLabel:SetColor("Accent")              -- Updates label color
CoolLabel:SetIcon("shield")               -- Updates label icon
CoolLabel:SetVisible(false)               -- Toggles visibility
```



## Creating a Paragraph
```lua
local CoolParagraph = Section:Paragraph({
    Title = "Paragraph",
    Content = "Paragraph Content",
    TitleColor = "Text",
    ContentColor = "DimText",
    TitleSize = 15,
    ContentSize = 14,
    Icon = "info",
    IconColor = "DimText",
    RichText = false,
    Align = Enum.TextXAlignment.Left,
    CopyButton = true
})

--[[
Title = <string> - The title of the paragraph.
Content = <string> - The body content of the paragraph.
TitleColor = <string | Color3> - Title color.
ContentColor = <string | Color3> - Body text color.
TitleSize = <number> - Font size for the title.
ContentSize = <number> - Font size for the body text.
Icon = <string | number> - Icon displayed next to the paragraph.
IconColor = <string | Color3> - Color of the icon.
RichText = <bool> - Enables RichText formatting.
Align = <TextXAlignment> - Text alignment.
CopyButton = <bool> - Adds a button to copy content to clipboard.
]]
```

### Paragraph Methods
```lua
CoolParagraph:SetTitle("New Title")                     -- Updates title
CoolParagraph:SetContent("New Content text")            -- Updates content
CoolParagraph:SetText("New Title", "New Content")       -- Updates both title and content
CoolParagraph:SetTitleColor("Accent")                   -- Updates title color
CoolParagraph:SetContentColor("DimText")                -- Updates content color
CoolParagraph:SetIcon("globe")                          -- Updates icon
CoolParagraph:SetVisible(false)                         -- Toggles visibility
```



## Creating a Watermark
```lua
local Watermark = Library:Watermark({
    Name = "Zolar Hub",
    Icon = "layers"
})

--[[
Name = <string> - The title text displayed on the draggable watermark bar.
Icon = <string | number> - Icon displayed on the watermark.
]]
```

### Watermark Methods
```lua
Watermark:SetName("Zolar Hub v1.1")  -- Updates watermark title
Watermark:SetVisible(false)          -- Toggles watermark visibility
```



## Theme and Config System
Zolar Library comes with a built-in interactive Config and Theme manager page.

```lua
local SettingsTab = Window:Tab({ Name = "Settings", Icon = "settings" })
local ConfigSubTab = SettingsTab:SubTab({ Name = "Configs", Icon = "folder" })

ConfigSubTab:ThemeConfig()
```



### How flags work.
The flags feature serves as the ID of an element in the config file and allows you to read or write the value anywhere in the code.

```lua
Section:Toggle({
    Name = "Toggle",
    Default = true,
    Flag = "MyToggle"
})

print(Library.Flags["MyToggle"]) -- prints the boolean value of the toggle.
```

To programmatically change the value of any flag element:
```lua
Library.SetFlags["MyToggle"](false)
```



## Global Library Methods
```lua
Library:SetUIScale(1.0)                         -- Sets the UI scale multiplier
Library:SetAccent(Color3.fromRGB(96, 150, 255)) -- Changes global accent color
Library:SetTheme("Azure")                       -- Applies theme preset ("Default", "Azure", "Emerald", "Ocean", "Rose")
Library:SaveConfigFile("Legit")                 -- Saves current configuration to file
Library:LoadConfigFile("Legit")                 -- Loads configuration from file
Library:SetAutoload("Legit")                    -- Sets configuration to automatically load on start
Library:ResetConfig()                           -- Resets all flags
```



## Destroying the Interface
```lua
Library:Unload()
```
