repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer.Character
repeat task.wait() until workspace:FindFirstChild("ServiceNPCs")
task.wait(5)

print("Mady By Masterp & AI...")

local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = Player:WaitForChild("Data")
local StatPoints = Data:WaitForChild("StatPoints")
local Level = Data:WaitForChild("Level")

local BodyVelocity = Instance.new("BodyVelocity")

local SYSTEM = "LEVEL_FARM"

-------------------------------------------------
-- CHARACTER
-------------------------------------------------

function getCharacter()
	return Player.Character or Player.CharacterAdded:Wait()
end

-------------------------------------------------
-- QUEST INFO
-------------------------------------------------

function getInfoQuest()

	local quests = {}

	local remote =
	ReplicatedStorage
	:WaitForChild("RemoteEvents")
	:WaitForChild("GetQuestArrowTarget")

	local result = remote:InvokeServer()

	if result then
		for i,v in pairs(result) do
			quests[i] = v
		end
	end

	return quests
end

-------------------------------------------------
-- EQUIP WEAPON
-------------------------------------------------

function equipWeapon()

	local char = getCharacter()
	local tool = Player.Backpack:FindFirstChild("Combat")

	if tool and char:FindFirstChild("Humanoid") then
		char.Humanoid:EquipTool(tool)
	end

end

-------------------------------------------------
-- AUTO STAT
-------------------------------------------------

function allocateStat(stat, amount)

	ReplicatedStorage
	.RemoteEvents
	.AllocateStat
	:FireServer(stat, amount)

end

function autoAllocate()

	local points = StatPoints.Value
	if points <= 0 then return end

	local melee = math.floor(points * 0.6)
	local defense = math.floor(points * 0.3)
	local left = points - melee - defense

	if melee > 0 then
		allocateStat("Melee", melee)
	end

	if defense > 0 then
		allocateStat("Defense", defense)
	end

	if left > 0 then
		allocateStat("Melee", left)
	end

end

-------------------------------------------------
-- ROLL FRUIT
-------------------------------------------------

function rollFruit()

	print("Start Roll Fruit")

	local npc = workspace:WaitForChild("ServiceNPCs"):WaitForChild("GemFruitDealer")

	local char = getCharacter()
	local root = char:WaitForChild("HumanoidRootPart")

	root.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0,0,4)

	task.wait(1)

	local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt",true)

	while SYSTEM == "ROLL_FRUIT" do

		local fruit = Player.Backpack:FindFirstChild("Quake Fruit")

		if fruit then
			print("Quake Fruit Found")
			SYSTEM = "EAT_QUAKE"
			break
		end

		fireproximityprompt(prompt)

		task.wait(3)

	end

end

-------------------------------------------------
-- EAT QUAKE
-------------------------------------------------

function eatQuake()

	print("Eating Quake")

	while SYSTEM == "EAT_QUAKE" do

		local quake = Player.Backpack:FindFirstChild("Quake")

		if quake then
			print("Quake Acquired")
			SYSTEM = "QUAKE_FARM"
			break
		end

		local fruit = Player.Backpack:FindFirstChild("Quake Fruit")

		if fruit then

			getCharacter().Humanoid:EquipTool(fruit)

			ReplicatedStorage
			.RemoteEvents
			.FruitAction
			:FireServer("eat","Quake Fruit")

		end

		task.wait(0.5)

	end

end

-------------------------------------------------
-- QUAKE FARM
-------------------------------------------------

function startQuakeFarm()

	print("Start Quake Farm")

	local char = getCharacter()
	local root = char:WaitForChild("HumanoidRootPart")

	local quake = Player.Backpack:FindFirstChild("Quake")

	if quake then
		char.Humanoid:EquipTool(quake)
	end

	ReplicatedStorage.Remotes.TeleportToPortal:FireServer("Shinjuku")

	task.wait(5)

	local farmPos = Vector3.new(
	321.706757,
	-1.539090,
	-1756.500977
	)

	root.CFrame = CFrame.new(farmPos)

	while SYSTEM == "QUAKE_FARM" do

		task.wait(1)

		if (root.Position - farmPos).Magnitude > 10 then
			root.CFrame = CFrame.new(farmPos)
		end

		ReplicatedStorage.RemoteEvents.SettingsToggle:FireServer("AutoSkillC",true)

	end

end

-------------------------------------------------
-- SETTINGS
-------------------------------------------------

ReplicatedStorage
:WaitForChild("RemoteEvents")
:WaitForChild("SettingsToggle")
:FireServer("AutoSkillZ", true)

-- ===============================
-- AUTO FARM + AUTO LOAD AUTOQUAKE
-- ===============================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local AUTOFARM = true
local LEVEL_TO_STOP = 4000

-- ฟังก์ชันโหลด AutoQuake
local function LoadAutoQuake()

    print("LEVEL 4000 REACHED")
    print("Stopping Auto Farm...")

    AUTOFARM = false
    _G.AUTOFUNCTION = false
    SYSTEM = "STOP"

    task.wait(2)

    print("Loading Auto Quake Script...")

    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/touchapol0001-dev/autoquake/main/autoquake.lua"))()
    end)

    if success then
        print("Auto Quake Loaded Successfully")
    else
        warn("Failed to load Auto Quake:", err)
    end
end

-- Loop ตรวจเลเวล
task.spawn(function()

    while task.wait(3) do

        if not AUTOFARM then
            break
        end

        local Level = player:FindFirstChild("Data")

        if Level and Level:FindFirstChild("Level") then

            local levelValue = Level.Level.Value

            print("Current Level:", levelValue)

            if levelValue >= LEVEL_TO_STOP then
                LoadAutoQuake()
                break
            end

        end

    end

end)

-- ===============================
-- ตัวอย่างระบบฟาร์ม
-- ===============================

while AUTOFARM do

    task.wait(1)

    if not player.Character then
        continue
    end

    local humanoid = player.Character:FindFirstChild("Humanoid")

    if humanoid then
        print("Still Alive")
    end

end
