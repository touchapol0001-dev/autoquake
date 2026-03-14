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
-- FAST RESET + STATS
-------------------------------------------------

local function resetAndAllocateStats()

	print("Reset Stats")

	ReplicatedStorage
	:WaitForChild("RemoteEvents")
	:WaitForChild("ResetStats")
	:FireServer()

	task.wait(2)

	local statPoints = player:WaitForChild("Data"):WaitForChild("StatPoints")

	while statPoints.Value <= 0 do
		task.wait()
	end

	local total = statPoints.Value

	local power = math.floor(total * 0.8)
	local defense = total - power

	local remote = ReplicatedStorage.RemoteEvents.AllocateStat

	if power > 0 then
		remote:FireServer("Power",power)
	end

	if defense > 0 then
		remote:FireServer("Defense",defense)
	end

	print("Stats Allocated",total)

end

-------------------------------------------------
-- AUTO STATS DURING FARM
-------------------------------------------------

task.spawn(function()

    local remote = game:GetService("ReplicatedStorage")
        :WaitForChild("RemoteEvents")
        :WaitForChild("AllocateStat")

    while task.wait(0.5) do

        if systemState ~= "FARM" then
            continue
        end

        local data = player:FindFirstChild("Data")
        if not data then
            continue
        end

        local statPoints = data:FindFirstChild("StatPoints")
        local powerStat = data:FindFirstChild("Power")

        if not statPoints or not powerStat then
            continue
        end

        local total = statPoints.Value
        if total <= 0 then
            continue
        end

        local currentPower = powerStat.Value
        local maxPower = 11500

        local powerLeft = math.max(0, maxPower - currentPower)

        local powerAllocate = math.min(powerLeft, math.floor(total * 0.8))
        local defenseAllocate = total - powerAllocate

        local allocated = false

        if powerAllocate > 0 then
            remote:FireServer("Power", powerAllocate)
            allocated = true
        end

        if defenseAllocate > 0 then
            remote:FireServer("Defense", defenseAllocate)
            allocated = true
        end

        -- แสดง log เฉพาะตอนอัพจริง
        if allocated then
            print("Auto Stats:", total)
        end

    end

end)

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

	print("Rolling Fruit")

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
			print("Found Quake Fruit")
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

	print("Eating Quake")

	while true do

		if hasQuake() then
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

			ReplicatedStorage.RemoteEvents.FruitAction
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

		else

			ReplicatedStorage.Remotes.EquipWeapon
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

	print("Teleport Shinjuku")

	ReplicatedStorage.Remotes.TeleportToPortal
	:FireServer("Shinjuku")

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	task.wait(6)

	hrp.CFrame = lockPos

end

-------------------------------------------------
-- SETTINGS
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

		task.wait(5)

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
