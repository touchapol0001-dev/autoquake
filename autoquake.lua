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
-- RESET + AUTO STATS
-------------------------------------------------

local function resetAndAllocateStats()

	print("Resetting Stats...")

	ReplicatedStorage
	:WaitForChild("RemoteEvents")
	:WaitForChild("ResetStats")
	:FireServer()

	task.wait(2)

	local statPoints = player:WaitForChild("Data"):WaitForChild("StatPoints")

	local total = statPoints.Value
	local powerPoints = math.floor(total * 0.8)
	local defensePoints = total - powerPoints

	print("Total Stats:", total)

	for i = 1, powerPoints do

		local args = {
			"Power",
			1
		}

		ReplicatedStorage
		:WaitForChild("RemoteEvents")
		:WaitForChild("AllocateStat")
		:FireServer(unpack(args))

		task.wait()

	end

	for i = 1, defensePoints do

		local args = {
			"Defense",
			1
		}

		ReplicatedStorage
		:WaitForChild("RemoteEvents")
		:WaitForChild("AllocateStat")
		:FireServer(unpack(args))

		task.wait()

	end

	print("Stats Allocation Complete")

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

	if not part then
		warn("GemFruitDealer part missing")
		return
	end

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

	print("Start Eating Quake Fruit")

	while true do

		if hasQuake() then
			print("Quake power acquired")
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

			local args = {
				"eat",
				"Quake Fruit"
			}

			ReplicatedStorage
			:WaitForChild("RemoteEvents")
			:WaitForChild("FruitAction")
			:FireServer(unpack(args))

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

		else

			ReplicatedStorage
			.Remotes
			.EquipWeapon
			:FireServer("Equip","Quake")

		end

	end

end)

-------------------------------------------------
-- TELEPORT SHINJUKU
-------------------------------------------------

local lockPos = CFrame.new(
321.706757,
-1.539090,
-1756.500977
) * CFrame.Angles(0,-0.113749,0)

local function teleportToSpot()

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	print("Teleport Shinjuku")

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

	print("Already have Quake → Skip Roll")

	resetAndAllocateStats()

	systemState = "FARM"

	teleportToSpot()

else

	teleportSailor()

	task.wait(6)

	autoRollFruit()

	eatQuake()

	resetAndAllocateStats()

	systemState = "FARM"

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
