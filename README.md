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
    Buttons = {
        {
            Text = "Okay",
            Primary = true,
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
Buttons = <table> - Table containing interactive button objects.
]]
```



## Creating a Button
```lua
local CoolButton = Section:Button({
    Name = "Button!",
    Description = "This is a button description",
    Icon = "mouse-pointer",
    Risky = false,
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
Confirm = <bool> - Requires double click to confirm before executing.
ConfirmText = <string> - Confirmation prompt text if Confirm is true.
HoldTime = <number> - Seconds to hold before executing (0 = instant click).
Callback = <function> - The function of the button.
]]
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

### Changing the value of an existing Toggle
```lua
CoolToggle:Set(true)
```

### Adding nested components to a Toggle
```lua
-- Add a Colorpicker next to the Toggle
CoolToggle:Colorpicker({
    Default = Color3.fromRGB(255, 0, 0),
    Transparency = 0,
    Flag = "ToggleColor",
    Callback = function(Color, Alpha, Rainbow)
        print(Color)
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
Extra:Slider({ Name = "FOV Size", Min = 0, Max = 300, Default = 100 })
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
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the slider.
]]
```

### Change Slider Value
```lua
CoolSlider:Set(50)
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
    Suffix = "s",
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
Step = <number> - Increment step when dragging.
Suffix = <string> - Text placed after the value numbers.
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the range slider.
]]
```

### Change Range Slider Value
```lua
CoolRange:Set(10, 60)
```



## Creating a Dropdown menu
```lua
local CoolDropdown = Section:Dropdown({
    Name = "Dropdown",
    Description = "Dropdown description",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Multi = false,
    Max = nil,
    Search = true,
    Placeholder = "Select option...",
    Flag = "MyDropdown",
    Callback = function(Value)
        print(Value)
    end    
})

--[[
Name = <string> - The name of the dropdown.
Description = <string> - Additional description text.
Options = <table> - Array of selectable options.
Default = <string | table> - The default selected value (table if Multi = true).
Multi = <bool> - Allows selecting multiple options.
Max = <number> - Maximum allowed selections if Multi is true.
Search = <bool> - Enables search bar inside dropdown menu.
Placeholder = <string> - Text displayed when no option is selected.
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the dropdown.
]]
```

### Adding a set of new Dropdown buttons to an existing menu
```lua
CoolDropdown:Refresh({"New 1", "New 2", "New 3"}, false)
```

The above boolean value "false" determines whether the current selection value will be kept or cleared.

### Selecting a dropdown option
```lua
CoolDropdown:Set("New 1")
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
    ClearButton = true,
    CopyButton = true,
    Flag = "MyTextbox",
    Callback = function(Value)
        print(Value)
    end	  
})

--[[
Name = <string> - The name of the textbox.
Description = <string> - Additional description text.
Default = <string> - The default value of the textbox.
Placeholder = <string> - Placeholder text when the box is empty.
Finished = <bool> - Only triggers callback on enter/focus lost if true.
ClearOnFocus = <bool> - Clears input field when clicked.
Numeric = <bool> - Restricts inputs to numbers only.
ClearButton = <bool> - Shows a quick clear button.
CopyButton = <bool> - Shows a quick copy button.
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the textbox.
]]
```

### Changing the value of a textbox
```lua
CoolTextbox:Set("New Text")
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

### Changing the value of a bind
```lua
CoolBind:Set(Enum.KeyCode.F)
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
Transparency = <number> - Default transparency value (0-1).
Rainbow = <bool> - Enables rainbow mode cycle by default.
Flag = <string> - The identifier used for configs.
Callback = <function> - The function of the colorpicker.
]]
```

### Setting the color picker's value
```lua
CoolColor:Set(Color3.fromRGB(255, 255, 255), 0, false)
```



## Creating a Label
```lua
local CoolLabel = Section:Label({
    Name = "Label",
    Description = "Label Description",
    Icon = "info",
    RightText = "Status: OK"
})

--[[
Name = <string> - The title text of the label.
Description = <string> - Subtitle description text.
Icon = <string | number> - Icon displayed on the label.
RightText = <string> - Text aligned to the right side.
Wrap = <bool> - Wraps long text across multiple lines.
]]
```

### Changing the value of an existing label
```lua
CoolLabel:Set("Label New!")
```



## Creating a Paragraph
```lua
local CoolParagraph = Section:Paragraph({
    Title = "Paragraph",
    Content = "Paragraph Content",
    Icon = "info",
    CopyButton = true
})

--[[
Title = <string> - The title of the paragraph.
Content = <string> - The body content of the paragraph.
Icon = <string | number> - Icon displayed on the paragraph.
CopyButton = <bool> - Adds a button to copy content to clipboard.
]]
```

### Changing an existing paragraph
```lua
CoolParagraph:SetText("Paragraph New!", "New Paragraph Content!")
```



## Creating a Watermark
```lua
local Watermark = Library:Watermark({
    Name = "Zolar Hub"
})

--[[
Name = <string> - The title text displayed on the draggable watermark bar.
]]
```



## Theme and Config System
Zolar Library comes with a built-in interactive Config and Theme manager page.

```lua
local SettingsTab = Window:Tab({Name = "Settings", Icon = "settings"})
local ConfigSubTab = SettingsTab:SubTab({Name = "Configs", Icon = "folder"})

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



## Destroying the Interface
```lua
Library:Unload()
```
