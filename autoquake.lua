repeat task.wait() until game:IsLoaded()

print("Auto Quake System Start")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local systemState = "ROLL"
local teleported = false
local allowEquipQuake = false

-------------------------------------------------
-- CHECK FRUIT
-------------------------------------------------

local function hasQuakeFruit()

	local char = player.Character
	local backpack = player:FindFirstChild("Backpack")

	if backpack and backpack:FindFirstChild("Quake Fruit") then
		return true
	end

	if char and char:FindFirstChild("Quake Fruit") then
		return true
	end

	return false
end

local function hasQuake()

	local char = player.Character
	local backpack = player:FindFirstChild("Backpack")

	if backpack and backpack:FindFirstChild("Quake") then
		return true
	end

	if char and char:FindFirstChild("Quake") then
		return true
	end

	if player:FindFirstChild("Data") and player.Data:FindFirstChild("DevilFruit") then
		if player.Data.DevilFruit.Value == "Quake" then
			return true
		end
	end

	return false
end

-------------------------------------------------
-- TWEEN
-------------------------------------------------

local function tweenToPosition(targetCFrame,speed)

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local distance = (hrp.Position - targetCFrame.Position).Magnitude
	local time = distance / speed

	local tween = TweenService:Create(
		hrp,
		TweenInfo.new(time,Enum.EasingStyle.Linear),
		{CFrame = targetCFrame}
	)

	tween:Play()
	tween.Completed:Wait()

end

-------------------------------------------------
-- RESET STATS
-------------------------------------------------

local statRemote =
ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AllocateStat")

local function resetStats()

	print("Reset Stats")

	ReplicatedStorage.RemoteEvents.ResetStats:FireServer()

	task.wait(1)

	local statPoints = player.Data.StatPoints

	while statPoints.Value > 0 do

		local points = statPoints.Value

		local power = math.floor(points * 0.8)
		local defense = points - power

		for i=1,power do
			statRemote:FireServer("Power",1)
		end

		for i=1,defense do
			statRemote:FireServer("Defense",1)
		end

		task.wait()

	end

end

-------------------------------------------------
-- AUTO STATS
-------------------------------------------------

local function autoStats()

	local statPoints = player.Data.StatPoints

	while true do

		if systemState ~= "FARM" then
			task.wait(0.2)
			continue
		end

		if statPoints.Value > 0 then

			local points = statPoints.Value

			local power = math.floor(points * 0.8)
			local defense = points - power

			for i=1,power do
				statRemote:FireServer("Power",1)
			end

			for i=1,defense do
				statRemote:FireServer("Defense",1)
			end

		end

		task.wait()

	end

end

-------------------------------------------------
-- AUTO EQUIP QUAKE
-------------------------------------------------

task.spawn(function()

	while task.wait(0.5) do

		if systemState ~= "FARM" then continue end
		if not allowEquipQuake then continue end

		local char = player.Character
		local backpack = player.Backpack

		if not char or not backpack then continue end

		local hum = char:FindFirstChild("Humanoid")
		if not hum then continue end

		local quake =
		backpack:FindFirstChild("Quake") or
		char:FindFirstChild("Quake")

		if quake then

			if quake.Parent ~= char then
				hum:EquipTool(quake)
			end

		else

			ReplicatedStorage.Remotes.EquipWeapon:FireServer("Equip","Quake")

		end

	end

end)

-------------------------------------------------
-- TELEPORT SYSTEM
-------------------------------------------------

local lockPos = CFrame.new(
321.706757,
-1.539090,
-1756.500977
) * CFrame.Angles(0,-0.113749,0)

local function teleportToSpot()

	if teleported then return end
	teleported = true

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	allowEquipQuake = false

	local oldPos = hrp.Position

	print("Teleport Shinjuku")

	ReplicatedStorage.Remotes.TeleportToPortal:FireServer("Shinjuku")

	repeat task.wait(0.5)
	until (hrp.Position - oldPos).Magnitude > 100

	print("Teleport Loaded")

	task.wait(2)

	for i=1,10 do
		hrp.CFrame = lockPos
		task.wait()
	end

	print("Lock Position")

	allowEquipQuake = true

end

-------------------------------------------------
-- LOCK POSITION
-------------------------------------------------

task.spawn(function()

	while task.wait(1) do

		if systemState ~= "FARM" then continue end

		local char = player.Character
		if not char then continue end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		if (hrp.Position - lockPos.Position).Magnitude > 10 then
			hrp.CFrame = lockPos
		end

	end

end)

-------------------------------------------------
-- SETTINGS
-------------------------------------------------

local SettingsToggle =
ReplicatedStorage.RemoteEvents.SettingsToggle

local settings = {
"DisablePvP",
"DisableVFX",
"DisableOtherVFX",
"RemoveTexture",
"AutoSkillC",
"RemoveShadows"
}

for _,v in pairs(settings) do
	SettingsToggle:FireServer(v,true)
end

-------------------------------------------------
-- MAIN
-------------------------------------------------

if hasQuake() then

	print("Already Have Quake")

	resetStats()

	systemState = "FARM"

	teleportToSpot()

else

	print("Teleport Sailor")

	ReplicatedStorage.Remotes.TeleportToPortal:FireServer("Sailor")

	task.wait(6)

	local npc =
	workspace.ServiceNPCs.GemFruitDealer

	local part =
	npc:FindFirstChild("HumanoidRootPart")
	or npc.PrimaryPart

	local target = part.CFrame * CFrame.new(0,0,4)

	tweenToPosition(target,100)

	local prompt

	repeat
		prompt = npc:FindFirstChildWhichIsA("ProximityPrompt",true)
		task.wait()
	until prompt

	while not hasQuakeFruit() do

		fireproximityprompt(prompt)

		task.wait(3)

	end

	print("Got Quake Fruit")

	while not hasQuake() do

		local fruit = player.Backpack:FindFirstChild("Quake Fruit")

		if fruit then

			player.Character.Humanoid:EquipTool(fruit)

			ReplicatedStorage.RemoteEvents.FruitAction
			:FireServer("eat","Quake Fruit")

		end

		task.wait(0.5)

	end

	resetStats()

	systemState = "FARM"

	task.wait(3)

	teleportToSpot()

end

task.spawn(autoStats)

-------------------------------------------------
-- RESPAWN
-------------------------------------------------

player.CharacterAdded:Connect(function()

	if systemState == "FARM" then

		teleported = false

		task.wait(3)

		teleportToSpot()

	end

end)
