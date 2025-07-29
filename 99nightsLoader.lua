repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui") 

for _, url in ipairs{
	"https://raw.githubusercontent.com/Lucasggk/BlueLock/refs/heads/main/Fix.name.ui.lua",
	"https://raw.githubusercontent.com/Lucasggk/99Nights/main/Functions/Bring.lua",
	"https://raw.githubusercontent.com/Lucasggk/99Nights/main/Functions/Bringc.lua",
	"https://raw.githubusercontent.com/Lucasggk/99Nights/main/Functions/Esp.lua",
	"https://raw.githubusercontent.com/Lucasggk/99Nights/main/Functions/No%20void.lua"
} do
	loadstring(game:HttpGet(url, true))()
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "99 Nights In The Forest |",
    SubTitle = " By RTaODev| 0.1",
    TabWidth = 180,
    Size = UDim2.fromOffset(600, 350),
    Acrylic = false,
    Theme = "Dark",
    Center = true,
    IsDraggable = true,
    Keybind = Enum.KeyCode.LeftControl
})

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local decalId = "rbxassetid://122755768466240"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DraggableImageButtonGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local imageButton = Instance.new("ImageButton")
imageButton.Name = "DraggableButton"
imageButton.Image = decalId
imageButton.Size = UDim2.new(0, 65, 0, 65)
imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
imageButton.Position = UDim2.new(0, 15, 0, 10)
imageButton.BackgroundTransparency = 0
imageButton.AutoButtonColor = false
imageButton.Parent = screenGui

local dragging, dragInput, mousePos, buttonPos = false

imageButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging, mousePos, buttonPos = true, input.Position, imageButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

imageButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		imageButton.Position = UDim2.new(
			buttonPos.X.Scale, buttonPos.X.Offset + delta.X,
			buttonPos.Y.Scale, buttonPos.Y.Offset + delta.Y
		)
	end
end)

imageButton.MouseButton1Click:Connect(function()
	Window:Minimize()
end)

local gui = Fluent.GUI
local playerGui = player.PlayerGui

if _G.fluentLoopRunning then
    _G.fluentLoopRunning = _G.fluentLoopRunning + 1
else
    _G.fluentLoopRunning = 1
end
local runId = _G.fluentLoopRunning

task.spawn(function()
    while gui and gui:IsDescendantOf(game) do
        if _G.fluentLoopRunning ~= runId then break end
        task.wait(0.05)
    end
    if _G.fluentLoopRunning == runId then
        local drag = playerGui:FindFirstChild("DraggableImageButtonGui")
        if drag then drag.Enabled = true end
    end
end)

task.spawn(function()
    while true do
        if _G.fluentLoopRunning ~= runId then break end
        if not gui or not gui:IsDescendantOf(game) then
            local drag = playerGui:FindFirstChild("DraggableImageButtonGui")
            if drag then drag:Destroy() end
            break
        end
        local minimized = Fluent and Fluent.Window and Fluent.Window.Minimized
        local drag = playerGui:FindFirstChild("DraggableImageButtonGui")
        if drag then drag.Enabled = minimized end
        task.wait(0.025)
    end
    if _G.fluentLoopRunning == runId then
        local drag = playerGui:FindFirstChild("DraggableImageButtonGui")
        if drag then drag.Enabled = true end
    end
end)










































-- script: tabs
local player = Window:AddTab({ Title = "User", Icon = "user" })
local survival = Window:AddTab({ Title = "Sobrevivência", Icon = "" })
local tps = Window:AddTab({ Title = "Teleports", Icon = "" })
local bring = Window:AddTab({ Title = "Brings", Icon = "" })
local esp = Window:AddTab({ Title = "Esp", Icon = "" })
local Combat = Window:AddTab({ Title = "Combat", Icon = "" })
-- script: Script 

player:AddSection("WalkSpeed")

player:AddButton({
	Title = "Speed Button",
	Description = "Cria botão que altera a velocidade entre 30 ou 100",
	Callback = function(v)
		local p = game:GetService("Players").LocalPlayer
		local g = p:WaitForChild("PlayerGui")
		local s = g:FindFirstChild("SpeedGui") or Instance.new("ScreenGui", g)
		s.Name = "SpeedGui"
		s.ResetOnSpawn = false
		local b = Instance.new("TextButton", s)
		b.Size = UDim2.new(0, 60, 0, 60)
		b.Position = UDim2.new(0, 10, 0, 10)
		b.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		b.Text = "WalkSpeed"
		b.Draggable = true
		b.Active = true
		local v = 30
		local function h()
			return (p.Character or p.CharacterAdded:Wait()):WaitForChild("Humanoid")
		end
		h().WalkSpeed = v
		b.MouseButton1Click:Connect(function()
			v = (v == 30) and 100 or 30
			h().WalkSpeed = v
			b.Text = ("vel: ".. v)
		end)
	end
})



local manterVelocidade = false

player:AddToggle("", {
    Title = "Nunca manter velocidade abaixo de 100",
    Description = "Caso cair em uma trap velocidade não reduz\n-> Se sua velocidade for menos que 30 ela muda pra 100!",
    Default = false,
    Callback = function(v)
        manterVelocidade = v
        if manterVelocidade then
            task.spawn(function()
                while manterVelocidade do
                    local char = game.Players.LocalPlayer.Character
                    local h = char and char:FindFirstChild("Humanoid")
                    if h and h.WalkSpeed < 30 then
                        h.WalkSpeed = 100
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

player:AddSection("Jump")

local jumpPower = 50
local JumpInput

JumpInput = player:AddInput("JumpInput", {
	Title = "Pulo",
	Description = "Digite o valor do pulo (50 a 200)",
	Default = 50,
	Placeholder = "Ex: 100",
	Numeric = true,
	Finished = true,
	Callback = function(v)
		local n = tonumber(v)
		if not n then return end
		if n < 50 then
			jumpPower = 50
			JumpInput:SetValue(50)
		elseif n > 200 then
			jumpPower = 200
			JumpInput:SetValue(200)
		else
			jumpPower = n
		end
	end
})

player:AddButton({
	Title = "Aplicar Pulo",
	Description = "Define o valor do pulo",
	Callback = function()
		game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
		game.Players.LocalPlayer.Character.Humanoid.JumpPower = jumpPower
	end
})

player:AddToggle("", {
	Title = "Infinite Jump",
	Description = "Auto se explica",
	Default = false,
	Callback = function(v)
		if v then
			_G.InfJump = game:GetService("UserInputService").JumpRequest:Connect(function()
				local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
			end)
		else
			if _G.InfJump then _G.InfJump:Disconnect() _G.InfJump = nil end
		end
	end
})

player:AddSection("Miscs")

player:AddToggle("removerfog", {
	Title = "Remover Neblina (Fog)",
	Description = "Ativa ou desativa a neblina do jogo.",
	Default = false,
	Callback = function(value)
		local Lighting = game:GetService("Lighting")
		
		if value then
			Lighting:SetAttribute("FogStartOriginal", Lighting.FogStart)
			Lighting:SetAttribute("FogEndOriginal", Lighting.FogEnd)
			Lighting:SetAttribute("FogColorOriginal", Lighting.FogColor)
			
			Lighting.FogStart = 1e10
			Lighting.FogEnd = 1e10
			Lighting.FogColor = Color3.new(1, 1, 1)
		else
			local fogStart = Lighting:GetAttribute("FogStartOriginal") or 0
			local fogEnd = Lighting:GetAttribute("FogEndOriginal") or 100000
			local fogColor = Lighting:GetAttribute("FogColorOriginal") or Color3.new(1, 1, 1)

			Lighting.FogStart = fogStart
			Lighting.FogEnd = fogEnd
			Lighting.FogColor = fogColor
		end
	end
})


--





local itens = {
    "Ammo (Rev & Rif)",
    "Bandage",
    "Berry",
    "Bolt",
    "Broken Fan",
    "Broken Microwave",
    "Cake",
    "Sack + Axe (Qualidade: Good+)",
    "Carrot",
    "Chair",
    "Coal",
    "Morsel (Cooked & Normal)",
    "Steak (Cooked & Normal)",
    "Coin Stack",
    "Fuel Canister",
    "Iron Body",
    "Leather Armor",
    "Log",
    "MedKit",
    "Metal Chair",
    "Oil Barrel",
    "Old Car Engine",
    "Old Flashlight",
    "Old Radio",
    "Revolver",
    "Rifle",
    "Sheet Metal",
    "Tyre",
    "Washing Machine"
}

local selectedItem

local bringdrop = bring:AddDropdown("Dropdown", {
    Title = "Item que ele traz",
    Description = "Escolha o item que o bring traz",
    Values = itens,
    Multi = false,
    Default = nil,
})

bringdrop:OnChanged(function(value)
    selectedItem = value
end)

bring:AddButton({
    Title = "Bring traz o item",
    Description = "Faz o bring trazer o item selecionado",
    Callback = function()
        if selectedItem == "Ammo (Rev & Rif)" then
            bringAmmo()
        elseif selectedItem == "Bandage" then
            bringBandage()
        elseif selectedItem == "Berry" then
            bringBerry()
        elseif selectedItem == "Bolt" then
            bringBolt()
        elseif selectedItem == "Broken Fan" then
            bringVentilador()
        elseif selectedItem == "Broken Microwave" then
            bringMicro()
        elseif selectedItem == "Cake" then
            bringCake()
        elseif selectedItem == "Carrot" then
            bringCarrot()
        elseif selectedItem == "Chair" then
            bringChair()
        elseif selectedItem == "Coal" then
            bringCoal()
        elseif selectedItem == "Coin Stack" then
            bringCoin()
        elseif selectedItem == "Fuel Canister" then
            bringFuel()
        elseif selectedItem == "Iron Body" then
            bringArm2()
        elseif selectedItem == "Leather Armor" then
            bringArm1()
        elseif selectedItem == "Log" then
            bringLog()
        elseif selectedItem == "MedKit" then
            bringMedKit()
        elseif selectedItem == "Oil Barrel" then
            bringBarril()
        elseif selectedItem == "Old Car Engine" then
            bringEngine()
        elseif selectedItem == "Old Flashlight" then
            bringFlashOld()
        elseif selectedItem == "Old Radio" then
            bringRadio()
        elseif selectedItem == "Revolver" then
            bringRevolver()
        elseif selectedItem == "Rifle" then
            bringRifle()
        elseif selectedItem == "Sheet Metal" then
            bringSheetMetal()
        elseif selectedItem == "Tyre" then
            bringRoda()
	elseif selectedItem == "Washing Machine" then
	    bringLavar()
	elseif selectedItem == "Metal Chair" then
	    bringMChair()
	elseif selectedItem == "Morsel (Cooked & Normal)" then
	    bringMorse()
	elseif selectedItem == "Steak (Cooked & Normal)" then
	    bringSteak()
	elseif selectedItem == "Sack + Axe (Qualidade: Good+)" then
	    bringFerr()
        end
    end
})

bring:AddSection("Auto Bring - Combustíveis/Fogo")

local abff = false
local abffThread = nil

bring:AddToggle("", {
	Title = "Auto Bring Combustíveis",
	Description = "puxa tudo que e possivel queimar para um pouco a frente do fogo",
	Default = false,
	Callback = function(l)
		abff = l
		if abff and not abffThread then
			abffThread = task.spawn(function()
				while abff do
					task.wait(0.5)
					blmCom()
				end
				abffThread = nil
			end)
		end
	end
})

bring:AddButton({
	Title = "Auto Bring Combustíveis (Manual)", 
	Description = "Mesma função do Toggle porem ele so bring 1 vez por click\nE não automaticamente",
	Callback = function() blmCom() end})
					
bring:AddSection("Auto Bring - Metais")

local abfg = false
local abfgThread = nil

bring:AddToggle("", {
	Title = "Auto Bring Metais",
	Description = "puxa tudo que é metal para trás da bancada de trabalho",
	Default = false,
	Callback = function(l)
		abfg = l
		if abfg and not abfgThread then
			abfgThread = task.spawn(function()
				while abfg do
					task.wait(0.5)
					blmMet()
				end
				abfgThread = nil
			end)
		end
	end
})

bring:AddButton({
	Title = "Auto Bring metais (Manual)", 
	Description = "Mesma função do Toggle porem ele so bring 1 vez por click\nE não automaticamente",
	Callback = function() blmMet() end})

       


--
tps:AddSection("Tps prontos")


tps:AddButton({
	Title = "Teleport to center (fogo)",
	Description = "Ao clicar te Teleporta para o fogo",
	Callback = function() 
		tpfire() 
	end
})

tps:AddButton({
	Title = "Teleport to Stronghold",
	Description = "Ao clicar te Teleporta para a fortaleza\nCaso ela já esteja Spawnada*",
	Callback = function()
		print("Botão teleport criado!")
		if workspace.Map.Landmarks.Stronghold.Building.Exterior then
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
				CFrame.new(workspace.Map.Landmarks.Stronghold.Building.Exterior:GetChildren()[12].Model.Part.Position + Vector3.new(0, 15, 0))
		else
			Fluent:Notify({
				Title = "Stronghold não esta spawnada",
				Content = "StrongHold não spawnada, desbloqueie mais partes do mapa",
				SubContent = "",
				Duration = 5
			})
		end
	end
})

tps:AddButton({
	Title = "Teleport to Disco voador",
	Description = "Ao clicar Teleporta para o Disco voador",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Items["Alien Chest"].Main.CFrame.Position + Vector3.new(0, 10, 0))
	end
})





	
tps:AddSection("Tps Pos")


local tv = {}
function gp() local p=game.Players.LocalPlayer.Character.HumanoidRootPart.Position return ("%d, %d, %d"):format(p.X, p.Y, p.Z) end
local tpd

local Dropdown = tps:AddDropdown("Dropdown", {
    Title = "Locais para teleport",
    Description = "",
    Values = tv,
    Multi = false,
    Default = nil,
    Callback = function(v)
	tpd = v
    end
})

tps:AddButton({
    Title = "Salvar novo local",
    Description = "Adiciona nova posição no Dropdown",
    Callback = function()
        table.insert(tv, gp())
        Dropdown:SetValues(tv)
    end
})

tps:AddButton({
    Title = "Limpar Locais salvos",
    Description = "Limpa todas posições salva no Dropdown",
    Callback = function()
	table.clear(tv)
	Dropdown:SetValue("")
        Dropdown:SetValues(tv)
    end
})

tps:AddButton({
    Title = "Teleportar para posição selecionada",
    Description = "",
    Callback = function()
        if tpd then
            local x, y, z = tpd:match("(-?%d+), (-?%d+), (-?%d+)")
            if x and y and z then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
            end
        end
    end
})

--

local ie = {"Bandage", "Bolt", "Broken Fan", "Broken Microwave", "Cake", "Carrot", "Chair", "Coal", "Coin Stack", "Cooked Morsel", "Cooked Steak", "Fuel Canister", "Iron Body", "Leather Armor", "Log", "MadKit", "Metal Chair", "MedKit", "Old Car Engine", "Old Flashlight", "Old Radio", "Revolver", "Revolver Ammo", "Rifle", "Rifle Ammo", "Morsel", "Sheet Metal", "Steak", "Tyre", "Washing Machine"}
local me = {"Bunny", "Wolf", "Alpha Wolf", "Bear", "Cultist", "Crossbow Cultist", "Alien"}

local vde = {}
local vdm = {}

local espdownItems = esp:AddDropdown("a", {
   Title = "Itens",
   Description = "Selecione para o esp",
   Values = ie,
   Multi = true,
   Default = {},
})

espdownItems:OnChanged(function(val)
	table.clear(vde)
	for i, state in next, val do
		if state then
			vde[#vde + 1] = i
		end
	end
end)

local espdownMobs = esp:AddDropdown("b", {
   Title = "Mobs",
   Description = "Selecione para o esp",
   Values = me,
   Multi = true,
   Default = {},
})

espdownMobs:OnChanged(function(val)
	table.clear(vdm)
	for i, state in next, val do
		if state then
			vdm[#vdm + 1] = i
		end
	end
end)

esp:AddButton({
	Title = "Adicionar esp",
	Description = "Adiciona os itens e mobs selecionados em esp",
	Callback = function()
		for _, i in vde do
			Aesp(i, "item")
		end
		for _, m in vdm do
			Aesp(m, "mob")
		end
	end
})


_G.aae = false
esp:AddToggle("", {
    Title = "Auto add esp", 
    Description = "Adiciona ESP automaticamente aos itens e mobs spawnados",
    Default = false,
    Callback = function(a)
        _G.aae = a
        if a then
            task.spawn(function()
                while _G.aae do
                    local itens = workspace:WaitForChild("Items")
                    local mobs = workspace:WaitForChild("Characters")

                    for _, obj in ipairs(itens:GetChildren()) do
                        if table.find(vde, obj.Name) then
                            Aesp(obj.Name, "item")
                        end
                    end

                    for _, mob in ipairs(mobs:GetChildren()) do
                        if table.find(vdm, mob.Name) then
                            Aesp(mob.Name, "mob")
                        end
                    end

                    task.wait(1)
                end
            end)
        end
    end
})

esp:AddButton({
	Title = "Remover esp",
	Description = "Remove todos esp dos itens e mobs",
	Callback = function()
		for _, i in vde do
			Desp(i, "item")
		end
		for _, m in vdm do
			Desp(m, "mob")
		end
		table.clear(vde)
		table.clear(vdm)
		espdownItems:SetValue(vde)
		espdownMobs:SetValue(vdm)
	end
})

--

_G.killaura = nil
Combat:AddToggle("", {
Title = "Kill Aura (OP)",
Description = "Ataca automaticamente qualquer NPC\nPara usar: Esteja com alguma arma corpo a corpo na sua mão\nEle ataca o NPC mais próximo",
Default = false,
Callback = function(value)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local evento = ReplicatedStorage.RemoteEvents:FindFirstChild("ToolDamageObject")
local caminho = workspace:FindFirstChild("Characters") or workspace

local armasValidas = {    
	["Old Axe"] = true,    
	["Good Axe"] = true,    
	["Strong Axe"] = true,    
	["Spear"] = true,    
	["Katana"] = true,    
	["Morningstar"] = true,
	["Laser Sword"] = true
}    

function getArmaValida()
    local inv = LocalPlayer:FindFirstChild("Inventory")
    local char = workspace[LocalPlayer.Name]
    local equipado = char and char:GetAttribute("Equipped")
    if not equipado or not armasValidas[equipado] then return nil end
    if inv then
        local arma = inv:FindFirstChild(equipado)
        if arma then
            return arma
        end
    end
    return nil
end

local function gerarID()    
	return "2_" .. LocalPlayer.UserId    
end    

local function getNPCsMaisProximos(character, targets, limite)    
	local hrp = character:FindFirstChild("HumanoidRootPart")    
	if not hrp then return {} end    

	local npcs = {}    

	for _, alvo in pairs(targets) do    
		if alvo ~= character then    
			local alvoRoot = alvo:FindFirstChild("HumanoidRootPart")    
			local humanoid = alvo:FindFirstChildWhichIsA("Humanoid")    
			if alvoRoot and humanoid and humanoid.Health > 0 then    
				local dist = (hrp.Position - alvoRoot.Position).Magnitude    
				table.insert(npcs, { alvo = alvo, dist = dist })    
			end    
		end    
	end    

	table.sort(npcs, function(a, b)    
		return a.dist < b.dist    
	end)    

	local resultado = {}    
	for i = 1, math.min(limite, #npcs) do    
		table.insert(resultado, npcs[i].alvo)    
	end    

	return resultado    
end    

if value then    
	_G.killaura = RunService.RenderStepped:Connect(function()    
		local char = workspace[Players.LocalPlayer.Name]
		local equipado = char and char:GetAttribute("Equipped")
		if not equipado or not armasValidas[equipado] then return end

		local arma = getArmaValida()    
		if not arma or not evento then return end    

		local c = LocalPlayer.Character    
		if not c then return end    

		local hrp = c:FindFirstChild("HumanoidRootPart")    
		if not hrp then return end    

		local alvos = getNPCsMaisProximos(c, caminho:GetChildren(), 15)    
		for _, alvo in pairs(alvos) do    
			evento:InvokeServer(alvo, arma, gerarID(), hrp.CFrame)    
		end    
	end)    
else    
	if _G.killaura then    
		_G.killaura:Disconnect()    
		_G.killaura = nil    
	end    
end

end

})

   

Combat:AddParagraph({
	Title = "Armas Válidas para Kill Aura",
	Content = "Old Axe\nGood Axe\nStrong Axe\nSpear\nKatana\nMorningstar"
})


--

function wiki(nome)
    local c = 0
    for _, i in ipairs(workspace.Items:GetChildren()) do
        if i.Name == nome then
            c = c + 1
        end
    end
    return c
end

function ghn()
    return math.floor(game:GetService("Players").LocalPlayer.PlayerGui.Interface.StatBars.HungerBar.Bar.Size.X.Scale * 100)
end

function feed(nome)
    for _, item in ipairs(workspace.Items:GetChildren()) do
        if item.Name == nome then
            game:GetService("ReplicatedStorage").RemoteEvents.RequestConsumeItem:InvokeServer(item)
            break
        end
    end
end

function notifeed(nome)
    Fluent:Notify({
        Title = "Auto feed pause",
        Content = "Sem '" .. nome .. "' Spawnado para consumo, Selecione outra comida",
        Duration = 3
    })
end

local vf, ife, tfe
local tf = false
local alimentos = {
    "Apple",
    "Berry",
    "Carrot",
    "Cake",
    "Chili",
    "Cooked Morsel",
    "Cooked Steak"
}
local c = "Carrot"
vf = 75

survival:AddSection("Auto feed")
survival:AddDropdown("", {
    Title = "Escolha a comida",
    Description = "Selecione o alimento para auto feed",
    Values = alimentos,
    Multi = false,
    Default = c,
    Callback = function(value)
        c = value
    end
})

task.spawn(function()
    local a = survival:AddParagraph({ Title = "fome:", Content = ghn() })
    local b = survival:AddParagraph({ Title = "Comida selecionada:", Content = c })
    while true do
        task.wait(0.2)
        a:SetDesc(ghn() .. "%")
        b:SetDesc(c)
    end
end)

ife = survival:AddInput("", {
    Title = "Feed %",
    Description = "Quando fome atingir (X%) Comer",
    Default = vf,
    Placeholder = "",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        vf = tonumber(Value) or 75
        if vf < 0 then
            vf = 1
            ife:SetValue(vf)
        elseif vf > 100 then
            vf = 100
            ife:SetValue(vf)
        end
    end
})

tfe = survival:AddToggle("", {
    Title = "Ativar auto feed",
    Description = "Auto se explica",
    Default = false,
    Callback = function(v)
        tf = v
        if tf then
            task.spawn(function()
                while tf do
                    task.wait(0.075)
                    if wiki(c) == 0 then
                        tfe:SetValue(false)
                        notifeed(c)
                        break
                    end
                    if ghn() <= vf then
                        feed(c)
                    end
                end
            end)
        end
    end
})

survival:AddSection("Auto Cook meat")

local acm
local aguardando = false

acm = survival:AddButton({
    Title = "Cozinhar Carnes",
    Description = "Após clicar, ele cozinha as carnes e após 5 segundos teleporta elas para você",
    Callback = function()
        if aguardando then return end
        aguardando = true

        blmMeat()

        local ini = os.time() + 5

        task.spawn(function()
            while os.time() < ini do
                local t = ini - os.time()
                acm:SetDesc("Espere: " .. t .. " segundos para usar novamente")
                task.wait(0.1)
            end

            acm:SetDesc("Após clicar, ele cozinha as carnes e após 5 segundos teleporta elas para você")
            aguardando = false
        end)

        task.delay(5, function()
            BringMeat()
        end)
    end
})

survival:AddParagraph({
	Title = "Como usar?",
	Content = "Na primeira vez ele ira bugar\nComo arrumar?\nQuando voce der o primeiro click no botão\nvá ate a fogueira e clique em uma das carnes\nApos isso elas irão cair e fritar\nA partir deste momento não acontecerá mais o bug\nCaso acontecer novamente e so refazer isso."
	})
