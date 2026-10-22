-- ═══════════════════════════════════════════════════════════════
-- BSTS-ID - LuxxyHub
-- v4.3 (Mono Glossy Edition)
-- ═══════════════════════════════════════════════════════════════

local CONFIG = {
    BrandName = "BSTS-ID - LuxxyHub",
    ConfigFile = "bstsid_luxxyhub_config.json",
    AllowedPlaceIds = { 114375429517112 },
    AllowedNameKeywords = {"bsts", "bus simulator", "bsts-id", "bstsid"},
    TruckKeyword = "BESI TUA",
    TrailerKeyword = "trailer",
    DestinationFolder = "DESTINASI POINT",
    DestinationPrefix = "DestinationPoint_",
    LoadFolder = "SEMUA MUATAN",
    LoadPromptAction = "Muat ke Truck",
    FarLoadOffset = 4,
    TruckSpawnerFolder = "TruckSpawnerRemotes",
    SpawnTruckRemote = "SpawnTruck",
    RemoveTruckRemote = "RemoveTrucks",
    TrailerNames = {
        "semi trailer", "trailer lowboy", "trailer pencocokan",
        "trailer besi tua", "trailer hino",
    },
    FarmTruckWhitelist = {
        "BESI TUA", "GIGA", "GIGA TRAILER",
        "HINO", "HINO TRAILER", "Trailer HINO",
        "FUSO", "FUSO THE GREAT", "FUSO KAYU", "FUSO LONG", "FUSO YANG HEBAT", "Fuso Panjang",
        "DYNA", "L300", "L300 HOREG",
        "RAGASA KUNING", "REDEKA", "REBEKA",
        "SEMI TRAILER", "TRAILER PENCOCOKAN", "TRAILER LOWBOY",
        "THE FUSO", "Canter Horeg", "Trailer Besi Tua",
    },
    Timeout = 10,
}

local DEFAULT_SLOT19 = Vector3.new(-527, 95, 305)
local DEFAULT_SLOT20 = Vector3.new(2482, 380, -607)

local IMG_TOGGLE = "rbxassetid://125806010780793"
local IMG_LOGO = "rbxassetid://72484610504506"

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer

local COLOR = {
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    GreyDark = Color3.fromRGB(20, 20, 20),
    GreyMed = Color3.fromRGB(60, 60, 60),
    BG = Color3.fromRGB(10, 10, 10),       
    BG2 = Color3.fromRGB(25, 25, 25),      
    TextDim = Color3.fromRGB(150, 150, 150),
    Error = Color3.fromRGB(220, 60, 60),   
    Success = Color3.fromRGB(80, 200, 100),
}

local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    return inst
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function tween(inst, props, time, style, dir)
    return TweenService:Create(inst, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function formatPrice(price)
    if not price or price <= 0 then return "—" end
    if price >= 1000000000 then return string.format("%.1f M", price / 1000000000)
    elseif price >= 1000000 then return string.format("%d Jt", math.floor(price / 1000000))
    elseif price >= 1000 then return string.format("%d K", math.floor(price / 1000)) end
    return tostring(price)
end

local function getSafeGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then
        local testOk = pcall(function()
            local t = Instance.new("Frame"); t.Parent = cg; t:Destroy()
        end)
        if testOk then return cg end
    end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then return pg end
    return LocalPlayer:WaitForChild("PlayerGui", 10)
end

local _pgCheck = LocalPlayer:FindFirstChild("PlayerGui")
if not _pgCheck then LocalPlayer:WaitForChild("PlayerGui", 5) end

local function createGlossyBorder(parent, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 2
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = parent
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(80, 80, 80)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255)),
    })
    grad.Rotation = 45
    grad.Parent = stroke
    return stroke
end

local function createGlassEffect(parent)
    local glass = Instance.new("Frame")
    glass.Size = UDim2.new(1, 0, 0.5, 0)
    glass.Position = UDim2.new(0, 0, 0, 0)
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.9
    glass.BorderSizePixel = 0
    glass.ZIndex = parent.ZIndex - 1
    glass.Parent = parent
    corner(glass, 18)
    local grad = Instance.new("UIGradient")
    grad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(1, 1)})
    grad.Rotation = 90
    grad.Parent = glass
    return glass
end

local function normalizeTruckName(str)
    str = string.lower(str or "")
    str = str:gsub("[_%-%.]", " ")
    str = str:gsub("%s+", " ")
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

local TRUCK_ALIASES = {
    ["besi tua"] = {"besi tua", "besi lama", "besitua", "besi tue", "besi"},
    ["besi lama"] = {"besi tua", "besi lama", "besitua", "besi tue", "besi"},
    ["fuso"] = {"fuso", "phuso"},
    ["giga"] = {"giga", "g1ga", "gig4"},
    ["hino"] = {"hino", "hin0", "h1no"},
    ["trailer"] = {"trailer", "treler", "treiler"},
    ["l300"] = {"l300", "l 300"},
    ["dyna"] = {"dyna", "dina"},
    ["rebeka"] = {"rebeka", "rebela", "rebel"},
    ["ragasa"] = {"ragasa", "ragasa kuning", "kuning"},
    ["the fuso"] = {"the fuso", "fuso the great"},
    ["canter"] = {"canter", "kanter"},
}

local function expandTruckKeyword(kw)
    local n = normalizeTruckName(kw)
    local aliases = TRUCK_ALIASES[n]
    if aliases then return aliases end
    for aliasKey, aliasList in pairs(TRUCK_ALIASES) do
        if n:find(aliasKey, 1, true) then return aliasList end
    end
    return {n}
end

local function truckNameMatches(truckName, keyword)
    local haystack = normalizeTruckName(truckName)
    local variants = expandTruckKeyword(keyword)
    for _, v in ipairs(variants) do
        if haystack:find(v, 1, true) then return true, v end
    end
    return false, nil
end

local defaultConfig = {
    flySpeed = 60, guiX = 0.5, guiY = 0.5, toggleOffsetX = nil, toggleOffsetY = nil,
    savedPositions = {}, slotCounter = 0, destinationCache = {}, autoFarmDestination = nil,
    autoFarmTruck = nil, loadPointCache = {}, favoriteTrucks = {}, disabledFarmTrucks = {}, lastTruckTab = "Truk",
}

local function saveConfig(data)
    if not writefile then return end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok and encoded then pcall(function() writefile(CONFIG.ConfigFile, encoded) end) end
end

local function loadConfig()
    if not (isfile and readfile) then return defaultConfig end
    local ok, content = pcall(function()
        if isfile(CONFIG.ConfigFile) then return readfile(CONFIG.ConfigFile) end
    end)
    if ok and content and content ~= "" then
        local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
        if ok2 and type(data) == "table" then
            for k, v in pairs(defaultConfig) do if data[k] == nil then data[k] = v end end
            return data
        end
    end
    return defaultConfig
end

local userConfig = loadConfig()

local function isBSTSGame()
    for _, id in ipairs(CONFIG.AllowedPlaceIds) do if game.PlaceId == id then return true end end
    local nameLower = string.lower(game.Name)
    for _, kw in ipairs(CONFIG.AllowedNameKeywords) do if string.find(nameLower, kw, 1, true) then return true end end
    return false
end

local function startCarTool()
    if _G.BSTS_LuxxyHub_Cleanup then pcall(_G.BSTS_LuxxyHub_Cleanup) end
    local activeConnections = {}
    local activeInstances = {}
    _G.BSTS_LuxxyHub_Cleanup = function()
        for _, c in pairs(activeConnections) do pcall(function() c:Disconnect() end) end
        for _, i in pairs(activeInstances) do pcall(function() if i and i.Parent then i:Destroy() end end) end
        activeConnections, activeInstances = {}, {}
    end
    local function bind(sig, cb) local c = sig:Connect(cb); table.insert(activeConnections, c); return c end
    local function track(i) table.insert(activeInstances, i); return i end

    pcall(function()
        local pg = getSafeGuiParent()
        if pg then
            local old = pg:FindFirstChild("BSTS_LuxxyHub")
            if old then old:Destroy() end
        end
    end)

    local savedPositions = userConfig.savedPositions or {}
    local slotCounter = userConfig.slotCounter or 0
    local targetVehicleRoot = nil
    local flyEnabled = false
    local flySpeed = userConfig.flySpeed or 60
    local flyBV, flyBG = nil, nil
    local farmEnabled = false
    local farmThread = nil

    local playerModule, controls
    pcall(function()
        playerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
        controls = playerModule:GetControls()
    end)

    local saveDirty = false
    local function markSaveDirty() saveDirty = true end
    task.spawn(function()
        while true do
            task.wait(2)
            if saveDirty then
                saveDirty = false
                userConfig.savedPositions = savedPositions
                userConfig.slotCounter = slotCounter
                userConfig.flySpeed = flySpeed
                saveConfig(userConfig)
            end
        end
    end)

    local TOGGLE_SIZE = 60
    local TOGGLE_MARGIN = 10

    local function getViewport()
        local cam = workspace.CurrentCamera
        if cam then return cam.ViewportSize end
        return Vector2.new(1280, 720)
    end

    local function isTogglePositionValid(x, y)
        if not x or not y or type(x) ~= "number" or type(y) ~= "number" then return false end
        local vp = getViewport()
        local minVisible = 20
        if x + TOGGLE_SIZE < minVisible or y + TOGGLE_SIZE < minVisible or x > vp.X - minVisible or y > vp.Y - minVisible then return false end
        return true
    end

    local function clampTogglePosition(x, y)
        local vp = getViewport()
        local maxX = vp.X - TOGGLE_SIZE - TOGGLE_MARGIN
        local maxY = vp.Y - TOGGLE_SIZE - TOGGLE_MARGIN
        x = math.clamp(x, TOGGLE_MARGIN, math.max(TOGGLE_MARGIN, maxX))
        y = math.clamp(y, TOGGLE_MARGIN, math.max(TOGGLE_MARGIN, maxY))
        return x, y
    end

    local startX, startY = 15, 100
    if isTogglePositionValid(userConfig.toggleOffsetX, userConfig.toggleOffsetY) then
        startX, startY = userConfig.toggleOffsetX, userConfig.toggleOffsetY
    else
        userConfig.toggleOffsetX = nil
        userConfig.toggleOffsetY = nil
        markSaveDirty()
    end

    local function findNearestCar()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local nearestTarget, shortestDist = nil, math.huge

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("VehicleSeat") then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    local vModel = obj:FindFirstAncestorOfClass("Model") or obj.Parent
                    local root = vModel
                    local cur = vModel
                    while cur and cur.Parent and cur.Parent ~= workspace do
                        cur = cur.Parent
                        if cur:IsA("Model") then root = cur end
                    end
                    nearestTarget = root
                end
            end
        end

        local kwLower = string.lower(CONFIG.TrailerKeyword)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, kwLower, 1, true) then
                    local parentIsModel = obj.Parent and obj.Parent:IsA("Model")
                    if not parentIsModel then
                        local basePart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if basePart then
                            local dist = (basePart.Position - hrp.Position).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                nearestTarget = obj
                            end
                        end
                    end
                end
            end
        end
        return nearestTarget
    end

    local function collectAllNames(instance, maxDepth)
        local names = {}
        maxDepth = maxDepth or 15
        local cur = instance
        local depth = 0
        while cur and cur ~= game and depth < maxDepth do
            depth = depth + 1
            pcall(function()
                if cur.Name and cur.Name ~= "" then table.insert(names, cur.Name) end
            end)
            pcall(function()
                if cur.DisplayName and cur.DisplayName ~= "" then table.insert(names, cur.DisplayName) end
            end)
            cur = cur.Parent
        end
        return names
    end

    local function getDrivenVehicle()
        local char = LocalPlayer.Character
        if not char then return nil, {} end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil, {} end
        local seat = hum.SeatPart
        if not seat then return nil, {} end
        local names = collectAllNames(seat, 15)
        local topModel = seat
        local cur = seat
        while cur and cur.Parent and cur.Parent ~= workspace do
            cur = cur.Parent
            if cur:IsA("Model") then topModel = cur end
        end
        return topModel, names
    end

    local function isTruckDisabled(name)
        local n = normalizeTruckName(name)
        for _, d in ipairs(userConfig.disabledFarmTrucks or {}) do
            if normalizeTruckName(d) == n then return true end
        end
        return false
    end

    local function isDrivingFarmTruck()
        local vehicle, names = getDrivenVehicle()
        if not vehicle then return false, nil end
        if #names == 0 then return false, nil end

        if userConfig.autoFarmTruck then
            for _, name in ipairs(names) do
                if truckNameMatches(name, userConfig.autoFarmTruck) then return true, vehicle end
            end
        end

        local whitelist = CONFIG.FarmTruckWhitelist or {}
        for _, name in ipairs(names) do
            local nameNorm = normalizeTruckName(name)
            for _, kw in ipairs(whitelist) do
                local kwNorm = normalizeTruckName(kw)
                if not isTruckDisabled(kw) then
                    local match = truckNameMatches(nameNorm, kw)
                    if match then
                        local isTrailerOnly = nameNorm:find("trailer", 1, true) and not nameNorm:find("hino", 1, true) and not nameNorm:find("besi", 1, true) and not nameNorm:find("giga", 1, true) and not nameNorm:find("semi", 1, true)
                        if not isTrailerOnly then return true, vehicle end
                    end
                end
            end
        end
        return false, vehicle
    end

    local function teleportCarToPos(pos)
        if not pos then return end
        local vehicle, _ = getDrivenVehicle()
        if not vehicle then vehicle = targetVehicleRoot end
        if not vehicle then return end
        
        local primaryPart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
        if not primaryPart then
            for _, d in pairs(vehicle:GetDescendants()) do if d:IsA("BasePart") then primaryPart = d break end end
        end
        if not primaryPart then return end
        local allParts, relCF = {}, {}
        for _, p in pairs(vehicle:GetDescendants()) do if p:IsA("BasePart") then table.insert(allParts, p) end end
        for _, p in pairs(allParts) do relCF[p] = primaryPart.CFrame:ToObjectSpace(p.CFrame) end
        for _, p in pairs(allParts) do p.Anchored = true end
        primaryPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        for p, rel in pairs(relCF) do p.CFrame = primaryPart.CFrame:ToWorldSpace(rel) end
        task.wait(0.1)
        for _, p in pairs(allParts) do pcall(function() if p:CanSetNetworkOwnership() then p:SetNetworkOwner(LocalPlayer) end end) end
        for _, p in pairs(allParts) do p.Anchored = false end
    end

    local function teleportPlayerToPos(pos)
        if not pos then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0)) end
    end

    local function scanDestinationPoints()
        local folder = workspace:FindFirstChild(CONFIG.DestinationFolder)
        if not folder then
            for _, alt in ipairs({"DESTINASI POINT", "DESTINASI", "DestinationPoints"}) do
                local f = workspace:FindFirstChild(alt)
                if f then folder = f break end
            end
        end
        if not folder then return {} end

        local results = {}
        for _, dest in ipairs(folder:GetChildren()) do
            if dest:IsA("Model") then
                local zone = dest:FindFirstChild("Zone", true)
                if not (zone and zone:IsA("BasePart")) then
                    local biggest = nil
                    for _, c in ipairs(dest:GetDescendants()) do
                        if c:IsA("BasePart") and c.Transparency > 0.5 and c.Name ~= "Tiang" and not c.Name:find("Border") then
                            if not biggest or c.Size.Magnitude > biggest.Size.Magnitude then biggest = c end
                        end
                    end
                    zone = biggest
                end
                if zone and zone:IsA("BasePart") then
                    local displayName = dest.Name
                    if displayName:sub(1, #CONFIG.DestinationPrefix) == CONFIG.DestinationPrefix then displayName = displayName:sub(#CONFIG.DestinationPrefix + 1) end
                    table.insert(results, {name = displayName, fullName = dest.Name, model = dest, zonePart = zone, position = zone.Position})
                end
            end
        end
        return results
    end

    local function getCachedDestinations()
        local pid = tostring(game.PlaceId)
        local cache = userConfig.destinationCache and userConfig.destinationCache[pid] or {}
        local out = {}
        for _, c in ipairs(cache) do table.insert(out, {name = c.name, fullName = c.fullName, position = Vector3.new(c.x, c.y, c.z), fromCache = true}) end
        return out
    end

    local function teleportToDestination(destName)
        local destinations = scanDestinationPoints()
        if #destinations == 0 then destinations = getCachedDestinations() end
        local target = nil
        for _, d in ipairs(destinations) do if d.name == destName or d.fullName == destName then target = d break end end
        if not target then return false end
        teleportCarToPos(target.position + Vector3.new(0, 3, 0))
        return true
    end

    local function scanLoadingPoints()
        local folder = workspace:FindFirstChild(CONFIG.LoadFolder) or workspace
        local results = {}
        local seen = {}
        for _, obj in pairs(folder:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local actionText = string.lower(obj.ActionText or "")
                local targetAction = string.lower(CONFIG.LoadPromptAction)
                if string.find(actionText, targetAction, 1, true) then
                    local parent = obj.Parent
                    local basePart = parent and parent:IsA("BasePart") and parent or (parent and parent:FindFirstChildWhichIsA("BasePart"))
                    if basePart then
                        local name = obj.ObjectText or "Unknown"
                        local key = name .. "_" .. math.floor(basePart.Position.X) .. "_" .. math.floor(basePart.Position.Z)
                        if not seen[key] then
                            seen[key] = true
                            table.insert(results, {name = name, actionText = obj.ActionText, prompt = obj, position = basePart.Position, holdDuration = obj.HoldDuration or 0.5, maxDist = obj.MaxActivationDistance or 10})
                        end
                    end
                end
            end
        end
        return results
    end

    local function farLoadItem(loadName, statusLbl)
        local loads = scanLoadingPoints()
        local target = nil
        for _, l in ipairs(loads) do if string.lower(l.name) == string.lower(loadName) then target = l break end end
        if not target then return false end

        local vehicle, _ = getDrivenVehicle()
        if not vehicle then vehicle = targetVehicleRoot end
        if not vehicle then vehicle = findNearestCar() end
        if not vehicle then return false end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local origPlayerCF = hrp.CFrame
        local primary = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
        if not primary then for _, d in pairs(vehicle:GetDescendants()) do if d:IsA("BasePart") then primary = d break end end end
        if not primary then return false end
        local origVehicleCF = primary.CFrame

        local offsetDir = (origVehicleCF.Position - target.position).Unit
        if offsetDir.Magnitude < 0.1 then offsetDir = Vector3.new(0, 0, 1) end
        local tpPos = target.position + offsetDir * CONFIG.FarLoadOffset
        tpPos = Vector3.new(tpPos.X, target.position.Y + 3, tpPos.Z)

        if statusLbl then statusLbl.Text = "⚡ Far-Load: " .. target.name; statusLbl.TextColor3 = COLOR.White end

        local allParts = {}
        for _, p in pairs(vehicle:GetDescendants()) do if p:IsA("BasePart") then table.insert(allParts, p) end end
        local relCF = {}
        for _, p in pairs(allParts) do relCF[p] = primary.CFrame:ToObjectSpace(p.CFrame) end

        for _, p in pairs(allParts) do p.Anchored = true end
        primary.CFrame = CFrame.new(tpPos)
        for p, rel in pairs(relCF) do p.CFrame = primary.CFrame:ToWorldSpace(rel) end
        hrp.CFrame = CFrame.new(tpPos)
        task.wait(0.1)

        if fireproximityprompt then pcall(function() fireproximityprompt(target.prompt) end)
        else pcall(function() target.prompt:InputHoldBegin(); task.wait(target.holdDuration + 0.1); target.prompt:InputHoldEnd() end) end
        task.wait(target.holdDuration + 0.4)

        primary.CFrame = origVehicleCF
        for p, rel in pairs(relCF) do p.CFrame = primary.CFrame:ToWorldSpace(rel) end
        hrp.CFrame = origPlayerCF
        task.wait(0.1)

        for _, p in pairs(allParts) do pcall(function() if p:CanSetNetworkOwnership() then p:SetNetworkOwner(LocalPlayer) end end) end
        for _, p in pairs(allParts) do p.Anchored = false end
        if statusLbl then statusLbl.Text = "✅ Far-Load OK: " .. target.name; statusLbl.TextColor3 = COLOR.Success end
        return true
    end

    local function loadTruckData()
        local trucks = {}
        local RS = game:GetService("ReplicatedStorage")
        local function mergeFromConfig(cfgName, keyName)
            local cfg = RS:FindFirstChild(cfgName)
            if not cfg then return end
            local ok, data = pcall(require, cfg)
            if not ok or type(data) ~= "table" then return end
            for name, val in pairs(data) do trucks[name] = trucks[name] or {}; trucks[name][keyName] = val end
        end
        mergeFromConfig("TruckPriceConfig", "price")
        mergeFromConfig("TruckPhotoConfig", "photo")
        mergeFromConfig("TruckPassConfig", "passId")

        local extraNames = {"BESI TUA", "Trailer Besi Tua", "Canter Horeg", "DYNA", "Fuso Kayu", "Fuso Panjang", "FUSO YANG HEBAT", "GIGA", "GIGA TRAILER", "HINO", "Trailer HINO", "L300", "L300 HOREG", "Ragasa Kuning", "REDEKA", "Trailer Pencocokan", "SEMI TRAILER", "Trailer Lowboy", "FUSO THE GREAT", "FUSO LONG", "FUSO KAYU", "REBEKA"}
        for _, n in ipairs(extraNames) do if not trucks[n] then trucks[n] = {} end end

        local arr = {}
        for name, info in pairs(trucks) do table.insert(arr, {name = name, price = tonumber(info.price) or 0, photo = info.photo, passId = info.passId}) end
        table.sort(arr, function(a, b) if a.price ~= b.price then return a.price > b.price end return a.name < b.name end)
        return arr
    end

    local function isTrailerTruck(name)
        local n = string.lower(name)
        for _, kw in ipairs(CONFIG.TrailerNames) do if string.find(n, kw, 1, true) then return true end end
        return false
    end

    local function spawnTruckByName(name)
        local RS = game:GetService("ReplicatedStorage")
        local folder = RS:FindFirstChild(CONFIG.TruckSpawnerFolder)
        if not folder then return false end
        local remote = folder:FindFirstChild(CONFIG.SpawnTruckRemote)
        if not remote then return false end
        local ok = pcall(function() remote:FireServer(name) end)
        if ok then print("[BSTS-ID] 🚀 Spawn: " .. name); return true end
        return false
    end

    local function removeAllTrucks()
        local RS = game:GetService("ReplicatedStorage")
        local folder = RS:FindFirstChild(CONFIG.TruckSpawnerFolder)
        if not folder then return false end
        local remote = folder:FindFirstChild(CONFIG.RemoveTruckRemote)
        if not remote then return false end
        local ok = pcall(function() remote:FireServer() end)
        if ok then print("[BSTS-ID] 🗑 Semua truck dihapus"); return true end
        return false
    end

    local function autoSpawnAndSit(truckName, statusLbl)
        if not truckName then return false end
        if statusLbl then statusLbl.Text = "🗑 Menghapus truck..."; statusLbl.TextColor3 = COLOR.White end
        removeAllTrucks()
        task.wait(1.5)
        if statusLbl then statusLbl.Text = "🚀 Spawn " .. truckName .. "..."; statusLbl.TextColor3 = COLOR.White end
        spawnTruckByName(truckName)
        task.wait(3)
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return false end

        local nearestSeat = nil
        local shortestDist = math.huge
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("VehicleSeat") then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < shortestDist then shortestDist = dist; nearestSeat = obj end
            end
        end

        if nearestSeat then
            if statusLbl then statusLbl.Text = "🧍 Duduk..."; statusLbl.TextColor3 = COLOR.White end
            hrp.CFrame = nearestSeat.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.5)
            hum.Sit = true
            task.wait(1)
            if hum.SeatPart == nearestSeat then return true
            else hrp.CFrame = nearestSeat.CFrame; task.wait(0.2); hum.Sit = true; task.wait(1); return hum.SeatPart == nearestSeat end
        end
        return false
    end

    local function toggleFly()
        flyEnabled = not flyEnabled
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if flyEnabled then
            hum.PlatformStand = true
            flyBV = Instance.new("BodyVelocity", hrp)
            flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBG = Instance.new("BodyGyro", hrp)
            flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            flyBG.P = 10000; flyBG.D = 100
        else
            if flyBV then flyBV:Destroy() end
            if flyBG then flyBG:Destroy() end
            hum.PlatformStand = false
        end
    end

    bind(RunService.RenderStepped, function()
        if not flyEnabled or not flyBV or not flyBG then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        if controls then
            local ok, mv = pcall(function() return controls:GetMoveVector() end)
            if ok and mv and mv.Magnitude > 0 then moveDir = (cam.CFrame.LookVector * -mv.Z + cam.CFrame.RightVector * mv.X) end
        end
        if moveDir.Magnitude == 0 then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then flyBV.Velocity = moveDir.Unit * flySpeed else flyBV.Velocity = Vector3.new(0, 0, 0) end
        flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
    end)

    local function getSlot19Pos()
        local slot = savedPositions[2]
        if slot and slot.pos then return slot.pos end
        return DEFAULT_SLOT19
    end
    local function getSlot20Pos()
        local slot = savedPositions[1]
        if slot and slot.pos then return slot.pos end
        return DEFAULT_SLOT20
    end

    local function stopFarm()
        farmEnabled = false
        if farmThread then pcall(function() task.cancel(farmThread) end); farmThread = nil end
    end

    local function startFarm(statusLbl)
        if farmEnabled then return end
        farmEnabled = true
        farmThread = task.spawn(function()
            while farmEnabled do
                local isDriving = isDrivingFarmTruck()
                if not isDriving then
                    local targetTruck = userConfig.autoFarmTruck
                    if not targetTruck then
                        for _, t in ipairs(CONFIG.FarmTruckWhitelist) do if not isTruckDisabled(t) then targetTruck = t; break end end
                    end
                    if not targetTruck then
                        if statusLbl then statusLbl.Text = "❌ Semua truck dimatikan"; statusLbl.TextColor3 = COLOR.Error end
                        task.wait(3)
                    else
                        local success = autoSpawnAndSit(targetTruck, statusLbl)
                        if not success then
                            if statusLbl then statusLbl.Text = "❌ Gagal spawn. Pastikan di jalan."; statusLbl.TextColor3 = COLOR.Error end
                            task.wait(3)
                        else task.wait(1) end
                    end
                else
                    local pos19, pos20 = getSlot19Pos(), getSlot20Pos()
                    if statusLbl then statusLbl.Text = "🌾 [1/6] TP Slot 19..."; statusLbl.TextColor3 = COLOR.White end
                    teleportCarToPos(pos19); task.wait(2)
                    if statusLbl then statusLbl.Text = "🌾 [2/6] Muat Slot 19..." end
                    if fireproximityprompt then
                        local p = workspace:FindFirstChild("SEMUA MUATAN") and workspace.SEMUA MUATAN:GetDescendants() or {}
                        for _, o in pairs(p) do if o:IsA("ProximityPrompt") and o.Enabled then pcall(function() fireproximityprompt(o) end); break end end
                    end
                    task.wait(2.5)
                    if not farmEnabled then break end

                    if statusLbl then statusLbl.Text = "🌾 [3/6] TP Slot 20..." end
                    teleportCarToPos(pos20); task.wait(2)
                    if statusLbl then statusLbl.Text = "🌾 [4/6] Muat Slot 20..." end
                    if fireproximityprompt then
                        local p = workspace:FindFirstChild("SEMUA MUATAN") and workspace.SEMUA MUATAN:GetDescendants() or {}
                        for _, o in pairs(p) do if o:IsA("ProximityPrompt") and o.Enabled then pcall(function() fireproximityprompt(o) end); break end end
                    end
                    task.wait(2.5)
                    if not farmEnabled then break end

                    local destName = userConfig.autoFarmDestination
                    if destName then
                        if statusLbl then statusLbl.Text = "💰 [5/6] TP Destinasi..."; statusLbl.TextColor3 = COLOR.Success end
                        teleportToDestination(destName); task.wait(3)
                        if statusLbl then statusLbl.Text = "💰 [6/6] Tunggu bayaran..." end
                        task.wait(2)
                    else
                        if statusLbl then statusLbl.Text = "⚠️ Set destinasi dulu di panel 🎯"; statusLbl.TextColor3 = COLOR.Error end
                        task.wait(2)
                    end
                end
            end
        end)
    end

    local cam = workspace.CurrentCamera
    local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
    if vp.X <= 0 or vp.Y <= 0 then vp = Vector2.new(1280, 720) end
    local guiW = math.clamp(340, math.min(260, vp.X - 40), math.max(math.min(260, vp.X - 40), vp.X - 40))
    local guiH = math.clamp(600, math.min(420, vp.Y - 60), math.max(math.min(420, vp.Y - 60), vp.Y - 60))

    local ScreenGui = track(new("ScreenGui", {Name = "BSTS_LuxxyHub", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 100, Parent = getSafeGuiParent()}))
    local ToggleWrapper = track(new("Frame", {Name = "ToggleWrapper", AnchorPoint = Vector2.new(0, 0), Size = UDim2.new(0, TOGGLE_SIZE, 0, TOGGLE_SIZE), Position = UDim2.new(0, startX, 0, startY), BackgroundTransparency = 1, ZIndex = 200, Parent = ScreenGui}))
    local ToggleBtn = new("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = COLOR.Black, BorderSizePixel = 0, Text = "", AutoButtonColor = false, Active = true, ZIndex = 202, Parent = ToggleWrapper})
    corner(ToggleBtn, 30); createGlossyBorder(ToggleBtn, 2); createGlassEffect(ToggleBtn)
    new("ImageLabel", {Size = UDim2.new(0.75, 0, 0.75, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = IMG_TOGGLE, ImageColor3 = Color3.fromRGB(255, 255, 255), ScaleType = Enum.ScaleType.Fit, ZIndex = 203, Parent = ToggleBtn})

    local isDragging, dragStartPos, dragStartInput, hasMoved = false, nil, nil, false
    local DRAG_THRESHOLD = 5

    bind(ToggleBtn.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true; hasMoved = false
            dragStartInput = Vector2.new(input.Position.X, input.Position.Y)
            dragStartPos = ToggleWrapper.Position
        end
    end)
    bind(UserInputService.InputChanged, function(input)
        if not isDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local currentInput = Vector2.new(input.Position.X, input.Position.Y)
            local delta = currentInput - dragStartInput
            if delta.Magnitude > DRAG_THRESHOLD then hasMoved = true end
            if hasMoved then
                local nx = dragStartPos.X.Offset + delta.X
                local ny = dragStartPos.Y.Offset + delta.Y
                local cx, cy = clampTogglePosition(nx, ny)
                ToggleWrapper.Position = UDim2.new(0, cx, 0, cy)
            end
        end
    end)
    bind(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDragging and hasMoved then
                local cx, cy = clampTogglePosition(ToggleWrapper.Position.X.Offset, ToggleWrapper.Position.Y.Offset)
                ToggleWrapper.Position = UDim2.new(0, cx, 0, cy)
                if isTogglePositionValid(cx, cy) then userConfig.toggleOffsetX = cx; userConfig.toggleOffsetY = cy; markSaveDirty() end
            end
            isDragging = false; dragStartPos = nil; dragStartInput = nil
        end
    end)

    local MainWrapper = track(new("Frame", {Name = "MainWrapper", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, guiW, 0, guiH), Position = UDim2.new(userConfig.guiX or 0.5, 0, userConfig.guiY or 0.5, 0), BackgroundTransparency = 1, Visible = false, ZIndex = 99, Parent = ScreenGui}))
    local MainFrame = track(new("Frame", {Name = "MainFrame", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = COLOR.BG, BorderSizePixel = 0, Active = true, Draggable = true, ClipsDescendants = true, ZIndex = 100, Parent = MainWrapper}))
    corner(MainFrame, 18); createGlossyBorder(MainFrame, 2); createGlassEffect(MainFrame)
    bind(MainFrame:GetPropertyChangedSignal("Position"), function()
        if MainWrapper.Visible then userConfig.guiX = MainWrapper.Position.X.Scale; userConfig.guiY = MainWrapper.Position.Y.Scale; markSaveDirty() end
    end)

    local Header = new("Frame", {Size = UDim2.new(1,0,0,50), BackgroundColor3 = COLOR.Black, BackgroundTransparency = 0.6, BorderSizePixel = 0, Parent = MainFrame})
    corner(Header, 18)
    new("ImageLabel", {Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 12, 0.5, -16), BackgroundTransparency = 1, Image = IMG_LOGO, ImageColor3 = Color3.fromRGB(255, 255, 255), ScaleType = Enum.ScaleType.Fit, ZIndex = 5, Parent = Header})
    new("TextLabel", {Size = UDim2.new(1,-90,1,-5), Position = UDim2.new(0,50,0,0), BackgroundTransparency = 1, Text = "BSTS-ID - LuxxyHub", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header})
    new("TextLabel", {Size = UDim2.new(1,-90,0,12), Position = UDim2.new(0,50,1,-15), BackgroundTransparency = 1, Text = "Mono Glossy v4.3", TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header})
    local CloseBtn = new("TextButton", {Size = UDim2.new(0,26,0,26), Position = UDim2.new(1,-34,0,12), BackgroundColor3 = COLOR.GreyDark, Text = "✕", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0, ZIndex = 150, Parent = Header})
    corner(CloseBtn, 13); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = CloseBtn})

    local Content = new("ScrollingFrame", {Size = UDim2.new(1,-16,1,-60), Position = UDim2.new(0,8,0,55), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = COLOR.White, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 110, Parent = MainFrame})
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6), Parent = Content})

    local function makePremiumBtn(parent, text, c1, c2, h)
        h = h or 40
        local btn = new("TextButton", {Size = UDim2.new(1,0,0,h), BackgroundColor3 = COLOR.GreyDark, Text = "", BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 120, Parent = parent})
        corner(btn, 10); createGlossyBorder(btn, 1); createGlassEffect(btn)
        local lbl = new("TextLabel", {Size = UDim2.new(1,-20,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = text, TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 130, Parent = btn})
        btn.MouseEnter:Connect(function() pcall(function() tween(btn, {Size = UDim2.new(1.02,0,0,h)}, 0.2):Play() end) end)
        btn.MouseLeave:Connect(function() pcall(function() tween(btn, {Size = UDim2.new(1,0,0,h)}, 0.2):Play() end) end)
        return btn, lbl
    end

    local SaveBtn, SaveLbl = makePremiumBtn(Content, "💾  Save Posisi ke Slot Baru", COLOR.GreyDark, COLOR.Black); SaveBtn.LayoutOrder = 1
    local FindBtn, FindLbl = makePremiumBtn(Content, "🔍  Cari Target Terdekat", COLOR.GreyDark, COLOR.Black); FindBtn.LayoutOrder = 2

    local PosTitle = new("TextLabel", {Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = "💾  POSISI TERSIMPAN (0)", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 3, ZIndex = 120, Parent = Content})
    local PositionsList = new("ScrollingFrame", {Size = UDim2.new(1,0,0,150), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.4, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = COLOR.White, CanvasSize = UDim2.new(0,0,0,0), LayoutOrder = 4, ZIndex = 120, Parent = Content})
    corner(PositionsList, 10)
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = PositionsList})
    new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = PositionsList})
    local EmptyLabel = new("TextLabel", {Name = "EmptyLabel", Size = UDim2.new(1,-12,0,60), BackgroundTransparency = 1, Text = "Belum ada posisi tersimpan.", TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, ZIndex = 121, LayoutOrder = 0, Parent = PositionsList})

    local ROW_HEIGHT = 58
    local ROW_PADDING = 6
    local refreshPositionList

    local function buildSlotRow(posData, index)
        if type(posData) ~= "table" or typeof(posData.pos) ~= "Vector3" then return end
        local row = new("Frame", {Size = UDim2.new(1,0,0,ROW_HEIGHT), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.2, BorderSizePixel = 0, LayoutOrder = index, ZIndex = 121, Parent = PositionsList})
        corner(row, 8); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = row})
        new("TextLabel", {Size = UDim2.new(1,-16,0,20), Position = UDim2.new(0,8,0,4), BackgroundTransparency = 1, Text = string.format("%s  •  X:%d Y:%d Z:%d", posData.name or "Slot", math.floor(posData.pos.X), math.floor(posData.pos.Y), math.floor(posData.pos.Z)), TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 122, Parent = row})
        local tpObj = new("TextButton", {Size = UDim2.new(0.32,-3,0,26), Position = UDim2.new(0,6,0,28), BackgroundColor3 = COLOR.GreyDark, Text = "🚗 TP Obj", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 10, BorderSizePixel = 0, ZIndex = 122, Parent = row})
        corner(tpObj, 6); createGlossyBorder(tpObj, 1)
        local tpPlr = new("TextButton", {Size = UDim2.new(0.32,-3,0,26), Position = UDim2.new(0.32,3,0,28), BackgroundColor3 = COLOR.GreyDark, Text = "🧍 TP Player", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 10, BorderSizePixel = 0, ZIndex = 122, Parent = row})
        corner(tpPlr, 6); createGlossyBorder(tpPlr, 1)
        local delBtn = new("TextButton", {Size = UDim2.new(0.36,-12,0,26), Position = UDim2.new(0.64,9,0,28), BackgroundColor3 = COLOR.Error, Text = "🗑 Hapus", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 10, BorderSizePixel = 0, ZIndex = 122, Parent = row})
        corner(delBtn, 6)
        tpObj.MouseButton1Click:Connect(function() tpObj.Text = "⏳..."; teleportCarToPos(posData.pos); task.wait(0.4); tpObj.Text = "✅ OK!"; task.wait(0.8); tpObj.Text = "🚗 TP Obj" end)
        tpPlr.MouseButton1Click:Connect(function() tpPlr.Text = "⏳..."; teleportPlayerToPos(posData.pos); task.wait(0.4); tpPlr.Text = "✅ OK!"; task.wait(0.8); tpPlr.Text = "🧍 TP Player" end)
        delBtn.MouseButton1Click:Connect(function()
            for i, p in ipairs(savedPositions) do if p == posData then table.remove(savedPositions, i) break end end
            markSaveDirty(); refreshPositionList()
        end)
    end

    refreshPositionList = function()
        for i = #savedPositions, 1, -1 do
            local pd = savedPositions[i]
            if type(pd) ~= "table" or typeof(pd.pos) ~= "Vector3" or type(pd.name) ~= "string" then table.remove(savedPositions, i); markSaveDirty() end
        end
        for _, c in pairs(PositionsList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        PosTitle.Text = "💾  POSISI TERSIMPAN (" .. #savedPositions .. ")"
        if #savedPositions == 0 then EmptyLabel.Visible = true else EmptyLabel.Visible = false; for i, pd in ipairs(savedPositions) do pcall(buildSlotRow, pd, i) end end
        PositionsList.CanvasSize = UDim2.new(0, 0, 0, #savedPositions == 0 and 72 or (#savedPositions * (ROW_HEIGHT + ROW_PADDING) + 12))
    end
    task.spawn(function() pcall(refreshPositionList) end)

    new("Frame", {Size = UDim2.new(1,0,0,1), BackgroundColor3 = COLOR.White, BackgroundTransparency = 0.8, BorderSizePixel = 0, LayoutOrder = 5, ZIndex = 120, Parent = Content})

    new("TextLabel", {Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = "🌾  AUTO FARM (FULL AUTO)", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 6, ZIndex = 120, Parent = Content})
    local FarmToggleRow = new("Frame", {Size = UDim2.new(1,0,0,50), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.3, BorderSizePixel = 0, LayoutOrder = 7, ZIndex = 120, Parent = Content})
    corner(FarmToggleRow, 10); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = FarmToggleRow})
    local FarmLabel = new("TextLabel", {Size = UDim2.new(0.55,0,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, Text = "AUTO FARM: OFF", TextColor3 = COLOR.Error, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 130, Parent = FarmToggleRow})
    local SwitchBg = new("Frame", {Size = UDim2.new(0,60,0,28), Position = UDim2.new(1,-72,0.5,-14), BackgroundColor3 = COLOR.GreyDark, BorderSizePixel = 0, ZIndex = 130, Parent = FarmToggleRow})
    corner(SwitchBg, 14)
    local SwitchBtn = new("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", ZIndex = 131, Parent = SwitchBg})
    local SwitchKnob = new("Frame", {Size = UDim2.new(0,22,0,22), Position = UDim2.new(0,3,0.5,-11), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0, ZIndex = 132, Parent = SwitchBg})
    corner(SwitchKnob, 11)

    local farmToggleActive = false
    local function setSwitchVisual(on)
        if on then
            tween(SwitchBg, {BackgroundColor3 = COLOR.White}, 0.2):Play(); tween(SwitchKnob, {BackgroundColor3 = COLOR.Black, Position = UDim2.new(1,-25,0.5,-11)}, 0.2):Play()
            FarmLabel.Text = "AUTO FARM: ON"; FarmLabel.TextColor3 = COLOR.Success
        else
            tween(SwitchBg, {BackgroundColor3 = COLOR.GreyDark}, 0.2):Play(); tween(SwitchKnob, {BackgroundColor3 = COLOR.White, Position = UDim2.new(0,3,0.5,-11)}, 0.2):Play()
            FarmLabel.Text = "AUTO FARM: OFF"; FarmLabel.TextColor3 = COLOR.Error
        end
    end

    new("Frame", {Size = UDim2.new(1,0,0,1), BackgroundColor3 = COLOR.White, BackgroundTransparency = 0.8, BorderSizePixel = 0, LayoutOrder = 7.1, ZIndex = 120, Parent = Content})
    new("TextLabel", {Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = "🚛  TRUCK SUPPORT", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 7.11, ZIndex = 120, Parent = Content})
    local TruckSupportInfo = new("TextLabel", {Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, Text = "✅ Semua truck aktif", TextColor3 = COLOR.Success, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 7.12, ZIndex = 120, Parent = Content})
    local TruckSupportList = new("ScrollingFrame", {Size = UDim2.new(1,0,0,120), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.4, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = COLOR.White, CanvasSize = UDim2.new(0,0,0,0), LayoutOrder = 7.13, ZIndex = 120, Parent = Content})
    corner(TruckSupportList, 10)
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = TruckSupportList})
    new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = TruckSupportList})

    local function toggleTruckDisabled(name)
        userConfig.disabledFarmTrucks = userConfig.disabledFarmTrucks or {}
        local n = normalizeTruckName(name)
        for i, d in ipairs(userConfig.disabledFarmTrucks) do
            if normalizeTruckName(d) == n then table.remove(userConfig.disabledFarmTrucks, i); markSaveDirty(); return false end
        end
        table.insert(userConfig.disabledFarmTrucks, name); markSaveDirty(); return true
    end

    local function getUniqueTruckList()
        local seen = {}; local out = {}
        for _, kw in ipairs(CONFIG.FarmTruckWhitelist or {}) do
            local norm = normalizeTruckName(kw)
            if not seen[norm] then seen[norm] = true; table.insert(out, kw) end
        end
        return out
    end

    local function buildTruckSupportRow(truckName, index)
        local disabled = isTruckDisabled(truckName)
        local row = new("TextButton", {Size = UDim2.new(1,0,0,30), BackgroundColor3 = disabled and COLOR.Black or COLOR.GreyDark, BackgroundTransparency = disabled and 0.5 or 0, BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = index, ZIndex = 121, Parent = TruckSupportList})
        corner(row, 8); createGlossyBorder(row, 1)
        new("TextLabel", {Size = UDim2.new(0.15,0,1,0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, Text = disabled and "❌" or "✅", TextColor3 = disabled and COLOR.Error or COLOR.Success, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 122, Parent = row})
        new("TextLabel", {Size = UDim2.new(0.85,-16,1,0), Position = UDim2.new(0.15,0,0,0), BackgroundTransparency = 1, Text = truckName, TextColor3 = disabled and COLOR.TextDim or COLOR.White, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 122, Parent = row})
        row.MouseButton1Click:Connect(function()
            toggleTruckDisabled(truckName)
            task.spawn(function()
                task.wait(0.05)
                for _, c in pairs(TruckSupportList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                local trucks = getUniqueTruckList()
                for i, t in ipairs(trucks) do pcall(buildTruckSupportRow, t, i) end
                TruckSupportList.CanvasSize = UDim2.new(0, 0, 0, #trucks * 34 + 12)
                local activeCount = 0
                for _, t in ipairs(trucks) do if not isTruckDisabled(t) then activeCount = activeCount + 1 end end
                TruckSupportInfo.Text = "✅ " .. activeCount .. "/" .. #trucks .. " truck aktif"
                TruckSupportInfo.TextColor3 = activeCount > 0 and COLOR.Success or COLOR.Error
            end)
        end)
    end

    task.spawn(function()
        task.wait(1)
        local trucks = getUniqueTruckList()
        for i, t in ipairs(trucks) do pcall(buildTruckSupportRow, t, i) end
        TruckSupportList.CanvasSize = UDim2.new(0, 0, 0, #trucks * 34 + 12)
        local activeCount = 0
        for _, t in ipairs(trucks) do if not isTruckDisabled(t) then activeCount = activeCount + 1 end end
        TruckSupportInfo.Text = "✅ " .. activeCount .. "/" .. #trucks .. " truck aktif"
    end)

    new("Frame", {Size = UDim2.new(1,0,0,1), BackgroundColor3 = COLOR.White, BackgroundTransparency = 0.8, BorderSizePixel = 0, LayoutOrder = 7.4, ZIndex = 120, Parent = Content})
    new("TextLabel", {Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = "🚛  SPAWN TRUCK", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 7.41, ZIndex = 120, Parent = Content})
    local TruckTabBar = new("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.3, BorderSizePixel = 0, LayoutOrder = 7.42, ZIndex = 120, Parent = Content})
    corner(TruckTabBar, 10); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = TruckTabBar})
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0,4), Parent = TruckTabBar})
    local TruckStatus = new("TextLabel", {Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, Text = "⏳ Loading...", TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 7.43, ZIndex = 120, Parent = Content})
    local TruckList = new("ScrollingFrame", {Size = UDim2.new(1,0,0,280), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.4, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = COLOR.White, CanvasSize = UDim2.new(0,0,0,0), LayoutOrder = 7.44, ZIndex = 120, Parent = Content})
    corner(TruckList, 10)
    new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = TruckList})
    new("UIGridLayout", {CellSize = UDim2.new(0, 96, 0, 118), CellPadding = UDim2.new(0, 6, 0, 6), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Left, Parent = TruckList})

    local allTrucksCache = {}
    local currentTab = userConfig.lastTruckTab or "Truk"

    local function buildTruckCard(truck)
        local isFav = false
        for _, n in ipairs(userConfig.favoriteTrucks or {}) do if n == truck.name then isFav = true break end end
        local card = new("Frame", {Size = UDim2.new(0, 96, 0, 118), BackgroundColor3 = COLOR.GreyDark, BorderSizePixel = 0, ZIndex = 121, Parent = TruckList})
        corner(card, 10); createGlossyBorder(card, isFav and 2 or 1)
        
        local img = new("ImageLabel", {Size = UDim2.new(1,-8,0,60), Position = UDim2.new(0,4,0,4), BackgroundColor3 = COLOR.Black, BackgroundTransparency = 0.3, BorderSizePixel = 0, Image = truck.photo and ("rbxassetid://" .. tostring(truck.photo)) or "", ScaleType = Enum.ScaleType.Fit, ZIndex = 122, Parent = card})
        corner(img, 6)
        local nameBadge = new("TextLabel", {Size = UDim2.new(1,-8,0,16), Position = UDim2.new(0,4,0,66), BackgroundColor3 = COLOR.Black, BackgroundTransparency = 0.2, BorderSizePixel = 0, Text = truck.name, TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 9, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 123, Parent = card})
        corner(nameBadge, 5)
        new("TextLabel", {Size = UDim2.new(1,-8,0,12), Position = UDim2.new(0,4,0,84), BackgroundTransparency = 1, Text = "💰 " .. formatPrice(truck.price) .. (truck.passId and " 🔒" or ""), TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 123, Parent = card})

        local spawnBtn = new("TextButton", {Size = UDim2.new(0.55,-3,0,18), Position = UDim2.new(0,4,1,-22), BackgroundColor3 = COLOR.White, BorderSizePixel = 0, Text = "🚀 Spawn", TextColor3 = COLOR.Black, Font = Enum.Font.GothamBold, TextSize = 9, AutoButtonColor = false, ZIndex = 123, Parent = card})
        corner(spawnBtn, 5)
        local farmBtn = new("TextButton", {Size = UDim2.new(0.4,-8,0,18), Position = UDim2.new(0.6,4,1,-22), BackgroundColor3 = COLOR.Success, BorderSizePixel = 0, Text = "🌾 Farm", TextColor3 = COLOR.Black, Font = Enum.Font.GothamBold, TextSize = 9, AutoButtonColor = false, ZIndex = 123, Parent = card})
        corner(farmBtn, 5)
        local favBtn = new("TextButton", {Size = UDim2.new(0,22,0,22), Position = UDim2.new(1,-24,0,2), BackgroundColor3 = isFav and Color3.fromRGB(255, 180, 50) or Color3.fromRGB(0,0,0), BackgroundTransparency = isFav and 0 or 0.4, BorderSizePixel = 0, Text = isFav and "⭐" or "☆", TextColor3 = isFav and COLOR.Black or COLOR.White, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false, ZIndex = 124, Parent = card})
        corner(favBtn, 11)

        spawnBtn.MouseButton1Click:Connect(function() spawnBtn.Text = "⏳"; spawnTruckByName(truck.name); task.wait(0.5); spawnBtn.Text = "✅ OK"; task.wait(0.8); spawnBtn.Text = "🚀 Spawn" end)
        farmBtn.MouseButton1Click:Connect(function() userConfig.autoFarmTruck = truck.name; markSaveDirty(); farmToggleActive = true; setSwitchVisual(true); stopFarm(); startFarm(StatusLabel); StatusLabel.Text = "Status: Auto-Farm Full " .. truck.name; StatusLabel.TextColor3 = COLOR.Success end)
        favBtn.MouseButton1Click:Connect(function()
            userConfig.favoriteTrucks = userConfig.favoriteTrucks or {}
            local found = false
            for i, n in ipairs(userConfig.favoriteTrucks) do if n == truck.name then table.remove(userConfig.favoriteTrucks, i); found = true; break end end
            if not found then table.insert(userConfig.favoriteTrucks, truck.name) end
            markSaveDirty(); task.spawn(function() task.wait(0.1); _G.BSTS_RefreshTruckList() end)
        end)

        card.MouseEnter:Connect(function() pcall(function() tween(card, {BackgroundColor3 = COLOR.GreyMed}, 0.15):Play() end) end)
        card.MouseLeave:Connect(function() pcall(function() tween(card, {BackgroundColor3 = COLOR.GreyDark}, 0.15):Play() end) end)
    end

    local function refreshTruckList()
        for _, c in pairs(TruckList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        if #allTrucksCache == 0 then allTrucksCache = loadTruckData() end

        local filtered = {}
        for _, t in ipairs(allTrucksCache) do
            local isTrailer = isTrailerTruck(t.name)
            if currentTab == "Truk" and not isTrailer then table.insert(filtered, t)
            elseif currentTab == "Trailer" and isTrailer then table.insert(filtered, t) end
        end

        table.sort(filtered, function(a, b)
            local af, bf = false, false
            for _, n in ipairs(userConfig.favoriteTrucks or {}) do if n == a.name then af = true end; if n == b.name then bf = true end end
            if af ~= bf then return af end
            return a.price > b.price
        end)

        TruckStatus.Text = string.format("✅ %s: %d truck", currentTab, #filtered)
        for _, t in ipairs(filtered) do pcall(buildTruckCard, t) end
        TruckList.CanvasSize = UDim2.new(0, 0, 0, math.max(math.ceil(#filtered / 3) * 124 + 12, 280))
    end

    _G.BSTS_RefreshTruckList = refreshTruckList

    local tabButtons = {}
    local function makeTabBtn(label, tabName)
        local btn = new("TextButton", {Size = UDim2.new(0, 90, 0, 26), BackgroundColor3 = (currentTab == tabName) and COLOR.White or COLOR.GreyDark, BorderSizePixel = 0, Text = label, TextColor3 = (currentTab == tabName) and COLOR.Black or COLOR.White, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false, ZIndex = 130, Parent = TruckTabBar})
        corner(btn, 8); tabButtons[tabName] = btn
        btn.MouseButton1Click:Connect(function()
            currentTab = tabName; userConfig.lastTruckTab = tabName; markSaveDirty()
            for k, b in pairs(tabButtons) do b.BackgroundColor3 = (k == tabName) and COLOR.White or COLOR.GreyDark; b.TextColor3 = (k == tabName) and COLOR.Black or COLOR.White end
            refreshTruckList()
        end)
    end

    makeTabBtn("🚛 Truk", "Truk")
    makeTabBtn("🚛 Trailer", "Trailer")

    local removeBtn = new("TextButton", {Size = UDim2.new(0, 100, 0, 26), BackgroundColor3 = COLOR.Error, BorderSizePixel = 0, Text = "🗑 Hapus Semua", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 9, AutoButtonColor = false, ZIndex = 130, Parent = TruckTabBar})
    corner(removeBtn, 8)
    removeBtn.MouseButton1Click:Connect(function() removeBtn.Text = "⏳..."; removeAllTrucks(); task.wait(0.6); removeBtn.Text = "✅ Done"; task.wait(0.8); removeBtn.Text = "🗑 Hapus Semua" end)
    task.spawn(function() task.wait(0.5); pcall(refreshTruckList) end)

    new("Frame", {Size = UDim2.new(1,0,0,1), BackgroundColor3 = COLOR.White, BackgroundTransparency = 0.8, BorderSizePixel = 0, LayoutOrder = 7.5, ZIndex = 120, Parent = Content})
    new("TextLabel", {Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = "🎯  DESTINASI POINT", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 7.51, ZIndex = 120, Parent = Content})
    local DestStatusRow = new("Frame", {Size = UDim2.new(1,0,0,42), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.3, BorderSizePixel = 0, LayoutOrder = 7.52, ZIndex = 120, Parent = Content})
    corner(DestStatusRow, 10); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = DestStatusRow})
    local DestStatus = new("TextLabel", {Size = UDim2.new(0.55,0,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = "⏳ Belum scan", TextColor3 = COLOR.TextDim, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 130, Parent = DestStatusRow})
    local ScanDestBtn = new("TextButton", {Size = UDim2.new(0.38,0,1,-10), Position = UDim2.new(0.6,0,0,5), BackgroundColor3 = COLOR.GreyDark, BorderSizePixel = 0, Text = "🔄 Scan Ulang", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 11, ZIndex = 130, Parent = DestStatusRow})
    corner(ScanDestBtn, 8)
    local DestList = new("ScrollingFrame", {Size = UDim2.new(1,0,0,140), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.4, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = COLOR.White, CanvasSize = UDim2.new(0,0,0,0), LayoutOrder = 7.53, ZIndex = 120, Parent = Content})
    corner(DestList, 10)
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = DestList})
    new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = DestList})
    local DestEmptyLabel = new("TextLabel", {Name = "EmptyLabel", Size = UDim2.new(1,-12,0,60), BackgroundTransparency = 1, Text = "Klik 'Scan Ulang' buat cari destinasi.", TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, ZIndex = 121, LayoutOrder = 0, Parent = DestList})

    local function buildDestRow(dest, index)
        local row = new("Frame", {Size = UDim2.new(1,0,0,52), BackgroundColor3 = COLOR.GreyDark, BackgroundTransparency = 0.2, BorderSizePixel = 0, LayoutOrder = index, ZIndex = 121, Parent = DestList})
        corner(row, 8); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = row})
        new("TextLabel", {Size = UDim2.new(1,-16,0,20), Position = UDim2.new(0,8,0,4), BackgroundTransparency = 1, Text = "🎯 " .. dest.name, TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 122, Parent = row})
        new("TextLabel", {Size = UDim2.new(1,-16,0,12), Position = UDim2.new(0,8,0,22), BackgroundTransparency = 1, Text = string.format("X:%d Y:%d Z:%d", math.floor(dest.position.X), math.floor(dest.position.Y), math.floor(dest.position.Z)), TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 122, Parent = row})
        local tpBtn = new("TextButton", {Size = UDim2.new(0.42,-3,0,22), Position = UDim2.new(0,6,0,28), BackgroundColor3 = COLOR.Black, Text = "🚗 TP Truck", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 10, BorderSizePixel = 0, ZIndex = 122, Parent = row})
        corner(tpBtn, 6); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = tpBtn})
        local setAutoBtn = new("TextButton", {Size = UDim2.new(0.52,-12,0,22), Position = UDim2.new(0.42,9,0,28), BackgroundColor3 = COLOR.White, Text = "🌾 Set Auto-Farm", TextColor3 = COLOR.Black, Font = Enum.Font.GothamBold, TextSize = 10, BorderSizePixel = 0, ZIndex = 122, Parent = row})
        corner(setAutoBtn, 6)
        tpBtn.MouseButton1Click:Connect(function() tpBtn.Text = "⏳..."; teleportToDestination(dest.fullName or dest.name); task.wait(0.4); tpBtn.Text = "✅ OK!"; task.wait(0.8); tpBtn.Text = "🚗 TP Truck" end)
        setAutoBtn.MouseButton1Click:Connect(function() userConfig.autoFarmDestination = dest.fullName or dest.name; markSaveDirty(); StatusLabel.Text = "Status: Auto-farm → " .. dest.name; StatusLabel.TextColor3 = COLOR.Success; setAutoBtn.Text = "✅ Tersimpan"; task.wait(1.2); setAutoBtn.Text = "🌾 Set Auto-Farm" end)
    end

    local function refreshDestList()
        for _, c in pairs(DestList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local destinations = scanDestinationPoints()
        if #destinations > 0 then
            local pid = tostring(game.PlaceId)
            local cache = {}
            for _, d in ipairs(destinations) do table.insert(cache, {name = d.name, fullName = d.fullName, x = d.position.X, y = d.position.Y, z = d.position.Z}) end
            userConfig.destinationCache = userConfig.destinationCache or {}; userConfig.destinationCache[pid] = cache; markSaveDirty()
        else destinations = getCachedDestinations() end

        if #destinations == 0 then DestEmptyLabel.Visible = true; DestStatus.Text = "❌ 0 destinasi"; DestStatus.TextColor3 = COLOR.Error
        else DestEmptyLabel.Visible = false; DestStatus.Text = "✅ " .. #destinations .. " destinasi"; DestStatus.TextColor3 = COLOR.Success; for i, d in ipairs(destinations) do pcall(buildDestRow, d, i) end end
        DestList.CanvasSize = UDim2.new(0, 0, 0, #destinations * 58 + 12)
    end
    task.spawn(function() task.wait(1); pcall(refreshDestList) end)
    ScanDestBtn.MouseButton1Click:Connect(function() ScanDestBtn.Text = "⏳ Scan..."; pcall(refreshDestList); ScanDestBtn.Text = "✅ Selesai!"; task.wait(1.2); ScanDestBtn.Text = "🔄 Scan Ulang" end)

    new("Frame", {Size = UDim2.new(1,0,0,1), BackgroundColor3 = COLOR.White, BackgroundTransparency = 0.8, BorderSizePixel = 0, LayoutOrder = 7.9, ZIndex = 120, Parent = Content})
    new("TextLabel", {Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = "🚚  LOADING POINT (FAR-LOAD)", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 7.91, ZIndex = 120, Parent = Content})
    local LoadStatusRow = new("Frame", {Size = UDim2.new(1,0,0,42), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.3, BorderSizePixel = 0, LayoutOrder = 7.92, ZIndex = 120, Parent = Content})
    corner(LoadStatusRow, 10); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = LoadStatusRow})
    local LoadStatus = new("TextLabel", {Size = UDim2.new(0.55,0,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = "⏳ Belum scan", TextColor3 = COLOR.TextDim, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 130, Parent = LoadStatusRow})
    local ScanLoadBtn = new("TextButton", {Size = UDim2.new(0.38,0,1,-10), Position = UDim2.new(0.6,0,0,5), BackgroundColor3 = COLOR.GreyDark, BorderSizePixel = 0, Text = "🔄 Scan Muatan", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 11, ZIndex = 130, Parent = LoadStatusRow})
    corner(ScanLoadBtn, 8)
    local LoadList = new("ScrollingFrame", {Size = UDim2.new(1,0,0,140), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.4, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = COLOR.White, CanvasSize = UDim2.new(0,0,0,0), LayoutOrder = 7.93, ZIndex = 120, Parent = Content})
    corner(LoadList, 10)
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = LoadList})
    new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = LoadList})
    local LoadEmptyLabel = new("TextLabel", {Name = "EmptyLabel", Size = UDim2.new(1,-12,0,60), BackgroundTransparency = 1, Text = "Klik 'Scan Muatan' buat cari loading point.", TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, ZIndex = 121, LayoutOrder = 0, Parent = LoadList})

    local function buildLoadRow(load, index)
        local row = new("Frame", {Size = UDim2.new(1,0,0,54), BackgroundColor3 = COLOR.GreyDark, BackgroundTransparency = 0.2, BorderSizePixel = 0, LayoutOrder = index, ZIndex = 121, Parent = LoadList})
        corner(row, 8); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = row})
        new("TextLabel", {Size = UDim2.new(1,-16,0,20), Position = UDim2.new(0,8,0,4), BackgroundTransparency = 1, Text = "📦 " .. load.name, TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 122, Parent = row})
        new("TextLabel", {Size = UDim2.new(1,-16,0,12), Position = UDim2.new(0,8,0,22), BackgroundTransparency = 1, Text = string.format("X:%d Y:%d Z:%d • Dist ≤ %d", math.floor(load.position.X), math.floor(load.position.Y), math.floor(load.position.Z), load.maxDist), TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 122, Parent = row})
        local farLoadBtn = new("TextButton", {Size = UDim2.new(0.48,-3,0,22), Position = UDim2.new(0,6,0,30), BackgroundColor3 = COLOR.Black, Text = "⚡ Far-Load", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 10, BorderSizePixel = 0, ZIndex = 122, Parent = row})
        corner(farLoadBtn, 6); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = farLoadBtn})
        local farLoadLoopBtn = new("TextButton", {Size = UDim2.new(0.48,-12,0,22), Position = UDim2.new(0.5,9,0,30), BackgroundColor3 = COLOR.White, Text = "🔁 Loop 5x", TextColor3 = COLOR.Black, Font = Enum.Font.GothamBold, TextSize = 10, BorderSizePixel = 0, ZIndex = 122, Parent = row})
        corner(farLoadLoopBtn, 6)
        farLoadBtn.MouseButton1Click:Connect(function() farLoadBtn.Text = "⏳..."; task.spawn(function() farLoadItem(load.name, StatusLabel) end); task.wait(0.3); farLoadBtn.Text = "✅ Done"; task.wait(0.8); farLoadBtn.Text = "⚡ Far-Load" end)
        farLoadLoopBtn.MouseButton1Click:Connect(function()
            farLoadLoopBtn.Text = "🔁 Running..."; farLoadLoopBtn.BackgroundColor3 = COLOR.Error; farLoadLoopBtn.TextColor3 = COLOR.White
            task.spawn(function()
                for i = 1, 5 do
                    if StatusLabel then StatusLabel.Text = "🔁 Loop " .. i .. "/5: " .. load.name; StatusLabel.TextColor3 = COLOR.White end
                    farLoadItem(load.name, StatusLabel); task.wait(0.5)
                end
                farLoadLoopBtn.Text = "✅ Selesai!"; task.wait(1); farLoadLoopBtn.Text = "🔁 Loop 5x"; farLoadLoopBtn.BackgroundColor3 = COLOR.White; farLoadLoopBtn.TextColor3 = COLOR.Black
            end)
        end)
    end

    local function refreshLoadList()
        for _, c in pairs(LoadList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local loads = scanLoadingPoints()
        if #loads == 0 then LoadEmptyLabel.Visible = true; LoadStatus.Text = "❌ 0 loading point"; LoadStatus.TextColor3 = COLOR.Error
        else LoadEmptyLabel.Visible = false; LoadStatus.Text = "✅ " .. #loads .. " loading point"; LoadStatus.TextColor3 = COLOR.Success; for i, l in ipairs(loads) do pcall(buildLoadRow, l, i) end end
        LoadList.CanvasSize = UDim2.new(0, 0, 0, #loads * 60 + 12)
    end
    task.spawn(function() task.wait(2); pcall(refreshLoadList) end)
    ScanLoadBtn.MouseButton1Click:Connect(function() ScanLoadBtn.Text = "⏳ Scan..."; pcall(refreshLoadList); ScanLoadBtn.Text = "✅ Selesai!"; task.wait(1.2); ScanLoadBtn.Text = "🔄 Scan Muatan" end)

    new("Frame", {Size = UDim2.new(1,0,0,1), BackgroundColor3 = COLOR.White, BackgroundTransparency = 0.8, BorderSizePixel = 0, LayoutOrder = 8, ZIndex = 120, Parent = Content})
    new("TextLabel", {Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = "✈️  FLY MODE", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 9, ZIndex = 120, Parent = Content})
    local FlyBtn, FlyLbl = makePremiumBtn(Content, "✈️  Fly: OFF", COLOR.GreyDark, COLOR.Black); FlyBtn.LayoutOrder = 10
    local FlySpeedRow = new("Frame", {Size = UDim2.new(1,0,0,38), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.4, BorderSizePixel = 0, LayoutOrder = 11, ZIndex = 120, Parent = Content})
    corner(FlySpeedRow, 8)
    new("TextLabel", {Size = UDim2.new(0.42,0,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = "✈️ Fly Speed:", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 130, Parent = FlySpeedRow})
    local FlySpeedBox = new("TextBox", {Size = UDim2.new(0.52,0,1,-8), Position = UDim2.new(0.44,0,0,4), BackgroundColor3 = COLOR.Black, PlaceholderText = "Default: 60", Text = tostring(flySpeed), TextColor3 = COLOR.White, PlaceholderColor3 = COLOR.TextDim, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, ZIndex = 130, Parent = FlySpeedRow})
    corner(FlySpeedBox, 6); new("UIStroke", {Thickness = 1, Color = COLOR.White, Transparency = 0.5, Parent = FlySpeedBox})
    local StatusLabel = new("TextLabel", {Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = "Status: Siap digunakan", TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 12, ZIndex = 120, Parent = Content})

    local isAnimating = false
    local function openGUI()
        if MainWrapper.Visible or isAnimating then return end
        isAnimating = true; MainWrapper.Visible = true; MainWrapper.Size = UDim2.new(0,0,0,0); MainFrame.BackgroundTransparency = 1
        pcall(function() tween(MainWrapper, {Size = UDim2.new(0,guiW,0,guiH)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play(); tween(MainFrame, {BackgroundTransparency = 0}, 0.3):Play() end)
        task.wait(0.4); isAnimating = false
    end
    local function closeGUI()
        if not MainWrapper.Visible or isAnimating then return end
        isAnimating = true
        pcall(function() tween(MainWrapper, {Size = UDim2.new(0,0,0,0)}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play(); tween(MainFrame, {BackgroundTransparency = 1}, 0.2):Play() end)
        task.wait(0.3); MainWrapper.Visible = false; MainWrapper.Size = UDim2.new(0,guiW,0,guiH); MainFrame.BackgroundTransparency = 0; isAnimating = false
    end
    local function toggleGUI() if MainWrapper.Visible then closeGUI() else openGUI() end end

    bind(ToggleBtn.MouseButton1Click, function() if hasMoved then return end; toggleGUI() end)
    bind(CloseBtn.MouseButton1Click, closeGUI)
    bind(SaveBtn.MouseButton1Click, function()
        local char = LocalPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        slotCounter = slotCounter + 1; table.insert(savedPositions, {name = "Slot " .. slotCounter, pos = hrp.Position}); markSaveDirty(); refreshPositionList()
        SaveLbl.Text = "✅  Tersimpan (Slot " .. slotCounter .. ")"; StatusLabel.Text = "Status: Disave ke Slot " .. slotCounter
        task.wait(1.2); SaveLbl.Text = "💾  Save Posisi ke Slot Baru"
    end)
    bind(FindBtn.MouseButton1Click, function()
        targetVehicleRoot = findNearestCar()
        if targetVehicleRoot then FindLbl.Text = "✅  " .. targetVehicleRoot.Name; StatusLabel.Text = "Status: Target ditemukan"
        else FindLbl.Text = "❌  Tidak ada target"; StatusLabel.Text = "Status: Tidak ada target" end
        task.wait(1.5); FindLbl.Text = "🔍  Cari Target Terdekat"
    end)
    bind(SwitchBtn.MouseButton1Click, function()
        farmToggleActive = not farmToggleActive; setSwitchVisual(farmToggleActive)
        if farmToggleActive then startFarm(StatusLabel) else stopFarm(); StatusLabel.Text = "Status: Siap digunakan"; StatusLabel.TextColor3 = COLOR.TextDim end
    end)
    bind(FlyBtn.MouseButton1Click, function()
        toggleFly()
        if flyEnabled then FlyLbl.Text = "✈️  Fly: ON"; FlyBtn.BackgroundColor3 = COLOR.White; FlyLbl.TextColor3 = COLOR.Black; StatusLabel.Text = "Status: Fly aktif"
        else FlyLbl.Text = "✈️  Fly: OFF"; FlyBtn.BackgroundColor3 = COLOR.GreyDark; FlyLbl.TextColor3 = COLOR.White; StatusLabel.Text = "Status: Fly nonaktif" end
    end)
    bind(FlySpeedBox.FocusLost, function()
        local v = tonumber(FlySpeedBox.Text)
        if v and v > 0 and v <= 500 then flySpeed = v; markSaveDirty(); StatusLabel.Text = "Status: Fly speed → " .. v
        else FlySpeedBox.Text = tostring(flySpeed); StatusLabel.Text = "⚠️ Fly speed harus 1-500" end
    end)
    bind(UserInputService.InputBegan, function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.T then
            if not targetVehicleRoot then targetVehicleRoot = findNearestCar() end
            if #savedPositions > 0 then teleportCarToPos(savedPositions[#savedPositions].pos) end
        elseif input.KeyCode == Enum.KeyCode.F then
            toggleFly()
            if flyEnabled then FlyLbl.Text = "✈️  Fly: ON"; FlyBtn.BackgroundColor3 = COLOR.White; FlyLbl.TextColor3 = COLOR.Black
            else FlyLbl.Text = "✈️  Fly: OFF"; FlyBtn.BackgroundColor3 = COLOR.GreyDark; FlyLbl.TextColor3 = COLOR.White end
        elseif input.KeyCode == Enum.KeyCode.RightControl then toggleGUI() end
    end)
    print("[BSTS-ID] ✅ v4.3 Mono Glossy Edition siap!")
end

task.spawn(function()
    if not isBSTSGame() then print("[BSTS-ID] Map tidak sesuai: " .. game.Name); return end
    print("[BSTS-ID] Game terdeteksi. Loading v4.3...")
    startCarTool()
end)

print("[BSTS-ID - LuxxyHub] v4.3 Mono Glossy Edition Loaded! ✨")
