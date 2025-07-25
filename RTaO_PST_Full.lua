local RTaOLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/RTaOexe1/rtao_dev/refs/heads/main/RTaO_UI.lua"))()

if RTaOLibrary:LoadAnimation() then
	RTaOLibrary:StartLoad()
end
if RTaOLibrary:LoadAnimation() then
	RTaOLibrary:Loaded()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

local Window = RTaOLibrary:Window({
    SubTitle = "RTaO Project",
    Size = UserInputService.TouchEnabled and UDim2.new(0, 380, 0, 260) or UDim2.new(0, 500, 0, 320),
    TabWidth = 140
})

local Tab_Main = Window:Tab("Main", "rbxassetid://10723407389")
local Tab_Buy = Window:Tab("Shop", "rbxassetid://10723415335")
local Tab_Teleport = Window:Tab("Teleport", "rbxassetid://10709782497")
local Tab_Movement = Window:Tab("Movement", "rbxassetid://10734950309")
local Tab_Settings = Window:Tab("Settings", "rbxassetid://10734950309")

Tab_Main:Button("📌 Save Sand Position", function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        _G.savedPositionDC = hrp.CFrame
        RTaOLibrary:Notify("Sand Position Saved", 3)
    else
        RTaOLibrary:Notify("Cannot save position.", 3)
    end
end)

Tab_Main:Button("🌊 Save Water Position", function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        _G.savedPositionW = hrp.CFrame
        RTaOLibrary:Notify("Water Position Saved", 3)
    else
        RTaOLibrary:Notify("Cannot save position.", 3)
    end
end)

local holdingPanAutoFarm = false
local holdTimeAutoFarm = 10
local shakeAutoFarmTime = 10

Tab_Main:Toggle("Auto Farm", nil, function(state)
    holdingPanAutoFarm = state
    if state then
        task.spawn(function()
            while holdingPanAutoFarm do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                
                if _G.savedPositionDC and hrp then
                    hrp.CFrame = _G.savedPositionDC
                    task.wait(0.2)
                end

                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                local startTime = tick()
                while holdingPanAutoFarm and tick() - startTime <= holdTimeAutoFarm do
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    local collectScript = tool and tool:FindFirstChild("Scripts") and tool.Scripts:FindFirstChild("Collect")
                    if collectScript then
                        pcall(function() collectScript:InvokeServer(1) end)
                    end
                    task.wait(0)
                end
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

                if _G.savedPositionW and hrp then
                    hrp.CFrame = _G.savedPositionW
                    task.wait(0.2)
                end

                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Scripts") and tool.Scripts:FindFirstChild("Pan") then
                    pcall(function() tool.Scripts.Pan:InvokeServer() end)
                end

                local shakeStart = tick()
                while holdingPanAutoFarm and (tick() - shakeStart <= shakeAutoFarmTime) do
                    local shakeScript = tool and tool:FindFirstChild("Scripts") and tool.Scripts:FindFirstChild("Shake")
                    if shakeScript then
                        pcall(function() shakeScript:FireServer() end)
                    end
                    task.wait(0)
                end
                task.wait(1.5)
            end
        end)
    end
end)

Tab_Main:Slider("Hold Time (seconds)", 0, 100, 10, function(value)
    holdTimeAutoFarm = value
end)

Tab_Main:Slider("Shake Time (seconds)", 0, 500, 10, function(value)
    shakeAutoFarmTime = value
end)

local sellAllStep = 10

Tab_Main:Button("💸 Sell All", function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local originalCFrame = hrp.CFrame
    local function getClosestMerchant()
        local merchants = {
            workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("StarterTown") and workspace.NPCs.StarterTown:FindFirstChild("Merchant"),
            workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("RiverTown") and workspace.NPCs.RiverTown:FindFirstChild("Merchant"),
            workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Cavern") and workspace.NPCs.Cavern:FindFirstChild("Merchant")
        }
        local closest, minDist = nil, math.huge
        for _, merchant in ipairs(merchants) do
            if merchant and merchant:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - merchant.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = merchant
                end
            end
        end
        return closest
    end

    local merchant = getClosestMerchant()
    if merchant and merchant:FindFirstChild("HumanoidRootPart") then
        local dest = merchant.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        local step = sellAllStep
        local pos = hrp.Position
        local direction = (dest - pos).Unit
        local distance = (dest - pos).Magnitude

        while distance > step do
            pos = pos + direction * step
            hrp.CFrame = CFrame.new(pos, dest)
            task.wait(0.05)
            distance = (dest - pos).Magnitude
        end
        hrp.CFrame = CFrame.new(dest)
        task.wait(0.3)
    end

    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("SellAll"):InvokeServer()

    local dest = originalCFrame.Position
    local step = sellAllStep
    local pos = hrp.Position
    local direction = (dest - pos).Unit
    local distance = (dest - pos).Magnitude
    while distance > step do
        pos = pos + direction * step
        hrp.CFrame = CFrame.new(pos, dest)
        task.wait(0.05)
        distance = (dest - pos).Magnitude
    end
    hrp.CFrame = originalCFrame
end)

Tab_Main:Slider("Sell Step", 1, 50, 10, function(value)
    sellAllStep = value
end)

Tab_Main:Button("📬 Claim All Collection", function()
    local Valuables = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Valuables")
    local ClaimRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Info"):WaitForChild("ClaimCollectionReward")

    local count = 0
    for _, item in ipairs(Valuables:GetChildren()) do
        local ok = pcall(function()
            ClaimRemote:FireServer(item)
        end)
        if ok then count += 1 end
    end

    RTaOLibrary:Notify("Claimed " .. count .. " collection(s)", 3)
end)

local teleportStep = 1
local teleportStepDelay = 0
local teleportHeight = 200

local markerNames = {}
local markerLookup = {}
local depositMarkers = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("DepositMarkers")

if depositMarkers then
    local nameCount = {}
    for _, marker in ipairs(depositMarkers:GetChildren()) do
        local baseName = marker.Name
        nameCount[baseName] = (nameCount[baseName] or 0) + 1
        local displayName = baseName
        if nameCount[baseName] > 1 then
            displayName = baseName .. " " .. tostring(nameCount[baseName])
        end
        table.insert(markerNames, displayName)
        markerLookup[displayName] = marker
    end
end

-- UI Dropdown Teleport
Tab_Teleport:Dropdown("Teleport to Marker", markerNames, nil, function(selected)
    local marker = markerLookup[selected]
    if not marker then return end

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local function stepTeleport(fromPos, toPos)
        local pos = fromPos
        local dir = (toPos - pos).Unit
        local dist = (toPos - pos).Magnitude
        local lastFreeze = tick()

        while dist > teleportStep do
            pos = pos + dir * teleportStep
            hrp.CFrame = CFrame.new(pos)
            task.wait(teleportStepDelay)

            if tick() - lastFreeze >= 0.5 then
                hrp.Anchored = true
                task.wait(0.5)
                hrp.Anchored = false
                lastFreeze = tick()
            end
            dist = (toPos - pos).Magnitude
        end
        hrp.CFrame = CFrame.new(toPos)
    end

    local startPos = hrp.Position
    local dest = marker.Position + Vector3.new(0, 5, 0)
    local upPos = Vector3.new(startPos.X, startPos.Y + teleportHeight, startPos.Z)
    local destUp = Vector3.new(dest.X, upPos.Y, dest.Z)

    stepTeleport(startPos, upPos)
    task.wait(teleportStepDelay)

    stepTeleport(upPos, destUp)
    task.wait(teleportStepDelay)

    stepTeleport(destUp, dest)

    RTaOLibrary:Notify("Teleported to " .. selected, 2)
end)

Tab_Teleport:Slider("Step Size", 1, 50, 1, function(value)
    teleportStep = value
end)

Tab_Teleport:Slider("Step Delay", 0, 5, 0, function(value)
    teleportStepDelay = value
end)

-- Walkspeed
Tab_Movement:Slider("Walk Speed", 0, 100, 16, function(value)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = value
    end
end)

-- Jump Power
Tab_Movement:Slider("Jump Power", 50, 200, 50, function(value)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = value
    end
end)

-- Gravity
Tab_Movement:Slider("Gravity", 0, 999, workspace.Gravity, function(value)
    workspace.Gravity = value
end)

-- Field of View
Tab_Movement:Slider("Camera FOV", 20, 120, Camera.FieldOfView, function(value)
    Camera.FieldOfView = value
end)

-- Infinite Jump
local infJump = false
Tab_Movement:Toggle("Infinite Jump", nil, function(state)
    infJump = state
end)

UserInputService.JumpRequest:Connect(function()
    if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip
local noclip = false
Tab_Movement:Toggle("Noclip", nil, function(state)
    noclip = state
end)

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Fly
local fly = false
local flySpeed = 50

Tab_Movement:Slider("Fly Speed", 10, 999, 50, function(value)
    flySpeed = value
end)

Tab_Movement:Toggle("Fly", nil, function(state)
    fly = state
end)

RunService.RenderStepped:Connect(function()
    if fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local direction = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then direction += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then direction -= Vector3.new(0, 1, 0) end

        hrp.Velocity = direction * flySpeed
    end
end)

Tab_Movement:Button("🔄 Reset Player", function()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        workspace.Gravity = 196.2
        Camera.FieldOfView = 70
        RTaOLibrary:Notify("Player reset complete", 2)
    end
end)

-- Buy Pan
local panDisplay = {
    "Rusty Pan [Initial Pan, No Buy]",
    "Plastic Pan [$ 500]",
    "Metal Pan [$ 12,000]",
    "Silver Pan [$ 50,000]",
    "Golden Pan [$ 333,000]",
    "Magnetic Pan [$ 1,000,000]",
    "Meteoric Pan [$ 3,500,000]",
    "Diamond Pan [$ 10,000,000]"
}
local panMap = {
    ["Rusty Pan [Initial Pan, No Buy]"] = "Rusty Pan",
    ["Plastic Pan [$ 500]"] = "Plastic Pan",
    ["Metal Pan [$ 12,000]"] = "Metal Pan",
    ["Silver Pan [$ 50,000]"] = "Silver Pan",
    ["Golden Pan [$ 333,000]"] = "Golden Pan",
    ["Magnetic Pan [$ 1,000,000]"] = "Magnetic Pan",
    ["Meteoric Pan [$ 3,500,000]"] = "Meteoric Pan",
    ["Diamond Pan [$ 10,000,000]"] = "Diamond Pan"
}

Tab_Buy:Dropdown("Buy Pan", panDisplay, nil, function(selected)
    local name = panMap[selected]
    if name == "Rusty Pan" then
        RTaOLibrary:Notify("Cannot buy initial pan", 3)
        return
    end

    local found
    local purchasable = workspace:FindFirstChild("Purchasable")
    if purchasable then
        for _, area in ipairs(purchasable:GetChildren()) do
            found = area:FindFirstChild(name)
            if found and found:FindFirstChild("ShopItem") then break end
        end
    end

    if found then
        ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(found.ShopItem)
        RTaOLibrary:Notify("Purchased: " .. selected, 3)
    else
        RTaOLibrary:Notify("Item not found: " .. selected, 3)
    end
end)

local shovelDisplay = {
    "Rusty Shovel [Initial Shovel, No Buy]",
    "Iron Shovel [$ 3,000]",
    "Steel Shovel [$ 25,000]",
    "Silver Shovel [$ 75,000]",
    "Reinforced Shovel [$ 135,000]",
    "The Excavator [$ 320,000]",
    "Golden Shovel [$ 1,333,000]",
    "Meteoric Shovel [$ 4,000,000]",
    "Diamond Shovel [$ 12,500,000]"
}
local shovelMap = {}
for _, name in ipairs(shovelDisplay) do
    shovelMap[name] = name:match("^(.-) %[") or name
end

Tab_Buy:Dropdown("Buy Shovel", shovelDisplay, nil, function(selected)
    local name = shovelMap[selected]
    if name == "Rusty Shovel" then
        RTaOLibrary:Notify("Cannot buy initial shovel", 3)
        return
    end

    local found
    local purchasable = workspace:FindFirstChild("Purchasable")
    if purchasable then
        for _, area in ipairs(purchasable:GetChildren()) do
            found = area:FindFirstChild(name)
            if found and found:FindFirstChild("ShopItem") then break end
        end
    end

    if found then
        ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(found.ShopItem)
        RTaOLibrary:Notify("Purchased: " .. selected, 3)
    else
        RTaOLibrary:Notify("Item not found: " .. selected, 3)
    end
end)

local sluiceDisplay = {
    "Wood Sluice Box [$ 5,000]",
    "Steel Sluice Box [$100,000]",
    "Gold Sluice Box [$ 655,000]",
    "Obsidian Sluice Box [$ 4,000,000]",
    "Enchanted Sluice Box [$ 12,000,000]"
}
local sluiceMap = {}
for _, name in ipairs(sluiceDisplay) do
    sluiceMap[name] = name:match("^(.-) %[") or name
end

Tab_Buy:Dropdown("Buy Sluice Box", sluiceDisplay, nil, function(selected)
    local name = sluiceMap[selected]
    local found
    local purchasable = workspace:FindFirstChild("Purchasable")
    if purchasable then
        for _, area in ipairs(purchasable:GetChildren()) do
            found = area:FindFirstChild(name)
            if found and found:FindFirstChild("ShopItem") then break end
        end
    end

    if found then
        ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(found.ShopItem)
        RTaOLibrary:Notify("Purchased: " .. selected, 3)
    else
        RTaOLibrary:Notify("Item not found: " .. selected, 3)
    end
end)

local potionDisplay = {
    "Basic Capacity Potion [$ 40,000]",
    "Basic Luck Potion [$ 50,000]",
    "Greater Capacity Potion [20 S]",
    "Greater Luck Potion [30 S]",
    "Merchant's Potion [200 S]"
}
local potionMap = {}
for _, name in ipairs(potionDisplay) do
    potionMap[name] = name:match("^(.-) %[") or name
end
local selectedPotion = nil

Tab_Buy:Dropdown("Buy Potion", potionDisplay, nil, function(selected)
    local name = potionMap[selected]
    selectedPotion = name
    local found
    local purchasable = workspace:FindFirstChild("Purchasable")
    if purchasable then
        for _, area in ipairs(purchasable:GetChildren()) do
            found = area:FindFirstChild(name)
            if found and found:FindFirstChild("ShopItem") then break end
        end
    end

    if found then
        ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(found.ShopItem)
        RTaOLibrary:Notify("Purchased: " .. selected, 3)
    else
        RTaOLibrary:Notify("Item not found: " .. selected, 3)
    end
end)

Tab_Buy:Button("🧪 Buy Potion Again", function()
    if not selectedPotion then
        RTaOLibrary:Notify("Select a potion first!", 2)
        return
    end

    local found
    local purchasable = workspace:FindFirstChild("Purchasable")
    if purchasable then
        for _, area in ipairs(purchasable:GetChildren()) do
            found = area:FindFirstChild(selectedPotion)
            if found and found:FindFirstChild("ShopItem") then break end
        end
    end

    if found then
        ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(found.ShopItem)
        RTaOLibrary:Notify("Purchased again: " .. selectedPotion, 3)
    end
end)

local totemDisplay = {
    "Strength Totem [$ 180,000]",
    "Luck Totem [$ 300,000]"
}
local totemMap = {}
for _, name in ipairs(totemDisplay) do
    totemMap[name] = name:match("^(.-) %[") or name
end
local selectedTotem = nil

Tab_Buy:Dropdown("Buy Totem", totemDisplay, nil, function(selected)
    local name = totemMap[selected]
    selectedTotem = name
    local found
    local purchasable = workspace:FindFirstChild("Purchasable")
    if purchasable then
        local riverTown = purchasable:FindFirstChild("RiverTown")
        if riverTown then
            found = riverTown:FindFirstChild(name)
        end
    end

    if found and found:FindFirstChild("ShopItem") then
        ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(found.ShopItem)
        RTaOLibrary:Notify("Purchased: " .. selected, 3)
    else
        RTaOLibrary:Notify("Item not found: " .. selected, 3)
    end
end)

Tab_Buy:Button("🗿 Buy Totem Again", function()
    if not selectedTotem then
        RTaOLibrary:Notify("Select a totem first!", 2)
        return
    end

    local found
    local purchasable = workspace:FindFirstChild("Purchasable")
    if purchasable then
        local riverTown = purchasable:FindFirstChild("RiverTown")
        if riverTown then
            found = riverTown:FindFirstChild(selectedTotem)
        end
    end

    if found and found:FindFirstChild("ShopItem") then
        ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(found.ShopItem)
        RTaOLibrary:Notify("Purchased again: " .. selectedTotem, 3)
    end
end)

-- ฟังก์ชัน Craft Item
local function craft(itemName)
    ReplicatedStorage.Remotes.Crafting.Craft:FireServer(itemName)
    RTaOLibrary:Notify("Requested Craft: " .. itemName, 2)
end

-- UI Section
Tab_Buy:Line()
Tab_Buy:Label("🔨 Craft Equipment")

-- ปุ่ม Craft แต่ละอัน
Tab_Buy:Button("🛠️ Craft T2 Pan", function()
    craft("T2 Pan")
end)

Tab_Buy:Button("🛠️ Craft T3 Pan", function()
    craft("T3 Pan")
end)

Tab_Buy:Button("🛠️ Craft T4 Pan", function()
    craft("T4 Pan")
end)

Tab_Buy:Button("🛠️ Craft T5 Pan", function()
    craft("T5 Pan")
end)

Tab_Buy:Button("🛠️ Craft T6 Pan", function()
    craft("T6 Pan")
end)

Tab_Buy:Button("🛠️ Craft T7 Pan", function()
    craft("T7 Pan")
end)

Tab_Buy:Button("🛠️ Craft T8 Pan", function()
    craft("T8 Pan")
end)

-- เพิ่มเติม: ปุ่ม Craft รวมแบบเร็ว
Tab_Buy:Button("⚙️ Craft All Available", function()
    local tiers = { "T2 Pan", "T3 Pan", "T4 Pan", "T5 Pan", "T6 Pan", "T7 Pan", "T8 Pan" }
    for _, tier in ipairs(tiers) do
        task.spawn(function()
            craft(tier)
        end)
        task.wait(0.3)
    end
end)
