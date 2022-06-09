local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GameDictionary = require(game.ReplicatedStorage.Shared.GameDictionary)
local cloneCompleted = true
local iterationNum = 0
local NumberofRooms
local movingCFrameVal
local currentPart
local CornerTable = {{Count = 0, Name = "Left", Rad = 90}, {Count = 0, Name = "Right", Rad = 0}}
local RotationTable = {0,90,180,270}
local RoomTable = {}

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local DungeonGenerationService = Knit.CreateService {
	Name = "DungeonGenerationService"
}

local function GetRandomFront()
	return game.ServerStorage.DungeonParts:FindFirstChild("Front"..Random.new():NextInteger(1,9))
end

local function GetRandomCorner(direction)
	return game.ServerStorage.DungeonParts:FindFirstChild(direction.."Corner"..Random.new():NextInteger(1,3))
end

local function clonePart(part, position, reName)
	cloneCompleted = false
	iterationNum = iterationNum + 1
	if iterationNum == NumberofRooms then
		
		local partName = "Finalboss-Room"
		local newModel = Instance.new('Model', workspace.TargetFilter.Map.DungeonRooms)
		newModel.Name = partName
		for i,v in pairs ( game.ServerStorage.DungeonParts.FinalbossPart:GetChildren()) do
			v:Clone().Parent = newModel
		end
		newModel.PrimaryPart = newModel:FindFirstChild("Floor")
		if string.sub(currentPart.Name, 1, 5) == "Front" then
			newModel:SetPrimaryPartCFrame(currentPart:GetPrimaryPartCFrame() * CFrame.new(0, 0, -movingCFrameVal*1))
		elseif string.sub(currentPart.Name, 1, 10) == "LeftCorner" then
			newModel:SetPrimaryPartCFrame(currentPart:GetPrimaryPartCFrame() * CFrame.new(0, 0, movingCFrameVal*1) * CFrame.fromEulerAnglesXYZ(0,math.rad(180),0))
		elseif string.sub(currentPart.Name, 1, 11) == "RightCorner" then
			newModel:SetPrimaryPartCFrame(currentPart:GetPrimaryPartCFrame() * CFrame.new(-movingCFrameVal*1, 0, 0) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0))
		end
		currentPart = newModel
		newModel.Floor.Parent = workspace.FloorFilter
	else
		local partName = part.Name
		local newModel = Instance.new('Model', workspace.TargetFilter.Map.DungeonRooms)
		newModel.Name = partName
		for i,v in pairs (part:GetChildren()) do
			v:Clone().Parent = newModel
		end
		if reName ~= nil then
			newModel.Name = reName
			part.Name = reName
		end
		currentPart = newModel
		newModel.PrimaryPart = newModel:FindFirstChild("Floor")
		if position ~= nil then
			newModel:SetPrimaryPartCFrame(position)
		end
		table.insert(RoomTable, newModel)
		CollectionService:AddTag(newModel, "Obstacle")
	end
	cloneCompleted = true
end

local function CornerCheck(tbl1, tbl2, part)
	if CornerTable[tbl1].Count ~= 2 then
		CornerTable[tbl1].Count += 1
		if CornerTable[tbl2].Count > 0 then
			CornerTable[tbl2].Count -= 1
		end
		clonePart(GetRandomCorner(CornerTable[tbl1].Name), part:GetPrimaryPartCFrame() 
			* CFrame.new(0, 0, -movingCFrameVal) * CFrame.fromEulerAnglesXYZ(0, math.rad(CornerTable[tbl1].Rad) ,0))
		return true
	end
end

local function CornerGenerate(part)
	if CornerTable[1].Count ~= 2 and CornerTable[2].Count ~= 2 then
		local CornerChance = math.random(1,2)
		CornerTable[CornerChance].Count += 1
		clonePart(GetRandomCorner(CornerTable[CornerChance].Name), part:GetPrimaryPartCFrame() * 
			CFrame.new(0, 0, -movingCFrameVal) * CFrame.fromEulerAnglesXYZ(0,math.rad(CornerTable[CornerChance].Rad),0))
	else
		if not CornerCheck(1, 2, part) then
			CornerCheck(2, 1, part)
		end
	end	
end

local function checkProceduralPart(part)
	if string.sub(part.Name, 1, 5) == "Front" or string.sub(part.Name, 1,3) == "End" then
		local FrontChance = math.random(1,3)
		if FrontChance == 1 then
			clonePart(GetRandomFront(), part:GetPrimaryPartCFrame() * CFrame.new(0, 0, -movingCFrameVal))
		else
			CornerGenerate(part)
		end
	elseif string.sub(part.Name, 1, 4) == "Left" then
		clonePart(GetRandomFront(), part:GetPrimaryPartCFrame() * CFrame.new(0, 0, movingCFrameVal) * CFrame.fromEulerAnglesXYZ(0,math.rad(180),0))
	elseif string.sub(part.Name, 1, 5) == "Right" then
		clonePart(GetRandomFront(), part:GetPrimaryPartCFrame() * CFrame.new(-movingCFrameVal, 0, 0) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0))
	elseif string.sub(part.Name, 1,2) == "Mini" then
		clonePart(GetRandomFront(), part:GetPrimaryPartCFrame() * CFrame.new(0, 0, -movingCFrameVal*2))
	end
end

function DungeonGenerationService:Generate(rooms, roomSize, floorSize, cFrame)
	
	local StartPiece = Random.new():NextInteger(1,3)
	
	local StartRoom = game.ServerStorage.DungeonParts.StartRoom:Clone()
	StartRoom.Parent = workspace.TargetFilter.Map.StarterRoom
	StartRoom:SetPrimaryPartCFrame(CFrame.new(cFrame) * CFrame.Angles(0, math.rad(RotationTable[math.random(1,4)]), 0)) -->>: Sets startCFrame with a random rotation
	
	NumberofRooms = rooms
	movingCFrameVal = floorSize
	
	local startCFrame = StartRoom.StartCFrame.CFrame
	
	if StartPiece == 1 then
		clonePart(GetRandomFront(), startCFrame) -->>: Always starts with a front part
	elseif StartPiece == 2 then
		CornerTable[1].Count += 1
		clonePart(GetRandomCorner("Left"), startCFrame * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)) -->>: Always starts with a front part
	elseif StartPiece == 3 then
		CornerTable[2].Count += 1
		clonePart(GetRandomCorner("Right"), startCFrame * CFrame.fromEulerAnglesXYZ(0,math.rad(0),0)) -->>: Always starts with a front part
	end

	for i = 1, NumberofRooms, 1 do -->>: Generates the rooms
		repeat task.wait() until cloneCompleted
		checkProceduralPart(currentPart)
	end

	local nextMultiple = roomSize
	local RoomNumber = 1

	for i,v in pairs (RoomTable) do -->>: Adds the EndParts to the rooms
		if i % nextMultiple == 0 then
			local RoomFolder = Instance.new("Folder", workspace.TargetFilter.Map.DungeonRooms)
			RoomFolder.Name = "Room-"..tostring(RoomNumber)
			local partName = "End-"..tostring(RoomNumber)
			local newModel = Instance.new('Model', workspace.TargetFilter.Map.DungeonRooms)
			newModel.Name = partName
			for i,v in pairs (game.ServerStorage.DungeonParts.DungeonEnd:GetChildren()) do
				v:Clone().Parent = newModel
			end
			currentPart = newModel
			newModel.PrimaryPart = newModel:FindFirstChild("Floor")
			if string.sub(v.Name, 1, 5) == "Front" then -- works
				newModel:SetPrimaryPartCFrame(RoomTable[i]:GetPrimaryPartCFrame() * CFrame.new(0, 0, -movingCFrameVal))
			elseif string.sub(v.Name, 1, 10) == "LeftCorner" then -- works
				newModel:SetPrimaryPartCFrame(RoomTable[i]:GetPrimaryPartCFrame() * CFrame.new(0, 0, movingCFrameVal) * CFrame.fromEulerAnglesXYZ(0,math.rad(180),0))
			elseif string.sub(v.Name, 1, 11) == "RightCorner" then -- works
				newModel:SetPrimaryPartCFrame(RoomTable[i]:GetPrimaryPartCFrame() * CFrame.new(-movingCFrameVal, 0, 0) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0))
			end
			CollectionService:AddTag(newModel, "Obstacle")
			RoomNumber += 1
		end
	end
	
	local tempRoomNumber = 1
	
	for iRoom,v in pairs (RoomTable) do -->>: Puts rooms into correct folders
		v.Floor.Parent = workspace.FloorFilter
		if iRoom % nextMultiple == 0 then
			for i = (nextMultiple-1), 0, -1 do
				RoomTable[iRoom - i].Parent = workspace.TargetFilter.Map.DungeonRooms:FindFirstChild("Room-"..tostring(tempRoomNumber))
			end
			tempRoomNumber += 1
		end
	end
	
--[[

]]
	for i = 1, (RoomNumber-1), 1 do
		for i,model in pairs (workspace.TargetFilter.Map.DungeonRooms:FindFirstChild("Room-"..tostring(i)):GetChildren()) do
			if model:IsA("Model") then
				for i,v in pairs (model:GetChildren()) do
					if v.Name == "MobSpawn" then
						v.Transparency = 1
					end
				end
			end
		end
	end

	task.wait(5)

	for i = 1, (RoomNumber-1), 1 do
		for i,model in pairs (workspace.TargetFilter.Map.DungeonRooms:FindFirstChild("Room-"..tostring(i)):GetChildren()) do
			if model:IsA("Model") then
				for i,v in pairs (model:GetChildren()) do
					if v.Name == "MobSpawn" then
						v.Transparency = 1
						v.Spawn.Particle:Emit(35)
						Debris:AddItem(v, 1)
						local Mob = game.ReplicatedStorage.GameAssets.Mobs.Zombie:Clone()
						Mob:SetPrimaryPartCFrame(v.CFrame + Vector3.new(0,2,0))
						Mob.Parent = workspace.TargetFilter.Enemies
						Mob.Humanoid.MaxHealth = GameDictionary.Mobs[Mob.Name].Health + ((GameDictionary.Mobs[Mob.Name].Health/4) * (#game.Players:GetChildren()))
						Mob.Humanoid.Health = GameDictionary.Mobs[Mob.Name].Health + ((GameDictionary.Mobs[Mob.Name].Health/4) * (#game.Players:GetChildren()))
						for i,vPart in pairs (Mob:GetChildren()) do
							if vPart:IsA("Part") and vPart.Name ~= "HeadPart" and vPart.Name ~= "Hitbox" and vPart.Name ~= "HumanoidRootPart" then
								local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0,false,0)
								local GateTween = TweenService:Create(vPart, tweenInfo, {Transparency = 0}):Play()
							end
						end
						--RunService.Heartbeat:Wait()
						task.wait(0.15) -->>: How fast the zombies spawn in
					end
				end
			end
		end

		repeat task.wait() until #workspace.TargetFilter.Enemies:GetChildren() == 0

		spawn(function()
			task.wait(1)
			local DungeonEnd = workspace.TargetFilter.Map.DungeonRooms:FindFirstChild("End-"..i)
			DungeonEnd.DungeonEnd.Gate.Glow.Enabled = false
			local tweenInfo = TweenInfo.new(2,Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0,false,0)
			local GateTween = TweenService:Create(DungeonEnd.DungeonEnd.Gate, tweenInfo, 
				{Position = Vector3.new(DungeonEnd.DungeonEnd.Gate.Position.X, 
					DungeonEnd.DungeonEnd.Gate.Position.Y - 9, DungeonEnd.DungeonEnd.Gate.Position.Z)}):Play()
			for i = 1, 3, 1 do
				DungeonEnd.DungeonEnd.Door.DungeonDone.Particle:Emit(200)
				task.wait(0.15) -->>: Particle emits have 0.15 second delays
			end
			DungeonEnd.DungeonEnd.Door.Unlock:Play()
			DungeonEnd.Barrier:Destroy()
		end)

		task.wait(1)

	end
	
end

function DungeonGenerationService:KnitInit()
end

function DungeonGenerationService:KnitStart()
	DungeonGenerationService:Generate(10, 3, 60, Vector3.new(90, -1, -240)) -->>: Number of Rooms, Room Chunks, Floor Size, Start CFrame
end

return DungeonGenerationService
