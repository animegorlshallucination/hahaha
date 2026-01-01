--[[
	Pryomatic Hub by Woow
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Pryomatic Hub",
    SubTitle = "by Woow",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Default",
    MinimizeKey = Enum.KeyCode.K
})

-- Create tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "diamond" })
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer

local JumpEnabled = false
local JumpValue = 50
local InfiniteJumpEnabled = false
local AutoBhop = false
local BhopPower = 35 
local storedParts = {}

local function getRepairKeywords()
    return {"stair", "step", "ramp", "trimp", "platform", "invisibleplatform", "floor", "ground", "pad", "road", "path", "bridge", "fence"}
end

local function isGameplayPart(name)
    local keywords = getRepairKeywords()
    name = string.lower(name)
    for _, keyword in pairs(keywords) do
        if name:find(keyword) then return true end
    end
    return false
end

-- ==================== MAIN TAB ====================
Tabs.Main:AddSection("Movement")

local JumpToggle = Tabs.Main:AddToggle("JumpToggle", {
    Title = "Jump Height Toggle",
    Default = false,
    Callback = function(state) JumpEnabled = state end,
})

local JumpSlider = Tabs.Main:AddSlider("JumpSlider", {
    Title = "Jump Strength",
    Min = 0,
    Max = 500,
    Default = 50,
    Rounding = 0,
    Callback = function(v) JumpValue = v end,
})

local InfiniteJumpToggle = Tabs.Main:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state) InfiniteJumpEnabled = state end,
})

Tabs.Main:AddSection("BHOP (Spammer)")

local BhopToggle = Tabs.Main:AddToggle("BhopToggle", {
    Title = "Bhop Toggle (Hold Space)",
    Default = false,
    Callback = function(state) AutoBhop = state end,
})

local BhopSlider = Tabs.Main:AddSlider("BhopSlider", {
    Title = "Velocity Boost",
    Min = 0,
    Max = 100,
    Default = 35,
    Rounding = 0,
    Callback = function(v) BhopPower = v end,
})

Tabs.Main:AddSection("Invis Wall Cleaners")

Tabs.Main:AddButton({
    Title = "Legacy Delete Invis Walls",
    Callback = function()
        local destroyed, stored = 0, 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = string.lower(obj.Name)
                if name:find("water") or (obj.CanCollide and obj.Transparency >= 0.8 and obj.Position.Y > 50 and not isGameplayPart(name)) then
                    pcall(function() obj:Destroy(); destroyed = destroyed + 1 end)
                elseif isGameplayPart(name) and obj.CanCollide then
                    local newPart = obj:Clone()
                    newPart.Parent = nil
                    table.insert(storedParts, newPart)
                    pcall(function() obj:Destroy(); stored = stored + 1 end)
                end
            end
        end
        task.wait(0.2)
        local mapParent = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Level") or Workspace
        for _, p in pairs(storedParts) do p.Parent = mapParent end
        storedParts = {}
        Window:Dialog({
            Title = "Legacy Clean",
            Content = "Walls: "..destroyed.." | Ramps: "..stored,
            Buttons = {{Title = "OK", Callback = function() end}}
        })
    end,
})

Tabs.Main:AddButton({
    Title = "Overhaul Delete Invis Walls",
    Callback = function()
        local modified, deleted = 0, 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = string.lower(obj.Name)
                if (obj.Transparency > 0.8 and obj.CanCollide and obj.Anchored) or (name:find("barrier") or name:find("invisible") or name:find("wall")) then
                    pcall(function() obj.CanCollide = false; modified = modified + 1 end)
                end
                if obj.Transparency == 1 and obj.CanCollide and obj.Size.Magnitude > 50 then
                    pcall(function() obj:Destroy(); deleted = deleted + 1 end)
                end
            end
        end
        Window:Dialog({
            Title = "Overhaul Clean",
            Content = "Modified: "..modified.." | Deleted: "..deleted,
            Buttons = {{Title = "OK", Callback = function() end}}
        })
    end,
})

Tabs.Main:AddSection("Ramp Spawner")

Tabs.Main:AddButton({
    Title = "Spawn Sharp Ramp",
    Callback = function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local rampa = Instance.new("WedgePart", Workspace)
        rampa.Name = "WDWRamp"
        rampa.Size = Vector3.new(12, 4, 30) 
        rampa.Anchored, rampa.CanCollide, rampa.Transparency = true, true, 0.1
        rampa.BrickColor, rampa.Material = BrickColor.new("Bright blue"), Enum.Material.Neon
        rampa.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 1.5, 0, 1)
        
        local spawnPos = root.CFrame * CFrame.new(0, -3.2, -18)
        rampa.CFrame = CFrame.new(spawnPos.Position, spawnPos.Position + root.CFrame.LookVector)
    end,
})

Tabs.Main:AddButton({
    Title = "Clear All Ramps",
    Callback = function()
        local count = 0
        for _, v in pairs(Workspace:GetChildren()) do 
            if v.Name == "WDWRamp" then 
                v:Destroy() 
                count = count + 1
            end 
        end
        Window:Dialog({
            Title = "Ramps",
            Content = "Cleared "..count.." ramps",
            Buttons = {{Title = "OK", Callback = function() end}}
        })
    end,
})

-- ==================== VISUALS TAB ====================
Tabs.Visuals:AddSection("File & Name Swapper")

local target1, target2 = "", ""

local Input1 = Tabs.Visuals:AddInput("Name1Input", {
    Title = "Name 1 (Original)",
    Default = "",
    Placeholder = "Old Name...",
    Callback = function(t) target1 = t end,
})

local Input2 = Tabs.Visuals:AddInput("Name2Input", {
    Title = "Name 2 (Replacement)",
    Default = "",
    Placeholder = "New Name...",
    Callback = function(t) target2 = t end,
})

Tabs.Visuals:AddButton({
    Title = "Execute Swap",
    Callback = function()
        if target1 == "" or target2 == "" then 
            Window:Dialog({
                Title = "Error",
                Content = "Please enter both names",
                Buttons = {{Title = "OK", Callback = function() end}}
            })
            return 
        end
        local count = 0
        for _, v in pairs(game:GetDescendants()) do
            if v.Name == target1 then
                v.Name = target2
                count = count + 1
            elseif v.Name == target2 then
                v.Name = target1
                count = count + 1
            end
        end
        Window:Dialog({
            Title = "Swap Done",
            Content = "Processed "..count.." objects.",
            Buttons = {{Title = "OK", Callback = function() end}}
        })
    end,
})

-- ==================== FUNCTIONALITY ====================
RunService.Stepped:Connect(function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if char and hrp and hum then
        if JumpEnabled then
            hum.JumpPower = JumpValue
            hum.JumpHeight = JumpValue
        end
        
        if AutoBhop and UIS:IsKeyDown(Enum.KeyCode.Space) then
            if hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.Velocity = Vector3.new(hrp.Velocity.X, BhopPower, hrp.Velocity.Z)
            end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Window:SelectTab(1)
