--made by RTaO 
if not getgenv().shared then
    getgenv().shared = {}
end

if not getgenv().voidware_loaded then
    getgenv().voidware_loaded = true
else
    local suc = pcall(function()
        shared.Voidware_InkGame_Library:Unload()
    end)
    if not suc then
        return 
    end
end

local isNew = false
pcall(function()
    if not isfolder("voidware_linoria") then makefolder("voidware_linoria"); isNew = true; end
    for _, v in pairs({"voidware_linoria/ink_game", "voidware_linoria/themes"}) do
        if not isfolder(v) then makefolder(v); isNew = true; end
    end
    for _, v in pairs({"voidware_linoria/ink_game/settings", "voidware_linoria/ink_game/themes"}) do
        if not isfolder(v) then makefolder(v); isNew = true; end
    end

    if isNew then
        writefile("voidware_linoria/themes/default.txt", "Jester")
        local suc = pcall(function()
            writefile("voidware_linoria/ink_game/settings/default.json", game:HttpGet("https://raw.githubusercontent.com/Erchobg/VoidwareProfiles/refs/heads/main/InkGame/ink_game/settings/default.json", true))
        end)
        if suc then
            writefile("voidware_linoria/ink_game/settings/autoload.txt", "default")
        end
    end
end)

task.spawn(function()
    pcall(function()
        if not isfile("Local_VW_Update_Log.json") then
            shared.UpdateLogBypass = true
        end
		loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWExtra/main/VWUpdateLog.lua", true))()
        shared.UpdateLogBypass = nil
    end)
end)

local allowedlibs = {"Obsidian", "LinoriaLib"}
local default = "Obsidian"
local function getLibrary()
    local res = default
    if not isfile("Voidware_InkGame_Library_Choice.txt") then
        writefile("Voidware_InkGame_Library_Choice.txt", res)
    else
        local suc, opt = pcall(function()
            return readfile("Voidware_InkGame_Library_Choice.txt")
        end)
        if suc then
            res = tostring(opt)
        end
    end

    if not table.find(allowedlibs, res) then
        res = defaut
    end
    writefile("Voidware_InkGame_Library_Choice.txt", res)
    return res
end

local suc, targetlib = pcall(getLibrary)
if not suc then
    targetlib = default
end

--// Library \\--
local repo = "https://raw.githubusercontent.com/mstudio45/"..tostring(targetlib).."/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
shared.Voidware_InkGame_Library = Library
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options
local Toggles
if targetlib == "Obsidian" then
    Options = getgenv().Library.Options
    Toggles = getgenv().Library.Toggles
else 
    Options = getgenv().Linoria.Options
    Toggles = getgenv().Linoria.Toggles   
end

local Window = Library:CreateWindow({
	Title = "RTaO HUB ",
    Footer = "https://discord.com",
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	TabPadding = 2,
	MenuFadeTime = 0
})

local Tabs = {
    Main = Window:AddTab("Main", "gamepad-2"),
    Other = Window:AddTab("Other", "settings"),
    Misc = Window:AddTab("Misc", "wrench"),
    Visuals = Window:AddTab("Visuals", "eye"),
    ["UI Settings"] = Window:AddTab("UI Settings", "sliders-horizontal"),
}

local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({Tasks = {}}, Maid)
end

function Maid:Add(task)
    if typeof(task) == "RBXScriptConnection" or (typeof(task) == "Instance" and task.Destroy) or typeof(task) == "function" then
        table.insert(self.Tasks, task)
    end
    return task
end

function Maid:Clean()
    for _, task in ipairs(self.Tasks) do
		pcall(function()
			if typeof(task) == "RBXScriptConnection" then
				task:Disconnect()
			elseif typeof(task) == "Instance" then
				task:Destroy()
			elseif typeof(task) == "function" then
				task()
			end
		end)
    end
	table.clear(self.Tasks)
    self.Tasks = {}
end

local Services = setmetatable({}, {
	__index = function(self, key)
		local suc, service = pcall(game.GetService, game, key)
		if suc and service then
			self[key] = service
			return service
		else
			warn(`[Services] Warning: "{key}" is not a valid Roblox service.`)
			return nil
		end
	end
})

local SharedFunctions = {}

function SharedFunctions.GetBoosts(arg1, arg2, arg3)
    local boosts = arg1 and arg1:FindFirstChild("Boosts")
    if boosts then
        local boostVal = boosts:FindFirstChild(arg2)
        if boostVal then
            if arg2 == "Faster Sprint" then
                return 1.5 * boostVal.Value
            elseif arg2 == "Damage Boost" then
                return 0.1 * boostVal.Value
            else
                return 0.1 * boostVal.Value
            end
        end
    end
    return 0
end

function SharedFunctions.Invisible(arg1, arg2, arg3)
    for _, part in ipairs(arg1:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if arg2 == 1 then
                part.Transparency = 1
            else
                part.Transparency = 1
            end
            if arg3 then
                part.CanCollide = false
            end
        end
    end
end

function SharedFunctions.CreateFolder(parent, name, lifetime, opts)
    local Folder = Instance.new("Folder")
    Folder.Name = name
    if opts then
        if opts.ObjectValue then
            Folder.Value = opts.ObjectValue
        end
        if opts.Attributes then
            for k, v in pairs(opts.Attributes) do
                Folder:SetAttribute(k, v)
            end
        end
    end
    Folder.Parent = parent
    if lifetime then
        task.delay(lifetime, function()
            if Folder and Folder.Parent then
                Folder:Destroy()
            end
        end)
    end
    return Folder
end

local Players = Services.Players
local Lighting = Services.Lighting
local RunService = Services.RunService
local HttpService = Services.HttpService
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local ProximityPromptService = Services.ProximityPromptService

local lplr = Players.LocalPlayer
local localPlayer = lplr

local camera = workspace.CurrentCamera

type ESP = {
    Color: Color3,
    IsEntity: boolean,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
}

local Script = {
    GameStateChanged = Instance.new("BindableEvent"),
    GameState = "unknown",
    Services = Services,
    Maid = Maid.new(),
    Connections = {},
    Functions = {},
    ESPTable = {
        Player = {},
        Seeker = {},
        Hider = {},
        Guard = {},
        Door = {},
        None = {},
        Key = {},
        EscapeDoor = {}
    },
    Temp = {}
}

local States = {}

function Script.Functions.Alert(message: string, time_obj: number)
    Library:Notify(message, time_obj or 5)

    --if TogglesNotifySound..Value then
        local sound = Instance.new("Sound", workspace) do
            sound.SoundId = "rbxassetid://4590662766"
            sound.Volume = 2
            sound.PlayOnRemove = true
            sound:Destroy()
        end
    --end
end

function Script.Functions.Warn(message: string)
    warn("WARN - voidware:", message)
end

function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        TextParent = args.TextParent,
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        Type = args.Type or "None",

        Highlights = {},
        Humanoid = nil,
        RSConnection = nil,

        Connections = {}
    }

    local tableIndex = #Script.ESPTable[ESPManager.Type] + 1

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart.Transparency == 1 then
        ESPManager.Object:SetAttribute("Transparency", ESPManager.Object.PrimaryPart.Transparency)
        ESPManager.Humanoid = Instance.new("Humanoid", ESPManager.Object)
        ESPManager.Object.PrimaryPart.Transparency = 0.99
    end

    local highlight = Instance.new("Highlight") do
        highlight.Adornee = ESPManager.Object
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = ESPManager.Color
        highlight.FillTransparency = Options.ESPFillTransparency.Value
        highlight.OutlineColor = ESPManager.Color
        highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
        highlight.Enabled = Toggles.ESPHighlight.Value
        highlight.Parent = ESPManager.Object
    end

    table.insert(ESPManager.Highlights, highlight)
    

    local billboardGui = Instance.new("BillboardGui") do
        billboardGui.Adornee = ESPManager.TextParent or ESPManager.Object
		billboardGui.AlwaysOnTop = true
		billboardGui.ClipsDescendants = false
		billboardGui.Size = UDim2.new(0, 1, 0, 1)
		billboardGui.StudsOffset = ESPManager.Offset
        billboardGui.Parent = ESPManager.TextParent or ESPManager.Object
	end

    local textLabel = Instance.new("TextLabel") do
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Oswald
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.Text = ESPManager.Text
		textLabel.TextColor3 = ESPManager.Color
		textLabel.TextSize = Options.ESPTextSize.Value
        textLabel.TextStrokeColor3 = .new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.75
        textLabel.Parent = billboardGui
	end

    function ESPManager.SetColor(newColor: Color3)
        ESPManager.Color = newColor

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight.FillColor = newColor
            highlight.OutlineColor = newColor
        end

        textLabel.TextColor3 = newColor
    end

    function ESPManager.Destroy()
        if ESPManager.RSConnection then
            ESPManager.RSConnection:Disconnect()
        end

        if ESPManager.IsEntity and ESPManager.Object then
            if ESPManager.Object.PrimaryPart then
                ESPManager.Object.PrimaryPart.Transparency = ESPManager.Object.PrimaryPart:GetAttribute("Transparency")
            end
            if ESPManager.Humanoid then
                ESPManager.Humanoid:Destroy()
            end
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight:Destroy()
        end
        if billboardGui then billboardGui:Destroy() end

        if Script.ESPTable[ESPManager.Type][tableIndex] then
            Script.ESPTable[ESPManager.Type][tableIndex] = nil
        end

        for _, conn in pairs(ESPManager.Connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        ESPManager.Connections = {}
    end

    ESPManager.RSConnection = RunService.RenderStepped:Connect(function()
        if not ESPManager.Object or not ESPManager.Object:IsDescendantOf(workspace) then
            ESPManager.Destroy()
            return
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight.Enabled = Toggles.ESPHighlight.Value
            highlight.FillTransparency = Options.ESPFillTransparency.Value
            highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
        end
        textLabel.TextSize = Options.ESPTextSize.Value

        if Toggles.ESPDistance.Value then
            textLabel.Text = string.format("%s\n[%s]", ESPManager.Text, math.floor(Script.Functions.DistanceFromCharacter(ESPManager.Object)))
        else
            textLabel.Text = ESPManager.Text
        end
    end)

    function ESPManager.GiveSignal(signal)
        table.insert(ESPManager.Connections, signal)
    end

    Script.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end

function Script.Functions.SeekerESP(player : Player)
    if player:GetAttribute("IsHunter") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local esp = Script.Functions.ESP({
            Object = player.Character,
            Text = player.Name .. " (Seeker)",
            Color = Options.SeekerEspColor.Value,
            Offset = Vector3.new(0, 3, 0),
            Type = "Seeker"
        })
    end
end

function Script.Functions.HiderESP(player : Player)
    if player:GetAttribute("IsHider") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local esp = Script.Functions.ESP({
            Object = player.Character,
            Text = player.Name .. " (Hider)", 
            Color = Options.HiderEspColor.Value,
            Offset = Vector3.new(0, 3, 0),
            Type = "Hider"
        })
        player:GetAttributeChangedSignal("IsHider"):Once(function()
            if not player:GetAttribute("IsHider") then
                esp.Destroy()
            end
        end)
    end
end

function Script.Functions.KeyESP(key)
    if key:IsA("Model") and key.PrimaryPart then
        local esp = Script.Functions.ESP({
            Object = key,
            Text = key.Name .. " (Key)",
            Color = Options.KeyEspColor.Value,
            Offset = Vector3.new(0, 1, 0),
            Type = "Key",
            IsEntity = true
        })
    end
end

function Script.Functions.DoorESP(door)
    if door:IsA("Model") and door.Name == "FullDoorAnimated" and door.PrimaryPart then
        local keyNeeded = door:GetAttribute("KeyNeeded") or "None"
        local esp = Script.Functions.ESP({
            Object = door,
            Text = "Door (Key: " .. keyNeeded .. ")",
            Color = Options.DoorEspColor.Value,
            Offset = Vector3.new(0, 2, 0),
            Type = "Door",
            IsEntity = true
        })
    end
end

function Script.Functions.EscapeDoorESP(door)
    if door:IsA("Model") and door.Name == "EXITDOOR" and door.PrimaryPart and door:GetAttribute("CANESCAPE") then
        local esp = Script.Functions.ESP({
            Object = door,
            Text = "Escape Door",
            Color = Options.EscapeDoorEspColor.Value,
            Offset = Vector3.new(0, 2, 0),
            Type = "EscapeDoor",
            IsEntity = true
        })
    end
end

function Script.Functions.GuardESP(character)
    if character and character:FindFirstChild("HumanoidRootPart") then
        local esp = Script.Functions.ESP({
            Object = character,
            Text = "Guard",
            Color = Options.GuardEspColor.Value,
            Offset = Vector3.new(0, 3, 0),
            Type = "Guard"
        })
        table.insert(esp.Connections, character.ChildAdded:Connect(function(v)
            if v.Name == "Dead" and v.ClassName == "Folder" then
                esp.Destroy()
            end
        end))
    end
end

function Script.Functions.PlayerESP(player: Player)
    if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end

    local playerEsp = Script.Functions.ESP({
        Type = "Player",
        Object = player.Character,
        Text = string.format("%s [%s]", player.DisplayName, player.Character.Humanoid.Health),
        TextParent = player.Character.PrimaryPart,
        Color = Options.PlayerEspColor.Value
    })

    playerEsp.GiveSignal(player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth > 0 then
            playerEsp.Text = string.format("%s [%s]", player.DisplayName, newHealth)
        else
            playerEsp.Destroy()
        end
    end))
end

Script.Functions.SafeRequire = function(module)
    if Script.Temp[tostring(module)] then return Script.Temp[tostring(module)] end
    local suc, err = pcall(function()
        return require(module)
    end)
    if not suc then
        warn("[SafeRequire]: Failure loading "..tostring(module).." ("..tostring(err)..")")
    else
        Script.Temp[tostring(module)] = err
    end
    return suc and err
end

Script.Functions.ExecuteClick = function()
    local args = {
        "Clicked"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Replication"):WaitForChild("Event"):FireServer(unpack(args))    
end

Script.Functions.CompleteDalgonaGame = function()
    Script.Functions.ExecuteClick()
    local args = {
        {
            Completed = true
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DALGONATEMPREMPTE"):FireServer(unpack(args))

    local args = {
        {
            Success = true
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DALGONATEMPREMPTE"):FireServer(unpack(args))
end

Script.Functions.PullRope = function(perfect)
    local args = {
        {
            PerfectQTE = true
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable"):FireServer(unpack(args))
end

function Script.Functions.RevealGlassBridge()
    local Effects = Script.Functions.SafeRequire(ReplicatedStorage.Modules.Effects) or {
        AnnouncementTween = function(args)
            Script.Functions.Alert(args.AnnouncementDisplayText, args.DisplayTime)
        end
    }

    local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then
        warn("GlassHolder not found in workspace.GlassBridge")
        return
    end

    for _, tilePair in pairs(glassHolder:GetChildren()) do
        for _, tileModel in pairs(tilePair:GetChildren()) do
            if tileModel:IsA("Model") and tileModel.PrimaryPart then
                local primaryPart = tileModel.PrimaryPart
                for _, child in ipairs(tileModel:GetChildren()) do
                    if child:IsA("Highlight") then
                        child:Destroy()
                    end
                end
                local isBreakable = primaryPart:GetAttribute("exploitingisevil") == true

                local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                local transparency = 0.5

                for _, part in pairs(tileModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
                            Transparency = transparency,
                            Color = targetColor
                        }):Play()
                    end
                end

                local highlight = Instance.new("Highlight")
                highlight.FillColor = targetColor
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0.5
                highlight.Parent = tileModel
            end
        end
    end

    Effects.AnnouncementTween({
        AnnouncementOneLine = true,
        FasterTween = true,
        DisplayTime = 10,
        AnnouncementDisplayText = "[Voidware]: Safe tiles are green, breakable tiles are red!"
    })
end

local EffectsModule
Script.Functions.OnLoad = function()
    EffectsModule = EffectsModule or Script.Functions.SafeRequire(ReplicatedStorage.Modules.Effects) or {
        AnnouncementTween = function(args)
            Script.Functions.Alert(args.AnnouncementDisplayText, args.DisplayTime)
        end
    }

    Script.Functions.EffectsNotification("Voidware - Ink Game loaded!", 5)
    Script.Functions.EffectsNotification("Join discord.gg/voidware for updates :)", 5)
end

function Script.Functions.EffectsNotification(text, dur)
    EffectsModule = EffectsModule or Script.Functions.SafeRequire(ReplicatedStorage.Moire(ReplicatedStorage.Mo