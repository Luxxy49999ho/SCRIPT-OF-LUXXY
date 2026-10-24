-- ═══════════════════════════════════════════════════════════════
-- BSTS-ID - LuxxyHub v11.2 (New Pakan Ternak & Locked Methods)
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
    LoadPromptAction = "muat",
    FarLoadOffset = 4,
    TruckSpawnerFolder = "TruckSpawnerRemotes",
    SpawnTruckRemote = "SpawnTruck",
    RemoveTruckRemote = "RemoveTrucks",
    TrailerNames = {
        "semi trailer", "trailer lowboy", "trailer pencocokan",
        "trailer besi tua", "trailer hino",
    },
    Timeout = 10,
    PakanTernakFinishPos = Vector3.new(2461, 382, 595),
    PakanTernakLoadPos = Vector3.new(-535, 97, 342),
}

local FARM_METHODS = {
    ["Pupuk"] = {"Rebeka", "Dyna", "Ragasa", "Besi Tua", "Giga"},
    ["Pakan Ternak"] = {"Besi Tua", "Fuso The", "Hino", "Giga"},
    ["Kayu"] = {"Fuso KA", "Besi Tua", "Giga", "Hino"},
    ["Perkebunan"] = {"Giga", "Besi Tua", "Rebeka"},
    ["Pertambangan"] = {"Rebeka", "Dyna", "Ragasa", "Besi Tua", "Giga"},
    ["Trailer Giga"] = {"Trailer Giga", "Semi Trailer"}
}

local DEFAULT_SLOT19 = Vector3.new(-527, 95, 305)

-- ICON ID BARU DARI USER
local IMG_TOGGLE = "rbxassetid://88353934832481"
local IMG_LOGO = "rbxassetid://88353934832481"
local ICON_HOME = "rbxassetid://125811901483426"
local ICON_CONFIG = "rbxassetid://120579037627073"
local ICON_SETTINGS = "rbxassetid://100972019770419"
local ICON_EXPLOIT = "rbxassetid://125445343355816"

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
    BG = Color3.fromRGB(15, 15, 15),       
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
    if not price then return "0" end
    if price <= 0 then return "0" end
    if price >= 1000000000 then return string.format("%.1f M", price / 1000000000) end
    if price >= 1000000 then return string.format("%d Jt", math.floor(price / 1000000)) end
    if price >= 1000 then return string.format("%d K", math.floor(price / 1000)) end
    return tostring(price)
end

local function getSafeGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok then if hui then return hui end end
    end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 then
        if cg then
            local testOk = pcall(function() local t = Instance.new("Frame"); t.Parent = cg; t:Destroy() end)
            if testOk then return cg end
        end
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

local function applyStaticGradient(parent)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(150, 150, 150)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255)),
    })
    grad.Rotation = 45
    grad.Parent = parent
end

local _animations = {}
task.spawn(function()
    local t = 0
    while true do
        t = t + 0.05
        for i = #_animations, 1, -1 do
            local item = _animations[i]
            if not item.gradient or not item.gradient.Parent then
                table.remove(_animations, i)
            else
                pcall(function()
                    if item.mode == "rotate" then
                        item.gradient.Rotation = (t * 60) % 360
                    end
                end)
            end
        end
        task.wait(0.05)
    end
end)

local function normalizeTruckName(str)
    if not str then return "" end
    str = string.lower(str)
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
        if haystack:find(v, 1, true) then return true end
    end
    return false
end

local defaultConfig = {
    flySpeed = 60, guiX = 0.5, guiY = 0.5, toggleOffsetX = nil, toggleOffsetY = nil,
    savedPositions = {}, slotCounter = 0, destinationCache = {}, autoFarmDestination = nil,
    autoFarmTruck = nil, loadPointCache = {}, favoriteTrucks = {}, disabledFarmTrucks = {}, lastTruckTab = "Truk",
    farmMethod = "Pakan Ternak", farmDelay = 0.12,
}

local function saveConfig(data)
    if not writefile then return end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok then if encoded then pcall(function() writefile(CONFIG.ConfigFile, encoded) end) end end
end

local function loadConfig()
    if not isfile then return defaultConfig end
    if not readfile then return defaultConfig end
    local ok, content = pcall(function() if isfile(CONFIG.ConfigFile) then return readfile(CONFIG.ConfigFile) end end)
    if ok then
        if content then
            if content ~= "" then
                local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
                if ok2 then
                    if type(data) == "table" then
                        for k, v in pairs(defaultConfig) do if data[k] == nil then data[k] = v end end
                        return data
                    end
                end
            end
        end
    end
    return defaultConfig
end

local userConfig = loadConfig()
-- FIX POSISI UI BIAR SELALU DI TENGAH SAAT EXECUTE
userConfig.guiX = 0.5
userConfig.guiY = 0.5
saveConfig(userConfig)

local function isBSTSGame()
    for _, id in ipairs(CONFIG.AllowedPlaceIds) do if game.PlaceId == id then return true end end
    local nameLower = string.lower(game.Name)
    for _, kw in ipairs(CONFIG.AllowedNameKeywords) do if string.find(nameLower, kw, 1, true) then return true end end
    return false
end

local function startCarTool()
    if _G.BSTS_LuxxyHub_Cleanup then pcall(_G.BSTS_LuxxyHub_Cleanup) end
    local activeConnections, activeInstances = {}, {}
    
    _G.BSTS_LuxxyHub_Cleanup = function()
        for _, c in pairs(activeConnections) do pcall(function() c:Disconnect() end) end
        for _, i in pairs(activeInstances) do pcall(function() if i then if i.Parent then i:Destroy() end end end) end
        activeConnections, activeInstances = {}, {}
    end
    
    local function bind(sig, cb) local c = sig:Connect(cb); table.insert(activeConnections, c); return c end
    local function track(i) table.insert(activeInstances, i); return i end

    pcall(function()
        local pg = getSafeGuiParent()
        if pg then local old = pg:FindFirstChild("BSTS_LuxxyHub"); if old then old:Destroy() end end
    end)

    local savedPositions = userConfig.savedPositions or {}
    local slotCounter = userConfig.slotCounter or 0
    local targetVehicleRoot = nil
    local flyEnabled = false
    local noclipEnabled = false
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
        if not x then return false end
        if not y then return false end
        if type(x) ~= "number" then return false end
        if type(y) ~= "number" then return false end
        local vp = getViewport()
        local minVisible = 20
        if x + TOGGLE_SIZE < minVisible then return false end
        if y + TOGGLE_SIZE < minVisible then return false end
        if x > vp.X - minVisible then return false end
        if y > vp.Y - minVisible then return false end
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
        return nearestTarget
    end

    local function getDrivenVehicle()
        local char = LocalPlayer.Character
        if not char then return nil, {} end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil, {} end
        local seat = hum.SeatPart
        if not seat then return nil, {} end
        
        local names = {}
        local cur = seat
        local depth = 0
        while cur and cur ~= game and depth < 15 do
            depth = depth + 1
            pcall(function() if cur.Name and cur.Name ~= "" then table.insert(names, cur.Name) end end)
            cur = cur.Parent
        end
        
        local topModel = seat
        local c2 = seat
        while c2 and c2.Parent and c2.Parent ~= workspace do
            c2 = c2.Parent
            if c2:IsA("Model") then topModel = c2 end
        end
        return topModel, names
    end

    local function isTruckDisabled(name)
        local n = normalizeTruckName(name)
        local dis = userConfig.disabledFarmTrucks or {}
        for _, d in ipairs(dis) do
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

        local allowed = FARM_METHODS[userConfig.farmMethod or "Pakan Ternak"] or {}
        for _, name in ipairs(names) do
            local nameNorm = normalizeTruckName(name)
            for _, kw in ipairs(allowed) do
                if not isTruckDisabled(kw) then
                    if truckNameMatches(nameNorm, kw) then
                        local isTrailerOnly = false
                        if nameNorm:find("trailer", 1, true) then
                            if not nameNorm:find("hino", 1, true) and not nameNorm:find("besi", 1, true) and not nameNorm:find("giga", 1, true) and not nameNorm:find("semi", 1, true) then
                                isTrailerOnly = true
                            end
                        end
                        if not isTrailerOnly then return true, vehicle end
                    end
                end
            end
        end
        return false, vehicle
    end

    local function teleportCarToPos(pos)
        if not pos then return end
        local vehicle = getDrivenVehicle()
        if not vehicle then vehicle = targetVehicleRoot end
        if not vehicle then return end
        if not vehicle:IsA("Model") then return end
        
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        local targetCFrame = CFrame.new(pos + Vector3.new(0, 5, 0)) 
        
        for i = 1, 3 do
            pcall(function() vehicle:PivotTo(targetCFrame) end)
            if hrp then
                if hum and hum.SeatPart then
                    hrp.CFrame = hum.SeatPart.CFrame * CFrame.new(0, 2, 0)
                else
                    hrp.CFrame = targetCFrame * CFrame.new(0, 5, 0)
                end
            end
            task.wait(0.1)
        end
        
        for _, p in pairs(vehicle:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() 
                    if p:CanSetNetworkOwnership() then 
                        p:SetNetworkOwner(LocalPlayer) 
                    end 
                end)
            end
        end
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
        if not folder then folder = workspace:FindFirstChild("DESTINASI POINT") end
        if not folder then folder = workspace:FindFirstChild("DESTINASI") end
        if not folder then return {} end

        local results = {}
        for _, dest in ipairs(folder:GetChildren()) do
            if dest:IsA("Model") then
                local zone = dest:FindFirstChild("Zone", true)
                if not zone then
                    local biggest = nil
                    for _, c in ipairs(dest:GetDescendants()) do
                        if c:IsA("BasePart") and c.Transparency > 0.5 and not c.Name:find("Border") then
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

    local function fireCollect()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        local bestPrompt = nil
        local shortestDist = math.huge
        
        local folder = workspace:FindFirstChild(CONFIG.LoadFolder) or workspace
        local selectedMethod = string.lower(userConfig.farmMethod or "pakan ternak")
        
        for _, o in pairs(folder:GetDescendants()) do
            if o:IsA("ProximityPrompt") and o.Enabled then
                local action = string.lower(o.ActionText or "")
                local objText = string.lower(o.ObjectText or "")
                
                local isMatch = false
                if selectedMethod == "makanan ternak" or selectedMethod == "pakan ternak" then
                    if objText:find("ternak", 1, true) or objText:find("pakan", 1, true) or objText:find("makanan", 1, true) then
                        isMatch = true
                    end
                else
                    if objText:find(selectedMethod, 1, true) then
                        isMatch = true
                    end
                end

                if isMatch and (action:find("muat", 1, true) or action:find("memuat", 1, true)) then
                    local parent = o.Parent
                    local basePart = parent
                    if parent and not parent:IsA("BasePart") then
                        basePart = parent:FindFirstChildWhichIsA("BasePart")
                    end
                    
                    if basePart then
                        local dist = (basePart.Position - hrp.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            bestPrompt = o
                        end
                    end
                end
            end
        end
        
        if bestPrompt then
            print("[BSTS-ID] Auto-load: " .. bestPrompt.ObjectText .. " (Jarak: " .. math.floor(shortestDist) .. ")")
            if fireproximityprompt then
                local success = pcall(function() fireproximityprompt(bestPrompt) end)
                if success then return true end
            end
            pcall(function()
                bestPrompt:InputHoldBegin()
                task.wait((bestPrompt.HoldDuration or 1) + 0.2)
                bestPrompt:InputHoldEnd()
            end)
            return true
        end
        print("[BSTS-ID] Prompt muat untuk " .. userConfig.farmMethod .. " tidak ditemukan.")
        return false
    end

    local allTrucksCache = nil
    local function loadTruckData()
        if allTrucksCache then return allTrucksCache end
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
        allTrucksCache = arr
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
        if ok then print("[BSTS-ID] Spawn: " .. name); return true end
        return false
    end

    local function removeAllTrucks()
        local RS = game:GetService("ReplicatedStorage")
        local folder = RS:FindFirstChild(CONFIG.TruckSpawnerFolder)
        if not folder then return false end
        local remote = folder:FindFirstChild(CONFIG.RemoveTruckRemote)
        if not remote then return false end
        local ok = pcall(function() remote:FireServer() end)
        if ok then print("[BSTS-ID] Semua truck dihapus"); return true end
        return false
    end

    local function autoSpawnAndSit(truckName, statusLbl)
        if not truckName then return false end
        if statusLbl then statusLbl.Text = "[Hapus] Menghapus truck..."; statusLbl.TextColor3 = COLOR.White end
        removeAllTrucks()
        task.wait(1.5)
        if statusLbl then statusLbl.Text = "[Spawn] " .. truckName .. "..."; statusLbl.TextColor3 = COLOR.White end
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
            if statusLbl then statusLbl.Text = "[Duduk] Duduk..."; statusLbl.TextColor3 = COLOR.White end
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
    
    local function toggleNoClip()
        noclipEnabled = not noclipEnabled
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipEnabled
            end
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
                        local allowed = FARM_METHODS[userConfig.farmMethod or "Pakan Ternak"]
                        if allowed and #allowed > 0 then
                            targetTruck = allowed[1]
                        end
                    end
                    
                    if not targetTruck then
                        if statusLbl then statusLbl.Text = "[X] Pilih truck support dulu"; statusLbl.TextColor3 = COLOR.Error end
                        task.wait(3)
                    else
                        if userConfig.farmMethod == "Pakan Ternak" then
                            -- LOGIC BARU PAKAN TERNAK
                            if statusLbl then statusLbl.Text = "[Spawn] " .. targetTruck ...; statusLbl.TextColor3 = COLOR.White end
                            removeAllTrucks()
                            task.wait(1.5)
                            spawnTruckByName(targetTruck)
                            task.wait(2.5)
                            
                            local truck = findNearestCar()
                            if not truck then
                                if statusLbl then statusLbl.Text = "[X] Gagal spawn. Pastikan di jalan."; statusLbl.TextColor3 = COLOR.Error end
                                task.wait(3)
                            else
                                local char = LocalPlayer.Character
                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                local hum = char and char:FindFirstChildOfClass("Humanoid")
                                
                                if hrp and hum then
                                    -- Loop muat 3x pura-pura
                                    for i = 1, 3 do
                                        if not farmEnabled then break end
                                        if statusLbl then statusLbl.Text = "[Load] Muat " .. i .. "/3..." end
                                        
                                        teleportPlayerToPos(CONFIG.PakanTernakLoadPos)
                                        task.wait(0.5)
                                        fireCollect()
                                        task.wait(1.5)
                                        
                                        if truck and truck.Parent then
                                            if statusLbl then statusLbl.Text = "[Tween] Kembali ke Truck..." end
                                            local targetPos = truck:GetPivot().Position + Vector3.new(5, 0, 5)
                                            local tw = TweenService:Create(hrp, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(targetPos)})
                                            tw:Play()
                                            task.wait(1.5)
                                        end
                                    end
                                    
                                    if not farmEnabled then break end
                                    
                                    -- Sit to Driver
                                    if statusLbl then statusLbl.Text = "[Sit] Duduk di Supir..." end
                                    local seat = nil
                                    for _, obj in pairs(truck:GetDescendants()) do
                                        if obj:IsA("VehicleSeat") then seat = obj; break end
                                    end
                                    if seat then
                                        hrp.CFrame = seat.CFrame * CFrame.new(0, 3, 0)
                                        task.wait(0.5)
                                        hum.Sit = true
                                        task.wait(1)
                                    end
                                    
                                    -- TP to Dest
                                    if statusLbl then statusLbl.Text = "[TP] Ke Destinasi..." end
                                    local destPos = CONFIG.PakanTernakFinishPos
                                    teleportCarToPos(destPos)
                                    task.wait(2)
                                    
                                    local RS = game:GetService("ReplicatedStorage")
                                    local fullNotify = RS:FindFirstChild("CargoFullNotify")
                                    local progUpdate = RS:FindFirstChild("CargoProgressUpdate")
                                    if progUpdate then
                                        pcall(function() firesignal(progUpdate.OnClientEvent, "\xF0\x9F\x8C\xBE PAKAN TERNAK", 8, 94, 20000, false, false) end)
                                    end
                                    if fullNotify then
                                        pcall(function() firesignal(fullNotify.OnClientEvent, destPos) end)
                                    end
                                    
                                    if statusLbl then statusLbl.Text = "[6/6] Tunggu bayaran..." end
                                    task.wait(4)
                                end
                            end
                        else
                            -- LOGIC LAMA (PUPUK)
                            local success = autoSpawnAndSit(targetTruck, statusLbl)
                            if not success then
                                if statusLbl then statusLbl.Text = "[X] Gagal spawn. Pastikan di jalan."; statusLbl.TextColor3 = COLOR.Error end
                                task.wait(3)
                            else task.wait(1) end
                        end
                    end
                else
                    -- SUDAH NYUPIR
                    if userConfig.farmMethod == "Pakan Ternak" then
                        if statusLbl then statusLbl.Text = "[TP] Ke Destinasi..." end
                        local destPos = CONFIG.PakanTernakFinishPos
                        teleportCarToPos(destPos)
                        task.wait(2)
                        
                        local RS = game:GetService("ReplicatedStorage")
                        local fullNotify = RS:FindFirstChild("CargoFullNotify")
                        local progUpdate = RS:FindFirstChild("CargoProgressUpdate")
                        if progUpdate then
                            pcall(function() firesignal(progUpdate.OnClientEvent, "\xF0\x9F\x8C\xBE PAKAN TERNAK", 8, 94, 20000, false, false) end)
                        end
                        if fullNotify then
                            pcall(function() firesignal(fullNotify.OnClientEvent, destPos) end)
                        end
                        task.wait(4)
                    else
                        -- LOGIC LAMA (PUPUK)
                        local pos19 = getSlot19Pos()
                        local dynamicDelay = userConfig.farmDelay or 0.12
                        
                        if statusLbl then statusLbl.Text = "[1/3] TP Slot 19..."; statusLbl.TextColor3 = COLOR.White end
                        teleportCarToPos(pos19)
                        task.wait(2.5 + dynamicDelay)
                        
                        if statusLbl then statusLbl.Text = "[2/3] Muat " .. userConfig.farmMethod .. "..." end
                        fireCollect()
                        task.wait(3 + dynamicDelay)
                        
                        if not farmEnabled then break end
                        
                        if statusLbl then statusLbl.Text = "[3/3] TP Destinasi..." end
                        local destPos = Vector3.new(2461, 382, 595)
                        teleportCarToPos(destPos)
                        task.wait(4 + dynamicDelay)
                        
                        if statusLbl then statusLbl.Text = "[Selesai] Tunggu bayaran..." end
                        task.wait(2 + dynamicDelay)
                    end
                end
            end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 🎨 UI BUILDER (v11.2)
    -- ═══════════════════════════════════════════════════════════════
    local cam = workspace.CurrentCamera
    local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
    if vp.X <= 0 or vp.Y <= 0 then vp = Vector2.new(1280, 720) end
    
    local guiW = 550 
    local guiH = math.clamp(400, 300, vp.Y - 60) 

    local ScreenGui = track(new("ScreenGui", {Name = "BSTS_LuxxyHub", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Global, IgnoreGuiInset = true, DisplayOrder = 100, Parent = getSafeGuiParent()}))
    local ToggleWrapper = track(new("Frame", {Name = "ToggleWrapper", AnchorPoint = Vector2.new(0, 0), Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0, startX, 0, startY), BackgroundTransparency = 1, ZIndex = 500, Parent = ScreenGui}))
    
    local ToggleBtn = new("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Active = true, ZIndex = 501, Parent = ToggleWrapper})
    corner(ToggleBtn, 30)
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Thickness = 3
    toggleStroke.Color = Color3.fromRGB(255, 255, 255)
    toggleStroke.Parent = ToggleBtn
    
    local toggleGrad = Instance.new("UIGradient")
    toggleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(80, 80, 80)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255)),
    })
    toggleGrad.Rotation = 45
    toggleGrad.Parent = toggleStroke
    table.insert(_animations, {gradient = toggleGrad, mode = "rotate"})

    new("ImageLabel", {Size = UDim2.new(0.85, 0, 0.85, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = IMG_TOGGLE, ScaleType = Enum.ScaleType.Fit, ZIndex = 502, Parent = ToggleBtn})

    local MainWrapper = track(new("Frame", {
        Name = "MainWrapper", 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        Size = UDim2.new(0, 0, 0, 0), 
        Position = UDim2.new(0.5, 0, 0.5, 0), -- FIX POSISI DI TENGAH
        BackgroundTransparency = 1, 
        Visible = false, 
        ZIndex = 400, 
        Parent = ScreenGui
    }))
    
    local MainFrame = track(new("Frame", {
        Name = "MainFrame", 
        Size = UDim2.new(1, 0, 1, 0), 
        BackgroundColor3 = COLOR.BG, 
        BorderSizePixel = 0, 
        Active = true, 
        ClipsDescendants = true, 
        ZIndex = 401, 
        Parent = MainWrapper
    }))
    corner(MainFrame, 12); createGlossyBorder(MainFrame, 2); applyStaticGradient(MainFrame)

    local isDragging, dragStartPos, dragStartInput, hasMoved = false, nil, nil, false
    local DRAG_THRESHOLD = 10 
    local isOpen = false
    local isAnimatingToggle = false

    bind(ToggleBtn.Activated, function()
        if hasMoved or isAnimatingToggle then return end
        isAnimatingToggle = true
        if isOpen then
            tween(MainWrapper, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
            task.wait(0.3)
            MainWrapper.Visible = false
            isOpen = false
        else
            MainWrapper.Visible = true
            MainWrapper.Size = UDim2.new(0, 0, 0, 0)
            tween(MainWrapper, {Size = UDim2.new(0, guiW, 0, guiH)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
            isOpen = true
        end
        task.wait(0.4)
        isAnimatingToggle = false
    end)

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

    -- Header
    local Header = new("Frame", {Size = UDim2.new(1,0,0,40), BackgroundColor3 = COLOR.Black, BackgroundTransparency = 0.3, BorderSizePixel = 0, Active = true, ZIndex = 410, Parent = MainFrame})
    corner(Header, 12)
    applyStaticGradient(Header)
    
    new("ImageLabel", {Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 10, 0.5, -12), BackgroundTransparency = 1, Image = IMG_LOGO, ImageColor3 = COLOR.White, ScaleType = Enum.ScaleType.Fit, ZIndex = 411, Parent = Header})
    new("TextLabel", {Size = UDim2.new(1,-100,1,-5), Position = UDim2.new(0,40,0,0), BackgroundTransparency = 1, Text = "LUXXY HUB", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 411, Parent = Header})
    new("TextLabel", {Size = UDim2.new(0,100,0,12), Position = UDim2.new(0,40,1,-15), BackgroundTransparency = 1, Text = "BSTS-ID v11.2", TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 411, Parent = Header})
    
    local MinimizeBtn = new("TextButton", {Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-70,0.5,-14), BackgroundColor3 = COLOR.GreyDark, Text = "-", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 18, BorderSizePixel = 0, ZIndex = 411, Active = true, Parent = Header})
    corner(MinimizeBtn, 6)
    local CloseBtn = new("TextButton", {Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-38,0.5,-14), BackgroundColor3 = COLOR.Error, Text = "X", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, ZIndex = 411, Active = true, Parent = Header})
    corner(CloseBtn, 6)

    -- Drag Logic di Header
    local dragging = false
    local dragInput, dragStart, startPos
    local dragThreshold = 10
    
    bind(Header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainWrapper.Position
        end
    end)
    bind(Header.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > dragThreshold then
                MainWrapper.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                userConfig.guiX = MainWrapper.Position.X.Scale; userConfig.guiY = MainWrapper.Position.Y.Scale; markSaveDirty()
            end
        end
    end)
    bind(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Sidebar
    local Sidebar = new("Frame", {Size = UDim2.new(0, 130, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.2, BorderSizePixel = 0, Active = true, ZIndex = 420, Parent = MainFrame})
    local Divider = new("Frame", {Size = UDim2.new(0, 1, 1, -40), Position = UDim2.new(0, 130, 0, 40), BackgroundColor3 = COLOR.White, BackgroundTransparency = 0.8, BorderSizePixel = 0, ZIndex = 421, Parent = MainFrame})

    local Content = new("Frame", {Size = UDim2.new(1, -131, 1, -40), Position = UDim2.new(0, 131, 0, 40), BackgroundTransparency = 1, Active = true, ZIndex = 420, Parent = MainFrame})
    
    local Pages = {}
    local function createPage(name)
        local p = new("ScrollingFrame", {
            Name = name, 
            Size = UDim2.new(1, 0, 1, 0), 
            BackgroundTransparency = 1, 
            BorderSizePixel = 0, 
            ScrollBarThickness = 2, 
            CanvasSize = UDim2.new(0,0,0,0), 
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false, 
            Active = true,
            ZIndex = 430, 
            Parent = Content
        })
        new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = p})
        new("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = p})
        Pages[name] = p
        return p
    end

    local HomePage = createPage("Home")
    local ConfigPage = createPage("Config")
    local SettingsPage = createPage("Settings")
    local ExploitPage = createPage("Exploit")

    local activeTab = nil
    local function switchTab(tabName)
        if activeTab == tabName then return end
        for name, p in pairs(Pages) do p.Visible = false end
        if Pages[tabName] then
            Pages[tabName].Visible = true
            activeTab = tabName
        end
    end

    local function makeNavBtn(text, iconId, order, pageName)
        local btn = new("TextButton", {Size = UDim2.new(1, -10, 0, 36), Position = UDim2.new(0, 5, 0, 10 + ((order-1) * 45)), BackgroundColor3 = COLOR.GreyDark, BackgroundTransparency = 0.9, Text = "", Active = true, ZIndex = 425, Parent = Sidebar})
        corner(btn, 6)
        
        local icon = new("ImageLabel", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 8, 0.5, -10), BackgroundTransparency = 1, Image = iconId, ImageColor3 = COLOR.TextDim, ZIndex = 426, Parent = btn})
        local lbl = new("TextLabel", {Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 34, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = COLOR.TextDim, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 426, Parent = btn})
        
        btn.Activated:Connect(function()
            switchTab(pageName)
            for _, child in pairs(Sidebar:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundTransparency = 0.9
                    for _, c in pairs(child:GetChildren()) do
                        if c:IsA("ImageLabel") then c.ImageColor3 = COLOR.TextDim end
                        if c:IsA("TextLabel") then c.TextColor3 = COLOR.TextDim end
                    end
                end
            end
            btn.BackgroundTransparency = 0.5
            icon.ImageColor3 = COLOR.White
            lbl.TextColor3 = COLOR.White
        end)
        
        if activeTab == nil then
            switchTab(pageName)
            btn.BackgroundTransparency = 0.5
            icon.ImageColor3 = COLOR.White
            lbl.TextColor3 = COLOR.White
        end
        return btn
    end

    makeNavBtn("HOME", ICON_HOME, 1, "Home")
    makeNavBtn("CONFIG", ICON_CONFIG, 2, "Config")
    makeNavBtn("SETTINGS", ICON_SETTINGS, 3, "Settings")
    makeNavBtn("EXPLOITER", ICON_EXPLOIT, 4, "Exploit")

    local function makePremiumBtn(parent, text, c1, c2, h)
        h = h or 35
        local btn = new("TextButton", {Size = UDim2.new(1,0,0,h), BackgroundColor3 = COLOR.GreyDark, Text = "", BorderSizePixel = 0, AutoButtonColor = false, Active = true, ZIndex = 435, Parent = parent})
        corner(btn, 8); createGlossyBorder(btn, 1)
        local lbl = new("TextLabel", {Size = UDim2.new(1,-20,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = text, TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 436, Parent = btn})
        btn.MouseEnter:Connect(function() pcall(function() tween(btn, {BackgroundColor3 = COLOR.GreyMed}, 0.2):Play() end) end)
        btn.MouseLeave:Connect(function() pcall(function() tween(btn, {BackgroundColor3 = COLOR.GreyDark}, 0.2):Play() end) end)
        return btn, lbl
    end

    -- ═══ ACCORDION SYSTEM ═══
    local function createAccordion(parent, title, isOpenDefault)
        local container = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = #parent:GetChildren() + 1, ZIndex = 440, Parent = parent})
        new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = container})

        local header = new("TextButton", {Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = COLOR.GreyDark, BackgroundTransparency = 0.5, Text = "", LayoutOrder = 1, ZIndex = 441, Parent = container})
        corner(header, 6)
        
        local lbl = new("TextLabel", {Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 442, Parent = header})
        
        local chevron = new("TextLabel", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -25, 0.5, -10), BackgroundTransparency = 1, Text = ">", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 14, Rotation = isOpenDefault and 90 or 0, ZIndex = 442, Parent = header})

        local contentWrapper = new("Frame", {Size = UDim2.new(1, 0, 0, isOpenDefault and 100 or 0), AutomaticSize = Enum.AutomaticSize.None, BackgroundTransparency = 1, ClipsDescendants = true, LayoutOrder = 2, ZIndex = 440, Parent = container})
        local content = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, ZIndex = 440, Parent = contentWrapper})
        new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = content})
        new("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = content})
        
        if isOpenDefault then
            task.spawn(function()
                task.wait(0.1)
                contentWrapper.Size = UDim2.new(1, 0, 0, content.AbsoluteSize.Y)
            end)
        end

        local isOpen = isOpenDefault
        header.Activated:Connect(function()
            isOpen = not isOpen
            tween(chevron, {Rotation = isOpen and 90 or 0}, 0.2):Play()
            if isOpen then
                contentWrapper.Visible = true
                contentWrapper.Size = UDim2.new(1, 0, 0, 0)
                local targetY = content.AbsoluteSize.Y
                tween(contentWrapper, {Size = UDim2.new(1, 0, 0, targetY)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
            else
                tween(contentWrapper, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
                task.wait(0.3)
                contentWrapper.Visible = false
            end
        end)
        return content
    end

    -- ═══ ISI TAB HOME (FARMING & SAVE POSITION) ═══
    local FarmContent = createAccordion(HomePage, "Farming", true)
    
    local FarmToggleRow = new("Frame", {Size = UDim2.new(1,0,0,45), BackgroundColor3 = COLOR.GreyDark, BorderSizePixel = 0, Active = true, LayoutOrder = 1, ZIndex = 443, Parent = FarmContent})
    corner(FarmToggleRow, 8)
    
    local FarmLabel = new("TextLabel", {Size = UDim2.new(0.55,0,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, Text = "AUTO FARM: OFF", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 444, Parent = FarmToggleRow})
    
    local SwitchBg = new("Frame", {Size = UDim2.new(0,50,0,24), Position = UDim2.new(1,-62,0.5,-12), BackgroundColor3 = COLOR.Black, BorderSizePixel = 0, ZIndex = 444, Parent = FarmToggleRow})
    corner(SwitchBg, 12)
    local SwitchBtn = new("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Active = true, ZIndex = 445, Parent = SwitchBg})
    local SwitchKnob = new("Frame", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,3,0.5,-9), BackgroundColor3 = COLOR.White, BorderSizePixel = 0, ZIndex = 446, Parent = SwitchBg})
    corner(SwitchKnob, 9)
    
    local StatusLabel = new("TextLabel", {Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, Text = "Status: Siap digunakan", TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, ZIndex = 443, Parent = FarmContent})

    -- DELAY INPUT
    local DelayRow = new("Frame", {Size = UDim2.new(1,0,0,35), BackgroundColor3 = COLOR.BG2, BorderSizePixel = 0, LayoutOrder = 3, ZIndex = 443, Parent = FarmContent})
    corner(DelayRow, 8)
    new("TextLabel", {Size = UDim2.new(0.42,0,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = "Delay (s):", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 444, Parent = DelayRow})
    local DelayBox = new("TextBox", {Size = UDim2.new(0.52,0,1,-8), Position = UDim2.new(0.44,0,0,4), BackgroundColor3 = COLOR.Black, Text = tostring(userConfig.farmDelay), TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, ZIndex = 444, Parent = DelayRow})
    corner(DelayBox, 6)

    -- TRUCK SUPPORT GRID
    local SupportTitle = new("TextLabel", {Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = "TRUCK SUPPORT (Pilih yang aktif)", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 4, ZIndex = 443, Parent = FarmContent})
    
    local SupportGrid = new("ScrollingFrame", {Size = UDim2.new(1,0,0,200), BackgroundColor3 = COLOR.BG2, BackgroundTransparency = 0.5, BorderSizePixel = 0, ScrollBarThickness = 2, LayoutOrder = 5, ZIndex = 443, Parent = FarmContent})
    corner(SupportGrid, 8)
    new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = SupportGrid})
    new("UIGridLayout", {CellSize = UDim2.new(0, 85, 0, 100), CellPadding = UDim.new(0, 6, 0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = SupportGrid})

    local function renderSupportGrid()
        for _, c in pairs(SupportGrid:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        
        local method = userConfig.farmMethod or "Pakan Ternak"
        local allowedNames = FARM_METHODS[method] or {}
        local tData = loadTruckData()

        for _, allowedName in ipairs(allowedNames) do
            local truckInfo = nil
            for _, t in ipairs(tData) do
                if truckNameMatches(t.name, allowedName) then
                    truckInfo = t
                    break
                end
            end
            
            if not truckInfo then
                truckInfo = {name = allowedName, price = 0, photo = nil}
            end

            local isSelected = (userConfig.autoFarmTruck == truckInfo.name) or 
                               (userConfig.autoFarmTruck and truckNameMatches(truckInfo.name, userConfig.autoFarmTruck))
            
            local bgCol = isSelected and COLOR.Success or COLOR.GreyDark

            local card = new("Frame", {Size = UDim2.new(0, 85, 0, 100), BackgroundColor3 = bgCol, ZIndex = 444, Parent = SupportGrid})
            corner(card, 6)
            
            local imgId = IMG_LOGO
            if truckInfo.photo and tostring(truckInfo.photo) ~= "" then
                imgId = "rbxassetid://" .. tostring(truckInfo.photo)
            end
            
            new("ImageLabel", {Size = UDim2.new(1,-4,0,55), Position = UDim2.new(0,2,0,2), BackgroundColor3 = COLOR.Black, Image = imgId, ScaleType = Enum.ScaleType.Fit, ZIndex = 445, Parent = card})
            new("TextLabel", {Size = UDim2.new(1,0,0,15), Position = UDim2.new(0,0,0,60), BackgroundColor3 = COLOR.Black, BackgroundTransparency=0.5, Text = truckInfo.name, TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 9, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 445, Parent = card})
            
            local selectBtn = new("TextButton", {Size = UDim2.new(1,-4,0,18), Position = UDim2.new(0,2,1,-20), BackgroundColor3 = isSelected and COLOR.White or COLOR.GreyMed, Text = isSelected and "AKTIF" or "PILIH", TextColor3 = isSelected and COLOR.Success or COLOR.White, Font = Enum.Font.GothamBold, TextSize = 9, Active = true, ZIndex = 446, Parent = card})
            corner(selectBtn, 4)
            
            selectBtn.Activated:Connect(function()
                userConfig.autoFarmTruck = truckInfo.name
                markSaveDirty()
                renderSupportGrid()
            end)
        end
    end

    -- Logika Switch
    local farmToggleActive = false
    local function setSwitchVisual(on)
        FarmLabel.TextColor3 = COLOR.White
        if on then
            tween(SwitchBg, {BackgroundColor3 = COLOR.White}, 0.2):Play()
            tween(SwitchKnob, {BackgroundColor3 = COLOR.Black, Position = UDim2.new(1,-21,0.5,-9)}, 0.2):Play()
            FarmLabel.Text = "AUTO FARM: ON"
        else
            tween(SwitchBg, {BackgroundColor3 = COLOR.Black}, 0.2):Play()
            tween(SwitchKnob, {BackgroundColor3 = COLOR.White, Position = UDim2.new(0,3,0.5,-9)}, 0.2):Play()
            FarmLabel.Text = "AUTO FARM: OFF"
        end
    end

    -- SAVE POSITION Accordion
    local PosContent = createAccordion(HomePage, "SAVE POSITION", false)
    
    local SaveBtn, SaveLbl = makePremiumBtn(PosContent, "[Save] Posisi ke Slot Baru"); SaveBtn.LayoutOrder = 1
    local FindBtn, FindLbl = makePremiumBtn(PosContent, "[Cari] Target Terdekat"); FindBtn.LayoutOrder = 2
    
    local PositionsList = new("ScrollingFrame", {Size = UDim2.new(1,0,0,220), BackgroundColor3 = COLOR.BG2, BorderSizePixel = 0, ScrollBarThickness = 3, LayoutOrder = 3, Active = true, ZIndex = 443, Parent = PosContent})
    corner(PositionsList, 8)
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6), Parent = PositionsList})
    new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = PositionsList})
    
    local function buildSlotRow(posData, index)
        if type(posData) ~= "table" or typeof(posData.pos) ~= "Vector3" then return end
        local row = new("Frame", {Size = UDim2.new(1,0,0,45), BackgroundColor3 = COLOR.GreyDark, LayoutOrder = index, ZIndex = 444, Parent = PositionsList})
        corner(row, 6)
        new("TextLabel", {Size = UDim2.new(1,-10,0,15), Position = UDim2.new(0,5,0,5), BackgroundTransparency = 1, Text = string.format("%s X:%d Y:%d Z:%d", posData.name or "Slot", math.floor(posData.pos.X), math.floor(posData.pos.Y), math.floor(posData.pos.Z)), TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 445, Parent = row})
        local tpBtn = new("TextButton", {Size = UDim2.new(0.4,-4,0,18), Position = UDim2.new(0,4,0,22), BackgroundColor3 = COLOR.Black, Text = "TP Truck", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 9, Active = true, ZIndex = 445, Parent = row})
        corner(tpBtn, 4)
        local delBtn = new("TextButton", {Size = UDim2.new(0.2,-4,0,18), Position = UDim2.new(0.8,0,0,22), BackgroundColor3 = COLOR.Error, Text = "Hapus", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 9, Active = true, ZIndex = 445, Parent = row})
        corner(delBtn, 4)
        tpBtn.Activated:Connect(function() teleportCarToPos(posData.pos) end)
        delBtn.Activated:Connect(function()
            for i, p in ipairs(savedPositions) do if p == posData then table.remove(savedPositions, i) break end end
            markSaveDirty(); row:Destroy()
        end)
    end

    local function refreshPosList()
        for _, c in pairs(PositionsList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        for i, pd in ipairs(savedPositions) do buildSlotRow(pd, i) end
    end
    task.spawn(refreshPosList)

    -- ═══ ISI TAB CONFIG (FARM SETTINGS) ═══
    local ConfigTitle = new("TextLabel", {Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1, Text = "FARM CONFIG", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, ZIndex = 431, Parent = ConfigPage})
    
    local FarmMethodRow = new("Frame", {Size = UDim2.new(1,0,0,45), BackgroundColor3 = COLOR.GreyDark, BorderSizePixel = 0, LayoutOrder = 2, ZIndex = 431, Parent = ConfigPage})
    corner(FarmMethodRow, 8)
    
    local FarmMethodLabel = new("TextLabel", {Size = UDim2.new(1,-140,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = "Selected Method", TextColor3 = COLOR.White, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 432, Parent = FarmMethodRow})
    
    local FarmMethodBtn = new("TextButton", {Size = UDim2.new(0, 130, 0, 32), Position = UDim2.new(1,-140,0.5,-16), BackgroundColor3 = COLOR.Black, Text = userConfig.farmMethod, TextColor3 = COLOR.Success, Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, Active = true, ZIndex = 432, Parent = FarmMethodRow})
    corner(FarmMethodBtn, 6)

    local DropdownFrame = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = COLOR.BG2, BorderSizePixel = 0, ClipsDescendants = true, Visible = false, LayoutOrder = 3, ZIndex = 432, Parent = ConfigPage})
    corner(DropdownFrame, 8)
    local DropdownLayout = new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = DropdownFrame})
    new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = DropdownFrame})
    
    local isDropdownOpen = false
    FarmMethodBtn.Activated:Connect(function()
        isDropdownOpen = not isDropdownOpen
        if isDropdownOpen then
            DropdownFrame.Visible = true
            DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
            tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 200)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
        else
            tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
            task.wait(0.3)
            DropdownFrame.Visible = false
        end
    end)

    -- LOCKED METHOD SYSTEM
    local methodList = {"Pupuk", "Pakan Ternak", "Kayu", "Perkebunan", "Pertambangan", "Trailer Giga"}
    for _, methodName in ipairs(methodList) do
        local isLocked = (methodName ~= "Pupuk" and methodName ~= "Pakan Ternak")
        local displayName = isLocked and (methodName .. " 🔒") or methodName
        local optBtn = new("TextButton", {
            Size = UDim2.new(1,0,0,28), 
            BackgroundColor3 = isLocked and COLOR.BG2 or COLOR.GreyDark, 
            Text = displayName, 
            TextColor3 = isLocked and COLOR.TextDim or COLOR.White, 
            Font = Enum.Font.GothamBold, 
            TextSize = 11, 
            BorderSizePixel = 0, 
            Active = not isLocked, 
            ZIndex = 433, 
            Parent = DropdownFrame
        })
        corner(optBtn, 6)
        optBtn.Activated:Connect(function()
            if isLocked then return end
            userConfig.farmMethod = methodName
            FarmMethodBtn.Text = methodName 
            userConfig.autoFarmTruck = nil 
            markSaveDirty()
            
            -- UPDATE TRUCK SUPPORT GRID DI HOME
            renderSupportGrid()
            
            isDropdownOpen = false
            tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
            task.wait(0.3)
            DropdownFrame.Visible = false
        end)
    end
    task.spawn(renderSupportGrid)

    -- ═══ ISI TAB SETTINGS (FLY DIHAPUS) ═══
    local SettingsTitle = new("TextLabel", {Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1, Text = "SETTINGS", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, ZIndex = 431, Parent = SettingsPage})
    -- Sengaja dikosongkan karena Fly dipindah ke Exploit

    -- ═══ ISI TAB EXPLOITER ═══
    local ExploitTitle = new("TextLabel", {Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1, Text = "EXPLOITER", TextColor3 = COLOR.White, Font = Enum.Font.GothamBlack, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, ZIndex = 431, Parent = ExploitPage})
    
    local FlyExploitBtn, FlyExploitLbl = makePremiumBtn(ExploitPage, "[Fly] OFF", COLOR.GreyDark, COLOR.Black); FlyExploitBtn.LayoutOrder = 2
    local NoClipBtn, NoClipLbl = makePremiumBtn(ExploitPage, "[No Clip] OFF", COLOR.GreyDark, COLOR.Black); NoClipBtn.LayoutOrder = 3
    local TPPlayerBtn, TPPlayerLbl = makePremiumBtn(ExploitPage, "[TP Player] Ke Kursor", COLOR.GreyDark, COLOR.Black); TPPlayerBtn.LayoutOrder = 4
    
    local ExploitInfo = new("TextLabel", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, Text = "Fitur TP Server butuh RemoteEvent. Script ini hanya bisa TP lokal.", TextColor3 = COLOR.TextDim, Font = Enum.Font.Gotham, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 5, ZIndex = 431, Parent = ExploitPage})

    -- ═══ LOGIKA MINIMIZE & CLOSE ═══
    local isMinimized = false
    local origSize = UDim2.new(0, guiW, 0, guiH)
    local unminimizedPos = UDim2.new(0.5, 0, 0.5, 0)
    
    MinimizeBtn.Activated:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            unminimizedPos = MainWrapper.Position
            MinimizeBtn.Text = "+"
            Sidebar.Visible = false
            Content.Visible = false
            Divider.Visible = false
            
            tween(MainWrapper, {
                Size = UDim2.new(0, guiW, 0, 40),
                Position = UDim2.new(0.5, 0, 0, 50)
            }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
        else
            MinimizeBtn.Text = "-"
            Sidebar.Visible = true
            Content.Visible = true
            Divider.Visible = true
            
            tween(MainWrapper, {
                Size = origSize,
                Position = unminimizedPos
            }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
        end
    end)

    CloseBtn.Activated:Connect(function()
        if _G.BSTS_LuxxyHub_Cleanup then pcall(_G.BSTS_LuxxyHub_Cleanup) end
        ScreenGui:Destroy()
    end)

    -- ═══ FUNGSI TOMBOL LAINNYA ═══
    bind(DelayBox.FocusLost, function()
        local v = tonumber(DelayBox.Text)
        if v and v >= 0 then 
            userConfig.farmDelay = v
            markSaveDirty()
        else 
            DelayBox.Text = tostring(userConfig.farmDelay) 
        end
    end)

    bind(SaveBtn.Activated, function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        slotCounter = slotCounter + 1
        table.insert(savedPositions, {name = "Slot " .. slotCounter, pos = hrp.Position})
        markSaveDirty(); refreshPosList()
        SaveLbl.Text = "Tersimpan (Slot " .. slotCounter .. ")"
        task.wait(1.2); SaveLbl.Text = "[Save] Posisi ke Slot Baru"
    end)
    
    bind(FindBtn.Activated, function()
        targetVehicleRoot = findNearestCar()
        if targetVehicleRoot then FindLbl.Text = targetVehicleRoot.Name; StatusLabel.Text = "Status: Target ditemukan"
        else FindLbl.Text = "Tidak ada target"; StatusLabel.Text = "Status: Tidak ada target" end
        task.wait(1.5); FindLbl.Text = "[Cari] Target Terdekat"
    end)

    bind(SwitchBtn.Activated, function()
        farmToggleActive = not farmToggleActive
        setSwitchVisual(farmToggleActive)
        if farmToggleActive then 
            startFarm(StatusLabel) 
        else 
            stopFarm(); StatusLabel.Text = "Status: Siap digunakan"; StatusLabel.TextColor3 = COLOR.TextDim 
        end
    end)
    
    -- Fly Logic Shared
    local function toggleFlyShared(btn, lbl)
        toggleFly()
        if flyEnabled then 
            lbl.Text = "[Fly] ON"; btn.BackgroundColor3 = COLOR.White; lbl.TextColor3 = COLOR.Black
        else 
            lbl.Text = "[Fly] OFF"; btn.BackgroundColor3 = COLOR.GreyDark; lbl.TextColor3 = COLOR.White
        end
    end

    bind(FlyExploitBtn.Activated, function() toggleFlyShared(FlyExploitBtn, FlyExploitLbl) end)

    bind(NoClipBtn.Activated, function()
        toggleNoClip()
        if noclipEnabled then
            NoClipLbl.Text = "[No Clip] ON"; NoClipBtn.BackgroundColor3 = COLOR.White; NoClipLbl.TextColor3 = COLOR.Black
        else
            NoClipLbl.Text = "[No Clip] OFF"; NoClipBtn.BackgroundColor3 = COLOR.GreyDark; NoClipLbl.TextColor3 = COLOR.White
        end
    end)

    bind(TPPlayerBtn.Activated, function()
        local mouse = LocalPlayer:GetMouse()
        if mouse and mouse.Hit then
            teleportPlayerToPos(mouse.Hit.Position)
            TPPlayerLbl.Text = "✅ Tersimpan"
            task.wait(1.2); TPPlayerLbl.Text = "[TP Player] Ke Kursor"
        end
    end)

    print("[BSTS-ID] v11.2 (New Pakan Ternak & Locked) Loaded!")
end

task.spawn(function()
    if not isBSTSGame() then print("[BSTS-ID] Map tidak sesuai: " .. game.Name); return end
    print("[BSTS-ID] Game terdeteksi. Loading v11.2...")
    startCarTool()
end)

print("[BSTS-ID - LuxxyHub] v11.2 Loaded! ✨")
