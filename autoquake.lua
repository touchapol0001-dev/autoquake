repeat task.wait() until game:IsLoaded()

print("Auto Quake System Start")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local systemState = "ROLL"

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
-- RESET STATS
-------------------------------------------------

local function resetStats()

	print("Reset Stats")

	ReplicatedStorage
	:WaitForChild("RemoteEvents")
	:WaitForChild("ResetStats")
	:FireServer()

	task.wait(2)

end

-------------------------------------------------
-- AUTO STATS FAST
-------------------------------------------------

local statRemote = ReplicatedStorage
:WaitForChild("RemoteEvents")
:WaitForChild("AllocateStat")

local function autoStats()

	print("Auto Stats Started")

	local statPoints = player
	:WaitForChild("Data")
	:WaitForChild("StatPoints")

	while systemState == "FARM" do

		local points = statPoints.Value

		if points > 0 then

			local power = math.floor(points * 0.8)
			local defense = points - power

			for i = 1,power do
				statRemote:FireServer("Power",1)
			end

			for i = 1,defense do
				statRemote:FireServer("Defense",1)
			end

		end

		task.wait(0.5)

	end

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
-- TELEPORT SAILOR
-------------------------------------------------

local function teleportSailor()

	print("Teleport Sailor")

	ReplicatedStorage.Remotes.TeleportToPortal:FireServer("Sailor")

end

-------------------------------------------------
-- AUTO ROLL
-------------------------------------------------

local function autoRollFruit()

	print("Start Rolling")

	local npc = workspace:WaitForChild("ServiceNPCs"):WaitForChild("GemFruitDealer")

	task.wait(6)

	local part =
	npc:FindFirstChild("HumanoidRootPart")
	or npc:FindFirstChild("Head")
	or npc.PrimaryPart

	local target = part.CFrame * CFrame.new(0,0,4)

	tweenToPosition(target,100)

	task.wait(1)

	local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt",true)

	while true do

		if hasQuakeFruit() then
			print("Quake Fruit Found")
			break
		end

		fireproximityprompt(prompt)

		print("Rolling fruit...")

		task.wait(3)

	end

end

-------------------------------------------------
-- EAT QUAKE
-------------------------------------------------

local function eatQuake()

	print("Start Eating Quake")

	while true do

		if hasQuake() then
			print("Quake acquired")
			break
		end

		local fruit =
		player.Backpack:FindFirstChild("Quake Fruit") or
		player.Character:FindFirstChild("Quake Fruit")

		if fruit then

			local hum = player.Character:FindFirstChild("Humanoid")

			if hum then
				hum:EquipTool(fruit)
			end

			ReplicatedStorage
			:WaitForChild("RemoteEvents")
			:WaitForChild("FruitAction")
			:FireServer("eat","Quake Fruit")

		end

		task.wait(0.5)

	end

end

-------------------------------------------------
-- AUTO EQUIP QUAKE
-------------------------------------------------

task.spawn(function()

	while task.wait(0.5) do

		if systemState ~= "FARM" then
			continue
		end

		local char = player.Character
		local backpack = player:FindFirstChild("Backpack")

		if not char or not backpack then
			continue
		end

		local hum = char:FindFirstChild("Humanoid")

		if not hum then
			continue
		end

		local quake =
		backpack:FindFirstChild("Quake") or
		char:FindFirstChild("Quake")

		if quake then

			if quake.Parent ~= char then
				hum:EquipTool(quake)
			end

		end

	end

end)

-------------------------------------------------
-- TELEPORT FARM
-------------------------------------------------

local lockPos = CFrame.new(
321.706757,
-1.539090,
-1756.500977
)

local function teleportToSpot()

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	print("Teleport Farm")

	ReplicatedStorage
	.Remotes
	.TeleportToPortal
	:FireServer("Shinjuku")

	task.wait(5)

	for i = 1,10 do
		hrp.CFrame = lockPos
		task.wait()
	end

end

-------------------------------------------------
-- SETTINGS ลดแลค
-------------------------------------------------

local SettingsToggle = ReplicatedStorage
:WaitForChild("RemoteEvents")
:WaitForChild("SettingsToggle")

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

	print("Already have Quake")

	resetStats()

	systemState = "FARM"

	task.spawn(autoStats)

	teleportToSpot()

else

	teleportSailor()

	task.wait(6)

	autoRollFruit()

	eatQuake()

	resetStats()

	systemState = "FARM"

	task.spawn(autoStats)

	task.wait(3)

	teleportToSpot()

end

-------------------------------------------------
-- RESPAWN
-------------------------------------------------

player.CharacterAdded:Connect(function()

	if systemState == "FARM" then

		task.wait(3)

		teleportToSpot()

	end

end)

-------------------------------------------------
-- LOCK POSITION
-------------------------------------------------

task.spawn(function()

	while task.wait(1) do

		if systemState ~= "FARM" then
			continue
		end

		local char = player.Character

		if char and char:FindFirstChild("HumanoidRootPart") then

			local hrp = char.HumanoidRootPart

			if (hrp.Position - lockPos.Position).Magnitude > 10 then
				hrp.CFrame = lockPos
			end

		end

	end

end)
