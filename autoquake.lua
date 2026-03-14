repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer.Character
task.wait(3)

print("AUTO QUAKE SYSTEM START")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local systemState = "FARM"

-------------------------------------------------
-- LEVEL CHECK
-------------------------------------------------

local function getLevel()

	local data = player:FindFirstChild("Data")

	if data and data:FindFirstChild("Level") then
		return data.Level.Value
	end

	return 0

end

-------------------------------------------------
-- CHECK QUAKE
-------------------------------------------------

local function hasQuake()

	local backpack = player:FindFirstChild("Backpack")
	local char = player.Character

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

	print("RESET STATS")

	ReplicatedStorage
	:WaitForChild("RemoteEvents")
	:WaitForChild("ResetStats")
	:FireServer()

	task.wait(2)

end

-------------------------------------------------
-- AUTO STATS
-------------------------------------------------

local statRemote =
ReplicatedStorage
:WaitForChild("RemoteEvents")
:WaitForChild("AllocateStat")

local function autoStats()

	print("AUTO STATS START")

	local statPoints =
	player
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
-- TELEPORT FARM
-------------------------------------------------

local teleported = false

local farmPos = CFrame.new(
321.706757,
-1.539090,
-1756.500977
)

local function teleportToFarm()

	if teleported then return end
	teleported = true

	print("Teleport Shinjuku")

	ReplicatedStorage
	.Remotes
	.TeleportToPortal
	:FireServer("Shinjuku")

	task.wait(5)

	local char = player.Character
	local hrp = char:WaitForChild("HumanoidRootPart")

	for i=1,10 do
		hrp.CFrame = farmPos
		task.wait()
	end

end

-------------------------------------------------
-- AUTO ROLL FRUIT
-------------------------------------------------

local function rollFruit()

	print("ROLLING FRUIT")

	local npc =
	workspace
	:WaitForChild("ServiceNPCs")
	:WaitForChild("GemFruitDealer")

	local prompt =
	npc:FindFirstChildWhichIsA("ProximityPrompt",true)

	while true do

		if player.Backpack:FindFirstChild("Quake Fruit") then
			print("FOUND QUAKE FRUIT")
			break
		end

		fireproximityprompt(prompt)

		task.wait(3)

	end

end

-------------------------------------------------
-- EAT QUAKE
-------------------------------------------------

local function eatQuake()

	print("EATING QUAKE")

	while not hasQuake() do

		local fruit =
		player.Backpack:FindFirstChild("Quake Fruit")

		if fruit then

			local hum =
			player.Character:FindFirstChild("Humanoid")

			hum:EquipTool(fruit)

			ReplicatedStorage
			.RemoteEvents
			.FruitAction
			:FireServer("eat","Quake Fruit")

		end

		task.wait(1)

	end

	print("QUAKE ACQUIRED")

end

-------------------------------------------------
-- MAIN FARM LOOP
-------------------------------------------------

task.spawn(function()

	while true do

		if systemState ~= "FARM" then
			task.wait(2)
			continue
		end

		local level = getLevel()

		print("LEVEL:",level)

		if level >= 4000 then

			print("LEVEL 4000 REACHED")

			systemState = "ROLL"

			rollFruit()

			eatQuake()

			resetStats()

			systemState = "FARM"

		end

		task.wait(10)

	end

end)

-------------------------------------------------
-- START
-------------------------------------------------

resetStats()

task.spawn(autoStats)

teleportToFarm()

-------------------------------------------------
-- RESPAWN
-------------------------------------------------

player.CharacterAdded:Connect(function()

	if systemState == "FARM" then

		teleported = false

		task.wait(3)

		teleportToFarm()

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

			if (hrp.Position - farmPos.Position).Magnitude > 15 then
				hrp.CFrame = farmPos
			end

		end

	end

end)
