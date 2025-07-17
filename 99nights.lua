-- Load RedzLib library
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()

-- Main Window
local Window = redzlib:MakeWindow({
    Title = "RTaO HUB",
    SubTitle = "by RTaO",
    SaveFolder = "RTaOHubUniversal"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://100006760882280", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(0, 6) },
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(chr)
    character = chr
    humanoid = chr:WaitForChild("Humanoid")
end)

-- 📱 Discord Tab
local TabDiscord = Window:MakeTab({
    Title = "Discord",
    Icon = "rbxassetid://84198990394879"
})

TabDiscord:AddSection("Discord")

TabDiscord:AddDiscordInvite({
    Name = "Info",
    Description = "Discord link",
    Logo = "rbxassetid://88800066762467",
    Invite = "https://discord.com"
})

-- 🛠️ Main Tab
local TabMain = Window:MakeTab({
    Title = "Main",
    Icon = "rbxassetid://106319096400681"
})
TabMain:AddSection("Main")

-- 🔥 Teleport to bonfire at night
local bonfirePosition = Vector3.new(0.32, 6.15, -0.22)
local teleportEnabled = false
local teleportConnection = nil

TabMain:AddToggle({
    Name = "Teleport to the bonfire at night",
    Default = false,
    Callback = function(value)
        teleportEnabled = value
        
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
        
        if value then
            teleportConnection = RunService.Heartbeat:Connect(function()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    if Lighting.ClockTime >= 18 or Lighting.ClockTime <= 6 then
                        local hrp = character.HumanoidRootPart
                        hrp.CFrame = CFrame.new(bonfirePosition)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        end
    end
})

-- 🕴 Infinite Jump
local infiniteJump = false
local jumpConnection = nil

TabMain:AddToggle({
    Name = "Infinite jump",
    Default = false,
    Callback = function(value)
        infiniteJump = value
        
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
        
        if value then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if infiniteJump and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

-- 🏃‍♂️ Speed Control
local speedEnabled = false
local currentSpeed = 16
local speedConnection = nil

TabMain:AddToggle({
    Name = "Enable Speed",
    Default = false,
    Callback = function(value)
        speedEnabled = value
        
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        
        if value and humanoid then
            humanoid.WalkSpeed = currentSpeed
            speedConnection = RunService.Heartbeat:Connect(function()
                if humanoid and speedEnabled then
                    humanoid.WalkSpeed = currentSpeed
                end
            end)
        elseif humanoid then
            humanoid.WalkSpeed = 16 -- Default speed
        end
    end
})

TabMain:AddSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 1000,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        currentSpeed = value
        if speedEnabled and humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

-- No Clip
local noclipEnabled = false
local noclipConnection = nil

local function noclipLoop()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

TabMain:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
        
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        if value then
            noclipConnection = RunService.Stepped:Connect(noclipLoop)
        end
    end
})

-- No Fall Damage
local noFallDamageEnabled = false
local originalStateChanged

TabMain:AddToggle({
    Name = "No Fall Damage",
    Default = false,
    Callback = function(value)
        noFallDamageEnabled = value
        
        if value then
            originalStateChanged = humanoid.StateChanged
            
            humanoid.StateChanged:Connect(function(_, newState)
                if newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.PlatformStanding then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
        else
            if originalStateChanged then
                humanoid.StateChanged = originalStateChanged
            end
        end
    end
})

-- 📦 Bring Tab
local TabBring = Window:MakeTab({
    Title = "Bring",
    Icon = "rbxassetid://126235770836058"  -- Custom icon ID
})
TabBring:AddSection("Bring Items")

local function bringItems(itemName, offsetY)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local offset = 0
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") and item.Name == itemName then
            local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if part then
                item:SetPrimaryPartCFrame(root.CFrame * CFrame.new(offset, offsetY or 2, 0))
                offset = offset + 2
                task.wait(0.1)
            end
        end
    end
end

TabBring:AddButton({
    Name = "Bring all Logs",
    Callback = function()
        bringItems("Log")
    end
})

TabBring:AddButton({
    Name = "Bring all Coal",
    Callback = function()
        bringItems("Coal")
    end
})

TabBring:AddButton({
    Name = "Bring all Fuel",
    Callback = function()
        bringItems("Fuel Canister")
    end
})

-- 🛡️ Defense Tab
local TabDefense = Window:MakeTab({
    Title = "Defense",
    Icon = "rbxassetid://90617532970599"  -- Custom icon ID
})
TabDefense:AddSection("Defense")

-- God Mode
local godModeEnabled = false

TabDefense:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(value)
        godModeEnabled = value
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:SetAttribute("GodMode", value)
            end
        end
    end
})

-- No Animal Aggro
local noAggroEnabled = false
local noAggroConnection = nil

TabDefense:AddToggle({
    Name = "No Animal Aggression",
    Default = false,
    Callback = function(value)
        noAggroEnabled = value
        
        if noAggroConnection then
            noAggroConnection:Disconnect()
            noAggroConnection = nil
        end
        
        if value then
            noAggroConnection = RunService.Heartbeat:Connect(function()
                if character then
                    for _, npc in ipairs(workspace:GetDescendants()) do
                        if npc:IsA("Model") and (npc.Name:find("Wolf") or npc.Name:find("Bunny")) then
                            local humanoid = npc:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                humanoid:SetAttribute("IgnorePlayer", true)
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- 👁️ Visual Tab
local TabVisual = Window:MakeTab({
    Title = "Visual",
    Icon = "rbxassetid://117867833889560"  -- Custom icon ID
})
TabVisual:AddSection("Visual")

-- Brightness Boost
local brightnessEnabled = false
local originalBrightness = Lighting.Brightness

TabVisual:AddToggle({
    Name = "Brightness Boost",
    Default = false,
    Callback = function(value)
        brightnessEnabled = value
        if value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
        else
            Lighting.Brightness = originalBrightness
        end
    end
})

-- Fullbright
local fullbrightEnabled = false

TabVisual:AddToggle({
    Name = "Fullbright",
    Default = false,
    Callback = function(value)
        fullbrightEnabled = value
        if value then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.GlobalShadows = true
        end
    end
})

-- FOV Changer
local fovEnabled = false
local currentFOV = 70
local fovConnection = nil

TabVisual:AddToggle({
    Name = "FOV Changer",
    Default = false,
    Callback = function(value)
        fovEnabled = value
        
        if fovConnection then
            fovConnection:Disconnect()
            fovConnection = nil
        end
        
        if value then
            fovConnection = RunService.RenderStepped:Connect(function()
                if workspace.CurrentCamera then
                    workspace.CurrentCamera.FieldOfView = currentFOV
                end
            end)
        elseif workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = 70
        end
    end
})

TabVisual:AddSlider({
    Name = "FOV Value",
    Min = 70,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "FOV",
    Callback = function(value)
        currentFOV = value
        if fovEnabled and workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = value
        end
    end
})

-- 🗺️ Map Tab
local TabMap = Window:MakeTab({
    Title = "Map",
    Icon = "rbxassetid://105948035084832"  -- Custom icon ID
})
TabMap:AddSection("Map")

-- Teleport Waypoints
local waypoints = {
    ["Bonfire"] = CFrame.new(0.32, 6.15, -0.22),
    ["Cabin"] = CFrame.new(-100, 5, 50), -- Adjust coordinates as needed
    ["River"] = CFrame.new(150, 3, -200) -- Adjust coordinates as needed
}

for name, cf in pairs(waypoints) do
    TabMap:AddButton({
        Name = "Teleport to "..name,
        Callback = function()
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = cf
            end
        end
    })
end

-- Cleanup on script termination
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        if teleportConnection then teleportConnection:Disconnect() end
        if jumpConnection then jumpConnection:Disconnect() end
        if speedConnection then speedConnection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
        if noAggroConnection then noAggroConnection:Disconnect() end
        if fovConnection then fovConnection:Disconnect() end
        
        -- Reset visual changes
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.GlobalShadows = true
        
        if workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = 70
        end
        
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end)