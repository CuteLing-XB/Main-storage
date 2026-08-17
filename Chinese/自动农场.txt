

if getgenv().ScriptExecuted then
	return
end

getgenv().ScriptExecuted = true

local countries = {
	"France",
	"Netherlands",
	"United States",
	"United Kingdom",
	"Australia",
	"Germany",
	"India",
	"Brazil",
	"Singapore",
	"Japan",
}

local colors = {
	Background = Color3.fromRGB(17, 18, 23),
	Panel = Color3.fromRGB(26, 27, 34),
	Stroke = Color3.fromRGB(50, 51, 63),
	TextPrimary = Color3.fromRGB(240, 240, 245),
	TextDim = Color3.fromRGB(145, 146, 158),
	Rose = Color3.fromRGB(225, 95, 110),
	FarmOn = Color3.fromRGB(70, 200, 130),
	FarmOff = Color3.fromRGB(200, 70, 80),
}

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = parent
	return corner
end

local function addStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or colors.Stroke
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function createTween(target, properties, duration, easingStyle, easingDirection)
	local tweenService = game:GetService("TweenService")
	return tweenService:Create(
		target,
		TweenInfo.new(
			duration or 0.2,
			easingStyle or Enum.EasingStyle.Quad,
			easingDirection or Enum.EasingDirection.Out
		),
		properties
	)
end

local function configureLabel(label, truncate)
	label.ClipsDescendants = true
	if truncate then
		label.TextTruncate = Enum.TextTruncate.AtEnd
	end

end

local farmEnabled = true
local httpService = game:GetService("HttpService")

local function jsonEncode(value)
	return httpService:JSONEncode(value)
end

local playersService = game:GetService("Players")
local localPlayer = playersService.LocalPlayer
local baseFolder = "ZKAYHub"
local userFolder = "ZKAYHub/PublicFarm/" .. localPlayer.Name
local settingsPath = userFolder .. "/settings.json"

local function makeFolders()
	if not isfolder(baseFolder) then
		makefolder(baseFolder)
	end
	if not isfolder(userFolder) then
		makefolder(userFolder)
	end

end

local defaultSettings = {
	country = countries[1],
	hopOnCount = "1000",
}

local farmSettings = table.clone(defaultSettings)

local function loadSettings()
	makeFolders()
	if not isfile(settingsPath) then
		return
	end
	local readOk, fileContent = pcall(readfile, settingsPath)
	if not readOk then
		warn("[ZKAYHub] Failed to read settings file:", fileContent)
		return
	end
	local decodeOk, decoded = pcall(httpService.JSONDecode, httpService, fileContent)
	if not decodeOk or type(decoded) ~= "table" then
		warn("[ZKAYHub] Failed to decode settings file, using defaults")
		return
	end
	for key, value in pairs(decoded) do
		if key == "hopOnCount" and tonumber(value) and tonumber(value) <= 500 then
			farmSettings[key] = "1000"
		else
			farmSettings[key] = value
		end
	end

end

loadSettings()
getgenv().TimeFarmed = getgenv().TimeFarmed or 0
getgenv().session_start = getgenv().session_start or os.time()
getgenv().carriedKills = getgenv().carriedKills or 0
getgenv().emotes = getgenv().emotes or 0
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZKAYFarmUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 120)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = colors.Background
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true
addCorner(mainFrame, 16)
addStroke(mainFrame, colors.Stroke, 1)

local killsBox = Instance.new("Frame")
killsBox.Name = "KillsBox"
killsBox.BackgroundColor3 = colors.Panel
killsBox.BorderSizePixel = 0
killsBox.Position = UDim2.fromOffset(16, 12)
killsBox.Size = UDim2.new(1, -32, 0, 42)
addCorner(killsBox, 10)
addStroke(killsBox, colors.Stroke, 1)
killsBox.Parent = mainFrame

local killsDot = Instance.new("Frame")
killsDot.BackgroundColor3 = colors.Rose
killsDot.Size = UDim2.fromOffset(8, 8)
killsDot.Position = UDim2.fromOffset(12, 17)
addCorner(killsDot, 4)
killsDot.Parent = killsBox

local killsCaptionLabel = Instance.new("TextLabel")
killsCaptionLabel.BackgroundTransparency = 1
killsCaptionLabel.Position = UDim2.fromOffset(28, 0)
killsCaptionLabel.Size = UDim2.new(0.5, -28, 1, 0)
killsCaptionLabel.Font = Enum.Font.GothamMedium
killsCaptionLabel.Text = "KILLS"
killsCaptionLabel.TextColor3 = colors.TextDim
killsCaptionLabel.TextSize = 11
killsCaptionLabel.TextXAlignment = Enum.TextXAlignment.Left
configureLabel(killsCaptionLabel, true)
killsCaptionLabel.Parent = killsBox

local killsValueLabel = Instance.new("TextLabel")
killsValueLabel.Name = "KillsValue"
killsValueLabel.BackgroundTransparency = 1
killsValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
killsValueLabel.Size = UDim2.new(0.5, -12, 1, 0)
killsValueLabel.Font = Enum.Font.GothamBold
killsValueLabel.Text = "0"
killsValueLabel.TextColor3 = colors.TextPrimary
killsValueLabel.TextSize = 19
killsValueLabel.TextXAlignment = Enum.TextXAlignment.Right
configureLabel(killsValueLabel, true)
killsValueLabel.Parent = killsBox

local farmToggleButton = Instance.new("TextButton")
farmToggleButton.Name = "FarmToggle"
farmToggleButton.BackgroundColor3 = colors.FarmOn
farmToggleButton.Position = UDim2.fromOffset(16, 66)
farmToggleButton.Size = UDim2.new(1, -32, 0, 40)
farmToggleButton.Font = Enum.Font.GothamBold
farmToggleButton.Text = "Start Farm"
farmToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
farmToggleButton.TextSize = 14
farmToggleButton.AutoButtonColor = false
addCorner(farmToggleButton, 11)
farmToggleButton.Parent = mainFrame

local function setFarmState(enabled)
	farmEnabled = enabled
	if enabled then
		farmToggleButton.Text = "Stop Farm"
		createTween(farmToggleButton, { BackgroundColor3 = colors.FarmOff }, 0.18):Play()
	else
		pcall(function()
			local character = localPlayer.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				rootPart.CFrame = CFrame.new(-42, 1855, 25227)
			end
		end)
		farmToggleButton.Text = "Start Farm"
		createTween(farmToggleButton, { BackgroundColor3 = colors.FarmOn }, 0.18):Play()
	end
end

farmToggleButton.MouseButton1Click:Connect(function()
	setFarmState(not farmEnabled)
end)

setFarmState(farmEnabled)


local savedCarriedKills = getgenv().SavedCarriedKills or 0
local savedEmotes = getgenv().SavedEmotes or 0
local sessionStartTime = getgenv().SavedSessionStart or os.time()
local carriedKills = 0
local killsPerHour = 0
local killsSinceLoad = 0
local totalKills = 0
local sessionKills = 0
local currentlyTargeting = false
local targetCFrame = nil
local currentTarget = nil
local isAttacking = false
local isUlted = false
local gKeyBusy = false
local ultKeyReady = false
local ultStartup = false
local isTeleporting = false
local teleportService = game:GetService("TeleportService")
local playersService2 = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualInput = game:GetService("VirtualInputManager")
local localPlayer2 = playersService2.LocalPlayer
local leaderstats = localPlayer2:FindFirstChild("leaderstats") or localPlayer2

workspace.FallenPartsDestroyHeight = 0 / 0
local fallenPartsWatcher = workspace
	:GetPropertyChangedSignal(("Fa" .. "llenP" .. "artsDestroyHe" .. "ight"))
	:Connect(function()
		local currentValue = workspace.FallenPartsDestroyHeight
		if currentValue == currentValue then
			workspace.FallenPartsDestroyHeight = 0 / 0
		end
	end)
local killFloorPart = Instance.new("Part", workspace)
killFloorPart.CFrame = CFrame.new(0, -10008, 0)
killFloorPart.Anchored = true
killFloorPart.Size = Vector3.new(2048, 10, 2048)
killFloorPart.Transparency = 0.5
killFloorPart.CanCollide = true
killFloorPart.Name = game:GetService("HttpService"):GenerateGUID()
local lastHealth = 100
local healthChangedConn = nil
local renderSteppedConn = nil
local characterAddedConn = nil

local function onCharacterAdded(character)
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 3)
	local rootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 3)
	if not humanoid or not rootPart then
		return
	end
	lastHealth = humanoid.Health
	if healthChangedConn then
		healthChangedConn:Disconnect()
		healthChangedConn = nil
	end
	if renderSteppedConn then
		renderSteppedConn:Disconnect()
		renderSteppedConn = nil
	end
	renderSteppedConn = runService.RenderStepped:Connect(function()
		local rootPart2 = character:FindFirstChild("HumanoidRootPart")
		if rootPart2 then
			lastHealth = humanoid.Health
			killFloorPart.CFrame = CFrame.new(rootPart2.Position.X, -10008, rootPart2.Position.Z)
		end
	end)
	healthChangedConn = humanoid.HealthChanged:Connect(function(newHealth)
		local rootPart2 = character:FindFirstChild("HumanoidRootPart")
		if newHealth <= 0 and rootPart2 and rootPart2.CFrame.Y <= 0 then
			humanoid.Health = lastHealth
		end
	end)
end

onCharacterAdded(localPlayer2.Character)
characterAddedConn = localPlayer2.CharacterAdded:Connect(function(newCharacter)
	task.wait(0.1)
	onCharacterAdded(newCharacter)
end)

local connections = {}
local ownedFolders = setmetatable({}, { __mode = "k" })

local function ensureMovingExclusion(character)
	if not character then
		return nil
	end
	local existingFolder = character:FindFirstChild("MovingExclusion")
	if existingFolder then
		return existingFolder
	end
	local folder = Instance.new("Folder")
	folder.Name = "MovingExclusion"
	pcall(function()
		folder:SetAttribute("ZKAYOwned", true)
	end)
	folder.Parent = character
	ownedFolders[folder] = true
	return folder
end

local function hookMovingExclusion(character)
	if not character then
		return
	end
	ensureMovingExclusion(character)
	local childRemovedConn = character.ChildRemoved:Connect(function(child)
		if child.Name == "MovingExclusion" then
			task.defer(ensureMovingExclusion, character)
		end
	end)
	table.insert(connections, childRemovedConn)
end

hookMovingExclusion(localPlayer2.Character)

table.insert(
	connections,
	localPlayer2.CharacterAdded:Connect(function(newCharacter)
		task.wait(0.1)
		hookMovingExclusion(newCharacter)
	end)
)

-- Invisibility system removed.
local desyncProcessing = false

local desyncHeartbeat = runService.Heartbeat:Connect(function()
	if not farmEnabled then
		return
	end
	if isUlted or isTeleporting then
		getgenv().desync = nil
	end

	local desyncActive = getgenv().desync ~= nil
	if not desyncActive then
		return
	end
	if desyncProcessing then
		return
	end

	desyncProcessing = true

	local myChar = localPlayer2.Character
	local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
	local myRootPart = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myChar or not myHumanoid or not myRootPart then
		desyncProcessing = false
		return
	end

	if myHumanoid.Health <= 0 then
		desyncProcessing = false
		return
	end

	local myRootCFrame = myRootPart.CFrame
	local myVelocity = myRootPart.Velocity
	local currentCamera = workspace.CurrentCamera
	local desyncCFrame = getgenv().desync and getgenv().desync.CFrame or nil

	if desyncCFrame then
		if currentCamera then
			myChar:SetAttribute("NoHeadLerp", true)
		end

		if currentlyTargeting and targetCFrame then
			myRootPart.CFrame = targetCFrame
		else
			myRootPart.CFrame = desyncCFrame
		end
	end

	runService.RenderStepped:Wait()

	if currentCamera then
		myChar:SetAttribute("NoHeadLerp", false)
	end

	if desyncCFrame then
		if currentlyTargeting and targetCFrame then
			myRootPart.CFrame = targetCFrame
		else
			if
				currentCamera
				and userInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
			then
				local value = currentCamera.CFrame.LookVector
				local var = Vector3.new(value.X, 0, value.Z)
				if var.Magnitude > 0.001 then
					myRootPart.CFrame = CFrame.new(myRootCFrame.Position, myRootCFrame.Position + var)
				else
					myRootPart.CFrame = myRootCFrame
				end
			else
				myRootPart.CFrame = myRootCFrame
			end
		end
	end

	myRootPart.Velocity = myVelocity
	desyncProcessing = false
end)
task.spawn(function()
	local function fn(arg)
		repeat
			task.wait()
		until (localPlayer2.Character == arg)
			and arg:FindFirstChild("HumanoidRootPart")
			and arg:FindFirstChildOfClass("Humanoid")
		if localPlayer2.Character ~= arg then
			return
		end
		local var = arg:FindFirstChild("HumanoidRootPart")
		task.spawn(function()
			while task.wait() and (not localPlayer2.Character or localPlayer2.Character == arg) do
				if getgenv().desync and not arg:FindFirstChild("AbsoluteImmortal") then
					local list = {}
					local afterimageOk, afterimageClone = pcall(function()
						return replicatedStorage.Resources.NinjaUlt.Afterimage_Despawn:Clone()
					end)
					local vanishingOk, vanishingClone = pcall(function()
						return replicatedStorage.Resources.VanishingKick.tpthing:Clone()
					end)
					if afterimageOk and afterimageClone then
						afterimageClone.Parent = var
						list[1] = afterimageClone
						for idx, val in pairs(afterimageClone:GetChildren()) do
							if val:IsA("ParticleEmitter") then
								val.Enabled = true
								val.Rate = 100
							end
						end
					end
					if vanishingOk and vanishingClone then
						vanishingClone.Parent = var
						list[2] = vanishingClone
						vanishingClone.Enabled = true
						vanishingClone.Rate = 100
					end
					repeat
						if list[1] and list[1].Parent then
							list[1].CFrame = var.CFrame
						end
						runService.RenderStepped:Wait()
					until not getgenv().desync or arg:FindFirstChild("AbsoluteImmortal")
					for idx, val in pairs(list) do
						pcall(function()
							val:Destroy()
						end)
					end
				end
			end
		end)
		task.spawn(function()
			for idx, val in pairs(arg:GetDescendants()) do
				if
					val:IsA("BasePart")
					and val ~= var
					and val.Transparency ~= 1
					and not val.Name:lower():find("hitbox")
				then
					task.spawn(function()
						while task.wait() and (not localPlayer2.Character or localPlayer2.Character == arg) do
							if val and (getgenv().desync and not arg:FindFirstChild("AbsoluteImmortal")) then
								val.Transparency = 0.5
								repeat
									runService.RenderStepped:Wait()
								until (not getgenv().desync or arg:FindFirstChild("AbsoluteImmortal"))
										or (localPlayer2.Character and localPlayer2.Character ~= arg)
								val.Transparency = 0
							end
						end
					end)
				end
			end
		end)
	end
	if localPlayer2.Character then
		task.spawn(fn, localPlayer2.Character)
	end
	localPlayer2.CharacterAdded:Connect(function(arg)
		task.spawn(fn, arg)
	end)
end)
local lightingService = game:GetService("Lighting")
local workspaceService = game:GetService("Workspace")
local terrain = Workspace:FindFirstChildOfClass("Terrain")

local function safeConnect(signal, handler)
	pcall(function()
		signal:Connect(handler)
	end)
end

local optimizers = {}
optimizers[1] = function()
	local trailColor = Color3.fromRGB(0, 85, 190)
	local function styleTrail(instance)
		if instance:IsA("Trail") then
			instance.Color = ColorSequence.new(trailColor)
			instance.Texture = ""
			instance.LightEmission = 0.8
		elseif instance:IsA("ParticleEmitter") then
			instance.Color = ColorSequence.new(trailColor)
			instance.LightEmission = 0.75
		end
	end
	local function styleCharacterFX(character)
		for index2, child in ipairs(character:GetDescendants()) do
			if child:IsA("Trail") or child:IsA("ParticleEmitter") then
				styleTrail(child)
			end
		end
		safeConnect(character.DescendantAdded, function(newDescendant)
			if newDescendant:IsA("Trail") or newDescendant:IsA("ParticleEmitter") then
				styleTrail(newDescendant)
			end
		end)
	end
	if localPlayer2.Character then
		styleCharacterFX(localPlayer2.Character)
	end
	safeConnect(localPlayer2.CharacterAdded, styleCharacterFX)
end

optimizers[2] = function()
	local skyboxIds = {
		Bk = 92959017845968,
		Ft = 129304841254693,
		Lf = 129249062260004,
		Rt = 117319232583147,
		Up = 121193772599100,
		Dn = 115022734343595,
	}
	for index2, skyInstance in ipairs(lightingService:GetChildren()) do
		if skyInstance:IsA("Sky") then
			skyInstance:Destroy()
		end
	end
	local sky = Instance.new("Sky")
	for key, assetId in pairs(skyboxIds) do
		sky["Skybox" .. key] = "rbxassetid://" .. assetId
	end
	sky.Parent = lightingService
end

optimizers[3] = function()
	lightingService.ClockTime = 12
	lightingService.GlobalShadows = false
	lightingService.Brightness = 0.8
	lightingService.ExposureCompensation = -0.2
	lightingService.FogStart, lightingService.FogEnd = 9e9, 9e9
	for index2, child in ipairs(lightingService:GetChildren()) do
		if child:IsA("PostEffect") or child:IsA("SunRaysEffect") then
			child.Enabled = false
		end
	end

end

optimizers[4] = function()
	safeConnect(workspaceService.DescendantAdded, function(newChild)
		if newChild:IsA("Smoke") then
			newChild:Destroy()
		elseif newChild:IsA("ParticleEmitter") then
			local ancestorModel = newChild:FindFirstAncestorOfClass("Model")
			if
				not (
					ancestorModel
					and ancestorModel:FindFirstChild("Class")
					and ancestorModel.Class.Value == "Hero Hunter"
				)
			then
				newChild:Destroy()
			end
		end
	end)
end

optimizers[5] = function()
	if not terrain then
		return
	end
	for index2, clouds in ipairs(terrain:GetChildren()) do
		if clouds:IsA("Clouds") then
			clouds.Enabled = false
		end
	end
	safeConnect(terrain.ChildAdded, function(newChild)
		if newChild:IsA("Clouds") then
			newChild.Enabled = false
		end
	end)
end

optimizers[6] = function()
	local function clearSkyTextures()
		local sky = lightingService:FindFirstChildOfClass("Sky")
		if sky then
			sky.SunAngularSize = 0
			sky.SunTextureId = ""
			sky.MoonAngularSize = 0
			sky.MoonTextureId = ""
		end
	end
	clearSkyTextures()
	local atmosphere = lightingService:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		atmosphere.Density = 0
		atmosphere.Haze = 0
		atmosphere.Glare = 0
	end
	safeConnect(lightingService.ChildAdded, function(newChild)
		if newChild:IsA("Sky") then
			task.wait()
			clearSkyTextures()
		elseif newChild:IsA("Atmosphere") then
			newChild.Density = 0
			newChild.Haze = 0
			newChild.Glare = 0
		end
	end)
end

task.spawn(function()
	local optimizerQueue = { 1, 2, 3, 4, 5, 6 }
	while #optimizerQueue > 0 do
		local randomIndex = math.random(#optimizerQueue)
		pcall(optimizers[optimizerQueue[randomIndex]])
		table.remove(optimizerQueue, randomIndex)
	end

end)
pcall(function()
	farmSettings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)
local desyncActive = false

local function getCharacter(input)
	if typeof(input) == "Instance" then
		if input:IsA("Player") then
			return input.Character
		elseif input:IsA("Model") then
			return input
		end
	end
	return nil
end

local function getRootPart(model)
	return model and model:FindFirstChild(("HumanoidRoot" .. "Part")) or nil
end

local function getHumanoid(model)
	return model and model:FindFirstChildOfClass("Humanoid") or nil
end

local function getOtherPlayers()
	local playersList = playersService2:GetPlayers()
	local selfIndex = table.find(playersList, localPlayer2)
	if selfIndex then
		table.remove(playersList, selfIndex)
	end
	return playersList
end

local function hasAnimation(humanoid, animIdPattern)
	if not humanoid then
		return false
	end
	for index2, track in pairs(humanoid:GetPlayingAnimationTracks()) do
		if track.Animation.AnimationId:match(animIdPattern) then
			return true
		end
	end
	return false
end

local function findWeakestTarget()
	local weakestPlayer = nil
	local lowestHealth = math.huge
	for index2, player in ipairs(playersService2:GetPlayers()) do
		if player == localPlayer2 then
			continue
		end
		if player == currentTarget then
			continue
		end
		local char = player.Character
		if not char then
			continue
		end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then
			continue
		end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			continue
		end
		if not humanoid.Health then
			continue
		end
		local torso = char:FindFirstChild("Torso")
		if not torso or torso.Transparency == 1 then
			continue
		end
		if hasAnimation(humanoid, "15128849047") then
			continue
		end
		if char:FindFirstChildWhichIsA("ForceField") then
			continue
		end
		if
			(
				char:GetAttribute("Ulted")
				and (char:GetAttribute("Character") == "Batter" or char:GetAttribute("Character") == "Bald")
			) or char:FindFirstChild("Counter")
		then
			continue
		end
		local rootPos = char.HumanoidRootPart.Position
		if not (rootPos.X >= -500 and rootPos.X <= 800 and rootPos.Z >= -600 and rootPos.Z <= 700) then
			continue
		end
		local health = humanoid.Health
		if health > 0 and health < lowestHealth then
			lowestHealth = health
			weakestPlayer = player
		end
	end
	return weakestPlayer
end

local function setupCharacterHandlers(character)
	local humanoid = character:WaitForChild("Humanoid")
	character.DescendantAdded:Connect(function(newDescendant)
		if newDescendant.Name == "Ragdoll" or newDescendant.Name == "RagdollSim" then
			if (not desyncActive) and humanoid.Health > 0 and not character:FindFirstChild("ExtraHitbox") then
				task.spawn(function()
					repeat
						desyncActive = true
						getgenv().desync = { CFrame = CFrame.new(9e9, 9e9, 9e9) }
						task.wait()
					until newDescendant.Parent ~= character or humanoid.Health <= 0
					desyncActive = false
					getgenv().desync = nil
				end)
			end
		end
	end)
	task.spawn(function()
		local playerGui = localPlayer2:WaitForChild("PlayerGui")
		if not playerGui then
			return
		end
		local hotbar = playerGui:WaitForChild("Hotbar")
		if not hotbar then
			return
		end
		local backpack = hotbar:WaitForChild("Backpack")
		if not backpack then
			return
		end
		local hotbarFrame = backpack:WaitForChild("Hotbar")
		if not hotbarFrame then
			return
		end
		local slotTwo = hotbarFrame:WaitForChild("2")
		if not slotTwo then
			return
		end
		local slotBase = slotTwo:WaitForChild("Base")
		if not slotBase then
			return
		end
		slotBase.ChildAdded:Connect(function(child)
			if child.Name == "Cooldown" and localPlayer2.Character:GetAttribute("Ulted") then
				task.spawn(function()
					ultStartup = true
					task.wait(0.05)
					ultStartup = false
				end)
			end
		end)
	end)
	local ultAnimIds = {
		["18464351556"] = true,
		["18464372850"] = true,
		["18464362124"] = true,
		["136370737633649"] = true,
	}
	humanoid.AnimationPlayed:Connect(function(track)
		local animId = track.Animation.AnimationId
		if ultAnimIds[animId:match("%d+")] then
			currentTarget = findWeakestTarget()
			return
		end
		local function isHunterClass(player)
			if not player or not player:IsA("Player") then
				return false
			end
			local char = getCharacter(player)
			local className = char and char:GetAttribute("Character")
			if type(className) ~= "string" then
				return false
			end
			className = className:lower()
			return className == "hunter" or className == "blade" or className:find("zombie", 1, true) ~= nil
		end
		local function freezeVelocityWhile(condition)
			local conn
			conn = runService.Heartbeat:Connect(function()
				if not condition() then
					conn:Disconnect()
					return
				end
				local myRoot = getRootPart(getCharacter(localPlayer2))
				if myRoot then
					myRoot.AssemblyLinearVelocity = Vector3.new()
					myRoot.AssemblyAngularVelocity = Vector3.new()
				end
			end)
			return conn
		end
		local ultHeartbeatConn = nil
		local ultRenderConn = nil
		local myRoot = nil
		local targetRoot = nil
		local ultFinished = false
		local function detachPhysics()
			if ultHeartbeatConn then
				ultHeartbeatConn:Disconnect()
				ultHeartbeatConn = nil
			end
			if ultRenderConn then
				ultRenderConn:Disconnect()
				ultRenderConn = nil
			end
			if sethiddenproperty then
				if myRoot and myRoot.Parent then
					pcall(function()
						sethiddenproperty(myRoot, "PhysicsRepRootPart", nil)
					end)
				end
				if targetRoot and targetRoot.Parent then
					pcall(function()
						sethiddenproperty(targetRoot, "PhysicsRepRootPart", nil)
					end)
				end
			end
			if myRoot and myRoot.Parent then
				myRoot.CFrame = CFrame.new(myRoot.Position)
				myRoot.AssemblyLinearVelocity = Vector3.zero
				myRoot.AssemblyAngularVelocity = Vector3.zero
				pcall(function()
					myRoot.Velocity = Vector3.zero
				end)
				pcall(function()
					myRoot.RotVelocity = Vector3.zero
				end)
				local myHumanoid = myRoot.Parent:FindFirstChildOfClass("Humanoid")
				if myHumanoid then
					pcall(function()
						myHumanoid.AutoRotate = true
					end)
				end
			end
			myRoot = nil
			targetRoot = nil
		end
		local function detachPhysicsAll()
			detachPhysics()
		end
		local function attachPhysicsTo(myRoot2, targetRoot2)
			if ultFinished then
				return
			end
			if ultHeartbeatConn then
				ultHeartbeatConn:Disconnect()
				ultHeartbeatConn = nil
			end
			if myRoot and myRoot.Parent then
				myRoot.AssemblyLinearVelocity = Vector3.zero
				myRoot.AssemblyAngularVelocity = Vector3.zero
				pcall(function()
					myRoot.Velocity = Vector3.zero
				end)
				pcall(function()
					myRoot.RotVelocity = Vector3.zero
				end)
			end
			if not myRoot2 or not targetRoot2 then
				return
			end
			myRoot = myRoot2
			targetRoot = targetRoot2
			if ultRenderConn then
				ultRenderConn:Disconnect()
				ultRenderConn = nil
			end
			local targetHumanoid = myRoot2.Parent and myRoot2.Parent:FindFirstChildOfClass("Humanoid")
			if targetHumanoid then
				ultRenderConn = runService.RenderStepped:Connect(function()
					if targetHumanoid and targetHumanoid.Parent then
						pcall(function()
							targetHumanoid.AutoRotate = false
						end)
					end
				end)
			end
			myRoot2.CFrame = targetRoot2.CFrame * CFrame.new(0, 0, 5)
			myRoot2.AssemblyLinearVelocity = Vector3.zero
			myRoot2.AssemblyAngularVelocity = Vector3.zero
			if sethiddenproperty then
				pcall(function()
					sethiddenproperty(myRoot2, "PhysicsRepRootPart", myRoot2)
				end)
				pcall(function()
					sethiddenproperty(myRoot2, "PhysicsRepRootPart", targetRoot2)
				end)
			end
			local heartbeatConn
			heartbeatConn = runService.Heartbeat:Connect(function()
				if not myRoot2 or not myRoot2.Parent
 or not targetRoot2 or not targetRoot2.Parent then
					heartbeatConn:Disconnect()
					if ultHeartbeatConn == heartbeatConn then
						ultHeartbeatConn = nil
					end
					if sethiddenproperty then
						if myRoot2 and myRoot2.Parent then
							pcall(function()
								sethiddenproperty(myRoot2, "PhysicsRepRootPart", nil)
							end)
						end
						if targetRoot2 and targetRoot2.Parent then
							pcall(function()
								sethiddenproperty(targetRoot2, "PhysicsRepRootPart", nil)
							end)
						end
					end
					if myRoot2 and myRoot2.Parent then
						myRoot2.AssemblyLinearVelocity = Vector3.zero
						myRoot2.AssemblyAngularVelocity = Vector3.zero
						pcall(function()
							myRoot2.Velocity = Vector3.zero
						end)
						pcall(function()
							myRoot2.RotVelocity = Vector3.zero
						end)
					end
					return
				end
				myRoot2.CFrame = targetRoot2.CFrame * CFrame.new(0, 0, 5)
				myRoot2.AssemblyLinearVelocity = Vector3.zero
				myRoot2.AssemblyAngularVelocity = Vector3.zero
				if sethiddenproperty then
					pcall(function()
						sethiddenproperty(myRoot2, "PhysicsRepRootPart", targetRoot2)
					end)
				end
			end)
			ultHeartbeatConn = heartbeatConn
		end
		if animId:match("18896229321") then
			task.wait(0.01)
			if not ultStartup then
				return
			end
			ultFinished = false
			getgenv().desync = nil
			isTeleporting = true
			task.spawn(function()
				local myChar = getCharacter(localPlayer2)
				if not myChar then
					return
				end
				if myChar:GetAttribute("Character") ~= "Purple" then
					return
				end
				local ultDeadline = tick() + 3
				local ultActive = true
				local ultStart = tick()
				local animDuration = 70
				local animFps = 30
				local function extractAnimId(animationId)
					return animationId:match("%d+")
				end
				local function findUltTrack()
					for index2, track2 in ipairs(localPlayer2.Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
						if extractAnimId(track2.Animation.AnimationId) == "18896229321" then
							return track2
						end
					end
					return nil
				end
				local ultTrack = findUltTrack()
				while not ultTrack do
					task.wait()
					ultTrack = findUltTrack()
				end
				task.spawn(function()
					repeat
						task.wait()
						ultTrack = findUltTrack()
					until not ultTrack
						or (ultTrack.TimePosition >= animDuration / animFps)
						or (tick() >= ultStart + 2.2)
					ultFinished = true
					local myChar2 = getCharacter(localPlayer2)
					if not myChar2 then
						return
					end
					pcall(function()
						localPlayer2.Character.HumanoidRootPart.CFrame = CFrame.new(150, 441, 32)
					end)
					ultKeyReady = true
					pcall(function()
						localPlayer2.Character.HumanoidRootPart.CFrame = CFrame.new(0, -29000, 0)
					end)
					task.wait(1.5)
					pcall(function()
						localPlayer2.Character.HumanoidRootPart.CFrame = CFrame.new(150, 441, 32)
					end)
					isTeleporting = false
					task.wait(5)
					pcall(function()
						localPlayer2.Character.HumanoidRootPart.CFrame = CFrame.new(-42, 1855, 25227)
					end)
				end)
				local freezeConn = freezeVelocityWhile(function()
					return ultActive
				end)
				local doneTargets = {}
				local currentTarget2 = nil
				local targetSince = tick()
				local savedMyCFrame = nil
				do
					local myChar2 = getCharacter(localPlayer2)
					local myRoot2 = myChar2 and getRootPart(myChar2)
					if myRoot2 then
						savedMyCFrame = myRoot2.CFrame
					end
				end
				local function resolveCharacter(input)
					if not input then
						return nil
					end
					if input:IsA("Player") then
						return getCharacter(input)
					end
					return nil
				end
				local function getHumanoidOf(input)
					return getHumanoid(resolveCharacter(input))
				end
				local function getRootOf(input)
					return getRootPart(resolveCharacter(input))
				end
				local function isInvulnerable(char)
					if not char then
						return false
					end
					if char:FindFirstChild("ForceField") then
						return true
					end
					if char:FindFirstChild("AbsoluteImmortal") then
						return true
					end
					if char:FindFirstChild("BeingGrabbed") then
						return true
					end
					if char:FindFirstChild("HunterCounter") then
						return true
					end
					if char:FindFirstChild("AtomicCounter") then
						return true
					end
					if char:FindFirstChild("forcefield") then
						return true
					end
					return false
				end
				local function isTargetInvalid(target)
					local targetChar = resolveCharacter(target)
					local targetHumanoid = targetChar and getHumanoid(targetChar)
					local targetRoot2 = targetChar and getRootPart(targetChar)
					if not targetChar or not targetHumanoid or not targetRoot2 then
						return true
					end
					if targetHumanoid.Health <= 0 then
						return true
					end
					if target:IsA("Player") then
						if isInvulnerable(targetChar) then
							return true
						end
						if targetChar:FindFirstChild("Counter") then
							return true
						end
						if hasAnimation(targetHumanoid, "15128849047") then
							return true
						end
						if targetChar:GetAttribute("Ulted") and targetChar:GetAttribute("Character") == "Batter" then
							return true
						end
					end
					local targetRootPos = targetChar.HumanoidRootPart.Position
					if
						not (
							targetRootPos.X >= -500
							and targetRootPos.X <= 800
							and targetRootPos.Z >= -600
							and targetRootPos.Z <= 700
						)
					then
						return true
					end
					return false
				end
				local function isCounteringTarget(target)
					local targetHumanoid = getHumanoidOf(target)
					return targetHumanoid
						and (
							hasAnimation(targetHumanoid, "18896222853")
							or hasAnimation(targetHumanoid, "137434257516014")
						)
				end
				local function hasCounter(player)
					if not player or not player:IsA("Player") then
						return false
					end
					local char = getCharacter(player)
					local humanoid2 = char and getHumanoid(char)
					if not char or not humanoid2 then
						return false
					end
					if humanoid2.Health <= 0 then
						return false
					end
					if hasAnimation(humanoid2, "15128849047") then
						return false
					end
					return isInvulnerable(char)
				end
				local function findWeakestDummy()
					local dummy = workspace.Live:FindFirstChild("Weakest Dummy")
					if not dummy then
						return nil
					end
					local dummyHumanoid = getHumanoid(dummy)
					if not dummyHumanoid or dummyHumanoid.Health <= 0 then
						return nil
					end
					return dummy
				end
				local function findNextTarget(excludedTarget)
					local hunterTargets = {}
					local otherTargets = {}
					for index2, player in pairs(getOtherPlayers()) do
						if player == excludedTarget or doneTargets[player] then
							continue
						end
						local root = getRootOf(player)
						if not isTargetInvalid(player) and not isCounteringTarget(player) and root then
							if isHunterClass(player) then
								table.insert(hunterTargets, player)
							else
								table.insert(otherTargets, player)
							end
						end
					end
					if #hunterTargets > 0 then
						return hunterTargets[math.random(1, #hunterTargets)]
					end
					if #otherTargets > 0 then
						return otherTargets[math.random(1, #otherTargets)]
					end
					local dummy = findWeakestDummy()
					if dummy and dummy ~= excludedTarget and not doneTargets[dummy] then
						return dummy
					end
					return nil
				end
				local function restoreMyPosition()
					if not savedMyCFrame then
						return
					end
					local myChar2 = getCharacter(localPlayer2)
					local myRoot2 = myChar2 and getRootPart(myChar2)
					if myRoot2 then
						pcall(function()
							myRoot2.CFrame = savedMyCFrame
						end)
					end
				end
				local function restoreAutoRotate()
					local myChar2 = getCharacter(localPlayer2)
					local myHumanoid = myChar2 and getHumanoid(myChar2)
					if myHumanoid then
						pcall(function()
							myHumanoid.AutoRotate = true
						end)
					end
				end
				local function anyCounteringPlayer()
					for index2, player in pairs(getOtherPlayers()) do
						if doneTargets[player] then
							continue
						end
						if hasCounter(player) then
							return true
						end
					end
					return false
				end
				local cleanedUp = false
				local function endUlt()
					if cleanedUp then
						return
					end
					cleanedUp = true
					detachPhysics()
					restoreAutoRotate()
					if _ffWatchConn then
						pcall(function()
							_ffWatchConn:Disconnect()
						end)
					end
					if _dummyRespawnConn then
						pcall(function()
							_dummyRespawnConn:Disconnect()
						end)
					end
					if _currentTargetAnimConn then
						pcall(function()
							_currentTargetAnimConn:Disconnect()
						end)
						_currentTargetAnimConn = nil
					end
					ultActive = false
					detachPhysicsAll()
				end
				local targetAnimConn = nil
				local function setTarget(target)
					if targetAnimConn then
						pcall(function()
							targetAnimConn:Disconnect()
						end)
						targetAnimConn = nil
					end
					detachPhysics()
					currentTarget2 = target
					targetSince = tick()
					if target then
						local myChar2 = getCharacter(localPlayer2)
						local myRoot2 = myChar2 and getRootPart(myChar2)
						local targetRoot2 = getRootOf(target)
						if myRoot2 and targetRoot2 then
							attachPhysicsTo(myRoot2, targetRoot2)
							local targetHumanoid = getHumanoidOf(target)
							if targetHumanoid then
								local targetAnimator = targetHumanoid:FindFirstChildOfClass("Animator")
								local animPlayedSignal = targetAnimator and targetAnimator.AnimationPlayed
									or targetHumanoid.AnimationPlayed
								targetAnimConn = animPlayedSignal:Connect(function(track2)
									local animId2 = track2.Animation.AnimationId
									if animId2:match("18896222853") or animId2:match("137434257516014") then
										if not ultActive then
											return
										end
										local currentVictim = currentTarget2
										if not currentVictim then
											return
										end
										doneTargets[currentVictim] = true
										detachPhysics()
										local nextTarget = findNextTarget(currentVictim)
										if nextTarget then
											setTarget(nextTarget)
											if findNextTarget(nextTarget) == nil and not anyCounteringPlayer() then
												task.wait(0.1)
												doneTargets[nextTarget] = true
												_everybodyDone = true
												endUlt()
											end
										else
											if anyCounteringPlayer() then
												detachPhysics()
												currentTarget2 = nil
											else
												_everybodyDone = true
												endUlt()
											end
										end
									end
								end)
							end
						end
					end
				end
				local dummyAddedConn = workspace.Live.ChildAdded:Connect(function(newChild)
					if newChild.Name == "Weakest Dummy" then
						doneTargets[newChild] = nil
					end
				end)
				local respawnScanConn = runService.RenderStepped:Connect(function()
					for index2, player in pairs(getOtherPlayers()) do
						if not doneTargets[player] then
							continue
						end
						local char = getCharacter(player)
						local humanoid2 = char and getHumanoid(char)
						if char and humanoid2 and humanoid2.Health > 0 and not isInvulnerable(char) then
							doneTargets[player] = nil
							if not currentTarget2 then
								setTarget(player)
							end
						end
					end
				end)
				local ultEnded = false
				local firstTarget = findNextTarget(nil)
				if firstTarget then
					setTarget(firstTarget)
					if findNextTarget(firstTarget) == nil then
						task.wait(0.1)
						doneTargets[firstTarget] = true
						ultEnded = true
						endUlt()
						return
					end
				end
				while track.IsPlaying and tick() < ultDeadline do
					if ultFinished then
						ultEnded = true
						endUlt()
						break
					end
					runService.Heartbeat:Wait()
					local now = tick()
					local needRetarget = false
					if not currentTarget2 then
						needRetarget = true
					else
						if isTargetInvalid(currentTarget2) then
							if not hasCounter(currentTarget2) then
								doneTargets[currentTarget2] = true
							end
							needRetarget = true
						elseif now - targetSince >= 0.8 then
							doneTargets[currentTarget2] = true
							needRetarget = true
						end
					end
					if needRetarget then
						local nextTarget = findNextTarget(currentTarget2)
						if not nextTarget then
							if anyCounteringPlayer() then
								detachPhysics()
								currentTarget2 = nil
							else
								ultEnded = true
								endUlt()
								break
							end
						else
							setTarget(nextTarget)
							if findNextTarget(nextTarget) == nil and not anyCounteringPlayer() then
								task.wait(0.1)
								doneTargets[nextTarget] = true
								ultEnded = true
								endUlt()
								break
							end
						end
					end
				end
				endUlt()
			end)
		end
	end)
end

task.spawn(function()
	local totalKillsVal = leaderstats:WaitForChild("Total Kills")
	local lastEmoteSpin = localPlayer2:GetAttribute("LastEmoteSpin")
	local initialTotalKills = totalKillsVal.Value
	killsSinceLoad = totalKillsVal.Value - savedCarriedKills
	while true do
		task.wait(0.25)
		totalKills = totalKillsVal.Value
		carriedKills = 0
		sessionKills = totalKills - initialTotalKills
		local emoteSpinVal = localPlayer2:GetAttribute("LastEmoteSpin")
		if emoteSpinVal ~= lastEmoteSpin then
			savedEmotes = savedEmotes + 1
			lastEmoteSpin = emoteSpinVal
		end
		local elapsedHours = math.max(os.time() - sessionStartTime, 1) / 3600
		killsPerHour = math.floor(carriedKills / elapsedHours)
		killsValueLabel.Text = tostring(carriedKills)
	end

end)
task.spawn(function()
	while true do
		if farmEnabled then
			getgenv().TimeFarmed += 1
		end
		local timeFarmed = getgenv().TimeFarmed
		local hours = math.floor(timeFarmed / 3600)
		local minutes = math.floor((timeFarmed % 3600) / 60)
		local seconds = timeFarmed % 60
		task.wait(1)
	end

end)
localPlayer2.CharacterAdded:Connect(setupCharacterHandlers)

if localPlayer2.Character then
	setupCharacterHandlers(localPlayer2.Character)
end

local serverQuery = {
	{
		QueryV2 = true,
		Page = 1,
		Filters = {
			Countries = {
				[farmSettings.country] = true,
			},
			Tags = {},
			HideFull = true,
			HideTagged = false,
			FriendsOnly = false,
			HidePassword = false,
		},
		limit = 60,
		Category = "Server List",
		Region = farmSettings.country,
		Sort = {
			Keys = {
				{
					By = "kills",
					Dir = "low",
				},
			},
		},
		Search = "",
		notFull = false,
	},
}

local function queueTeleportScript()
	local teleportCode = string.format(
		'getgenv().TimeFarmed=%d\010getgenv().SavedCarriedKills=%d\010getgenv().SavedEmotes=%d\010getgenv().SavedSessionStart=%d\010getgenv().renderEnabled=%s\010getgenv().PYKey = %q\010loadstring(game:HttpGet("https://gitlab.com/zkay404-group/ProjectYielding/-/raw/main/ZKPublicFarm"))()\010',
		getgenv().TimeFarmed,
		carriedKills,
		savedEmotes,
		sessionStartTime,
		tostring(getgenv().renderEnabled or false),
		tostring(getgenv().PYKey or "")
	)
	pcall(queue_on_teleport, teleportCode)
end

local function pickServer(serverData)
	local candidateIds = {}
	for idx, val in ipairs(serverData.servers) do
		local playerCount = val.players
		if playerCount and playerCount >= 10 and playerCount <= 13 then
			table.insert(candidateIds, val.id)
		end
	end
	if #candidateIds == 0 then
		return nil
	end
	local randomIndex = math.random(1, #candidateIds)
	return candidateIds[randomIndex]
end

local isHopping = false
local forceHop = false

function hopServer()
	if (not forceHop) and not farmEnabled then
		return
	end
	if isHopping then
		return
	end
	isHopping = true
	repeat
		task.wait()
	until (not isUlted) and not isTeleporting
	queueTeleportScript()
	task.spawn(function()
		while true do
			local serverList = game:GetService("ReplicatedStorage")
				:WaitForChild("Ranked")
				:WaitForChild("GetServerBrowserData")
				:InvokeServer(jsonEncode(serverQuery))
			local serverId = pickServer(serverList)
			if serverId then
				local teleportOk, teleportErr = pcall(function()
					teleportService:TeleportToPlaceInstance(game.PlaceId, serverId, localPlayer2)
				end)
				if not teleportOk then
					task.wait(2)
				else
					task.wait(5)
				end
			else
				task.wait(3)
			end
		end
	end)
end


local blacklistIds = {
	422755031,
	198131804,
	681405668,
	3414432341,
	339633571,
	430966809,
	2039323684,
	117723419,
	1015595932,
	263944298,
	112905203,
	2284964418,
	1266437961,
	3120648134,
	1148139861,
	1633233654,
	3350014406,
	971193650,
	661273560,
	66105529,
	77342385,
	167343092,
	2055306963,
	141984224,
	438917845,
	1391134999,
	1796550069,
	255671730,
	3162123826,
	1059541187,
	1259898795,
	31070091,
	1041867508,
	994994173,
	1446694201,
	77525605,
	1001242712,
	2533866869,
	4983064295,
}

local function checkPlayerThreat(player)
	if player == localPlayer2 then
		return
	end
	local displayName = player.DisplayName
	local nameTag = displayName .. "(@" .. player.Name .. ")"
	local staffGroups = { "Staff", "Special People", "Friends with Staff" }
	local groupOk, isInGroup = pcall(function()
		return player:IsInGroup(
			(
				(
					((54 * (("g"):byte()) - 738396) + (22 * (("F"):byte()) + 1425080))
					+ ((442333 + 196920) + (-960142 + 442234))
				)
				+ (
					((35 * (("7"):byte()) - 622316) + (math.floor(1327254.6450)))
					+ ((97588 - 410936) + (math.ceil(10804360.3480)))
				)
			)
		)
	end)
	if groupOk and isInGroup then
		local roleOk, role = pcall(function()
			return player:GetRoleInGroup(
				(
					(
						((43 * #"VSSHreQRSqCgXAkiHpTecdffyl" - 392660) + (math.ceil(875422.2910)))
						+ ((42 * (("v"):byte()) + 810279) + (-653216 + 71653))
					)
					+ (
						((math.ceil(616649.5980)) + (443906 - 866208))
						+ ((48 * (("s"):byte()) - 400009) + (12242558 - 746963))
					)
				)
			)
		end)
		local isStaff = false
		local roleText = (roleOk and role) and role or "?"
		if roleOk and role then
			local roleLower = role:lower()
			isStaff = roleLower:find("moderator")
				or roleLower:find("developer")
				or roleLower:find("contributor")
				or roleLower:find("tester")
				or roleLower:find("owner")
				or roleLower:find("anomaly player")
		end
		if isStaff then
			setFarmState(false)
			forceHop = true
			hopServer()
			return
		end
	end
	for index2, blacklistId in ipairs(blacklistIds) do
		if player.UserId == blacklistId then
			setFarmState(false)
			forceHop = true
			hopServer()
			return
		end
	end
	local friendNames = {}
	for index3, friendId in ipairs(blacklistIds) do
		local friendsOk, isFriend = pcall(function()
			return player:IsFriendsWith(friendId)
		end)
		if friendsOk and isFriend then
			local nameOk, friendName = pcall(function()
				return playersService2:GetNameFromUserIdAsync(friendId)
			end)
			if nameOk then
				local displayName2 = friendName
				pcall(function()
					local userInfos = game:GetService("UserService"):GetUserInfosByUserIdsAsync({ friendId })
					if userInfos and userInfos[1] then
						displayName2 = userInfos[1].DisplayName
					end
				end)
				friendNames[#friendNames + 1] = displayName2 .. "(@" .. friendName .. ")"
			end
		end
	end
	if #friendNames > 0 then
		setFarmState(false)
		forceHop = true
		hopServer()
		return
	end
	local leaderstats2 = player:FindFirstChild("leaderstats")
	local totalKillsVal = nil
	if leaderstats2 then
		totalKillsVal = leaderstats2:FindFirstChild("Total Kills")
	else
		totalKillsVal = player:FindFirstChild("Total Kills")
	end
	if totalKillsVal and totalKillsVal.Value >= 10000 then
		hopServer()
		return true
	end
	if not totalKillsVal then
		local leaderstatsConn
		leaderstatsConn = player.ChildAdded:Connect(function(leaderstatsInstance)
			if leaderstatsInstance.Name == "leaderstats" then
				leaderstatsConn:Disconnect()
				local killsConn
				killsConn = leaderstatsInstance.ChildAdded:Connect(function(killsValue)
					if killsValue.Name == "Total Kills" then
						killsConn:Disconnect()
						if killsValue.Value >= 10000 then
							hopServer()
							return
						end
						local killsChangedConn
						killsChangedConn = killsValue:GetPropertyChangedSignal("Value"):Connect(function()
							if killsValue.Value >= 10000 then
								killsChangedConn:Disconnect()
								hopServer()
							end
						end)
					end
				end)
			end
		end)
		return
	end
	local killsChangedConn
	killsChangedConn = totalKillsVal:GetPropertyChangedSignal("Value"):Connect(function()
		if totalKillsVal.Value >= 10000 then
			killsChangedConn:Disconnect()
			hopServer()
		end
	end)
end

local playerAddedConn = playersService2.PlayerAdded:Connect(function(player)
	task.spawn(pcall, checkPlayerThreat, player)
end)

for index2, player in pairs(playersService2:GetPlayers()) do
	if player ~= localPlayer2 then
		task.spawn(pcall, checkPlayerThreat, player)
	end

end

local unusedFlag2 = true
deathCounterConns = {}
deathCounterDebounce = {}
hookedChars = {}
local watchPlayerCounters
local watchPlayerCombat
local combatConns
local counterHooks
local isReviving = false

local function getReviveTime()
	return 0
end

local function isCounterAccessory(instance)
	return instance:IsA("Accessory") and instance.Name == "Counter"
end

local counterHookEnabled = false
local reviveAnimConn = nil
local charAddedConn = nil

local function setRootCFrame(cframe)
	local value = localPlayer2.Character
	local rootPart = value and value:FindFirstChild("HumanoidRootPart")
	if not (value and rootPart) then
		return
	end
	task.spawn(function()
		runService.RenderStepped:Once(function()
			rootPart.Velocity = Vector3.new()
			runService.Heartbeat:Wait()
			rootPart.Velocity = Vector3.new()
		end)
		runService.Heartbeat:Once(function()
			rootPart.CFrame = cframe
		end)
	end)
end

local function resetCamera()
	local myChar = localPlayer2.Character
	local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
	if myChar and myHumanoid and workspace.CurrentCamera then
		local camCFrame = workspace.CurrentCamera.CFrame
		workspace.CurrentCamera:Destroy()
		local newCamera = Instance.new("Camera", workspace)
		newCamera.CameraType = Enum.CameraType.Custom
		newCamera.CameraSubject = myHumanoid
		newCamera.CFrame = camCFrame
		localPlayer2.CameraMode = Enum.CameraMode.Classic
		local head = myChar:FindFirstChild("Head")
		if head then
			head.Anchored = false
		end
	end

end

local function getDisplayName(player2)
	local displayOk, displayName = pcall(function()
		return player2.DisplayName
	end)
	if not displayOk or not displayName or displayName == "" then
		return player2.Name
	end
	for index3, otherPlayer in pairs(playersService2:GetPlayers()) do
		if otherPlayer ~= player2 and otherPlayer.DisplayName == displayName then
			return player2.Name
		end
	end
	return displayName
end

local function watchReviveAnim(humanoid)
	if reviveAnimConn then
		reviveAnimConn:Disconnect()
		reviveAnimConn = nil
	end
	if not humanoid then
		return
	end
	reviveAnimConn = humanoid.AnimationPlayed:Connect(function(track)
		if not track.Animation.AnimationId:match("11343250001") then
			return
		end
		isReviving = true
		task.spawn(function()
			task.wait(0.2)
			local reviveTime = getReviveTime()
			local stopped = reviveTime <= 0
			if reviveTime <= 0 then
				pcall(function()
					track:Stop()
				end)
			end
			task.spawn(resetCamera)
			local myChar = localPlayer2.Character
			myChar:WaitForChild("AbsoluteImmortal", 1)
			local myRoot = myChar:FindFirstChild("HumanoidRootPart")
			local savedCFrame = myRoot.CFrame
			local counterPlayer = nil
			for index3, player2 in pairs(playersService2:GetPlayers()) do
				if player2 ~= localPlayer2 then
					local char = player2.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					local humanoid2 = char and char:FindFirstChildOfClass("Humanoid")
					if char and root and humanoid2 then
						for index4, track2 in pairs(humanoid2:GetPlayingAnimationTracks()) do
							if
								track2.Animation.AnimationId:match("11343318134")
								and (myRoot.Position - root.Position).Magnitude <= 15
							then
								counterPlayer = player2
							end
						end
					end
				end
			end
			local counterHumanoid = nil
			local counterName = nil
			if counterPlayer then
				local counterChar = counterPlayer.Character
				counterHumanoid = counterChar and counterChar:FindFirstChildOfClass("Humanoid")
				counterName = getDisplayName(counterPlayer)
			else
				local dummyModel = Instance.new("Model")
				local dummyHumanoid = Instance.new("Humanoid", dummyModel)
				dummyHumanoid.Health = 100
				counterHumanoid = dummyHumanoid
				counterName = nil
				task.delay(
					reviveTime
						+ (
							(
								((358704 - 805113) + (math.ceil(15935.2020)))
								+ ((51 * (("L"):byte()) - 415533) + (1975737 - 951120))
							)
							+ (
								((44 * (("Y"):byte()) + 372062) + (math.floor(497613.2920)))
								+ ((1 * #"ygCJhavjXVJopLxpb" - 239896) + (-224387 - 591810))
							)
						),
					function()
						dummyHumanoid.Health = 0
					end
				)
			end
			if reviveTime > 0 then
				task.wait(reviveTime)
				myChar = localPlayer2.Character
				myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if not (myChar and myRoot) then
					return
				end
			end
			local oldSubject = workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject
			if workspace.CurrentCamera then
				workspace.CurrentCamera.CameraSubject = nil
			end
			local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
			local sinkCFrame = CFrame.new(0, -10000, 0) * CFrame.Angles(math.rad(90), 0, 0)
			local startTick = tick()
			repeat
				setRootCFrame(sinkCFrame)
				if reviveTime > 0 and not stopped then
					stopped = true
					pcall(function()
						track:Stop()
					end)
				end
				runService.RenderStepped:Wait()
			until (counterHumanoid and counterHumanoid.Health <= 0)
				or (myHumanoid and myHumanoid.Health <= 0)
				or tick() >= startTick + 10
			if workspace.CurrentCamera then
				workspace.CurrentCamera.CameraSubject = oldSubject
			end
			setRootCFrame(savedCFrame)
			task.wait(1)
			local myChar2 = localPlayer2.Character
			if myChar2 then
				local freeze = myChar2:FindFirstChild("Freeze")
				local noRotate = myChar2:FindFirstChild("NoRotate")
				if freeze then
					freeze:Destroy()
				end
				if noRotate then
					noRotate:Destroy()
				end
			end
			task.spawn(resetCamera)
			isReviving = false
		end)
	end)
end

local function hookCharacterRevive(character)
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		watchReviveAnim(humanoid)
	else
		task.spawn(function()
			local humanoid2 = character:WaitForChild("Humanoid", 5)
			if humanoid2 then
				watchReviveAnim(humanoid2)
			end
		end)
	end

end

hookCharacterRevive(localPlayer2.Character)
charAddedConn = localPlayer2.CharacterAdded:Connect(function(newCharacter)
	task.wait(0.1)
	hookCharacterRevive(newCharacter)
end)

local function hookCounterOnCharacter(char, player2)
	if not char or not player2 or player2 == localPlayer2 then
		return
	end
	if hookedChars[char] then
		return
	end
	hookedChars[char] = true
	for index3, child in pairs(char:GetChildren()) do
		if isCounterAccessory(child) then
			if counterHookEnabled and not deathCounterDebounce[player2] then
				deathCounterDebounce[player2] = true
			end
		end
	end
	local childAddedConn = char.ChildAdded:Connect(function(newChild)
		if not counterHookEnabled then
			return
		end
		if not isCounterAccessory(newChild) then
			return
		end
		if deathCounterDebounce[player2] then
			return
		end
		deathCounterDebounce[player2] = true
	end)
	table.insert(deathCounterConns, childAddedConn)
end

local function hookPlayerCounter(player2)
	if player2 == localPlayer2 then
		return
	end
	if player2.Character then
		task.spawn(hookCounterOnCharacter, player2.Character, player2)
	end
	local charAddedConn2 = player2.CharacterAdded:Connect(function(newChar)
		if not counterHookEnabled then
			return
		end
		task.wait(0.1)
		hookCounterOnCharacter(newChar, player2)
	end)
	table.insert(deathCounterConns, charAddedConn2)
end

for index3, conn in pairs(deathCounterConns) do
	pcall(conn.Disconnect, conn)
end

for index4, player2 in pairs(playersService2:GetPlayers()) do
	hookPlayerCounter(player2)
end

table.insert(
	deathCounterConns,
	playersService2.PlayerAdded:Connect(function(player3)
		if counterHookEnabled then
			hookPlayerCounter(player3)
		end
	end)
)
combatConns = {}
counterHooks = {}
local flag = false
local desyncResetConn = localPlayer2.CharacterAdded:Connect(function()
	getgenv().desync = nil
end)
isCountering = function(humanoid)
	if not humanoid then
		return false
	end
	local model = humanoid:FindFirstAncestorWhichIsA("Model")
	if model and model:FindFirstChild("Counter") then
		return true
	end
	for index5, track in pairs(humanoid:GetPlayingAnimationTracks()) do
		local animId = track.Animation.AnimationId
		if animId:match("13726226905") or animId:match("13726235415") then
			return true
		end
	end
	return false
end

watchPlayerCombat = function(player3, char)
	if not char then
		return
	end
	if combatConns[player3] then
		pcall(function()
			combatConns[player3]:Disconnect()
		end)
		combatConns[player3] = nil
	end
	repeat
		task.wait()
	until not char.Parent
		or (char:FindFirstChild(("H" .. "umanoidRootPart"))
 and char:FindFirstChildOfClass("Humanoid"))
	if not char.Parent then
		return
	end
	local targetRoot = char:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = char:FindFirstChildOfClass("Humanoid")
	if not (targetRoot and targetHumanoid) then
		return
	end
	local function findTrackByAnimId(humanoid, animId)
		local idPattern = tostring(animId):match("%d+")
		for index5, track in pairs(humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.AnimationId:match(idPattern) then
				return track
			end
		end
		return nil
	end
	local animPlayedConn = targetHumanoid.AnimationPlayed:Connect(function(track)
		local animId = track.Animation.AnimationId
		local myChar = localPlayer2.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if not (myChar and myRoot) then
			return
		end
		task.spawn(function()
			if track.WeightTarget == 0 or track.Speed == 0 then
				return
			end
			local desyncPos = CFrame.new(9e9, 9e9, 9e9)
			local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
			local function runDesync(stopCondition)
				pcall(function()
					repeat
						getgenv().desync = { CFrame = desyncPos }
						task.wait()
						local myChar2 = localPlayer2.Character
						local myRoot2 = myChar2 and myChar2:FindFirstChild("HumanoidRootPart")
						local myHumanoid2 = myChar2 and myChar2:FindFirstChildOfClass("Humanoid")
						if not (myChar2 and myRoot2 and myHumanoid2) then
							return
						end
						myRoot = myRoot2
						myHumanoid = myHumanoid2
					until stopCondition()
				end)
				getgenv().desync = nil
				if sethiddenproperty then
					local myRoot2 = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
					if myRoot2 then
						pcall(function()
							sethiddenproperty(myRoot2, "PhysicsRepRootPart", nil)
						end)
					end
				end
			end
			local function isCountered(humanoid)
				if not humanoid then
					return false
				end
				local model = humanoid:FindFirstAncestorWhichIsA("Model")
				return model and model:FindFirstChild("Counter") and true or false
			end
			local function makeTouchProbe(probeSize)
				local probePart = Instance.new("Part", workspace)
				probePart.Anchored = true
				probePart.Size = probeSize
				probePart.CanCollide = false
				probePart.Transparency = 1
				local isTouched = false
				local touchedConn = probePart.Touched:Connect(function(otherPart)
					if otherPart == myRoot then
						isTouched = true
					end
				end)
				local touchEndedConn = probePart.TouchEnded:Connect(function(otherPart)
					if otherPart == myRoot then
						isTouched = false
					end
				end)
				return probePart,
					function()
						return isTouched
					end,
					function()
						pcall(function()
							probePart:Destroy()
						end)
						touchedConn:Disconnect()
						touchEndedConn:Disconnect()
					end
			end
			local function getCombatPos()
				return myRoot.Position
			end
			if animId:match("12983333733")
 and char:GetAttribute("Ulted") ~= nil then
				task.delay(
					(
						(
							((math.floor(51865.1240)) + (20 * (("I"):byte()) - 900478))
							+ ((11 * (("z"):byte()) + 653714) + (38 * (("k"):byte()) + 512843))
						)
						+ (
							((1770345 - 932208) + (math.ceil(142528.0460)))
							+ ((math.floor(284682.5050)) + (47 * #"mfZCqLIR" - 1590535))
						)
					),
					function()
						if char:FindFirstChild("AbsoluteImmortal", true) and char:FindFirstChild("Freeze") then
							task.wait(4.25)
							local startTick = tick()
							runDesync(function()
								return (getCombatPos() - targetRoot.Position).Magnitude > 150
 or tick() >= startTick + 2
 or not track.IsPlaying
							end)
						end
					end
				)
			end
			if animId:match("11365563255")
 and char:GetAttribute("Ulted") ~= nil then
				task.delay(
					(
						(
							((43 * (("p"):byte()) - 637418) + (-112592 + 586155))
							+ ((649517 - 598260) + (bit32.bxor(27709, 47697) + 219015))
						)
						+ (
							((-856097 - 94089) + (bit32.bxor(32106, 771414) + 844955))
							+ ((math.floor(983374.2500)) + (2 * #"oqqSMwNadSYgCfIffCRJ" - 1812367))
						)
					),
					function()
						if char:FindFirstChild("AbsoluteImmortal", true) and char:FindFirstChild("Freeze") then
							task.wait(3)
							local startTick = tick()
							runDesync(function()
								return tick() >= startTick + 2.5
							end)
						end
					end
				)
			end
			if animId:match("13927612951")
 and char:GetAttribute("Ulted") ~= nil then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 150
 or tick() >= startTick + 2.5
				end)
			end
			if animId:match("12342141464") then
				task.wait(3.5)
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 125
 or tick() >= startTick + 1.25
				end)
			end
			if animId:match("12463072679") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 25
 or tick() >= startTick + 0.75
				end)
			end
			if animId:match("13603396939") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - (targetRoot.CFrame * CFrame.new(0, 0, -1)).Position).Magnitude > 7.5
 or isCountering(
						targetHumanoid
					)
 or tick() >= startTick + 2.5
				end)
			end
			if animId:match("12460977270") then
				local probePart1, isTouched1, cleanupProbe1 = makeTouchProbe(
					Vector3.new(
						12.5,
						(
							(
								((36 * #"HaHsNNotsDLfaCtHic" - 695117) + (6 * #"fZLQ" + 1147034))
								+ ((34 * (("I"):byte()) + 132643) + (bit32.bxor(17906, 89215) + 30526))
							)
							+ (
								((13 * #"DDtLGk" + 82403) + (-1627784 + 676021))
								+ ((-761984 + 215864) + (55 * #"vwHALNkgicrQrUAwJdaKm" + 723935))
							)
						),
						12.5
					)
				)
				local probeTick1 = tick()
				repeat
					probePart1.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -6.25)
					if isTouched1() and not isCountering(targetHumanoid) then
						getgenv().desync = { CFrame = desyncPos }
					else
						getgenv().desync = nil
					end
					runService.RenderStepped:Wait()
				until tick() >= probeTick1 + 1.85 or not track.IsPlaying
				getgenv().desync = nil
				cleanupProbe1()
			end
			if animId:match("14057231976") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 10
 or tick() >= startTick + 0.5
				end)
				task.wait(0.5)
				local startTick2 = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 10
 or isCountering(targetHumanoid)
 or tick() >= startTick2 + 1.25
				end)
			end
			if animId:match("13630786846") then
				local probePart2, isTouched2, cleanupProbe2 = makeTouchProbe(
					Vector3.new(
						(
							(
								((37 * (("C"):byte()) + 691759) + (2 * #"YcKqhgGGuExFmyyUozjqZa" - 298927))
								+ ((56 * (("q"):byte()) - 924025) + (39 * (("B"):byte()) - 12067))
							)
							+ (
								((25 * (("k"):byte()) + 610396) + (-1309775 - 50838))
								+ ((42 * (("W"):byte()) + 921824) + (bit32.bxor(55513, 226818) + 112553))
							)
						),
						(
							(
								((42 * (("T"):byte()) - 172092) + (-646404 + 411068))
								+ ((32011 + 91227) + (2 * (("M"):byte()) + 4680))
							)
							+ (
								((-607506 + 940001) + (-448832 - 478050))
								+ ((math.floor(114067.6730)) + (bit32.bxor(19802, 322393) + 451515))
							)
						),
						(
							(
								((44 * (("X"):byte()) - 395596) + (52 * (("2"):byte()) - 563530))
								+ ((58 * (("w"):byte()) - 31911) + (bit32.bxor(42690, 799400) + 375889))
							)
							+ (
								((12 * (("E"):byte()) - 834396) + (6 * (("d"):byte()) + 675328))
								+ ((694188 - 202524) + (14 * (("2"):byte()) - 557301))
							)
						)
					)
				)
				local probeTick2 = tick()
				repeat
					probePart2.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -37.5)
					if isTouched2() and not isCountering(targetHumanoid) then
						getgenv().desync = { CFrame = desyncPos }
					else
						getgenv().desync = nil
					end
					runService.RenderStepped:Wait()
				until tick() >= probeTick2 + 1.5 or not track.IsPlaying
				getgenv().desync = nil
				cleanupProbe2()
			end
			if animId:match("72451715583225") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 15
 or tick() >= startTick + 0.75
				end)
			end
			if animId:match("13813955149") then
				if (getCombatPos() - targetRoot.Position).Magnitude <= 25 then
					getgenv().desync = { CFrame = CFrame.new(9e9, 9e9, 9e9) }
					task.wait(0.75)
					getgenv().desync = nil
				end
				local holder = nil
				holder = workspace.Thrown.ChildAdded:Connect(function(arg)
					if arg:IsA("MeshPart") and arg.Name:lower() == "trash can" then
						holder:Disconnect()
						local startTick = tick()
						runDesync(function()
							return (getCombatPos() - arg.Position).Magnitude > 25
 or tick() >= startTick + 2
						end)
					end
				end)
			end
			if animId:match("15128849047") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 100
 or findTrackByAnimId(
						targetHumanoid,
						"15123665491"
					)
 or tick() >= startTick + 3
				end)
			end
			if animId:match("15391323441") then
				task.wait(5.5)
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 125
 or tick() >= startTick + 1
				end)
			end
			if animId:match("16082123712") then
				task.wait(2.5)
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 50
 or tick() >= startTick + 1.5
				end)
			end
			if animId:match("14719290328") then
				if (getCombatPos() - targetRoot.Position).Magnitude <= 50 then
					getgenv().desync = { CFrame = CFrame.new(9e9, 9e9, 9e9) }
				end
				task.wait(0.5)
				if track.IsPlaying then
					local startTick = tick()
					runDesync(function()
						return (getCombatPos() - targetRoot.Position).Magnitude > 50
 or isCountered(myHumanoid)
 or tick() >= startTick + 3.5
 or not track.IsPlaying
					end)
				end
			end
			if animId:match("15520132233") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 50
 or isCountered(myHumanoid)
 or tick() >= startTick + 3.3
 or not track.IsPlaying
				end)
				repeat
					task.wait()
				until tick() >= startTick + 5.5
				local startTick2 = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 100
 or isCountered(myHumanoid)
 or tick() >= startTick2 + 1
 or not track.IsPlaying
				end)
			end
			if animId:match("15676072469") then
				local probePart3, isTouched3, cleanupProbe3 = makeTouchProbe(
					Vector3.new(
						(
							(
								((25 * #"OkMQbN" + 937922) + (56 * (("m"):byte()) - 180662))
								+ ((49 * #"cqyDjeKIsIprKWFWdi" - 227951) + (math.ceil(435001.7390)))
							)
							+ (
								((10 * (("O"):byte()) + 933793) + (-282252 - 397339))
								+ ((-919957 + 934034) + (12 * (("K"):byte()) - 1241366))
							)
						),
						(
							(
								((31 * (("2"):byte()) + 694401) + (-1751645 + 896622))
								+ ((bit32.bxor(20023, 247830) + 574965) + (32 * (("R"):byte()) - 1054622))
							)
							+ (
								((10 * (("U"):byte()) + 677700) + (248283 - 60033))
								+ ((math.ceil(231194.6900)) + (18 * #"lxEWKmbL" - 692969))
							)
						),
						(
							(
								((bit32.bxor(45816, 97507) + 285179) + (45 * #"nSrxXxjz" - 190659))
								+ ((9 * #"XARnxrvkcZrPGRd" - 863753) + (bit32.bxor(27712, 283122) + 120477))
							)
							+ (((824213 - 159094) + (-1631845 + 734011)) + ((-160307 - 159411) + (-93133 + 897740)))
						)
					)
				)
				local probeTick3 = tick()
				repeat
					probePart3.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -75)
					if isTouched3() and not isCountered(myHumanoid) then
						getgenv().desync = { CFrame = desyncPos }
					else
						getgenv().desync = nil
					end
					runService.RenderStepped:Wait()
				until tick() >= probeTick3 + 2 or not track.IsPlaying
				getgenv().desync = nil
				cleanupProbe3()
			end
			if animId:match("16057411888") then
				task.wait(4.25)
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 50
 or tick() >= startTick + 2
				end)
			end
			if animId:match("18435535291") then
				task.wait(4.25)
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 100
 or tick() >= startTick + 1.25
				end)
			end
			if animId:match("17857788598") then
				task.wait(0.65)
				if track.IsPlaying then
					local probePart = Instance.new("Part", workspace)
					probePart.Anchored = true
					probePart.Size = Vector3.new(35, 2048, 35)
					probePart.CanCollide = false
					probePart.Transparency = 1
					local isTouched = false
					local touchedConn = probePart.Touched:Connect(function(arg)
						if arg == myRoot then
							isTouched = true
						end
					end)
					local touchEndedConn = probePart.TouchEnded:Connect(function(arg)
						if arg == myRoot then
							isTouched = false
						end
					end)
					local probeTick = tick()
					repeat
						probePart.CFrame = targetRoot.CFrame
						if isTouched and not findTrackByAnimId(targetHumanoid, "15128849047") then
							getgenv().desync = { CFrame = CFrame.new(9e9, 9e9, 9e9) }
						else
							getgenv().desync = nil
						end
						runService.RenderStepped:Wait()
					until tick() >= probeTick + 0.85 or not track.IsPlaying
					getgenv().desync = nil
					touchedConn:Disconnect()
					touchEndedConn:Disconnect()
					pcall(function()
						probePart:Destroy()
					end)
				end
			end
			if animId:match("129651400898906") then
				task.wait(0.5)
				local value = targetRoot.CFrame
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 75
 or tick() >= startTick + 1.25
 or not track.IsPlaying
				end)
				task.wait(1)
				local startTick2 = tick()
				runDesync(function()
					return (getCombatPos() - value.Position).Magnitude > 75
 or tick() >= startTick2 + 1.75
				end)
			end
			if animId:match("18896229321") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 15
 or isCountering(targetHumanoid)
 or tick() >= startTick + 3.5
 or not track.IsPlaying
				end)
				task.wait(1)
				if track.IsPlaying then
					if (getCombatPos() - targetRoot.Position).Magnitude <= 25 then
						local startTick2 = tick()
						runDesync(function()
							return (getCombatPos() - targetRoot.Position).Magnitude > 25
 or tick() >= startTick2 + 2
 or not track.IsPlaying
						end)
					end
				end
			end
			if animId:match("18897119503") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 50
 or tick() >= startTick + 1.5
				end)
			end
			if animId:match("106755459092436") or animId:match("75502010126640") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 50
 or tick() >= startTick + 2
				end)
			end
			if animId:match("16515850153") then
				task.spawn(function()
					if (getCombatPos() - targetRoot.Position).Magnitude <= 15 then
						getgenv().desync = { CFrame = CFrame.new(9e9, 9e9, 9e9) }
					end
					local var = workspace.Thrown:WaitForChild("Dotted", 1)
					if var then
						local dotsPart = var:WaitForChild("Dots", 1)
						if not dotsPart then
							getgenv().desync = nil
							return
						end
						local startTick = tick()
						if (getCombatPos() - dotsPart.Position).Magnitude > 20 then
							getgenv().desync = nil
						end
						runDesync(function()
							return (getCombatPos() - var2.Position).Magnitude > 20
 or isCountered(myHumanoid)
 or tick() >= startTick + 4.25
						end)
					else
						getgenv().desync = nil
					end
				end)
			end
			if animId:match("16431491215") then
				local startTick = tick()
				repeat
					task.wait()
				until (getCombatPos() - (targetRoot.CFrame * CFrame.new(0, 0, -25)).Position).Magnitude <= 25
					or findTrackByAnimId(targetHumanoid, "15128849047")
					or tick() >= startTick + 0.75
				if not findTrackByAnimId(targetHumanoid, "15128849047") then
					runDesync(function()
						return (getCombatPos() - (targetRoot.CFrame * CFrame.new(0, 0, -20)).Position).Magnitude > 25
 or findTrackByAnimId(
							targetHumanoid,
							"15128849047"
						)
 or tick() >= startTick + 0.75
					end)
				end
			end
			if animId:match("16597912086") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 15
 or isCountering(targetHumanoid)
 or tick() >= startTick + 0.75
				end)
			end
			if animId:match("17275150809") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 50
 or tick() >= startTick + 1
				end)
			end
			if animId:match("17278415853")
 and char:GetAttribute("Character") == "Esper" then
				task.wait(11)
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 100
 or tick() >= startTick + 6
				end)
			end
			if animId:match("16734584478") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 75
 or tick() >= startTick + 5.75
				end)
			end
			if animId:match("13376869471") then
				local probePart = Instance.new("Part", workspace)
				probePart.Anchored = true
				probePart.Size = Vector3.new(10, 7.5, 60)
				probePart.CanCollide = false
				probePart.Transparency = 1
				local isTouched = false
				local touchedConn = probePart.Touched:Connect(function(arg)
					if arg == myRoot then
						isTouched = true
					end
				end)
				local touchEndedConn = probePart.TouchEnded:Connect(function(arg)
					if arg == myRoot then
						isTouched = false
					end
				end)
				local probeTick = tick()
				repeat
					probePart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -probePart.Size.Z / 2)
					runService.RenderStepped:Wait()
				until isTouched or tick() >= probeTick + 3 or not track.IsPlaying
				if isTouched then
					local probeTick2 = tick()
					runDesync(function()
						return not isTouched or tick() >= probeTick2 + 1 or not track.IsPlaying
					end)
				end
				touchedConn:Disconnect()
				touchEndedConn:Disconnect()
				pcall(function()
					probePart:Destroy()
				end)
			end
			if animId:match("13294790250") then
				task.wait(0.5)
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - (targetRoot.CFrame * CFrame.new(0, 0, -2.5)).Position).Magnitude > 10
 or isCountering(
						targetHumanoid
					)
 or tick() >= startTick + 0.75
				end)
			end
			if animId:match("13632347366") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 75
 or isCountered(myHumanoid)
 or tick() >= startTick + 1.75
 or not track.IsPlaying
				end)
			end
			if animId:match("13723174078") then
				task.wait(0.5)
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 50
 or tick() >= startTick + 2
 or not track.IsPlaying
				end)
			end
			if animId:match("13881335713") then
				task.wait(0.75)
				if track.IsPlaying then
					local probePart = Instance.new("Part", workspace)
					probePart.Anchored = true
					probePart.Size = Vector3.new(35, 5, 60)
					probePart.CanCollide = false
					probePart.Transparency = 1
					local isTouched = false
					local touchedConn = probePart.Touched:Connect(function(arg)
						if arg == myRoot then
							isTouched = true
						end
					end)
					local touchEndedConn = probePart.TouchEnded:Connect(function(arg)
						if arg == myRoot then
							isTouched = false
						end
					end)
					local probeTick = tick()
					repeat
						probePart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -probePart.Size.Z / 2)
						runService.RenderStepped:Wait()
					until isTouched or tick() >= probeTick + 3 or not track.IsPlaying
					if isTouched then
						local probeTick2 = tick()
						runDesync(function()
							return not isTouched or tick() >= probeTick2 + 1 or not track.IsPlaying
						end)
					end
					touchedConn:Disconnect()
					touchEndedConn:Disconnect()
					pcall(function()
						probePart:Destroy()
					end)
				end
			end
			if animId:match("14721837245") then
				local startTick = tick()
				runDesync(function()
					return (getCombatPos() - targetRoot.Position).Magnitude > 25
 or findTrackByAnimId(
						targetHumanoid,
						"15128849047"
					)
 or tick() >= startTick + 1.5
 or not track.IsPlaying
				end)
				if tick() >= startTick + 1.5 then
					task.wait(1)
					local startTick2 = tick()
					runDesync(function()
						return (getCombatPos() - targetRoot.Position).Magnitude > 100
 or tick() >= startTick2 + 1.5
 or not track.IsPlaying
					end)
				end
			end
			if animId:match("13083332742") then
				task.wait(1)
				local probePart = Instance.new("Part", workspace)
				probePart.Anchored = true
				probePart.Size = Vector3.new(12.5, 5, 1000)
				probePart.CanCollide = false
				probePart.Transparency = 1
				task.delay(0.25, function()
					probePart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -probePart.Size.Z / 2)
				end)
				local isTouched = false
				local touchedConn = probePart.Touched:Connect(function(arg)
					if arg == myRoot then
						isTouched = true
					end
				end)
				local touchEndedConn = probePart.TouchEnded:Connect(function(arg)
					if arg == myRoot then
						isTouched = false
					end
				end)
				local probeTick = tick()
				repeat
					if isTouched and not isCountered(myHumanoid) then
						getgenv().desync = { CFrame = CFrame.new(9e9, 9e9, 9e9) }
					else
						getgenv().desync = nil
					end
					runService.RenderStepped:Wait()
				until tick() >= probeTick + 4 or not track.IsPlaying
				getgenv().desync = nil
				touchedConn:Disconnect()
				touchEndedConn:Disconnect()
				pcall(function()
					probePart:Destroy()
				end)
			end
			if animId:match("13146710762") then
				task.wait(3.25)
				if track.IsPlaying then
					local probeParts = {}
					local offsets = {
						CFrame.new(50, 0, -200) * CFrame.Angles(0, math.rad(-15), 0),
						CFrame.new(-50, 0, -200) * CFrame.Angles(0, math.rad(15), 0),
						CFrame.new(0, 0, -200),
					}
					local isTouched = false
					local probeConns = {}
					for index5, offset in ipairs(offsets) do
						local probePart = Instance.new("Part", workspace)
						probePart.Anchored = true
						probePart.Size = Vector3.new(100, 75, 400)
						probePart.CanCollide = false
						probePart.Transparency = 1
						probePart.CFrame = targetRoot.CFrame * offset
						table.insert(probeParts, probePart)
						table.insert(
							probeConns,
							probePart.Touched:Connect(function(otherPart)
								if otherPart == myRoot then
									isTouched = true
								end
							end)
						)
						table.insert(
							probeConns,
							probePart.TouchEnded:Connect(function(otherPart)
								if otherPart == myRoot then
									isTouched = false
								end
							end)
						)
					end
					local probeTick = tick()
					repeat
						if isTouched and not isCountered(myHumanoid) then
							getgenv().desync = { CFrame = CFrame.new(9e9, 9e9, 9e9) }
						else
							getgenv().desync = nil
						end
						runService.RenderStepped:Wait()
					until tick() >= probeTick + 6 or not track.IsPlaying
					getgenv().desync = nil
					for index6, conn2 in ipairs(probeConns) do
						conn2:Disconnect()
					end
					for index7, part in ipairs(probeParts) do
						pcall(function()
							part:Destroy()
						end)
					end
				end
			end
			if animId:match("11343318134") then
				task.wait(7.5)
				if not track.IsPlaying then
					return
				end
				local probeParts = {}
				local offsets = {
					CFrame.new(60, 0, -250) * CFrame.Angles(0, math.rad(-15), 0),
					CFrame.new(-60, 0, -250) * CFrame.Angles(0, math.rad(15), 0),
					CFrame.new(0, 0, -250),
				}
				local touchedFlags = { false, false, false }
				local probeConns = {}
				for index5, offset in ipairs(offsets) do
					local probePart = Instance.new("Part", workspace)
					probePart.Anchored = true
					probePart.Size = Vector3.new(125, 5, 500)
					probePart.CanCollide = false
					probePart.Transparency = 1
					table.insert(probeParts, probePart)
					local flagIndex = index5
					table.insert(
						probeConns,
						probePart.Touched:Connect(function(otherPart)
							if otherPart == myRoot then
								touchedFlags[flagIndex] = true
							end
						end)
					)
					table.insert(
						probeConns,
						probePart.TouchEnded:Connect(function(otherPart)
							if otherPart == myRoot then
								touchedFlags[flagIndex] = false
							end
						end)
					)
				end
				local probeTick = tick()
				repeat
					for index6, part in ipairs(probeParts) do
						part.CFrame = targetRoot.CFrame * offsets[index6]
					end
					if touchedFlags[1] or touchedFlags[2] or touchedFlags[3] then
						getgenv().desync = { CFrame = CFrame.new(9e9, 9e9, 9e9) }
					else
						getgenv().desync = nil
					end
					runService.RenderStepped:Wait()
				until tick() >= probeTick + 2.5 or not track.IsPlaying
				getgenv().desync = nil
				for index6, conn2 in ipairs(probeConns) do
					conn2:Disconnect()
				end
				for index7, part in ipairs(probeParts) do
					pcall(function()
						part:Destroy()
					end)
				end
			end
		end)
	end)
	combatConns[player3] = animPlayedConn
end

watchPlayerCounters = function(player3)
	if player3 == localPlayer2 then
		return
	end
	if player3.Character then
		task.spawn(watchPlayerCombat, player3, player3.Character)
	end
	local charAddedConn2 = player3.CharacterAdded:Connect(function(newChar)
		task.spawn(watchPlayerCombat, player3, newChar)
	end)
	counterHooks[player3] = charAddedConn2
end

for index5, player3 in pairs(playersService2:GetPlayers()) do
	task.spawn(watchPlayerCounters, player3)
end

local playerAddedConn2 = playersService2.PlayerAdded:Connect(function(player4)
	if player4 == localPlayer2 then
		return
	end
	task.spawn(function()
		local startTick = tick()
		repeat
			runService.RenderStepped:Wait()
		until player4:GetAttribute("PreloadDone") or tick() >= startTick + 30
		if player4 and player4.Parent then
			if player4.Character then
				task.spawn(watchPlayerCombat, player4, player4.Character)
			end
			local charAddedConn2 = player4.CharacterAdded:Connect(function(newChar)
				task.spawn(watchPlayerCombat, player4, newChar)
			end)
			counterHooks[player4] = charAddedConn2
		end
	end)
end)
local playerRemovingConn = playersService2.PlayerRemoving:Connect(function(player4)
	if combatConns[player4] then
		pcall(function()
			combatConns[player4]:Disconnect()
		end)
		combatConns[player4] = nil
	end
	if counterHooks[player4] then
		pcall(function()
			counterHooks[player4]:Disconnect()
		end)
		counterHooks[player4] = nil
	end

end)

local function detachSelfPhysics()
	local myChar = localPlayer2.Character
	if sethiddenproperty then
		if myChar and myChar.Parent then
			pcall(function()
				sethiddenproperty(myChar, "PhysicsRepRootPart", nil)
			end)
		end
	end
	if myChar and myChar.Parent then
		pcall(function()
			myChar.HumanoidRootPart.CFrame = CFrame.new(myChar.HumanoidRootPart.Position)
		end)
		pcall(function()
			myChar.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		end)
		pcall(function()
			myChar.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
		end)
		pcall(function()
			myChar.HumanoidRootPart.Velocity = Vector3.zero
		end)
		pcall(function()
			myChar.HumanoidRootPart.RotVelocity = Vector3.zero
		end)
		local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
		if myHumanoid then
			pcall(function()
				myHumanoid.AutoRotate = true
			end)
		end
	end

end

local function setupCombatLoop()
	local unusedCount = 6
	local dashCooldown = nil
	local leftClickGoal = {
		{
			Goal = "LeftClick",
			MousePos = CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
		},
	}
	local releaseGoal = {
		{
			Goal = "LeftClickRelease",
		},
	}
	local mobileClickGoal = {
		{
			Mobile = true,
			Goal = "LeftClick",
			MousePos = CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
		},
	}
	local dashGoal = {
		{
			Dash = Enum.KeyCode.W,
			Key = Enum.KeyCode.Q,
			Goal = "KeyPress",
			MousePos = CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
		},
	}
	local attackAnimIds = {
		"17799224866",
		"17838006839",
		"17838619895",
		"17857788598",
		"17857880283",
		"18179181663",
		"18182425133",
		"18464351556",
		"18464356233",
		"18464372850",
		"18464362124",
		"136370737633649",
		"130301810149072",
		"17889290569",
		"10479335397",
		"18896229321",
	}
	local function isAttacking2(humanoid)
		if not humanoid then
			return false
		end
		for index6, track in pairs(humanoid:GetPlayingAnimationTracks()) do
			local animId = track.Animation.AnimationId
			for index7, animId2 in ipairs(attackAnimIds) do
				if animId:match(animId2) then
					isAttacking = true
					return true
				end
			end
		end
		isAttacking = false
		return false
	end
	local processing = false
	runService.Heartbeat:Connect(function()
		if not farmEnabled then
			return
		end
		if processing then
			return
		end
		if getgenv().desync then
			return
		end
		if isUlted then
			if ultKeyReady then
				virtualInput:SendKeyEvent(true, Enum.KeyCode.One, false, game)
				task.wait(0.001)
				virtualInput:SendKeyEvent(false, Enum.KeyCode.One, false, game)
				task.wait(0.05)
				local playerGui = localPlayer2:FindFirstChild("PlayerGui")
				if not playerGui then
					return
				end
				local hotbar = playerGui:FindFirstChild("Hotbar")
				if not hotbar then
					return
				end
				local backpack = hotbar:FindFirstChild("Backpack")
				if not backpack then
					return
				end
				local hotbarFrame = backpack:FindFirstChild("Hotbar")
				if not hotbarFrame then
					return
				end
				local slotOne = hotbarFrame:FindFirstChild("1")
				local onCooldown = false
				if slotOne then
					local slotBase = slotOne:FindFirstChild("Base")
					if slotBase then
						onCooldown = slotBase:FindFirstChild("Cooldown") ~= nil
						if onCooldown then
							if slotBase:FindFirstChild("Cooldown").Size.Y.Scale <= -0.8 then
								ultKeyReady = false
							end
						end
					end
				end
			else
				if ultKeyReady then
					ultKeyReady = false
				end
				local playerGui = localPlayer2:FindFirstChild("PlayerGui")
				if not playerGui then
					return
				end
				local hotbar = playerGui:FindFirstChild("Hotbar")
				if not hotbar then
					return
				end
				local backpack = hotbar:FindFirstChild("Backpack")
				if not backpack then
					return
				end
				local hotbarFrame = backpack:FindFirstChild("Hotbar")
				if not hotbarFrame then
					return
				end
				local slotTwo = hotbarFrame:FindFirstChild("2")
				local isReady = false
				if slotTwo then
					local slotBase = slotTwo:FindFirstChild("Base")
					if slotBase then
						isReady = slotBase:FindFirstChild("Cooldown") == nil
							or slotBase:FindFirstChild("Cooldown").Size.Y.Scale >= -0.2
						if isReady then
							pcall(function()
								localPlayer2.Character.HumanoidRootPart.CFrame = CFrame.new(150, 441, 32)
							end)
							virtualInput:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
							task.wait(0.001)
							virtualInput:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
							task.wait(0.05)
						end
					end
				end
			end
		else
			if not currentTarget then
				return
			end
			local targetChar = currentTarget.Character
			local myChar = localPlayer2.Character
			if not targetChar or not myChar then
				return
			end
			if targetChar:FindFirstChildWhichIsA("ForceField") then
				return
			end
			if targetChar:FindFirstChild("AbsoluteImmortal") then
				return
			end
			if targetChar:FindFirstChild("BeingGrabbed") then
				return
			end
			if targetChar:FindFirstChild("HunterCounter") then
				return
			end
			if targetChar:FindFirstChild("AtomicCounter") then
				return
			end
			local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
			if isAttacking2(myHumanoid) then
				return
			end
			local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
			local targetTorso = targetChar:FindFirstChild("Torso")
			if not targetHumanoid or not targetTorso or targetTorso.Transparency == 1 then
				return
			end
			processing = true
			local communicate = myChar:FindFirstChild("Communicate")
			if not communicate then
				processing = false
				return
			end
			if not myChar:GetAttribute("HoldingSpace") then
				local var = myChar:FindFirstChild("Communicate")
				pcall(var.FireServer, var, {
					Goal = "KeyPress",
					Key = Enum.KeyCode.Space,
					MousePos = CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
				})
			end
			if myChar:FindFirstChild("Ragdoll") or myChar:FindFirstChild("RagdollSim") then
				communicate:FireServer({ Dash = Enum.KeyCode.S, Key = Enum.KeyCode.Q, Goal = "KeyPress" })
			end
			if
				(targetChar:FindFirstChild("Ragdoll") or targetChar:FindFirstChild("RagdollSim"))
				or targetHumanoid.Health <= 15
			then
				if myChar:GetAttribute("HoldingM1") then
					communicate:FireServer(jsonEncode(releaseGoal))
					task.wait(0.1)
				end
				if not (targetHumanoid.Health <= 15) then
					if not dashCooldown or tick() - dashCooldown >= 7 then
						communicate:FireServer(jsonEncode(dashGoal))
						dashCooldown = tick()
					end
				end
				virtualInput:SendKeyEvent(true, Enum.KeyCode.One, false, game)
				task.wait(0.001)
				virtualInput:SendKeyEvent(false, Enum.KeyCode.One, false, game)
				task.wait(0.05)
				virtualInput:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
				task.wait(0.001)
				virtualInput:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
				task.wait(0.05)
				virtualInput:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
				task.wait(0.001)
				virtualInput:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
				task.wait(0.05)
				virtualInput:SendKeyEvent(true, Enum.KeyCode.Four, false, game)
				task.wait(0.001)
				virtualInput:SendKeyEvent(false, Enum.KeyCode.Four, false, game)
			else
				task.wait(0.1)
				if myChar:GetAttribute("mobile") then
					communicate:FireServer(jsonEncode(mobileClickGoal))
				else
					communicate:FireServer(jsonEncode(leftClickGoal))
				end
				task.wait(0.1)
				communicate:FireServer(jsonEncode(releaseGoal))
				task.wait(0.1)
			end
		end
		processing = false
	end)
end

local function offsetCFrameBehind(targetRoot, heightOffset, forwardOffset)
	local targetCFrame2 = targetRoot.CFrame
	local rx, ry, rz = targetCFrame2:ToEulerAnglesYXZ()
	local yawCFrame = CFrame.fromEulerAnglesYXZ(0, ry, 0)
	local offsetCFrame = CFrame.new(targetCFrame2.Position) * yawCFrame * CFrame.new(0, heightOffset, forwardOffset)
	local offsetPos = offsetCFrame.Position
	return CFrame.new(offsetPos) * yawCFrame
end

local function setupAimLoop()
	local heartbeatConn = nil
	local unusedHolder2 = nil
	local immortalWait = nil
	currentTarget = findWeakestTarget()
	heartbeatConn = runService.Heartbeat:Connect(function()
		if not farmEnabled then
			if currentlyTargeting then
				currentlyTargeting = false
				detachSelfPhysics()
				currentTarget = findWeakestTarget()
			end
			return
		end
		if isReviving then
			return
		end
		if not currentTarget then
			currentlyTargeting = false
			detachSelfPhysics()
			currentTarget = findWeakestTarget()
			return
		end
		local targetChar = currentTarget.Character
		local myChar = localPlayer2.Character
		if not myChar then
			return
		end
		local magicHealthBar = localPlayer2.PlayerGui.Bar.MagicHealth.Health.Bar
		if magicHealthBar.Size.X == UDim.new(1, 0) and not gKeyBusy then
			gKeyBusy = true
			ultKeyReady = false
			task.spawn(function()
				task.wait(0.5)
				virtualInput:SendKeyEvent(true, Enum.KeyCode.G, false, game)
				task.wait(0.001)
				virtualInput:SendKeyEvent(false, Enum.KeyCode.G, false, game)
				gKeyBusy = false
			end)
		end
		if myChar:GetAttribute("Ulted") then
			isUlted = true
			currentlyTargeting = false
			return
		else
			isUlted = false
		end
		if isTeleporting then
			return
		end
		if not targetChar then
			if currentlyTargeting then
				currentlyTargeting = false
			end
			detachSelfPhysics()
			currentTarget = findWeakestTarget()
			return
		end
		if targetChar:GetAttribute("Ulted") or targetChar:FindFirstChild("Counter") then
			if currentlyTargeting then
				currentlyTargeting = false
			end
			detachSelfPhysics()
			currentTarget = findWeakestTarget()
			return
		end
		local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
		local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
		local myRoot = myChar:FindFirstChild("HumanoidRootPart")
		local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
		if not targetRoot or not targetHumanoid or not myRoot or not myHumanoid then
			if currentlyTargeting then
				currentlyTargeting = false
			end
			detachSelfPhysics()
			currentTarget = findWeakestTarget()
			return
		end
		if targetChar:FindFirstChild("AbsoluteImmortal") then
			if targetHumanoid.Health <= 20 then
				detachSelfPhysics()
				currentTarget = findWeakestTarget()
				return
			else
				if not immortalWait then
					immortalWait = tick()
				else
					if
						(tick() - immortalWait >= 5)
						or (targetChar:FindFirstChildOfClass("Humanoid") and targetChar.Humanoid.Health <= 10)
					then
						immortalWait = nil
						if currentlyTargeting then
							currentlyTargeting = false
						end
						detachSelfPhysics()
						currentTarget = findWeakestTarget()
						return
					end
				end
			end
		end
		if targetHumanoid.Health <= 0 then
			if currentlyTargeting then
				currentlyTargeting = false
			end
			detachSelfPhysics()
			currentTarget = findWeakestTarget()
			return
		end
		local targetTorso = targetChar:FindFirstChild("Torso")
		if not targetTorso or targetTorso.Transparency == 1 then
			if currentlyTargeting then
				currentlyTargeting = false
			end
			detachSelfPhysics()
			currentTarget = findWeakestTarget()
			return
		end
		if not currentlyTargeting then
			warn("[ZKAYHub] Targeting: " .. currentTarget.Name)
			currentlyTargeting = true
			myHumanoid.AutoRotate = false
		end
		myRoot.AssemblyLinearVelocity = Vector3.zero
		myRoot.AssemblyAngularVelocity = Vector3.zero
		if not getgenv().desync then
			myRoot.CFrame = offsetCFrameBehind(targetRoot, 0, 5)
			targetCFrame = myRoot.CFrame
		else
			targetCFrame = offsetCFrameBehind(targetRoot, 0, 5)
		end
		if sethiddenproperty then
			sethiddenproperty(myRoot, "PhysicsRepRootPart", targetRoot)
		end
	end)
end

local function setupAntiAfk()
	local virtualUser = game:GetService("VirtualUser")
	localPlayer2.Idled:Connect(function()
		virtualUser:CaptureController()
		virtualUser:ClickButton2(Vector2.new())
	end)
end


task.spawn(function()
	local thrownFolder = workspace:FindFirstChild("Thrown")
	if thrownFolder then
		for index6, part in pairs(thrownFolder:GetChildren()) do
			if part.Name:lower():find("debris") or part.Name:lower() == "part" then
				task.spawn(pcall, _deleteNew, part)
			end
		end
		thrownFolder.ChildAdded:Connect(function(newPart)
			if newPart.Name:lower():find("debris") or newPart.Name:lower() == "part" then
				task.spawn(pcall, _deleteNew, newPart)
			end
		end)
	end

end)
task.wait(1)
setupCombatLoop()
setupAimLoop()
setupAntiAfk()
task.spawn(function()
	local desyncTimer = nil
	while true do
		if getgenv().desync then
			desyncTimer = tick()
			repeat
				task.wait()
			until (tick() - desyncTimer >= 20) or not getgenv().desync
			desyncTimer = nil
			getgenv().desync = nil
		end
		runService.RenderStepped:Wait()
	end

end)
task.spawn(function()
	while task.wait(0.25) do
		local myChar = localPlayer2.Character
		local communicate = myChar and myChar:FindFirstChild("Communicate")
		if communicate then
			pcall(communicate.FireServer, communicate, { Goal = "Emote Spin" })
		end
	end

end)
local sawUlt = false
task.spawn(function()
	while true do
		if isUlted then
			sawUlt = true
		end
		local playerCount = #playersService2:GetPlayers()
		if
			((playerCount <= 7) or (sessionKills >= tonumber(farmSettings.hopOnCount)) or sawUlt)
			and ((not isUlted) and not isTeleporting)
		then
			hopServer()
		end
		task.wait(1)
	end

end)
