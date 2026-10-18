-- ═══════════════════════════════════════════════════════════════
--       L U X X Y   H U B   v1  (Te4 Style UI)
--   Auto Farm | Combat | Teleport | Settings
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")

local CommF_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegAttack = Net:WaitForChild("RE/RegisterAttack")
local RegHit = Net:WaitForChild("RE/RegisterHit")

-- ═══ ANTI-VFX ═══
pcall(function()
    hookfunction(require(ReplicatedStorage.Effect.Container.Death), function() end)
    hookfunction(require(ReplicatedStorage.GuideModule).ChangeDisplayedNPC, function() end)
end)

-- ═══ CONFIG & STATE ═══
_G.AutoFarm = false
_G.BringMob = true
_G.AutoBuso = true
_G.KillAura = false
_G.Aimbot = false
_G.SelectedWeapon = "Melee"

local BringPos = CFrame.new(0, 0, 0)
local TweenSpeed = 350

-- ═══ FUNCTIONS ═══
local function TP(CF)
    if not Char or not HRP then return end
    local Dist = (CF.Position - HRP.Position).Magnitude
    if Dist < 50 then HRP.CFrame = CF return end
    
    -- Simple Tween
    local Tween = TweenService:Create(HRP, TweenInfo.new(Dist / TweenSpeed, Enum.EasingStyle.Linear), {CFrame = CF})
    Tween:Play()
    Tween.Completed:Wait()
end

local function EquipWeapon(ToolType)
    local Backpack = LP:FindFirstChild("Backpack")
    if not Backpack then return end
    local Tool = nil
    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == ToolType then
            Tool = v
            break
        end
    end
    if Tool and Char:FindFirstChild("Humanoid") then
        Char.Humanoid:EquipTool(Tool)
    end
end

local function Attack(Mob)
    if not Mob or not Mob:FindFirstChild("HumanoidRootPart") then return end
    local MobHRP = Mob.HumanoidRootPart
    BringPos = MobHRP.CFrame
    
    -- Bring Mob
    if _G.BringMob then
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                if (v.HumanoidRootPart.Position - MobHRP.Position).Magnitude < 200 then
                    v.HumanoidRootPart.CFrame = MobHRP.CFrame
                    v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                    v.HumanoidRootPart.CanCollide = false
                    v.Humanoid.WalkSpeed = 0
                    v.Humanoid.JumpPower = 0
                    if v.Humanoid:FindFirstChild("Animator") then
                        v.Humanoid.Animator:Destroy()
                    end
                end
            end
        end
    end

    -- Attack Logic
    EquipWeapon(_G.SelectedWeapon)
    local tool = Char:FindFirstChildOfClass("Tool")
    
    if tool then
        RegAttack:FireServer(0.5)
        local enemies = {}
        for _, e in pairs(workspace.Enemies:GetChildren()) do
            if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 and e:FindFirstChild("Head") then
                if (e.Head.Position - HRP.Position).Magnitude <= 60 then
                    table.insert(enemies, e)
                end
            end
        end
        if #enemies > 0 then
            RegHit:FireServer(Mob:FindFirstChild("Head") or MobHRP, enemies)
        end
    end
end

-- ═══ QUEST DATA ═══
local Quests = {
    [1] = {Lvl=1, Quest="BanditQuest1", QuestLvl=1, Mob="Bandit", CFrameQuest=CFrame.new(1059, 15, 1550), CFrameMon=CFrame.new(1045, 27, 1560)},
    [2] = {Lvl=10, Quest="JungleQuest", QuestLvl=1, Mob="Monkey", CFrameQuest=CFrame.new(-1598, 35, 153), CFrameMon=CFrame.new(-1448, 67, 11)},
    [3] = {Lvl=15, Quest="JungleQuest", QuestLvl=2, Mob="Gorilla", CFrameQuest=CFrame.new(-1598, 35, 153), CFrameMon=CFrame.new(-1129, 40, -525)},
    [4] = {Lvl=30, Quest="BuggyQuest1", QuestLvl=1, Mob="Pirate", CFrameQuest=CFrame.new(-1141, 4, 3831), CFrameMon=CFrame.new(-1103, 13, 3896)},
    [5] = {Lvl=40, Quest="BuggyQuest1", QuestLvl=2, Mob="Brute", CFrameQuest=CFrame.new(-1141, 4, 3831), CFrameMon=CFrame.new(-1140, 14, 4322)},
    [6] = {Lvl=60, Quest="DesertQuest", QuestLvl=1, Mob="Desert Bandit", CFrameQuest=CFrame.new(894, 5, 4392), CFrameMon=CFrame.new(924, 6, 4481)},
    [7] = {Lvl=75, Quest="DesertQuest", QuestLvl=2, Mob="Desert Officer", CFrameQuest=CFrame.new(894, 5, 4392), CFrameMon=CFrame.new(1608, 8, 4371)},
    [8] = {Lvl=90, Quest="SnowQuest", QuestLvl=1, Mob="Snow Bandit", CFrameQuest=CFrame.new(1389, 88, -1298), CFrameMon=CFrame.new(1354, 87, -1393)},
    [9] = {Lvl=100, Quest="SnowQuest", QuestLvl=2, Mob="Snowman", CFrameQuest=CFrame.new(1389, 88, -1298), CFrameMon=CFrame.new(1201, 144, -1550)},
    [10] = {Lvl=120, Quest="MarineQuest2", QuestLvl=1, Mob="Chief Petty Officer", CFrameQuest=CFrame.new(-5039, 27, 4324), CFrameMon=CFrame.new(-4881, 22, 4273)},
}

-- ═══ MAIN FARM LOOP ═══
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm and Char and HRP then
            pcall(function()
                local MyLevel = LP.Data.Level.Value
                local CurrentQuest = nil
                for i = #Quests, 1, -1 do
                    if MyLevel >= Quests[i].Lvl then
                        CurrentQuest = Quests[i]
                        break
                    end
                end

                if CurrentQuest then
                    -- Check if has quest
                    local QuestGui = LP.PlayerGui.Main.Quest
                    local HasQuest = false
                    if QuestGui.Visible and string.find(QuestGui.Container.QuestTitle.Title.Text, CurrentQuest.Mob) then
                        HasQuest = true
                    end

                    if not HasQuest then
                        -- Get Quest
                        TP(CurrentQuest.CFrameQuest)
                        task.wait(0.5)
                        CommF_:InvokeServer("StartQuest", CurrentQuest.Quest, CurrentQuest.QuestLvl)
                        task.wait(0.5)
                    else
                        -- Farm Mob
                        local Mob = nil
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if v.Name == CurrentQuest.Mob and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                Mob = v
                                break
                            end
                        end
                        
                        if Mob then
                            Attack(Mob)
                            -- Hover near mob
                            if (HRP.Position - Mob.HumanoidRootPart.Position).Magnitude > 15 then
                                TP(Mob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                            end
                        else
                            TP(CurrentQuest.CFrameMon)
                        end
                    end
                end
            end)
        end
    end
end)

-- ═══ KILL AURA ═══
task.spawn(function()
    while task.wait(0.1) do
        if _G.KillAura and Char and HRP then
            pcall(function()
                EquipWeapon(_G.SelectedWeapon)
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("Head") then
                        if (v.Head.Position - HRP.Position).Magnitude <= 60 then
                            RegAttack:FireServer(0.5)
                            RegHit:FireServer(v.Head, {v})
                        end
                    end
                end
            end)
        end
    end
end)

-- ═══ AUTO BUSO ═══
task.spawn(function()
    while task.wait(1) do
        if _G.AutoBuso and Char then
            pcall(function()
                if not Char:FindFirstChild("HasBuso") then
                    CommF_:InvokeServer("Buso")
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
--       U I   L I B R A R Y   (Te4 Style Dark & Purple)
-- ═══════════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LuxxyHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 320)
Main.Position = UDim2.new(0.5, -250, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Color = Color3.fromRGB(120, 50, 200)
UIStroke.Thickness = 1.5

-- Sidebar (Tabs)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "LUXXY HUB"
Title.TextColor3 = Color3.fromRGB(120, 50, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Sidebar

-- Page Container
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -140, 1, -20)
Pages.Position = UDim2.new(0, 135, 0, 10)
Pages.BackgroundTransparency = 1
Pages.Parent = Main

-- Tab System Logic
local Tabs = {}
local function CreateTab(Name, Icon)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.Position = UDim2.new(0, 5, 0, 40 + (#Tabs * 35))
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Btn.Text = "  " .. Icon .. " " .. Name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Sidebar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.Parent = Pages

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 5)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Page

    table.insert(Tabs, {Btn = Btn, Page = Page})

    Btn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
            tab.Page.Visible = false
        end
        Btn.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
        Page.Visible = true
    end)

    if #Tabs == 1 then
        Btn.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
        Page.Visible = true
    end

    return Page
end

-- Elements
local function CreateSection(Page, Text)
    local Sec = Instance.new("Frame")
    Sec.Size = UDim2.new(1, -10, 0, 25)
    Sec.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Sec.Parent = Page
    Instance.new("UICorner", Sec).CornerRadius = UDim.new(0, 4)
    
    local Txt = Instance.new("TextLabel")
    Txt.Size = UDim2.new(1, -10, 1, 0)
    Txt.Position = UDim2.new(0, 5, 0, 0)
    Txt.BackgroundTransparency = 1
    Txt.Text = Text
    Txt.TextColor3 = Color3.fromRGB(120, 50, 200)
    Txt.Font = Enum.Font.GothamBold
    Txt.TextSize = 12
    Txt.TextXAlignment = Enum.TextXAlignment.Left
    Txt.Parent = Sec
end

local function CreateToggle(Page, Text, Default, Callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Btn.Parent = Page
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    local Txt = Instance.new("TextLabel")
    Txt.Size = UDim2.new(1, -40, 1, 0)
    Txt.Position = UDim2.new(0, 10, 0, 0)
    Txt.BackgroundTransparency = 1
    Txt.Text = Text
    Txt.TextColor3 = Color3.fromRGB(220, 220, 220)
    Txt.Font = Enum.Font.Gotham
    Txt.TextSize = 12
    Txt.TextXAlignment = Enum.TextXAlignment.Left
    Txt.Parent = Btn

    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 20, 0, 20)
    Ind.Position = UDim2.new(1, -25, 0.5, -10)
    Ind.BackgroundColor3 = Default and Color3.fromRGB(120, 50, 200) or Color3.fromRGB(50, 50, 50)
    Ind.Parent = Btn
    Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

    local State = Default
    Btn.MouseButton1Click:Connect(function()
        State = not State
        Ind.BackgroundColor3 = State and Color3.fromRGB(120, 50, 200) or Color3.fromRGB(50, 50, 50)
        Callback(State)
    end)
end

local function CreateDropdown(Page, Text, Options, Callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Btn.Parent = Page
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    local Txt = Instance.new("TextLabel")
    Txt.Size = UDim2.new(1, -10, 1, 0)
    Txt.Position = UDim2.new(0, 10, 0, 0)
    Txt.BackgroundTransparency = 1
    Txt.Text = Text .. " : Pilih"
    Txt.TextColor3 = Color3.fromRGB(220, 220, 220)
    Txt.Font = Enum.Font.Gotham
    Txt.TextSize = 12
    Txt.TextXAlignment = Enum.TextXAlignment.Left
    Txt.Parent = Btn

    local List = Instance.new("ScrollingFrame")
    List.Size = UDim2.new(1, -20, 0, 100)
    List.Position = UDim2.new(0, 10, 0, 35)
    List.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    List.Visible = false
    List.Parent = Btn.Parent
    Instance.new("UICorner", List).CornerRadius = UDim.new(0, 4)

    local L = Instance.new("UIListLayout", List)
    L.Padding = UDim.new(0, 2)

    for _, opt in pairs(Options) do
        local oBtn = Instance.new("TextButton")
        oBtn.Size = UDim2.new(1, -10, 0, 25)
        oBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        oBtn.Text = opt
        oBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        oBtn.Font = Enum.Font.Gotham
        oBtn.TextSize = 11
        oBtn.Parent = List
        Instance.new("UICorner", oBtn).CornerRadius = UDim.new(0, 3)

        oBtn.MouseButton1Click:Connect(function()
            Txt.Text = Text .. " : " .. opt
            List.Visible = false
            Callback(opt)
        end)
    end

    Btn.MouseButton1Click:Connect(function()
        List.Visible = not List.Visible
    end)
end

local function CreateButton(Page, Text, Callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
    Btn.Text = Text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Parent = Page
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    Btn.MouseButton1Click:Connect(function()
        Callback()
    end)
end

-- ═══ BUILD UI TABS ═══
local FarmTab = CreateTab("Farm", "🌾")
CreateSection(FarmTab, "AUTO FARM")
CreateToggle(FarmTab, "Auto Farm Level", false, function(v) _G.AutoFarm = v end)
CreateToggle(FarmTab, "Bring Mob", true, function(v) _G.BringMob = v end)
CreateToggle(FarmTab, "Auto Buso", true, function(v) _G.AutoBuso = v end)

local CombatTab = CreateTab("Combat", "⚔️")
CreateSection(CombatTab, "ATTACK")
CreateDropdown(CombatTab, "Weapon", {"Melee", "Sword", "Blox Fruit", "Gun"}, function(v) _G.SelectedWeapon = v end)
CreateToggle(CombatTab, "Kill Aura", false, function(v) _G.KillAura = v end)
CreateToggle(CombatTab, "Aimbot Skills", false, function(v) _G.Aimbot = v end)

local TeleportTab = CreateTab("Teleport", "✈️")
CreateSection(TeleportTab, "TRAVEL")
local Islands = {"Windmill", "Jungle", "Pirate Village", "Desert", "Frozen Village", "Marine Base", "Skyland", "Prison", "Colosseum"}
CreateDropdown(TeleportTab, "Pilih Island", Islands, function(v) 
    if v == "Windmill" then TP(CFrame.new(998, 31, 1522)) end
    if v == "Jungle" then TP(CFrame.new(-1676, 19, 160)) end
    if v == "Pirate Village" then TP(CFrame.new(-1227, 39, 3894)) end
    if v == "Desert" then TP(CFrame.new(934, 18, 4285)) end
    if v == "Frozen Village" then TP(CFrame.new(1383, 113, -1352)) end
    if v == "Marine Base" then TP(CFrame.new(-4736, 35, 4220)) end
    if v == "Skyland" then TP(CFrame.new(-5353, 529, -531)) end
    if v == "Prison" then TP(CFrame.new(5185, 32, 716)) end
    if v == "Colosseum" then TP(CFrame.new(-1532, 13, -2797)) end
end)

local SettingsTab = CreateTab("Settings", "⚙️")
CreateSection(SettingsTab, "SERVER")
CreateButton(SettingsTab, "Hop Server (Lowest Player)", function()
    local Http = game:GetService("HttpService")
    local TS = game:GetService("TeleportService")
    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local res = Http:JSONDecode(game:HttpGet(url))
    if res and res.data[1] then
        TS:TeleportToPlaceInstance(game.PlaceId, res.data[1].id, LP)
    end
end)
CreateButton(SettingsTab, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- Draggable UI
local dragging = false
local dragInput, mousePos, framePos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragInput = input
        mousePos = input.Position
        framePos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - mousePos
        Main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Minimize Button (Toggle)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0, 10, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
MinBtn.Text = "L"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = ScreenGui
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

print("[Luxxy Hub v1] Loaded Successfully!")
