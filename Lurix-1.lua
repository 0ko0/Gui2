--[[
   ██╗     ██╗   ██╗██████╗ ██╗██╗  ██╗
   ██║     ██║   ██║██╔══██╗██║╚██╗██╔╝
   ██║     ██║   ██║██████╔╝██║ ╚███╔╝
   ██║     ██║   ██║██╔══██╗██║ ██╔██╗
   ███████╗╚██████╔╝██║  ██║██║██╔╝ ██╗
   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝
   Lurix UI Library  ·  v1.0
   Accent : RGB(110, 150, 255)  ·  Base : Deep Black
   All-device support  ·  All-executor support
--]]

-- ─────────────────────────── Cleanup ──────────────────────────────────── --
do
    local function tryExit(t)
        if type(t)=="table" and type(t.Exit)=="function" then
            pcall(t.Exit, t)
        end
    end
    tryExit(getgenv().Lurix)
    tryExit(getgenv().Library)
end

-- ──────────────────── Executor Compatibility Stubs ────────────────────── --
cloneref       = cloneref       or function(o) return o end
gethui         = gethui         or function() return cloneref(game:GetService("CoreGui")) end
isfolder       = isfolder       or function() return false end
makefolder     = makefolder     or function() end
isfile         = isfile         or function() return false end
writefile      = writefile      or function() end
readfile       = readfile       or function() return "" end
listfiles      = listfiles      or function() return {} end
delfile        = delfile        or function() end
getcustomasset = getcustomasset or function(p) return p end

-- ──────────────────────────── Services ────────────────────────────────── --
local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpSvc    = game:GetService("HttpService")
local TweenSvc   = game:GetService("TweenService")
local GuiSvc     = game:GetService("GuiService")
local CoreGui    = cloneref(game:GetService("CoreGui"))

-- ──────────────────────── Core Locals ─────────────────────────────────── --
local LocalPlayer = Players.LocalPlayer
local GuiInset    = GuiSvc:GetGuiInset().Y
local IsMobile    = UIS.TouchEnabled and not UIS.KeyboardEnabled

local function VpSize()
    return workspace.CurrentCamera.ViewportSize
end

-- ─────────────────────── Folder Bootstrap ─────────────────────────────── --
local DIR = "lurix"
if not isfolder(DIR)              then makefolder(DIR)              end
if not isfolder(DIR.."/Configs")  then makefolder(DIR.."/Configs")  end
if not isfolder(DIR.."/Assets")   then makefolder(DIR.."/Assets")   end

-- ══════════════════════════════════════════════════════════════════════════
--                           LIBRARY TABLE
-- ══════════════════════════════════════════════════════════════════════════
local Library = {} do
Library.__index = Library

-- Internal state
Library.Flags        = {}
Library.SetFlags     = {}
Library.Threads      = {}
Library.Connections  = {}
Library.ThemingStuff = {}
Library.ThemeMap     = {}
Library.SearchItems  = {}
Library.OpenFrames   = {}
Library.Holder       = nil
Library.UnusedHolder = nil
Library.Font         = nil

-- Config
Library.Directory   = DIR
Library.Folders     = { Configs = "/Configs", Assets = "/Assets" }
Library.FontSize    = 14
Library.MenuKeybind = tostring(Enum.KeyCode.RightShift)
Library.Animation   = { Time = 0.25, Style = "Quint", Direction = "Out" }
Library.ZIndexOrder = { OptionHolder = 4, KeybindWindow = 4, ColorpickerWindow = 6 }
Library.Theme       = nil

local Flags    = Library.Flags
local SetFlags = Library.SetFlags

-- ─────────────────────────── Key Display Map ──────────────────────────── --
local KeyNames = {
    Unknown="?",Backspace="Back",Tab="Tab",Return="Enter",Escape="Esc",
    Space="Space",Delete="Del",End="End",Insert="Ins",Home="Home",
    PageUp="PgUp",PageDown="PgDn",LeftShift="LShift",RightShift="RShift",
    LeftControl="LCtrl",RightControl="RCtrl",LeftAlt="LAlt",RightAlt="RAlt",
    CapsLock="Caps",F1="F1",F2="F2",F3="F3",F4="F4",F5="F5",F6="F6",
    F7="F7",F8="F8",F9="F9",F10="F10",F11="F11",F12="F12",
    Zero="0",One="1",Two="2",Three="3",Four="4",Five="5",
    Six="6",Seven="7",Eight="8",Nine="9",
}
for _,c in {"A","B","C","D","E","F","G","H","I","J","K","L","M",
            "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"} do
    KeyNames[c] = c
end

-- ─────────────────────────────── Theme ────────────────────────────────── --
Library.Theme = {
    Background          = Color3.fromRGB(8,   8,   14),
    Inline              = Color3.fromRGB(13,  14,  22),
    Accent              = Color3.fromRGB(110, 150, 255),
    Tab                 = Color3.fromRGB(16,  17,  26),
    ["Dark Icon"]       = Color3.fromRGB(52,  58,  88),
    Element             = Color3.fromRGB(19,  20,  30),
    Liner               = Color3.fromRGB(26,  28,  44),
    Outline             = Color3.fromRGB(32,  35,  54),
    ["Dark Text"]       = Color3.fromRGB(82,  88, 118),
    Text                = Color3.fromRGB(208, 218, 255),
    Toggle              = Color3.fromRGB(38,  42,  66),
    ["Hovered Element"] = Color3.fromRGB(24,  26,  40),
}

-- ───────────────────────────── Custom Font ────────────────────────────── --
do
    local assetDir  = DIR.."/Assets"
    local ttfPath   = assetDir.."/Figtree-SemiBold.ttf"
    local fontPath  = assetDir.."/Figtree-SemiBold.font"
    local ok = pcall(function()
        if not isfile(ttfPath) then
            writefile(ttfPath, game:HttpGet(
                "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/Figtree-SemiBold.ttf"
            ))
        end
        writefile(fontPath, HttpSvc:JSONEncode({
            name  = "Figtree-SemiBold",
            faces = {{
                name    = "Figtree-SemiBold",
                weight  = 600,
                style   = "Normal",
                assetId = getcustomasset(ttfPath)
            }}
        }))
        Library.Font = Font.new(getcustomasset(fontPath))
    end)
    if not ok or not Library.Font then
        Library.Font = Font.fromEnum(Enum.Font.GothamSemibold)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
--                         CORE METHODS
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── Create ───────────────────────────────────────────────────────────── --
Library.Create = function(Self, Class, Props)
    local obj = Instance.new(Class)
    local data = { Class = Class, Properties = Props, Instance = obj }

    for k, v in Props do
        if k == "Name"     then obj.Name     = "\0"          continue end
        if k == "FontFace" then obj.FontFace = Library.Font   continue end
        if k == "TextSize" then obj.TextSize = Library.FontSize continue end
        if Class == "TextButton" then
            if k == "AutoButtonColor" then obj.AutoButtonColor = false continue end
            if k == "Text"           then obj.Text = ""          continue end
        end
        pcall(function() obj[k] = v end)
    end

    return setmetatable(data, Library)
end

-- ─── Thread ───────────────────────────────────────────────────────────── --
Library.Thread = function(Self, fn)
    local t = coroutine.create(fn)
    coroutine.wrap(function() coroutine.resume(t) end)()
    table.insert(Library.Threads, t)
    return t
end

-- ─── Connect ──────────────────────────────────────────────────────────── --
Library.Connect = function(Self, Signal, Callback)
    local conn

    if Self.Instance then
        if type(Signal) == "string" then
            local ev = Self.Instance[Signal]
            if ev then
                if IsMobile and Signal == "MouseButton1Down" then
                    conn = Self.Instance.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch
                        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            Callback(inp)
                        end
                    end)
                else
                    conn = ev:Connect(Callback)
                end
            end
        else
            conn = Signal:Connect(Callback)
        end
    else
        if type(Signal) ~= "string" then
            conn = Signal:Connect(Callback)
        end
    end

    if conn then table.insert(Library.Connections, conn) end
    return conn
end

-- ─── Tween ────────────────────────────────────────────────────────────── --
Library.Tween = function(Self, Props, Info, RawInst)
    local obj = (type(Self) == "table" and Self.Instance) or RawInst
    if not obj then return end
    Info = Info or TweenInfo.new(
        Library.Animation.Time,
        Enum.EasingStyle[Library.Animation.Style],
        Enum.EasingDirection[Library.Animation.Direction]
    )
    local tw = TweenSvc:Create(obj, Info, Props)
    tw:Play()
    return tw
end

-- ─── GetTweenProperty ─────────────────────────────────────────────────── --
Library.GetTweenProperty = function(Self, Inst)
    local obj = (type(Self) == "table" and Self.Instance) or Inst
    if not obj then return nil end
    if     obj:IsA("Frame")         then return {"BackgroundTransparency"}
    elseif obj:IsA("TextLabel")
        or obj:IsA("TextButton")    then return {"TextTransparency","BackgroundTransparency"}
    elseif obj:IsA("ImageLabel")
        or obj:IsA("ImageButton")   then return {"BackgroundTransparency","ImageTransparency"}
    elseif obj:IsA("ScrollingFrame") then return {"BackgroundTransparency","ScrollBarImageTransparency"}
    elseif obj:IsA("TextBox")       then return {"TextTransparency","BackgroundTransparency"}
    elseif obj:IsA("UIStroke")      then return {"Transparency"}
    end
    return nil
end

-- ─── Fade ─────────────────────────────────────────────────────────────── --
Library.Fade = function(Self, Prop, Show, RawInst)
    local obj = (type(Self) == "table" and Self.Instance) or RawInst
    if not obj then return end
    local old = obj[Prop]
    obj[Prop] = Show and 1 or old
    local tw = Library:Tween({[Prop] = Show and old or 1}, nil, obj)
    if tw then
        local ch = tw.Completed:Connect(function()
            if not Show then task.wait(); pcall(function() obj[Prop] = old end) end
        end)
        table.insert(Library.Connections, ch)
    end
    return tw
end

-- ─── FadeDescendants ──────────────────────────────────────────────────── --
Library.FadeDescendants = function(Self, Show, Callback)
    if Show then Self.Instance.Visible = true end
    local last
    local all = Self.Instance:GetDescendants()
    table.insert(all, Self.Instance)
    for _, child in all do
        local props = Library:GetTweenProperty(child)
        if not props then continue end
        for _, p in props do
            last = Library:Fade(p, Show, child)
        end
    end
    if last then
        local ch = last.Completed:Connect(function()
            if Callback then Callback() end
            pcall(function() Self.Instance.Visible = Show end)
        end)
        table.insert(Library.Connections, ch)
    else
        if Callback then Callback() end
        pcall(function() Self.Instance.Visible = Show end)
    end
end

-- ─── MakeDraggable ────────────────────────────────────────────────────── --
Library.MakeDraggable = function(Self)
    if not Self.Instance then return end
    local gui = Self.Instance
    local dragging, dragStart, startPos = false, nil, nil

    Self:Connect("InputBegan", function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = gui.Position
            local ch = inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
            table.insert(Library.Connections, ch)
        end
    end)

    Library:Connect(UIS.InputChanged, function(inp)
        if not dragging then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = inp.Position - dragStart
        local nx    = startPos.X.Offset + delta.X
        local ny    = startPos.Y.Offset + delta.Y
        if gui.Parent then
            local ps = gui.Parent.AbsoluteSize
            local gs = gui.AbsoluteSize
            nx = math.clamp(nx, 0, ps.X - gs.X)
            ny = math.clamp(ny, 0, ps.Y - gs.Y)
        end
        Self:Tween({Position = UDim2.fromOffset(nx, ny)},
            TweenInfo.new(0.08, Enum.EasingStyle.Linear))
    end)
end

-- ─── MakeResizeable ───────────────────────────────────────────────────── --
Library.MakeResizeable = function(Self, MinSize)
    if not Self.Instance or IsMobile then return end
    local gui = Self.Instance
    local et  = 6
    MinSize = MinSize or Vector2.new(400, 300)

    local function MakeEdge(pos, size)
        return Library:Create("TextButton", {
            Name="\0", Parent=gui, Text="", AutoButtonColor=false,
            BackgroundColor3=Library.Theme.Accent, BackgroundTransparency=1,
            Position=pos, Size=size, BorderSizePixel=0, ZIndex=10
        })
    end

    local edges = {
        { btn=MakeEdge(UDim2.new(0,0,0,et),    UDim2.new(0,et,1,-et*2)), side="L" },
        { btn=MakeEdge(UDim2.new(1,-et,0,et),  UDim2.new(0,et,1,-et*2)), side="R" },
        { btn=MakeEdge(UDim2.new(0,et,0,0),    UDim2.new(1,-et*2,0,et)), side="T" },
        { btn=MakeEdge(UDim2.new(0,et,1,-et),  UDim2.new(1,-et*2,0,et)), side="B" },
    }

    local resizing, curSide, sm, sp, ss = false, nil, nil, nil, nil

    for _, e in edges do
        e.btn:Connect("InputBegan", function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true; curSide = e.side
                sm = UIS:GetMouseLocation()
                sp = Vector2.new(gui.Position.X.Offset, gui.Position.Y.Offset)
                ss = Vector2.new(gui.Size.X.Offset,     gui.Size.Y.Offset)
                e.btn.Instance.BackgroundTransparency = 0.7
            end
        end)
    end

    Library:Connect(UIS.InputEnded, function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
            for _, e in edges do e.btn.Instance.BackgroundTransparency = 1 end
        end
    end)

    Library:Connect(RunService.RenderStepped, function()
        if not resizing then return end
        local ml = UIS:GetMouseLocation()
        local dx, dy = ml.X - sm.X, ml.Y - sm.Y
        local x, y, w, h = sp.X, sp.Y, ss.X, ss.Y
        if     curSide=="L" then x=sp.X+dx; w=ss.X-dx
        elseif curSide=="R" then w=ss.X+dx
        elseif curSide=="T" then y=sp.Y+dy; h=ss.Y-dy
        elseif curSide=="B" then h=ss.Y+dy
        end
        if w < MinSize.X then if curSide=="L" then x=x-(MinSize.X-w) end w=MinSize.X end
        if h < MinSize.Y then if curSide=="T" then y=y-(MinSize.Y-h) end h=MinSize.Y end
        Self:Tween({Position=UDim2.fromOffset(x,y), Size=UDim2.fromOffset(w,h)},
            TweenInfo.new(0.08, Enum.EasingStyle.Linear))
    end)
end

-- ─── OnHover ──────────────────────────────────────────────────────────── --
Library.OnHover = function(Self, Enter, Leave)
    if not Self.Instance then return end
    Library:Connect(Self.Instance.MouseEnter, Enter)
    Library:Connect(Self.Instance.MouseLeave, Leave)
end

-- ─── IsMouseOverFrame ─────────────────────────────────────────────────── --
Library.IsMouseOverFrame = function(Self)
    if not Self.Instance then return false end
    local mp = UIS:GetMouseLocation()
    local ap = Self.Instance.AbsolutePosition
    local as = Self.Instance.AbsoluteSize
    return mp.X>=ap.X and mp.X<=ap.X+as.X and mp.Y>=ap.Y and mp.Y<=ap.Y+as.Y
end

-- ─── SafeCall ─────────────────────────────────────────────────────────── --
Library.SafeCall = function(Self, fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then warn("[Lurix] " .. tostring(err)) end
end

-- ─── Round ────────────────────────────────────────────────────────────── --
Library.Round = function(Self, n, f)
    local m = 1 / (f or 1)
    return math.floor(n * m) / m
end

-- ═══════════════════════════════════════════════════════════════════════════
--                          THEME SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

Library.AddToTheme = function(Self, Props)
    local obj = Self.Instance
    local td  = { Item=obj, Properties=Props }
    for p, v in Props do
        if type(v) == "string" then
            pcall(function() obj[p] = Library.Theme[v] or v end)
        elseif type(v) == "function" then
            pcall(function() obj[p] = v() end)
        end
    end
    table.insert(Library.ThemingStuff, td)
    Library.ThemeMap[obj] = td
    return Self
end

Library.ChangeItemTheme = function(Self, Props)
    local obj = Self.Instance
    if Library.ThemeMap[obj] then
        Library.ThemeMap[obj].Properties = Props
    end
end

Library.ChangeTheme = function(Self, Key, Color)
    Library.Theme[Key] = Color
    for _, item in Library.ThemingStuff do
        for p, v in item.Properties do
            if type(v) == "string" and v == Key then
                pcall(function() item.Item[p] = Color end)
            elseif type(v) == "function" then
                pcall(function() item.Item[p] = v() end)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
--                          CONFIG SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

Library.GetConfig = function(Self)
    local cfg = {}
    for k, v in Library.Flags do
        if   type(v)=="table" and v.Key   then cfg[k]={Key=tostring(v.Key),Mode=v.Mode}
        elseif type(v)=="table" and v.Color then cfg[k]={Color="#"..v.HexValue,Alpha=v.Alpha}
        else  cfg[k]=v
        end
    end
    return HttpSvc:JSONEncode(cfg)
end

Library.LoadConfig = function(Self, json)
    local ok, decoded = pcall(HttpSvc.JSONDecode, HttpSvc, json)
    if not ok then return false, decoded end
    for k, v in decoded do
        local fn = Library.SetFlags[k]
        if fn then
            if   type(v)=="table" and v.Key   then fn(v)
            elseif type(v)=="table" and v.Color then fn(v.Color, v.Alpha)
            else  fn(v)
            end
        end
    end
    return true
end

Library.GetConfigsList = function(Self, DropRef)
    local list  = {}
    local files = listfiles(Library.Directory .. Library.Folders.Configs)
    for _, f in files do
        if f:sub(-5) == ".json" then
            local name = f:match("[/\\]([^/\\]+)%.json$")
            if name then table.insert(list, name) end
        end
    end
    if DropRef and DropRef.Refresh then DropRef:Refresh(list) end
    return list
end

-- ═══════════════════════════════════════════════════════════════════════════
--                           HOLDERS
-- ═══════════════════════════════════════════════════════════════════════════

Library.Holder = Library:Create("ScreenGui", {
    Parent          = gethui(),
    IgnoreGuiInset  = true,
    Name            = "\0",
    ZIndexBehavior  = Enum.ZIndexBehavior.Global,
    ResetOnSpawn    = false
})

Library.UnusedHolder = Library:Create("ScreenGui", {
    Parent         = gethui(),
    Name           = "\0",
    Enabled        = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    ResetOnSpawn   = false
})

-- Mobile scaling applied at ScreenGui level (fixes original UIScale-before-MainFrame bug)
if IsMobile then
    local sc = math.clamp(VpSize().X / 1100, 0.46, 0.82)
    Library:Create("UIScale", { Name="\0", Parent=Library.Holder.Instance, Scale=sc })
end

-- Notification panel (bottom-right, stacks upward)
Library.NotifHolder = Library:Create("Frame", {
    Name                = "\0",
    Parent              = Library.Holder.Instance,
    BackgroundTransparency = 1,
    AnchorPoint         = Vector2.new(1, 1),
    Position            = UDim2.new(1, -12, 1, -12),
    Size                = UDim2.new(0, 268, 0, 0),
    AutomaticSize       = Enum.AutomaticSize.Y,
    BorderSizePixel     = 0,
})
Library:Create("UIListLayout", {
    Name               = "\0",
    Parent             = Library.NotifHolder.Instance,
    Padding            = UDim.new(0, 8),
    SortOrder          = Enum.SortOrder.LayoutOrder,
    VerticalAlignment  = Enum.VerticalAlignment.Bottom,
    FillDirection      = Enum.FillDirection.Vertical,
})

-- ═══════════════════════════════════════════════════════════════════════════
--                          EXIT / UNLOAD
-- ═══════════════════════════════════════════════════════════════════════════

Library.Exit = function(Self)
    for _, c in Library.Connections do pcall(function() c:Disconnect() end) end
    for _, t in Library.Threads     do pcall(function() coroutine.close(t) end) end
    pcall(function() Library.Holder.Instance:Destroy()       end)
    pcall(function() Library.UnusedHolder.Instance:Destroy() end)
    getgenv().Lurix   = nil
    getgenv().Library = nil
end
Library.Unload = Library.Exit

-- ═══════════════════════════════════════════════════════════════════════════
--                         COLORPICKER
-- ═══════════════════════════════════════════════════════════════════════════

Library.CreateColorpicker = function(Self, Data)
    local CP = {
        Hue=0, Saturation=1, Value=1, Alpha=Data.Alpha or 0,
        Color=Color3.new(1,1,1), HexValue="FFFFFF",
        Flag=Data.Flag, IsOpen=false, Items={}
    }

    local Items = {}

    Items["Btn"] = Library:Create("ImageButton", {
        Name="\0", Parent=Data.Parent.Instance, AutoButtonColor=false,
        Image="rbxassetid://77492218953155", ImageColor3=Color3.new(1,1,1),
        BackgroundTransparency=1, Size=UDim2.new(0,20,0,20), BorderSizePixel=0
    })

    Items["Win"] = Library:Create("TextButton", {
        Name="\0", Parent=Library.UnusedHolder.Instance, Visible=false,
        Text="", AutoButtonColor=false, Size=UDim2.new(0,224,0,228),
        BackgroundColor3=Library.Theme.Inline, BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Inline"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Win"].Instance,CornerRadius=UDim.new(0,10)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["Win"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})

    -- Palette (main SV square)
    Items["Palette"] = Library:Create("TextButton", {
        Name="\0", Parent=Items["Win"].Instance, Text="", AutoButtonColor=false,
        Position=UDim2.new(0,10,0,38), Size=UDim2.new(1,-50,1,-52),
        BackgroundColor3=Color3.new(1,0,0), BorderSizePixel=0
    })
    Library:Create("UICorner",{Name="\0",Parent=Items["Palette"].Instance,CornerRadius=UDim.new(0,6)})

    Items["SatLayer"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Palette"].Instance,
        BackgroundColor3=Color3.new(1,1,1),Size=UDim2.new(1,0,1,0),BorderSizePixel=0
    })
    Library:Create("UIGradient",{Name="\0",Parent=Items["SatLayer"].Instance,
        Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}})
    Library:Create("UICorner",{Name="\0",Parent=Items["SatLayer"].Instance,CornerRadius=UDim.new(0,6)})

    Items["ValLayer"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Palette"].Instance,
        BackgroundColor3=Color3.new(0,0,0),Size=UDim2.new(1,0,1,0),BorderSizePixel=0
    })
    Library:Create("UIGradient",{Name="\0",Parent=Items["ValLayer"].Instance,Rotation=90,
        Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}})
    Library:Create("UICorner",{Name="\0",Parent=Items["ValLayer"].Instance,CornerRadius=UDim.new(0,6)})

    Items["PDrag"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Palette"].Instance,
        BackgroundTransparency=1,Size=UDim2.new(0,14,0,14),BorderSizePixel=0
    })
    Library:Create("UICorner",{Name="\0",Parent=Items["PDrag"].Instance,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["PDrag"].Instance,
        Color=Color3.new(1,1,1),Thickness=2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})

    -- Hue strip (right side, vertical)
    Items["Hue"] = Library:Create("TextButton",{
        Name="\0",Parent=Items["Win"].Instance,Text="",AutoButtonColor=false,
        AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,10),
        Size=UDim2.new(0,14,1,-28),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0
    })
    Library:Create("UICorner",{Name="\0",Parent=Items["Hue"].Instance,CornerRadius=UDim.new(1,0)})
    Library:Create("UIGradient",{Name="\0",Parent=Items["Hue"].Instance,Rotation=90,
        Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,1,1)),
            ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),
            ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,1,1)),
            ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),
            ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),
            ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,1,1)),
        }})
    Items["HDrag"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Hue"].Instance,BackgroundTransparency=1,
        AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0,0),
        Size=UDim2.new(1,6,0,4),BorderSizePixel=0
    })
    Library:Create("UICorner",{Name="\0",Parent=Items["HDrag"].Instance,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["HDrag"].Instance,Color=Color3.new(1,1,1),Thickness=1.5})

    -- Alpha strip (top, horizontal)
    Items["Alpha"] = Library:Create("TextButton",{
        Name="\0",Parent=Items["Win"].Instance,Text="",AutoButtonColor=false,
        Position=UDim2.new(0,10,0,12),Size=UDim2.new(1,-50,0,14),
        BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0
    })
    Library:Create("UICorner",{Name="\0",Parent=Items["Alpha"].Instance,CornerRadius=UDim.new(1,0)})
    Items["AlphaGrad"] = Library:Create("UIGradient",{Name="\0",Parent=Items["Alpha"].Instance,
        Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))},
        Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}})
    Items["ADrag"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Alpha"].Instance,BackgroundTransparency=1,
        AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),
        Size=UDim2.new(0,4,1,6),BorderSizePixel=0
    })
    Library:Create("UICorner",{Name="\0",Parent=Items["ADrag"].Instance,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["ADrag"].Instance,Color=Color3.new(1,1,1),Thickness=1.5})

    -- Hex readout
    Items["HexLabel"] = Library:Create("TextLabel",{
        Name="\0",FontFace=Library.Font,TextSize=11,
        Parent=Items["Win"].Instance,BackgroundColor3=Library.Theme.Element,
        TextColor3=Library.Theme["Dark Text"],AnchorPoint=Vector2.new(0.5,1),
        Position=UDim2.new(0.5,-14,1,-8),Size=UDim2.new(1,-52,0,20),BorderSizePixel=0,Text="#FFFFFF"
    }):AddToTheme({BackgroundColor3="Element",TextColor3="Dark Text"})
    Library:Create("UICorner",{Name="\0",Parent=Items["HexLabel"].Instance,CornerRadius=UDim.new(0,5)})

    CP.Items = Items

    function CP:UpdateVisuals()
        local c = Color3.fromHSV(CP.Hue, CP.Saturation, CP.Value)
        CP.Color = c
        local r,g,b = math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)
        CP.HexValue = string.format("%02X%02X%02X", r, g, b)

        Items["Btn"].Instance.ImageColor3  = c
        Items["Palette"].Instance.BackgroundColor3 = Color3.fromHSV(CP.Hue, 1, 1)
        Items["AlphaGrad"].Instance.Color  = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(c.R,c.G,c.B)),
            ColorSequenceKeypoint.new(1, Color3.new(c.R,c.G,c.B)),
        }
        Items["HexLabel"].Instance.Text = "#" .. CP.HexValue

        local pw = Items["Palette"].Instance.AbsoluteSize.X
        local ph = Items["Palette"].Instance.AbsoluteSize.Y
        Items["PDrag"].Instance.Position = UDim2.fromOffset(
            math.clamp(CP.Saturation * pw - 7, 0, pw - 14),
            math.clamp((1 - CP.Value) * ph - 7, 0, ph - 14)
        )
        Items["HDrag"].Instance.Position  = UDim2.new(0.5, 0, CP.Hue, 0)
        Items["ADrag"].Instance.Position  = UDim2.new(1 - CP.Alpha, 0, 0.5, 0)

        Flags[CP.Flag] = {Color=c, Alpha=CP.Alpha, HexValue=CP.HexValue}
        Library:SafeCall(Data.Callback or function()end, c, CP.Alpha)
    end

    function CP:Set(Color, Alpha)
        if type(Color) == "string" then
            Color = Color:gsub("#","")
            local r = tonumber(Color:sub(1,2),16) or 0
            local g = tonumber(Color:sub(3,4),16) or 0
            local b = tonumber(Color:sub(5,6),16) or 0
            Color = Color3.new(r/255, g/255, b/255)
        end
        if Color then
            local h,s,v = Color:ToHSV()
            CP.Hue=h; CP.Saturation=s; CP.Value=v
        end
        if Alpha ~= nil then CP.Alpha = math.clamp(1 - Alpha, 0, 1) end
        CP:UpdateVisuals()
    end

    function CP:SlidePalette(inp)
        local ap = Items["Palette"].Instance.AbsolutePosition
        local as = Items["Palette"].Instance.AbsoluteSize
        CP.Saturation = math.clamp((inp.Position.X-ap.X)/as.X, 0, 1)
        CP.Value      = 1 - math.clamp((inp.Position.Y-ap.Y)/as.Y, 0, 1)
        CP:UpdateVisuals()
    end
    function CP:SlideHue(inp)
        local ap = Items["Hue"].Instance.AbsolutePosition
        local as = Items["Hue"].Instance.AbsoluteSize
        CP.Hue = math.clamp((inp.Position.Y-ap.Y)/as.Y, 0, 1)
        CP:UpdateVisuals()
    end
    function CP:SlideAlpha(inp)
        local ap = Items["Alpha"].Instance.AbsolutePosition
        local as = Items["Alpha"].Instance.AbsoluteSize
        CP.Alpha = 1 - math.clamp((inp.Position.X-ap.X)/as.X, 0, 1)
        CP:UpdateVisuals()
    end

    function CP:SetOpen(bool)
        CP.IsOpen = bool
        if bool then
            local bp = Items["Btn"].Instance.AbsolutePosition
            local vp = VpSize()
            Items["Win"].Instance.Position = UDim2.fromOffset(
                math.clamp(bp.X - 200, 5, vp.X - 234),
                math.clamp(bp.Y + 26 + GuiInset, 5, vp.Y - 238)
            )
            Items["Win"].Instance.Parent  = Library.Holder.Instance
            Items["Win"].Instance.Visible = true
            Library.OpenFrames[CP] = CP
        else
            Items["Win"].Instance.Parent  = Library.UnusedHolder.Instance
            Items["Win"].Instance.Visible = false
            Library.OpenFrames[CP] = nil
        end
        local zv = bool and Library.ZIndexOrder.ColorpickerWindow or 1
        for _, d in Items["Win"].Instance:GetDescendants() do
            if not d.ClassName:find("UI") then pcall(function() d.ZIndex=zv end) end
        end
    end

    local spal, shue, salpha = false, false, false
    Items["Palette"]:Connect("InputBegan", function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            spal=true; CP:SlidePalette(i)
        end
    end)
    Items["Hue"]:Connect("InputBegan", function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            shue=true; CP:SlideHue(i)
        end
    end)
    Items["Alpha"]:Connect("InputBegan", function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            salpha=true; CP:SlideAlpha(i)
        end
    end)
    Library:Connect(UIS.InputChanged, function(i)
        if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
        if spal   then CP:SlidePalette(i) end
        if shue   then CP:SlideHue(i)     end
        if salpha then CP:SlideAlpha(i)   end
    end)
    Library:Connect(UIS.InputEnded, function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            spal=false; shue=false; salpha=false
        end
    end)
    Library:Connect(UIS.InputBegan, function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            if CP.IsOpen and not Items["Win"]:IsMouseOverFrame() then CP:SetOpen(false) end
        end
    end)
    Items["Btn"]:Connect("MouseButton1Down", function() CP:SetOpen(not CP.IsOpen) end)

    if Data.Default then CP:Set(Data.Default, Data.Alpha) end
    SetFlags[CP.Flag] = function(v,a) CP:Set(v,a) end
    return CP, Items
end

-- ═══════════════════════════════════════════════════════════════════════════
--                           KEYBIND
-- ═══════════════════════════════════════════════════════════════════════════

Library.CreateKeybind = function(Self, Data)
    local KB = {
        Flag=Data.Flag, IsOpen=false, Key="", Mode=Data.Mode or "Toggle",
        Toggled=false, Picking=false, Items={}
    }

    local Items = {}

    Items["Btn"] = Library:Create("ImageButton",{
        Name="\0",Parent=Data.Parent.Instance,AutoButtonColor=false,
        Image="rbxassetid://123677974615593",ImageColor3=Library.Theme["Dark Text"],
        BackgroundTransparency=1,Size=UDim2.new(0,20,0,20),BorderSizePixel=0
    }):AddToTheme({ImageColor3="Dark Text"})

    Items["Win"] = Library:Create("TextButton",{
        Name="\0",Parent=Library.UnusedHolder.Instance,Text="",AutoButtonColor=false,
        Visible=false,Size=UDim2.new(0,210,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=Library.Theme.Inline,BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Inline"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Win"].Instance,CornerRadius=UDim.new(0,10)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["Win"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})
    Library:Create("UIPadding",{Name="\0",Parent=Items["Win"].Instance,
        PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),
        PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})
    Library:Create("UIListLayout",{Name="\0",Parent=Items["Win"].Instance,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})

    local function KBRow(icon, label)
        local row = Library:Create("TextButton",{
            Name="\0",Parent=Items["Win"].Instance,Text="",AutoButtonColor=false,
            Size=UDim2.new(1,0,0,36),BackgroundColor3=Library.Theme.Element,BorderSizePixel=0
        }):AddToTheme({BackgroundColor3="Element"})
        Library:Create("UICorner",{Name="\0",Parent=row.Instance,CornerRadius=UDim.new(0,7)})
        Library:Create("ImageLabel",{Name="\0",Parent=row.Instance,Image=icon,
            ImageColor3=Library.Theme.Accent,BackgroundTransparency=1,
            AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,8,0.5,0),
            Size=UDim2.new(0,16,0,16),BorderSizePixel=0}):AddToTheme({ImageColor3="Accent"})
        local lbl = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
            Parent=row.Instance,TextColor3=Library.Theme.Text,Text=label,
            BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,30,0.5,0),
            AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})
        return row, lbl
    end

    Items["KeyRow"],  Items["KeyText"]  = KBRow("rbxassetid://113351170187860",  "None")
    Items["ModeRow"], Items["ModeText"] = KBRow("rbxassetid://77336523487505", "Mode: Toggle")

    KB.Items = Items

    function KB:SetOpen(bool)
        KB.IsOpen = bool
        if bool then
            local bp = Items["Btn"].Instance.AbsolutePosition
            local vp = VpSize()
            Items["Win"].Instance.Position = UDim2.fromOffset(
                math.clamp(bp.X-180, 5, vp.X-220),
                bp.Y + 26 + GuiInset
            )
            Items["Win"].Instance.Parent  = Library.Holder.Instance
            Items["Win"].Instance.Visible = true
            Library.OpenFrames[KB] = KB
        else
            Items["Win"].Instance.Parent  = Library.UnusedHolder.Instance
            Items["Win"].Instance.Visible = false
            Library.OpenFrames[KB] = nil
        end
    end

    function KB:Set(v)
        if type(v) == "table" then
            KB.Key  = tostring(v.Key  or "")
            KB.Mode = tostring(v.Mode or "Toggle")
        else
            KB.Key = tostring(v or "")
        end
        local disp = KeyNames[KB.Key] or KB.Key
        Items["KeyText"].Instance.Text  = (disp == "" and "None" or disp)
        Items["ModeText"].Instance.Text = "Mode: " .. (KB.Mode or "Toggle")
        Flags[KB.Flag] = {Key=KB.Key, Mode=KB.Mode}
        Library:SafeCall(Data.Callback or function()end, Flags[KB.Flag])
    end

    Items["KeyRow"]:Connect("MouseButton1Down", function()
        KB.Picking = true
        Items["KeyText"].Instance.Text = "..."
        Items["KeyText"].Instance.TextColor3 = Library.Theme.Accent
    end)

    Items["ModeRow"]:Connect("MouseButton1Down", function()
        local modes = {"Toggle","Hold","Always"}
        local i     = table.find(modes, KB.Mode) or 1
        KB.Mode     = modes[(i % #modes) + 1]
        Items["ModeText"].Instance.Text = "Mode: " .. KB.Mode
        Flags[KB.Flag] = {Key=KB.Key, Mode=KB.Mode}
    end)

    Library:Connect(UIS.InputBegan, function(inp)
        if KB.Picking then
            local key
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                key = tostring(inp.KeyCode):gsub("Enum.KeyCode.","")
            else
                key = tostring(inp.UserInputType):gsub("Enum.UserInputType.","")
            end
            KB:Set({Key=key, Mode=KB.Mode})
            KB.Picking = false
            Items["KeyText"].Instance.TextColor3 = Library.Theme.Text
            return
        end
        if not KB.Key or KB.Key=="" then return end
        local k = tostring(inp.KeyCode):gsub("Enum.KeyCode.","")
        local t = tostring(inp.UserInputType):gsub("Enum.UserInputType.","")
        if k ~= KB.Key and t ~= KB.Key then return end
        if KB.Mode=="Toggle" then
            KB.Toggled = not KB.Toggled
            Library:SafeCall(Data.Callback or function()end, KB.Toggled)
        elseif KB.Mode=="Hold" then
            KB.Toggled = true
            Library:SafeCall(Data.Callback or function()end, true)
        elseif KB.Mode=="Always" then
            Library:SafeCall(Data.Callback or function()end, true)
        end
    end)

    Library:Connect(UIS.InputEnded, function(inp)
        if KB.Mode ~= "Hold" then return end
        local k = tostring(inp.KeyCode):gsub("Enum.KeyCode.","")
        if k == KB.Key then
            KB.Toggled = false
            Library:SafeCall(Data.Callback or function()end, false)
        end
    end)

    Library:Connect(UIS.InputBegan, function(inp)
        if KB.IsOpen and
           (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch) and
           not Items["Win"]:IsMouseOverFrame() then
            KB:SetOpen(false)
        end
    end)

    Items["Btn"]:Connect("MouseButton1Down", function() KB:SetOpen(not KB.IsOpen) end)

    if Data.Default then
        KB:Set({Key=tostring(Data.Default):gsub("Enum.KeyCode.",""), Mode=KB.Mode})
    end
    SetFlags[KB.Flag] = function(v) KB:Set(v) end
    return KB, Items
end

-- ═══════════════════════════════════════════════════════════════════════════
--                           TOOLTIP
-- ═══════════════════════════════════════════════════════════════════════════

Library.Tooltip = function(Self, Text)
    if not Text or Text == "" then return Self end

    local tip = Library:Create("Frame",{
        Name="\0",Parent=Library.Holder.Instance,Visible=false,
        BackgroundColor3=Library.Theme.Inline,Size=UDim2.new(0,0,0,0),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0,ZIndex=20
    }):AddToTheme({BackgroundColor3="Inline"})
    Library:Create("UICorner",{Name="\0",Parent=tip.Instance,CornerRadius=UDim.new(0,7)})
    Library:Create("UIStroke",{Name="\0",Parent=tip.Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})
    Library:Create("UIPadding",{Name="\0",Parent=tip.Instance,
        PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,5),
        PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})
    Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=12,
        Parent=tip.Instance,TextColor3=Library.Theme["Dark Text"],Text=Text,
        BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0,ZIndex=20
    }):AddToTheme({TextColor3="Dark Text"})

    local rs
    Self:OnHover(function()
        tip.Instance.Visible = true
        rs = RunService.RenderStepped:Connect(function()
            local mp = UIS:GetMouseLocation()
            local vp = VpSize()
            tip.Instance.Position = UDim2.fromOffset(
                math.clamp(mp.X+16, 4, vp.X-204),
                math.clamp(mp.Y+16, 4, vp.Y-44)
            )
        end)
    end, function()
        tip.Instance.Visible = false
        if rs then rs:Disconnect(); rs=nil end
    end)

    return Self
end

-- ═══════════════════════════════════════════════════════════════════════════
--                         NOTIFICATION
-- ═══════════════════════════════════════════════════════════════════════════

Library.Notification = function(Self, Text, Duration, Color)
    Duration = Duration or 3
    Color    = Color    or Library.Theme.Accent

    local frame = Library:Create("Frame",{
        Name="\0",Parent=Library.NotifHolder.Instance,
        BackgroundColor3=Library.Theme.Inline,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BorderSizePixel=0,ClipsDescendants=true
    }):AddToTheme({BackgroundColor3="Inline"})
    Library:Create("UICorner",{Name="\0",Parent=frame.Instance,CornerRadius=UDim.new(0,9)})
    Library:Create("UIStroke",{Name="\0",Parent=frame.Instance,Color=Color,Thickness=1})
    Library:Create("UIPadding",{Name="\0",Parent=frame.Instance,
        PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),
        PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,12)})

    -- Left accent bar
    local bar = Library:Create("Frame",{
        Name="\0",Parent=frame.Instance,
        BackgroundColor3=Color,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,-14,0.5,0),
        Size=UDim2.new(0,3,1,-20),BorderSizePixel=0
    })
    Library:Create("UICorner",{Name="\0",Parent=bar.Instance,CornerRadius=UDim.new(1,0)})

    local textLbl = Library:Create("TextLabel",{
        Name="\0",FontFace=Library.Font,TextSize=13,
        Parent=frame.Instance,TextColor3=Library.Theme.Text,
        Text=Text,BackgroundTransparency=1,TextWrapped=true,
        Size=UDim2.new(1,-30,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0
    }):AddToTheme({TextColor3="Text"})

    local timeLbl = Library:Create("TextLabel",{
        Name="\0",FontFace=Library.Font,TextSize=11,
        Parent=frame.Instance,TextColor3=Library.Theme["Dark Text"],
        Text=Duration.."s",BackgroundTransparency=1,
        AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0
    }):AddToTheme({TextColor3="Dark Text"})

    local progressBar = Library:Create("Frame",{
        Name="\0",Parent=frame.Instance,
        BackgroundColor3=Color,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,-14,1,10),
        Size=UDim2.new(1,28,0,2),BorderSizePixel=0
    })
    Library:Create("UICorner",{Name="\0",Parent=progressBar.Instance,CornerRadius=UDim.new(1,0)})

    -- Start hidden
    frame.Instance.BackgroundTransparency = 1
    textLbl.Instance.TextTransparency     = 1
    timeLbl.Instance.TextTransparency     = 1

    Library:Thread(function()
        task.wait(0.05)
        local info = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        frame:Tween({BackgroundTransparency=0}, info)
        textLbl:Tween({TextTransparency=0}, info)
        timeLbl:Tween({TextTransparency=0}, info)
        progressBar:Tween({Size=UDim2.new(0,28,0,2)},
            TweenInfo.new(Duration, Enum.EasingStyle.Linear))

        Library:Thread(function()
            local rem = Duration
            while rem > 0 do
                task.wait(0.1)
                rem = math.max(0, rem - 0.1)
                pcall(function()
                    timeLbl.Instance.Text = Library:Round(rem, 0.1) .. "s"
                end)
            end
        end)

        task.wait(Duration)
        frame:Tween({BackgroundTransparency=1}, info)
        textLbl:Tween({TextTransparency=1}, info)
        timeLbl:Tween({TextTransparency=1}, info)
        task.wait(0.4)
        pcall(function() frame.Instance:Destroy() end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                           WATERMARK
-- ═══════════════════════════════════════════════════════════════════════════

Library.Watermark = function(Self, Params)
    Params = Params or {}
    local WM = {
        Name   = Params.Name or Params.name or "Lurix",
        Logo   = Params.Logo or Params.logo or "",
        Extra  = Params.Extra or Params.extra or "v1.0",
        Items  = {}
    }

    local wrap = Library:Create("Frame",{
        Name="\0",Parent=Library.Holder.Instance,
        AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,12+GuiInset),
        Size=UDim2.new(0,0,0,36),AutomaticSize=Enum.AutomaticSize.X,
        BackgroundColor3=Library.Theme.Inline,BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Inline"})
    Library:Create("UICorner",{Name="\0",Parent=wrap.Instance,CornerRadius=UDim.new(0,9)})
    Library:Create("UIStroke",{Name="\0",Parent=wrap.Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})
    Library:Create("UIPadding",{Name="\0",Parent=wrap.Instance,PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
    Library:Create("UIListLayout",{Name="\0",Parent=wrap.Instance,
        FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,
        Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})

    if WM.Logo ~= "" then
        local logo = Library:Create("ImageLabel",{Name="\0",Parent=wrap.Instance,Image=WM.Logo,
            ImageColor3=Library.Theme.Accent,BackgroundTransparency=1,
            Size=UDim2.new(0,20,0,20),BorderSizePixel=0}):AddToTheme({ImageColor3="Accent"})
        Library:Create("UICorner",{Name="\0",Parent=logo.Instance,CornerRadius=UDim.new(1,0)})
    end

    WM.Items["Name"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=14,
        Parent=wrap.Instance,TextColor3=Library.Theme.Text,Text=WM.Name,
        BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})

    Library:Create("Frame",{Name="\0",Parent=wrap.Instance,BackgroundColor3=Library.Theme.Liner,
        Size=UDim2.new(0,1,0,16),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})

    WM.Items["Extra"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=12,
        Parent=wrap.Instance,TextColor3=Library.Theme["Dark Text"],Text=WM.Extra,
        BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Dark Text"})

    WM.Frame = wrap
    function WM:SetText(t)  WM.Items["Name"].Instance.Text  = t  end
    function WM:SetExtra(t) WM.Items["Extra"].Instance.Text = t  end
    function WM:SetVisibility(b) wrap.Instance.Visible = b        end
    return setmetatable(WM, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                            WINDOW
-- ═══════════════════════════════════════════════════════════════════════════

Library.Window = function(Self, Params)
    Params = Params or {}

    local vp    = VpSize()
    local WinW  = math.clamp(math.floor(vp.X * 0.43), 560, 840)
    local WinH  = math.clamp(math.floor(vp.Y * 0.62), 380, 540)

    local Window = {
        Logo        = Params.Logo or Params.logo or "",
        IsOpen      = true,
        Pages       = {},
        Items       = {},
        Current     = nil,
        SearchQuery = "",
    }

    local Items = {}

    -- ── Main frame ──────────────────────────────────────────────────────── --
    Items["Main"] = Library:Create("TextButton",{
        Name="\0",Text="",AutoButtonColor=false,
        Parent=Library.Holder.Instance,
        AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.fromOffset(WinW, WinH),
        BackgroundColor3=Library.Theme.Background,BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Background"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Main"].Instance,CornerRadius=UDim.new(0,14)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["Main"].Instance,Color=Library.Theme.Outline,Thickness=1.2}):AddToTheme({Color="Outline"})

    Items["Main"]:MakeDraggable()
    Items["Main"]:MakeResizeable(Vector2.new(480, 320))

    -- Mobile scale fix: applied AFTER MainFrame creation
    if IsMobile then
        local sc = math.clamp(vp.X / 1100, 0.5, 0.85)
        Library:Create("UIScale",{Name="\0",Parent=Items["Main"].Instance,Scale=sc})
    end

    -- ── Sidebar ─────────────────────────────────────────────────────────── --
    Items["Side"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Main"].Instance,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),
        Size=UDim2.new(0,58,1,-20),
        BackgroundColor3=Library.Theme.Inline,BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Inline"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Side"].Instance,CornerRadius=UDim.new(0,12)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["Side"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})

    -- Subtle accent tint overlay on sidebar
    local sideTint = Library:Create("Frame",{
        Name="\0",Parent=Items["Side"].Instance,
        BackgroundColor3=Library.Theme.Accent,BackgroundTransparency=0.93,
        Size=UDim2.new(1,0,1,0),BorderSizePixel=0
    }):AddToTheme({BackgroundColor3=function() return Library.Theme.Accent end})
    Library:Create("UICorner",{Name="\0",Parent=sideTint.Instance,CornerRadius=UDim.new(0,12)})

    -- Logo at top of sidebar
    local logoFrame = Library:Create("Frame",{
        Name="\0",Parent=Items["Side"].Instance,
        BackgroundColor3=Library.Theme.Accent,BackgroundTransparency=0,
        AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,10),
        Size=UDim2.new(0,38,0,38),BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Accent"})
    Library:Create("UICorner",{Name="\0",Parent=logoFrame.Instance,CornerRadius=UDim.new(1,0)})

    if Window.Logo ~= "" then
        Library:Create("ImageLabel",{Name="\0",Parent=logoFrame.Instance,
            Image=Window.Logo,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),BorderSizePixel=0})
    else
        Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=20,
            Parent=logoFrame.Instance,Text="L",TextColor3=Color3.new(1,1,1),
            BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,1,0),
            TextXAlignment=Enum.TextXAlignment.Center,BorderSizePixel=0})
    end

    -- Page list
    Items["Pages"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Side"].Instance,
        BackgroundTransparency=1,
        Position=UDim2.new(0,0,0,58),Size=UDim2.new(1,0,1,-100),BorderSizePixel=0
    })
    Library:Create("UIPadding",{Name="\0",Parent=Items["Pages"].Instance,
        PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)})
    Library:Create("UIListLayout",{Name="\0",Parent=Items["Pages"].Instance,
        Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})

    -- Avatar at bottom of sidebar
    local avFrame = Library:Create("Frame",{
        Name="\0",Parent=Items["Side"].Instance,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,1),
        Position=UDim2.new(0.5,0,1,-10),Size=UDim2.new(0,36,0,36),BorderSizePixel=0
    })
    Library:Create("UICorner",{Name="\0",Parent=avFrame.Instance,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Name="\0",Parent=avFrame.Instance,Color=Library.Theme.Outline,Thickness=1.5}):AddToTheme({Color="Outline"})
    local avImg = Library:Create("ImageLabel",{Name="\0",Parent=avFrame.Instance,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,-4,1,-4),BorderSizePixel=0,Image=""})
    Library:Create("UICorner",{Name="\0",Parent=avImg.Instance,CornerRadius=UDim.new(1,0)})
    pcall(function()
        avImg.Instance.Image = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)

    -- ── Top bar ─────────────────────────────────────────────────────────── --
    Items["Top"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Main"].Instance,
        BackgroundTransparency=1,
        Position=UDim2.new(0,78,0,0),Size=UDim2.new(1,-78,0,58),BorderSizePixel=0
    })
    Library:Create("Frame",{Name="\0",Parent=Items["Top"].Instance,
        BackgroundColor3=Library.Theme.Liner,BackgroundTransparency=0.5,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})

    -- Search
    Items["Search"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Top"].Instance,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0),
        Size=UDim2.new(0,230,0,34),
        BackgroundColor3=Library.Theme.Element,BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Element"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Search"].Instance,CornerRadius=UDim.new(0,8)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["Search"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})
    Library:Create("ImageLabel",{Name="\0",Parent=Items["Search"].Instance,
        Image="rbxassetid://115682280990954",ImageColor3=Library.Theme["Dark Icon"],
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),
        Size=UDim2.new(0,14,0,14),BorderSizePixel=0}):AddToTheme({ImageColor3="Dark Icon"})
    Items["SearchInput"] = Library:Create("TextBox",{
        Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=Items["Search"].Instance,BackgroundTransparency=1,
        PlaceholderText="Search...",PlaceholderColor3=Library.Theme["Dark Text"],
        TextColor3=Library.Theme.Text,Text="",ClearTextOnFocus=false,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,30,0.5,0),
        Size=UDim2.new(1,-42,0,14),TextXAlignment=Enum.TextXAlignment.Left,
        AutomaticSize=Enum.AutomaticSize.Y,BorderSizePixel=0
    }):AddToTheme({TextColor3="Text",PlaceholderColor3="Dark Text"})

    -- Settings button
    Items["SettingsBtn"] = Library:Create("TextButton",{
        Name="\0",Parent=Items["Top"].Instance,Text="",AutoButtonColor=false,
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.new(0,34,0,34),BackgroundColor3=Library.Theme.Element,BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Element"})
    Library:Create("UICorner",{Name="\0",Parent=Items["SettingsBtn"].Instance,CornerRadius=UDim.new(0,8)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["SettingsBtn"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})
    Library:Create("ImageLabel",{Name="\0",Parent=Items["SettingsBtn"].Instance,
        Image="rbxassetid://77336523487505",ImageColor3=Library.Theme["Dark Icon"],
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,17,0,17),BorderSizePixel=0}):AddToTheme({ImageColor3="Dark Icon"})

    -- ── Content area ────────────────────────────────────────────────────── --
    Items["Content"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Main"].Instance,
        BackgroundTransparency=1,
        Position=UDim2.new(0,78,0,58),Size=UDim2.new(1,-78,1,-58),BorderSizePixel=0
    })

    -- ── Open/close pill ─────────────────────────────────────────────────── --
    Items["Pill"] = Library:Create("TextButton",{
        Name="\0",Parent=Library.Holder.Instance,Text="",AutoButtonColor=false,
        AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,8),
        Size=UDim2.new(0,84,0,30),Selectable=false,
        BackgroundColor3=Library.Theme.Inline,BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Inline"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Pill"].Instance,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["Pill"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})
    Library:Create("UIListLayout",{Name="\0",Parent=Items["Pill"].Instance,
        FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,Padding=UDim.new(0,6)})

    local dot = Library:Create("Frame",{Name="\0",Parent=Items["Pill"].Instance,
        BackgroundColor3=Library.Theme.Accent,Size=UDim2.new(0,6,0,6),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Accent"})
    Library:Create("UICorner",{Name="\0",Parent=dot.Instance,CornerRadius=UDim.new(1,0)})

    Items["PillText"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=13,
        Parent=Items["Pill"].Instance,TextColor3=Library.Theme.Text,Text="Lurix",
        BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0
    }):AddToTheme({TextColor3="Text"})

    Window.Items = Items

    -- ── Search logic ────────────────────────────────────────────────────── --
    local function Normalize(t) return tostring(t or ""):lower():gsub("%s+","") end

    function Window:RegisterSearchItem(Data)
        if not Library.SearchItems[Data.Page] then Library.SearchItems[Data.Page]={} end
        table.insert(Library.SearchItems[Data.Page], {Name=Normalize(Data.Name), Holder=Data.Holder})
    end

    Library:Connect(Items["SearchInput"].Instance:GetPropertyChangedSignal("Text"), function()
        local q = Normalize(Items["SearchInput"].Instance.Text)
        Window.SearchQuery = q
        local page = Window.Current
        if not page or not Library.SearchItems[page] then return end
        for _, item in Library.SearchItems[page] do
            pcall(function()
                item.Holder.Visible = (q=="" or item.Name:find(q,1,true) ~= nil)
            end)
        end
    end)

    -- ── Open / close ────────────────────────────────────────────────────── --
    function Window:SetOpen(bool)
        Window.IsOpen = bool
        Items["Main"].Instance.Visible = bool
        Items["PillText"].Instance.Text = bool and "Lurix" or "Open"
        if not bool then
            for _, f in Library.OpenFrames do pcall(function() f:SetOpen(false) end) end
        end
    end

    function Window:Center()
        Items["Main"].Instance.Position = UDim2.new(0.5,0,0.5,0)
    end

    Library:Connect(UIS.InputBegan, function(inp)
        if UIS:GetFocusedTextBox() then return end
        local k = tostring(inp.KeyCode):gsub("Enum.KeyCode.","")
        local t = tostring(inp.UserInputType):gsub("Enum.UserInputType.","")
        if k==Library.MenuKeybind or t==Library.MenuKeybind then
            Window:SetOpen(not Window.IsOpen)
        end
    end)

    Items["Pill"]:Connect("MouseButton1Down", function()
        Window:SetOpen(not Window.IsOpen)
    end)

    Items["SettingsBtn"]:OnHover(function()
        Items["SettingsBtn"]:Tween({BackgroundColor3=Library.Theme["Hovered Element"]})
    end, function()
        Items["SettingsBtn"]:Tween({BackgroundColor3=Library.Theme.Element})
    end)

    -- ── Built-in settings panel ──────────────────────────────────────────── --
    local settWin = Library:Create("Frame",{
        Name="\0",Parent=Library.UnusedHolder.Instance,Visible=false,
        BackgroundColor3=Library.Theme.Inline,
        Size=UDim2.new(0,264,0,0),AutomaticSize=Enum.AutomaticSize.Y,BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Inline"})
    Library:Create("UICorner",{Name="\0",Parent=settWin.Instance,CornerRadius=UDim.new(0,10)})
    Library:Create("UIStroke",{Name="\0",Parent=settWin.Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})
    Library:Create("UIPadding",{Name="\0",Parent=settWin.Instance,
        PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12),
        PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
    Library:Create("UIListLayout",{Name="\0",Parent=settWin.Instance,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})

    local settOpen, settRS = false, nil

    local function OpenSettings(bool)
        settOpen = bool
        if bool then
            local bp = Items["SettingsBtn"].Instance.AbsolutePosition
            local bs = Items["SettingsBtn"].Instance.AbsoluteSize
            settWin.Instance.Position = UDim2.fromOffset(
                math.clamp(bp.X-230, 5, VpSize().X-274),
                bp.Y + bs.Y + 8 + GuiInset
            )
            settWin.Instance.Parent  = Library.Holder.Instance
            settWin.Instance.Visible = true
            settRS = RunService.RenderStepped:Connect(function()
                local bp2 = Items["SettingsBtn"].Instance.AbsolutePosition
                settWin.Instance.Position = UDim2.fromOffset(
                    math.clamp(bp2.X-230, 5, VpSize().X-274),
                    bp2.Y + Items["SettingsBtn"].Instance.AbsoluteSize.Y + 8 + GuiInset
                )
            end)
        else
            settWin.Instance.Parent  = Library.UnusedHolder.Instance
            settWin.Instance.Visible = false
            if settRS then settRS:Disconnect(); settRS=nil end
        end
    end

    Library:Connect(UIS.InputBegan, function(inp)
        if settOpen and (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch) then
            local bp = Items["SettingsBtn"].Instance.AbsolutePosition
            local bs = Items["SettingsBtn"].Instance.AbsoluteSize
            local mp = UIS:GetMouseLocation()
            local overBtn = mp.X>=bp.X and mp.X<=bp.X+bs.X and mp.Y>=bp.Y and mp.Y<=bp.Y+bs.Y
            if not overBtn and not settWin:IsMouseOverFrame() then OpenSettings(false) end
        end
    end)
    Items["SettingsBtn"]:Connect("MouseButton1Down", function() OpenSettings(not settOpen) end)

    -- Settings helpers
    local function SHeading(txt)
        Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=11,
            Parent=settWin.Instance,TextColor3=Library.Theme["Dark Text"],Text=txt:upper(),
            BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0,
        }):AddToTheme({TextColor3="Dark Text"})
    end

    local function SBtn(txt, cb)
        local b = Library:Create("TextButton",{Name="\0",Parent=settWin.Instance,Text="",AutoButtonColor=false,
            BackgroundColor3=Library.Theme.Element,Size=UDim2.new(1,0,0,34),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Element"})
        Library:Create("UICorner",{Name="\0",Parent=b.Instance,CornerRadius=UDim.new(0,7)})
        Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=13,Parent=b.Instance,
            TextColor3=Library.Theme.Text,Text=txt,BackgroundTransparency=1,
            AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0),
            AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})
        b:Connect("MouseButton1Down", cb)
        b:OnHover(function() b:Tween({BackgroundColor3=Library.Theme["Hovered Element"]})
        end, function() b:Tween({BackgroundColor3=Library.Theme.Element}) end)
        return b
    end

    -- Configs
    SHeading("Configs")
    local cfgFolder   = Library.Directory .. Library.Folders.Configs .. "/"
    local cfgSelected = nil

    local cfgNameBox = Library:Create("TextBox",{Name="\0",FontFace=Library.Font,TextSize=13,
        Parent=settWin.Instance,BackgroundColor3=Library.Theme.Element,
        PlaceholderText="Config name...",PlaceholderColor3=Library.Theme["Dark Text"],
        TextColor3=Library.Theme.Text,Text="",
        Size=UDim2.new(1,0,0,32),BorderSizePixel=0,ClearTextOnFocus=false,
    }):AddToTheme({BackgroundColor3="Element",TextColor3="Text",PlaceholderColor3="Dark Text"})
    Library:Create("UICorner",{Name="\0",Parent=cfgNameBox.Instance,CornerRadius=UDim.new(0,7)})
    Library:Create("UIPadding",{Name="\0",Parent=cfgNameBox.Instance,PaddingLeft=UDim.new(0,10)})

    -- Config action row
    local actRow = Library:Create("Frame",{Name="\0",Parent=settWin.Instance,
        BackgroundTransparency=1,Size=UDim2.new(1,0,0,32),BorderSizePixel=0})
    Library:Create("UIListLayout",{Name="\0",Parent=actRow.Instance,
        FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),
        SortOrder=Enum.SortOrder.LayoutOrder,HorizontalFlex=Enum.UIFlexAlignment.Fill})

    local cfgList = { Options={}, Refresh=function(Self,list)
        for _,o in Self.Options do pcall(function() o:Destroy() end) end
        Self.Options={}
        for _,item in list do
            local row = Library:Create("TextButton",{Name="\0",Parent=settWin.Instance,Text="",AutoButtonColor=false,
                BackgroundColor3=Library.Theme.Element,Size=UDim2.new(1,0,0,28),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Element"})
            Library:Create("UICorner",{Name="\0",Parent=row.Instance,CornerRadius=UDim.new(0,6)})
            local lbl = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=13,Parent=row.Instance,
                TextColor3=Library.Theme["Dark Text"],Text=item,BackgroundTransparency=1,
                AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),
                AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Dark Text"})
            row:Connect("MouseButton1Down", function()
                cfgSelected = item
                for _,o in Self.Options do
                    pcall(function()
                        local l = o.Instance:FindFirstChildOfClass("TextLabel")
                        if l then l.TextColor3=Library.Theme["Dark Text"] end
                    end)
                end
                lbl.Instance.TextColor3 = Library.Theme.Accent
            end)
            table.insert(Self.Options, row)
        end
    end}

    local function SmallBtn(parent, txt, cb)
        local b = Library:Create("TextButton",{Name="\0",Parent=parent.Instance,Text="",AutoButtonColor=false,
            BackgroundColor3=Library.Theme.Element,AutomaticSize=Enum.AutomaticSize.X,
            Size=UDim2.new(0,0,1,0),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Element"})
        Library:Create("UICorner",{Name="\0",Parent=b.Instance,CornerRadius=UDim.new(0,6)})
        Library:Create("UIPadding",{Name="\0",Parent=b.Instance,PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})
        Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=12,Parent=b.Instance,
            TextColor3=Library.Theme.Text,Text=txt,BackgroundTransparency=1,
            AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
            AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})
        b:Connect("MouseButton1Down", cb)
        b:OnHover(function() b:Tween({BackgroundColor3=Library.Theme["Hovered Element"]})
        end, function() b:Tween({BackgroundColor3=Library.Theme.Element}) end)
    end

    SmallBtn(actRow,"New", function()
        local name = cfgNameBox.Instance.Text
        if name=="" then Library:Notification("Enter a config name", 2, Color3.fromRGB(255,180,60)) return end
        writefile(cfgFolder..name..".json", Library:GetConfig())
        Library:Notification("Saved: "..name, 3, Color3.fromRGB(80,220,100))
        Library:GetConfigsList(cfgList)
    end)
    SmallBtn(actRow,"Load", function()
        if not cfgSelected then return end
        local f = cfgFolder..cfgSelected..".json"
        if not isfile(f) then return end
        local ok,err = Library:LoadConfig(readfile(f))
        if ok then Library:Notification("Loaded: "..cfgSelected, 3, Library.Theme.Accent)
        else Library:Notification("Error: "..(err or "?"), 3, Color3.fromRGB(255,80,80)) end
    end)
    SmallBtn(actRow,"Save", function()
        if not cfgSelected then return end
        writefile(cfgFolder..cfgSelected..".json", Library:GetConfig())
        Library:Notification("Saved: "..cfgSelected, 3, Color3.fromRGB(80,220,100))
    end)
    SmallBtn(actRow,"Del", function()
        if not cfgSelected then return end
        delfile(cfgFolder..cfgSelected..".json")
        cfgSelected=nil
        Library:GetConfigsList(cfgList)
        Library:Notification("Deleted config", 2, Color3.fromRGB(255,80,80))
    end)

    -- Interface section
    SHeading("Interface")
    SBtn("Unload", function() Library:Exit() end)

    -- Animation style
    local styleOptions = {"Linear","Quad","Quart","Back","Bounce","Cubic","Elastic","Exponential","Sine","Quint"}
    Library:GetConfigsList(cfgList)
    Window:Center()
    return setmetatable(Window, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                             PAGE
-- ═══════════════════════════════════════════════════════════════════════════

Library.Page = function(Self, Params)
    Params = Params or {}

    local Page = {
        Icon     = Params.Icon  or Params.icon  or "rbxassetid://129245697782918",
        Badge    = Params.Badge or Params.badge or nil,
        Window   = Self,
        ColumnsData = {},
        Items    = {},
        Active   = false,
        Debounce = false,
    }

    local Items = {}

    -- Tab button in sidebar
    Items["Tab"] = Library:Create("TextButton",{
        Name="\0",Text="",AutoButtonColor=false,
        Parent=Page.Window.Items["Pages"].Instance,
        BackgroundTransparency=1,Size=UDim2.new(1,0,0,40),BorderSizePixel=0
    })

    Items["TabBg"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Tab"].Instance,
        BackgroundColor3=Library.Theme.Tab,BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0),BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Tab"})
    Library:Create("UICorner",{Name="\0",Parent=Items["TabBg"].Instance,CornerRadius=UDim.new(0,10)})

    -- Active accent bar (left edge)
    Items["Accent"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Tab"].Instance,
        BackgroundColor3=Library.Theme.Accent,BackgroundTransparency=1,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,-3,0.5,0),
        Size=UDim2.new(0,3,0,20),BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Accent"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Accent"].Instance,CornerRadius=UDim.new(1,0)})

    Items["Icon"] = Library:Create("ImageLabel",{
        Name="\0",Parent=Items["Tab"].Instance,Image=Page.Icon,
        ImageColor3=Library.Theme["Dark Icon"],BackgroundTransparency=1,
        AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,22,0,22),BorderSizePixel=0
    }):AddToTheme({ImageColor3="Dark Icon"})

    -- Optional badge
    if Page.Badge then
        Items["Badge"] = Library:Create("Frame",{Name="\0",Parent=Items["Tab"].Instance,
            BackgroundColor3=Library.Theme.Accent,AnchorPoint=Vector2.new(1,0),
            Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,BorderSizePixel=0}):AddToTheme({BackgroundColor3="Accent"})
        Library:Create("UICorner",{Name="\0",Parent=Items["Badge"].Instance,CornerRadius=UDim.new(1,0)})
        Library:Create("UIPadding",{Name="\0",Parent=Items["Badge"].Instance,PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4)})
        Items["BadgeText"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=10,
            Parent=Items["Badge"].Instance,TextColor3=Color3.new(1,1,1),Text=tostring(Page.Badge),
            BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
            AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0})
    end

    -- Content frame
    Items["Page"] = Library:Create("Frame",{
        Name="\0",Parent=Library.UnusedHolder.Instance,
        BackgroundTransparency=1,Visible=false,
        Size=UDim2.new(1,0,1,0),BorderSizePixel=0
    })
    Library:Create("UIListLayout",{Name="\0",Parent=Items["Page"].Instance,
        FillDirection=Enum.FillDirection.Horizontal,
        HorizontalFlex=Enum.UIFlexAlignment.Fill,
        Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})
    Library:Create("UIPadding",{Name="\0",Parent=Items["Page"].Instance,
        PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8),PaddingRight=UDim.new(0,10)})

    -- Two scrollable columns
    for i, pad in {[1]={l=0,r=0},[2]={l=0,r=0}} do
        local col = Library:Create("ScrollingFrame",{
            Name="\0",Parent=Items["Page"].Instance,Active=true,
            AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),
            ScrollBarThickness=2,ScrollBarImageColor3=Library.Theme.Accent,
            BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),BorderSizePixel=0,
            MidImage="rbxassetid://81680855285439",BottomImage="rbxassetid://81680855285439",
            TopImage="rbxassetid://81680855285439"
        }):AddToTheme({ScrollBarImageColor3="Accent"})
        Library:Create("UIPadding",{Name="\0",Parent=col.Instance,
            PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)})
        Library:Create("UIListLayout",{Name="\0",Parent=col.Instance,
            Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})
        Page.ColumnsData[i] = col
    end

    Library.SearchItems[Page] = {}
    Page.Items = Items

    function Page:SetBadge(n)
        if Items["BadgeText"] then
            Items["BadgeText"].Instance.Text = tostring(n)
            if Items["Badge"] then Items["Badge"].Instance.Visible = (n and n > 0) end
        end
    end

    function Page:Turn()
        local Old = Page.Window.Current
        if Old == Page or Page.Debounce then return end
        if Old and Old.Debounce then return end
        Page.Debounce = true

        if Old then
            Old.Active = false
            Old.Items["TabBg"]:Tween({BackgroundTransparency=1})
            Old.Items["Accent"]:Tween({BackgroundTransparency=1})
            Old.Items["Icon"]:ChangeItemTheme({ImageColor3="Dark Icon"})
            Old.Items["Icon"]:Tween({ImageColor3=Library.Theme["Dark Icon"]})
            Old.Items["Page"]:FadeDescendants(false, function()
                Old.Items["Page"].Instance.Parent = Library.UnusedHolder.Instance
            end)
        end

        Items["Page"].Instance.Parent  = Page.Window.Items["Content"].Instance
        Items["Page"].Instance.Visible = true
        Items["Page"]:FadeDescendants(true, function()
            Page.Debounce = false
        end)

        Items["TabBg"]:Tween({BackgroundTransparency=0.88})
        Items["Accent"]:Tween({BackgroundTransparency=0})
        Items["Icon"]:ChangeItemTheme({ImageColor3="Accent"})
        Items["Icon"]:Tween({ImageColor3=Library.Theme.Accent})

        Page.Active = true
        Page.Window.Current = Page
    end

    Items["Tab"]:OnHover(function()
        if Page.Active then return end
        Items["TabBg"]:Tween({BackgroundTransparency=0.94})
    end, function()
        if Page.Active then return end
        Items["TabBg"]:Tween({BackgroundTransparency=1})
    end)

    Items["Tab"]:Connect("MouseButton1Down", function() Page:Turn() end)
    if #Page.Window.Pages == 0 then Page:Turn() end
    table.insert(Page.Window.Pages, Page)
    return setmetatable(Page, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                            SECTION
-- ═══════════════════════════════════════════════════════════════════════════

Library.Section = function(Self, Params)
    Params = Params or {}

    local Section = {
        Name   = Params.Name or Params.name or "Section",
        Side   = Params.Side or Params.side or 1,
        Window = Self.Window,
        Page   = Self,
        Items  = {},
    }

    local Items = {}

    Items["Wrap"] = Library:Create("Frame",{
        Name="\0",Parent=Section.Page.ColumnsData[Section.Side].Instance,
        BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,BorderSizePixel=0
    })
    Library:Create("UIListLayout",{Name="\0",Parent=Items["Wrap"].Instance,
        Padding=UDim.new(0,0),SortOrder=Enum.SortOrder.LayoutOrder})

    -- Title row
    local titleRow = Library:Create("Frame",{
        Name="\0",Parent=Items["Wrap"].Instance,
        BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),BorderSizePixel=0
    })
    -- Accent pip
    Library:Create("Frame",{Name="\0",Parent=titleRow.Instance,
        BackgroundColor3=Library.Theme.Accent,BackgroundTransparency=0.4,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),
        Size=UDim2.new(0,3,0,13),BorderSizePixel=0
    }):AddToTheme({BackgroundColor3=function() return Library.Theme.Accent end})
    Library:Create("UICorner",{Name="\0",Parent=titleRow.Instance:GetChildren()[1],CornerRadius=UDim.new(1,0)})

    Items["Title"] = Library:Create("TextLabel",{
        Name="\0",FontFace=Library.Font,TextSize=Library.FontSize+1,
        Parent=titleRow.Instance,TextColor3=Library.Theme.Text,
        Text=Section.Name,BackgroundTransparency=1,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0
    }):AddToTheme({TextColor3="Text"})

    -- Body
    Items["Body"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Wrap"].Instance,
        BackgroundColor3=Library.Theme.Inline,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BorderSizePixel=0
    }):AddToTheme({BackgroundColor3="Inline"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Body"].Instance,CornerRadius=UDim.new(0,10)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["Body"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})
    Library:Create("UIPadding",{Name="\0",Parent=Items["Body"].Instance,PaddingBottom=UDim.new(0,12)})

    Items["Content"] = Library:Create("Frame",{
        Name="\0",Parent=Items["Body"].Instance,
        BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,12),Size=UDim2.new(1,-24,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,BorderSizePixel=0
    })
    Library:Create("UIListLayout",{Name="\0",Parent=Items["Content"].Instance,
        Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})

    Section.Items = Items
    return setmetatable(Section, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                            TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════

Library.Toggle = function(Self, Params)
    Params = Params or {}
    local Toggle = {
        Name     = Params.Name     or Params.name     or "Toggle",
        Flag     = Params.Flag     or Params.flag     or (Params.Name or Params.name),
        Default  = Params.Default  or Params.default  or false,
        Tooltip  = Params.Tooltip  or Params.tooltip  or "",
        Callback = Params.Callback or Params.callback or function()end,
        Window   = Self.Window, Page=Self.Page, Section=Self,
        Value    = false, Items = {},
    }
    local Parent = Params.Parent or Toggle.Section.Items["Content"]
    local Items  = {}

    Items["Row"] = Library:Create("TextButton",{Name="\0",Text="",AutoButtonColor=false,
        Parent=Parent.Instance,BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),BorderSizePixel=0})
    Items["Row"]:Tooltip(Toggle.Tooltip)
    Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,
        BackgroundColor3=Library.Theme.Liner,BackgroundTransparency=0.6,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})

    Items["Text"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=Items["Row"].Instance,TextColor3=Library.Theme["Dark Text"],Text=Toggle.Name,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Dark Text"})

    Items["Sub"] = Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-46,0.5,0),
        Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BorderSizePixel=0})
    Library:Create("UIListLayout",{Name="\0",Parent=Items["Sub"].Instance,
        FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,
        VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,8)})

    Items["Track"] = Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.new(0,34,0,20),BackgroundColor3=Library.Theme.Element,BorderSizePixel=0}):AddToTheme({BackgroundColor3="Element"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Track"].Instance,CornerRadius=UDim.new(1,0)})

    Items["Knob"] = Library:Create("Frame",{Name="\0",Parent=Items["Track"].Instance,
        Position=UDim2.fromOffset(3,3),Size=UDim2.fromOffset(14,14),
        BackgroundColor3=Library.Theme.Toggle,BorderSizePixel=0}):AddToTheme({BackgroundColor3="Toggle"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Knob"].Instance,CornerRadius=UDim.new(1,0)})

    Toggle.Items = Items

    Items["Row"]:OnHover(function()
        if Toggle.Value then return end
        Items["Track"]:Tween({BackgroundColor3=Library.Theme["Hovered Element"]})
    end, function()
        if Toggle.Value then return end
        Items["Track"]:Tween({BackgroundColor3=Library.Theme.Element})
    end)

    function Toggle:Set(bool)
        Toggle.Value = bool
        if bool then
            Items["Track"]:ChangeItemTheme({BackgroundColor3="Accent"})
            Items["Text"]:ChangeItemTheme({TextColor3="Text"})
            Items["Knob"]:ChangeItemTheme({BackgroundColor3="Accent"})
            Items["Track"]:Tween({BackgroundColor3=Library.Theme.Accent,BackgroundTransparency=0.72})
            Items["Text"]:Tween({TextColor3=Library.Theme.Text})
            Items["Knob"]:Tween({Position=UDim2.fromOffset(17,3),BackgroundColor3=Library.Theme.Accent})
        else
            Items["Track"]:ChangeItemTheme({BackgroundColor3="Element"})
            Items["Text"]:ChangeItemTheme({TextColor3="Dark Text"})
            Items["Knob"]:ChangeItemTheme({BackgroundColor3="Toggle"})
            Items["Track"]:Tween({BackgroundColor3=Library.Theme.Element,BackgroundTransparency=0})
            Items["Text"]:Tween({TextColor3=Library.Theme["Dark Text"]})
            Items["Knob"]:Tween({Position=UDim2.fromOffset(3,3),BackgroundColor3=Library.Theme.Toggle})
        end
        Flags[Toggle.Flag] = bool
        Library:SafeCall(Toggle.Callback, bool)
    end

    function Toggle:SetVisibility(b) Items["Row"].Instance.Visible=b end
    function Toggle:Colorpicker(D)
        D=D or {}
        return Library:CreateColorpicker(Self,{Parent=Items["Sub"],Flag=D.Flag or Toggle.Flag.."_Color",Default=D.Default,Alpha=D.Alpha,Callback=D.Callback})
    end
    function Toggle:Keybind(D)
        D=D or {}
        return Library:CreateKeybind(Self,{Parent=Items["Sub"],Flag=D.Flag or Toggle.Flag.."_Key",Default=D.Default,Mode=D.Mode,Callback=D.Callback})
    end

    Items["Row"]:Connect("MouseButton1Down", function() Toggle:Set(not Toggle.Value) end)
    if Toggle.Window then
        Toggle.Window:RegisterSearchItem({Name=Toggle.Name,Page=Toggle.Page,Holder=Items["Row"].Instance})
    end
    Toggle:Set(Toggle.Default)
    SetFlags[Toggle.Flag] = function(v) Toggle:Set(v) end
    return setmetatable(Toggle, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                            BUTTON
-- ═══════════════════════════════════════════════════════════════════════════

Library.Button = function(Self, Params)
    Params = Params or {}
    local Button = {
        Name     = Params.Name     or Params.name     or "Button",
        Tooltip  = Params.Tooltip  or Params.tooltip  or "",
        Callback = Params.Callback or Params.callback or function()end,
        Window   = Self.Window, Page=Self.Page, Section=Self, Items={},
    }
    local Parent = Params.Parent or Button.Section.Items["Content"]
    local Items  = {}

    Items["Row"] = Library:Create("Frame",{Name="\0",Parent=Parent.Instance,BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,40),BorderSizePixel=0})
    Items["Row"]:Tooltip(Button.Tooltip)
    Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,
        BackgroundColor3=Library.Theme.Liner,BackgroundTransparency=0.6,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})

    Items["Btn"] = Library:Create("TextButton",{Name="\0",Text="",AutoButtonColor=false,
        Parent=Items["Row"].Instance,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(1,0,0,30),BackgroundColor3=Library.Theme.Element,BorderSizePixel=0}):AddToTheme({BackgroundColor3="Element"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Btn"].Instance,CornerRadius=UDim.new(0,7)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["Btn"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})

    Items["Text"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=Items["Btn"].Instance,TextColor3=Library.Theme.Text,Text=Button.Name,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})

    Button.Items = Items

    Items["Btn"]:OnHover(function() Items["Btn"]:Tween({BackgroundColor3=Library.Theme["Hovered Element"]})
    end, function() Items["Btn"]:Tween({BackgroundColor3=Library.Theme.Element}) end)

    function Button:Press()
        Items["Btn"]:ChangeItemTheme({BackgroundColor3="Accent"})
        Items["Btn"]:Tween({BackgroundColor3=Library.Theme.Accent},TweenInfo.new(0.08,Enum.EasingStyle.Linear))
        task.delay(0.14,function()
            Items["Btn"]:ChangeItemTheme({BackgroundColor3="Element"})
            Items["Btn"]:Tween({BackgroundColor3=Library.Theme.Element})
        end)
        Library:SafeCall(Button.Callback)
    end

    function Button:SetText(t) Items["Text"].Instance.Text=tostring(t) end
    function Button:SetVisibility(b) Items["Row"].Instance.Visible=b end

    if Button.Window then
        Button.Window:RegisterSearchItem({Name=Button.Name,Page=Button.Page,Holder=Items["Row"].Instance})
    end
    Items["Btn"]:Connect("MouseButton1Down", function() Button:Press() end)
    return setmetatable(Button, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                            SLIDER
-- ═══════════════════════════════════════════════════════════════════════════

Library.Slider = function(Self, Params)
    Params = Params or {}
    local Slider = {
        Name     = Params.Name     or Params.name     or "Slider",
        Flag     = Params.Flag     or Params.flag     or (Params.Name or Params.name),
        Default  = Params.Default  or Params.default  or 0,
        Min      = Params.Min      or Params.min      or 0,
        Max      = Params.Max      or Params.max      or 100,
        Decimals = Params.Decimals or Params.decimals or 1,
        Suffix   = Params.Suffix   or Params.suffix   or "",
        Tooltip  = Params.Tooltip  or Params.tooltip  or "",
        Callback = Params.Callback or Params.callback or function()end,
        Window=Self.Window, Page=Self.Page, Section=Self, Value=0, Items={},
    }
    local Parent = Params.Parent or Slider.Section.Items["Content"]
    local Items  = {}

    Items["Row"] = Library:Create("Frame",{Name="\0",Parent=Parent.Instance,BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,42),BorderSizePixel=0})
    Items["Row"]:Tooltip(Slider.Tooltip)
    Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,
        BackgroundColor3=Library.Theme.Liner,BackgroundTransparency=0.6,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})

    Items["Label"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=Items["Row"].Instance,TextColor3=Library.Theme.Text,Text=Slider.Name,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0),Position=UDim2.new(0,0,0,5),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})

    Items["Track"] = Library:Create("TextButton",{Name="\0",Text="",AutoButtonColor=false,
        Parent=Items["Row"].Instance,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,2),
        Size=UDim2.new(0,130,0,10),BackgroundColor3=Library.Theme.Element,BorderSizePixel=0}):AddToTheme({BackgroundColor3="Element"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Track"].Instance,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["Track"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})

    Items["Fill"] = Library:Create("Frame",{Name="\0",Parent=Items["Track"].Instance,
        BackgroundColor3=Library.Theme.Accent,Size=UDim2.new(0,0,1,0),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Accent"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Fill"].Instance,CornerRadius=UDim.new(1,0)})
    Library:Create("UIGradient",{Name="\0",Parent=Items["Fill"].Instance,
        Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(80,120,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(130,170,255))}})

    Items["Dragger"] = Library:Create("TextButton",{Name="\0",Text="",AutoButtonColor=false,
        Parent=Items["Fill"].Instance,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.new(0,16,0,16),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0})
    Library:Create("UICorner",{Name="\0",Parent=Items["Dragger"].Instance,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Name="\0",Parent=Items["Dragger"].Instance,Color=Library.Theme.Accent,Thickness=2}):AddToTheme({Color="Accent"})

    Items["Value"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=Items["Row"].Instance,TextColor3=Library.Theme["Dark Text"],Text="0"..Slider.Suffix,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-138,0,5),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Dark Text"})

    Slider.Items = Items

    function Slider:Set(v)
        v = Library:Round(math.clamp(v, Slider.Min, Slider.Max), Slider.Decimals)
        Slider.Value = v
        local pct = (v-Slider.Min)/(Slider.Max-Slider.Min)
        Items["Fill"]:Tween({Size=UDim2.new(pct,0,1,0)},TweenInfo.new(0.06,Enum.EasingStyle.Linear))
        local disp = tostring(Slider.Decimals<1 and math.floor(v) or v)..Slider.Suffix
        Items["Value"].Instance.Text = disp
        Flags[Slider.Flag] = v
        Library:SafeCall(Slider.Callback, v)
    end

    function Slider:Slide(inp)
        local ap = Items["Track"].Instance.AbsolutePosition
        local as = Items["Track"].Instance.AbsoluteSize
        local pct = math.clamp((inp.Position.X-ap.X)/as.X, 0, 1)
        Slider:Set(Slider.Min + pct*(Slider.Max-Slider.Min))
    end

    function Slider:SetVisibility(b) Items["Row"].Instance.Visible=b end

    local active = false
    Items["Track"]:Connect("InputBegan",function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then active=true;Slider:Slide(i) end
    end)
    Items["Dragger"]:Connect("InputBegan",function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then active=true end
    end)
    Library:Connect(UIS.InputChanged,function(i)
        if not active then return end
        if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
        Slider:Slide(i)
    end)
    Library:Connect(UIS.InputEnded,function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then active=false end
    end)

    if Slider.Window then
        Slider.Window:RegisterSearchItem({Name=Slider.Name,Page=Slider.Page,Holder=Items["Row"].Instance})
    end
    Slider:Set(Slider.Default)
    SetFlags[Slider.Flag]=function(v) Slider:Set(v) end
    return setmetatable(Slider, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                           DROPDOWN
-- ═══════════════════════════════════════════════════════════════════════════

Library.Dropdown = function(Self, Params)
    Params = Params or {}
    local OptionItems = Params.Items or Params.items or {}
    local Dropdown = {
        Name     = Params.Name     or Params.name     or "Dropdown",
        Flag     = Params.Flag     or Params.flag     or (Params.Name or Params.name),
        Default  = Params.Default  or Params.default,
        Multi    = Params.Multi    or Params.multi    or false,
        MaxSize  = Params.MaxSize  or Params.maxSize  or 180,
        Tooltip  = Params.Tooltip  or Params.tooltip  or "",
        Callback = Params.Callback or Params.callback or function()end,
        Window=Self.Window, Page=Self.Page, Section=Self,
        Value=nil, IsOpen=false, Options={}, Items={},
    }
    if Dropdown.Multi then Dropdown.Value={} end

    local Parent = Params.Parent or Dropdown.Section.Items["Content"]
    local UI     = {}

    UI["Row"] = Library:Create("Frame",{Name="\0",Parent=Parent.Instance,BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,40),BorderSizePixel=0})
    UI["Row"]:Tooltip(Dropdown.Tooltip)
    Library:Create("Frame",{Name="\0",Parent=UI["Row"].Instance,
        BackgroundColor3=Library.Theme.Liner,BackgroundTransparency=0.6,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})

    UI["Label"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=UI["Row"].Instance,TextColor3=Library.Theme.Text,Text=Dropdown.Name,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})

    UI["Btn"] = Library:Create("TextButton",{Name="\0",Text="",AutoButtonColor=false,
        Parent=UI["Row"].Instance,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.new(0,120,0,26),BackgroundColor3=Library.Theme.Element,BorderSizePixel=0}):AddToTheme({BackgroundColor3="Element"})
    Library:Create("UICorner",{Name="\0",Parent=UI["Btn"].Instance,CornerRadius=UDim.new(0,6)})
    Library:Create("UIStroke",{Name="\0",Parent=UI["Btn"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})

    UI["BtnText"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize-1,
        Parent=UI["Btn"].Instance,TextColor3=Library.Theme["Dark Text"],Text="Select...",
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,8,0.5,0),
        Size=UDim2.new(1,-24,0,14),TextTruncate=Enum.TextTruncate.AtEnd,BorderSizePixel=0}):AddToTheme({TextColor3="Dark Text"})

    UI["Arrow"] = Library:Create("ImageLabel",{Name="\0",Parent=UI["Btn"].Instance,
        Image="rbxassetid://127296511745226",ImageColor3=Library.Theme["Dark Icon"],
        BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),
        Size=UDim2.new(0,12,0,12),BorderSizePixel=0}):AddToTheme({ImageColor3="Dark Icon"})

    UI["List"] = Library:Create("TextButton",{Name="\0",Text="",AutoButtonColor=false,
        Parent=Library.UnusedHolder.Instance,Visible=false,ClipsDescendants=true,
        Size=UDim2.new(0,140,0,50),BackgroundColor3=Library.Theme.Background,
        BackgroundTransparency=0.04,BorderSizePixel=0}):AddToTheme({BackgroundColor3="Background"})
    Library:Create("UICorner",{Name="\0",Parent=UI["List"].Instance,CornerRadius=UDim.new(0,9)})
    Library:Create("UIStroke",{Name="\0",Parent=UI["List"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})
    Library:Create("UIListLayout",{Name="\0",Parent=UI["List"].Instance,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
    Library:Create("UIPadding",{Name="\0",Parent=UI["List"].Instance,
        PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)})

    Dropdown.Items = UI

    function Dropdown:SetOpen(bool)
        Dropdown.IsOpen = bool
        if bool then
            local bp = UI["Btn"].Instance.AbsolutePosition
            local bs = UI["Btn"].Instance.AbsoluteSize
            local vp = VpSize()
            UI["List"].Instance.Size = UDim2.fromOffset(math.max(bs.X,140), Dropdown.MaxSize)
            UI["List"].Instance.Position = UDim2.fromOffset(
                math.clamp(bp.X, 5, vp.X-150), bp.Y+bs.Y+6+GuiInset)
            UI["List"].Instance.Parent  = Library.Holder.Instance
            UI["List"].Instance.Visible = true
            UI["Arrow"]:Tween({Rotation=-90})
            for _,f in Library.OpenFrames do if f~=Dropdown then pcall(function() f:SetOpen(false) end) end end
            Library.OpenFrames[Dropdown] = Dropdown
        else
            UI["Arrow"]:Tween({Rotation=0})
            UI["List"].Instance.Parent  = Library.UnusedHolder.Instance
            UI["List"].Instance.Visible = false
            Library.OpenFrames[Dropdown] = nil
        end
        local zv = bool and Library.ZIndexOrder.OptionHolder or 1
        for _,d in UI["List"].Instance:GetDescendants() do
            if not d.ClassName:find("UI") then pcall(function() d.ZIndex=zv end) end
        end
    end

    function Dropdown:Add(name)
        local ob = Library:Create("TextButton",{Name="\0",Text="",AutoButtonColor=false,
            Parent=UI["List"].Instance,BackgroundTransparency=1,
            Size=UDim2.new(1,0,0,22),BorderSizePixel=0})
        local ot = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
            Parent=ob.Instance,TextColor3=Library.Theme["Dark Text"],Text=name,
            BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),
            AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Dark Text"})
        local oc = Library:Create("ImageLabel",{Name="\0",Parent=ob.Instance,
            Image="rbxassetid://114461119629011",ImageColor3=Library.Theme.Accent,
            BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),
            Position=UDim2.new(2,0,0.5,0),Size=UDim2.new(0,12,0,12),BorderSizePixel=0}):AddToTheme({ImageColor3="Accent"})

        local opt = {Btn=ob,Text=ot,Check=oc,Name=name,IsSelected=false}

        function opt:ToggleState(on)
            if on then oc:Tween({Position=UDim2.new(1,0,0.5,0)}); ot:ChangeItemTheme({TextColor3="Text"}); ot:Tween({TextColor3=Library.Theme.Text})
            else     oc:Tween({Position=UDim2.new(2,0,0.5,0)}); ot:ChangeItemTheme({TextColor3="Dark Text"}); ot:Tween({TextColor3=Library.Theme["Dark Text"]}) end
        end

        ob:OnHover(function() if not opt.IsSelected then ot:Tween({TextColor3=Library.Theme.Text}) end
        end, function() if not opt.IsSelected then ot:Tween({TextColor3=Library.Theme["Dark Text"]}) end end)

        ob:Connect("MouseButton1Down", function()
            if Dropdown.Multi then
                opt.IsSelected = not opt.IsSelected
                local idx = table.find(Dropdown.Value, name)
                if idx then table.remove(Dropdown.Value,idx) else table.insert(Dropdown.Value,name) end
                opt:ToggleState(opt.IsSelected)
                Flags[Dropdown.Flag] = Dropdown.Value
                UI["BtnText"].Instance.Text = #Dropdown.Value>0 and table.concat(Dropdown.Value,", ") or "Select..."
                Library:SafeCall(Dropdown.Callback, Dropdown.Value)
            else
                if Dropdown.Value==name then return end
                for _,o in Dropdown.Options do o.IsSelected=false;o:ToggleState(false) end
                opt.IsSelected=true;opt:ToggleState(true)
                Dropdown.Value=name;Flags[Dropdown.Flag]=name
                UI["BtnText"].Instance.Text=name
                UI["BtnText"]:ChangeItemTheme({TextColor3="Text"})
                UI["BtnText"].Instance.TextColor3=Library.Theme.Text
                Library:SafeCall(Dropdown.Callback,name)
                Dropdown:SetOpen(false)
            end
        end)

        Dropdown.Options[name]=opt; return opt
    end

    function Dropdown:Remove(name)
        if Dropdown.Options[name] then Dropdown.Options[name].Btn.Instance:Destroy(); Dropdown.Options[name]=nil end
    end

    function Dropdown:Refresh(list)
        for n in Dropdown.Options do Dropdown:Remove(n) end
        for _,v in list do Dropdown:Add(v) end
    end

    function Dropdown:Set(v)
        if Dropdown.Multi then
            if type(v)~="table" then return end
            for _,o in Dropdown.Options do o.IsSelected=false;o:ToggleState(false) end
            Dropdown.Value={}
            for _,n in v do
                if Dropdown.Options[n] then Dropdown.Options[n].IsSelected=true;Dropdown.Options[n]:ToggleState(true);table.insert(Dropdown.Value,n) end
            end
            Flags[Dropdown.Flag]=Dropdown.Value
            UI["BtnText"].Instance.Text=#Dropdown.Value>0 and table.concat(Dropdown.Value,", ") or "Select..."
        else
            if not Dropdown.Options[v] then return end
            for _,o in Dropdown.Options do o.IsSelected=false;o:ToggleState(false) end
            Dropdown.Options[v].IsSelected=true;Dropdown.Options[v]:ToggleState(true)
            Dropdown.Value=v;Flags[Dropdown.Flag]=v
            UI["BtnText"].Instance.Text=v
            UI["BtnText"]:ChangeItemTheme({TextColor3="Text"})
            UI["BtnText"].Instance.TextColor3=Library.Theme.Text
        end
        Library:SafeCall(Dropdown.Callback,Dropdown.Value)
    end

    function Dropdown:SetText(t) UI["Label"].Instance.Text=tostring(t) end
    function Dropdown:SetVisibility(b) UI["Row"].Instance.Visible=b end

    UI["Btn"]:OnHover(function() UI["Btn"]:Tween({BackgroundColor3=Library.Theme["Hovered Element"]})
    end, function() UI["Btn"]:Tween({BackgroundColor3=Library.Theme.Element}) end)
    UI["Btn"]:Connect("MouseButton1Down",function() Dropdown:SetOpen(not Dropdown.IsOpen) end)
    Library:Connect(UIS.InputBegan,function(i)
        if Dropdown.IsOpen and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and not UI["List"]:IsMouseOverFrame() then
            Dropdown:SetOpen(false)
        end
    end)

    if Dropdown.Window then Dropdown.Window:RegisterSearchItem({Name=Dropdown.Name,Page=Dropdown.Page,Holder=UI["Row"].Instance}) end
    for _,v in OptionItems do Dropdown:Add(v) end
    if Dropdown.Default then Dropdown:Set(Dropdown.Default) end
    SetFlags[Dropdown.Flag]=function(v) Dropdown:Set(v) end
    return setmetatable(Dropdown, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                             LABEL
-- ═══════════════════════════════════════════════════════════════════════════

Library.Label = function(Self, Params)
    Params = Params or {}
    local Label = {
        Name=Params.Name or Params.name or "Label", Tooltip=Params.Tooltip or Params.tooltip or "",
        Window=Self.Window, Page=Self.Page, Section=Self, Items={},
    }
    local Parent = Params.Parent or Label.Section.Items["Content"]
    local Items  = {}

    Items["Row"] = Library:Create("Frame",{Name="\0",Parent=Parent.Instance,BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,30),BorderSizePixel=0})
    Items["Row"]:Tooltip(Label.Tooltip)
    Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,BackgroundColor3=Library.Theme.Liner,BackgroundTransparency=0.6,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})

    Items["Text"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=Items["Row"].Instance,TextColor3=Library.Theme.Text,Text=Label.Name,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})

    Items["Sub"] = Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,BackgroundTransparency=1,
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BorderSizePixel=0})
    Library:Create("UIListLayout",{Name="\0",Parent=Items["Sub"].Instance,FillDirection=Enum.FillDirection.Horizontal,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,6)})

    Label.Items = Items
    function Label:SetText(t) Items["Text"].Instance.Text=tostring(t) end
    function Label:SetVisibility(b) Items["Row"].Instance.Visible=b end
    function Label:Colorpicker(D)
        D=D or {}
        return Library:CreateColorpicker(Self,{Parent=Items["Sub"],Flag=D.Flag or Label.Name.."_Color",Default=D.Default,Alpha=D.Alpha,Callback=D.Callback})
    end
    function Label:Keybind(D)
        D=D or {}
        return Library:CreateKeybind(Self,{Parent=Items["Sub"],Flag=D.Flag or Label.Name.."_Key",Default=D.Default,Mode=D.Mode,Callback=D.Callback})
    end
    if Label.Window then Label.Window:RegisterSearchItem({Name=Label.Name,Page=Label.Page,Holder=Items["Row"].Instance}) end
    return setmetatable(Label, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                            TEXTBOX
-- ═══════════════════════════════════════════════════════════════════════════

Library.Textbox = function(Self, Params)
    Params = Params or {}
    local Textbox = {
        Name=Params.Name or Params.name or "Textbox", Flag=Params.Flag or Params.flag or (Params.Name or Params.name),
        Default=Params.Default or Params.default or "", Placeholder=Params.Placeholder or Params.placeholder or "Type here...",
        Tooltip=Params.Tooltip or Params.tooltip or "", Numeric=Params.Numeric or Params.numeric or false,
        Finished=Params.Finished or Params.finished or false, Callback=Params.Callback or Params.callback or function()end,
        Window=Self.Window, Page=Self.Page, Section=Self, Value="", Items={},
    }
    local Parent = Params.Parent or Textbox.Section.Items["Content"]
    local Items  = {}

    Items["Row"] = Library:Create("Frame",{Name="\0",Parent=Parent.Instance,BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,44),BorderSizePixel=0})
    Items["Row"]:Tooltip(Textbox.Tooltip)
    Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,BackgroundColor3=Library.Theme.Liner,BackgroundTransparency=0.6,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})

    Items["Label"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=Items["Row"].Instance,TextColor3=Library.Theme.Text,Text=Textbox.Name,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0),Position=UDim2.new(0,0,0,5),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})

    Items["Box"] = Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,
        AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,130,0,28),
        BackgroundColor3=Library.Theme.Element,BorderSizePixel=0}):AddToTheme({BackgroundColor3="Element"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Box"].Instance,CornerRadius=UDim.new(0,7)})
    Items["Stroke"] = Library:Create("UIStroke",{Name="\0",Parent=Items["Box"].Instance,Color=Library.Theme.Outline,Thickness=1}):AddToTheme({Color="Outline"})

    Items["Input"] = Library:Create("TextBox",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=Items["Box"].Instance,BackgroundTransparency=1,PlaceholderText=Textbox.Placeholder,
        PlaceholderColor3=Library.Theme["Dark Text"],TextColor3=Library.Theme.Text,Text="",ClearTextOnFocus=false,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,8,0.5,0),Size=UDim2.new(1,-16,0,14),
        TextXAlignment=Enum.TextXAlignment.Left,AutomaticSize=Enum.AutomaticSize.Y,BorderSizePixel=0}):AddToTheme({TextColor3="Text",PlaceholderColor3="Dark Text"})

    Textbox.Items = Items

    function Textbox:Set(v)
        if Textbox.Numeric then if not tonumber(v) and #tostring(v)>0 then v=Textbox.Value end end
        Textbox.Value=v; Items["Input"].Instance.Text=tostring(v); Flags[Textbox.Flag]=v
        Library:SafeCall(Textbox.Callback,v)
    end
    function Textbox:SetText(t) Items["Label"].Instance.Text=tostring(t) end
    function Textbox:SetVisibility(b) Items["Row"].Instance.Visible=b end

    Items["Input"]:Connect("Focused",function()
        Items["Box"]:Tween({BackgroundColor3=Library.Theme["Hovered Element"]})
        local s=Items["Box"].Instance:FindFirstChildOfClass("UIStroke")
        if s then Library:Tween({Color=Library.Theme.Accent},nil,s) end
    end)
    Items["Input"]:Connect("FocusLost",function(enter)
        Items["Box"]:Tween({BackgroundColor3=Library.Theme.Element})
        local s=Items["Box"].Instance:FindFirstChildOfClass("UIStroke")
        if s then Library:Tween({Color=Library.Theme.Outline},nil,s) end
        if Textbox.Finished and enter then Textbox:Set(Items["Input"].Instance.Text) end
    end)
    if not Textbox.Finished then
        Library:Connect(Items["Input"].Instance:GetPropertyChangedSignal("Text"),function() Textbox:Set(Items["Input"].Instance.Text) end)
    end
    if Textbox.Window then Textbox.Window:RegisterSearchItem({Name=Textbox.Name,Page=Textbox.Page,Holder=Items["Row"].Instance}) end
    Textbox:Set(Textbox.Default)
    SetFlags[Textbox.Flag]=function(v) Textbox:Set(v) end
    return setmetatable(Textbox, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                         DIVIDER  (new)
-- ═══════════════════════════════════════════════════════════════════════════

Library.Divider = function(Self, Params)
    Params = Params or {}
    local Divider = { Name=Params.Name or Params.name or "", Section=Self, Items={} }
    local Parent  = Params.Parent or Divider.Section.Items["Content"]
    local Items   = {}

    Items["Row"] = Library:Create("Frame",{Name="\0",Parent=Parent.Instance,BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,22),BorderSizePixel=0})

    if Divider.Name ~= "" then
        Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,BackgroundColor3=Library.Theme.Liner,
            AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(0.35,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})
        Items["Text"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=11,
            Parent=Items["Row"].Instance,TextColor3=Library.Theme["Dark Text"],Text=Divider.Name,
            BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
            AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Dark Text"})
        Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,BackgroundColor3=Library.Theme.Liner,
            AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.new(0.35,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})
    else
        Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,BackgroundColor3=Library.Theme.Liner,
            AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})
    end

    Divider.Items = Items
    function Divider:SetVisibility(b) Items["Row"].Instance.Visible=b end
    function Divider:SetText(t) if Items["Text"] then Items["Text"].Instance.Text=tostring(t) end end
    return setmetatable(Divider, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                         PROGRESS  (new)
-- ═══════════════════════════════════════════════════════════════════════════

Library.Progress = function(Self, Params)
    Params = Params or {}
    local Progress = {
        Name=Params.Name or Params.name or "Progress", Flag=Params.Flag or Params.flag or (Params.Name or Params.name),
        Default=Params.Default or Params.default or 0, Max=Params.Max or Params.max or 100,
        Suffix=Params.Suffix or Params.suffix or "%", Tooltip=Params.Tooltip or Params.tooltip or "",
        Callback=Params.Callback or Params.callback or function()end,
        Section=Self, Value=0, Items={},
    }
    local Parent = Params.Parent or Progress.Section.Items["Content"]
    local Items  = {}

    Items["Row"] = Library:Create("Frame",{Name="\0",Parent=Parent.Instance,BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,42),BorderSizePixel=0})
    Items["Row"]:Tooltip(Progress.Tooltip)
    Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,BackgroundColor3=Library.Theme.Liner,BackgroundTransparency=0.6,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})

    Items["Label"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=Items["Row"].Instance,TextColor3=Library.Theme.Text,Text=Progress.Name,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0),Position=UDim2.new(0,0,0,5),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})

    Items["Val"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
        Parent=Items["Row"].Instance,TextColor3=Library.Theme["Dark Text"],Text="0"..Progress.Suffix,
        BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,5),
        AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0}):AddToTheme({TextColor3="Dark Text"})

    Items["Track"] = Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,-5),Size=UDim2.new(1,0,0,8),
        BackgroundColor3=Library.Theme.Element,BorderSizePixel=0}):AddToTheme({BackgroundColor3="Element"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Track"].Instance,CornerRadius=UDim.new(1,0)})

    Items["Fill"] = Library:Create("Frame",{Name="\0",Parent=Items["Track"].Instance,
        BackgroundColor3=Library.Theme.Accent,Size=UDim2.new(0,0,1,0),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Accent"})
    Library:Create("UICorner",{Name="\0",Parent=Items["Fill"].Instance,CornerRadius=UDim.new(1,0)})
    Library:Create("UIGradient",{Name="\0",Parent=Items["Fill"].Instance,
        Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(80,120,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(150,185,255))}})

    Progress.Items = Items

    function Progress:Set(v)
        v=math.clamp(v, 0, Progress.Max); Progress.Value=v
        local pct=v/Progress.Max
        Items["Fill"]:Tween({Size=UDim2.new(pct,0,1,0)})
        Items["Val"].Instance.Text=tostring(math.floor(v))..Progress.Suffix
        Flags[Progress.Flag]=v; Library:SafeCall(Progress.Callback,v)
    end
    function Progress:SetVisibility(b) Items["Row"].Instance.Visible=b end

    Progress:Set(Progress.Default)
    SetFlags[Progress.Flag]=function(v) Progress:Set(v) end
    return setmetatable(Progress, Library)
end

-- ═══════════════════════════════════════════════════════════════════════════
--                         PARAGRAPH  (new)
-- ═══════════════════════════════════════════════════════════════════════════

Library.Paragraph = function(Self, Params)
    Params = Params or {}
    local Para = {
        Title=Params.Title or Params.title or "",
        Content=Params.Content or Params.content or "",
        Section=Self, Items={},
    }
    local Parent = Params.Parent or Para.Section.Items["Content"]
    local Items  = {}

    Items["Row"] = Library:Create("Frame",{Name="\0",Parent=Parent.Instance,BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BorderSizePixel=0})
    Library:Create("Frame",{Name="\0",Parent=Items["Row"].Instance,BackgroundColor3=Library.Theme.Liner,BackgroundTransparency=0.6,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BorderSizePixel=0}):AddToTheme({BackgroundColor3="Liner"})
    Library:Create("UIListLayout",{Name="\0",Parent=Items["Row"].Instance,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
    Library:Create("UIPadding",{Name="\0",Parent=Items["Row"].Instance,PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,8)})

    if Para.Title ~= "" then
        Items["Title"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize,
            Parent=Items["Row"].Instance,TextColor3=Library.Theme.Text,Text=Para.Title,
            BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,BorderSizePixel=0}):AddToTheme({TextColor3="Text"})
    end

    Items["Body"] = Library:Create("TextLabel",{Name="\0",FontFace=Library.Font,TextSize=Library.FontSize-1,
        Parent=Items["Row"].Instance,TextColor3=Library.Theme["Dark Text"],Text=Para.Content,
        BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,LineHeight=1.4,BorderSizePixel=0}):AddToTheme({TextColor3="Dark Text"})

    Para.Items = Items
    function Para:SetContent(t) Items["Body"].Instance.Text=tostring(t) end
    function Para:SetTitle(t) if Items["Title"] then Items["Title"].Instance.Text=tostring(t) end end
    function Para:SetVisibility(b) Items["Row"].Instance.Visible=b end
    return setmetatable(Para, Library)
end

end -- close Library do block

-- ═══════════════════════════════════════════════════════════════════════════
--                            EXPORT
-- ═══════════════════════════════════════════════════════════════════════════
getgenv().Lurix   = Library
getgenv().Library = Library   -- backward compat for scripts expecting Library
return Library


