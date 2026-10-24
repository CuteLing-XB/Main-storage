-- M.E.G. Endless Reality - translated UI

bit32 = {}
local N = 32
local P = 2 ^ N
bit32.bnot = function(x)
    x = x % P
    return (P - 1) - x
end
bit32.band = function(x, y)
    if y == 255 then
        return x % 256
    end
    if y == 65535 then
        return x % 65536
    end
    if y == 4294967295 then
        return x % 4294967296
    end
    x, y = x % P, y % P
    local r = 0
    local p = 1
    for i = 1, N do
        local a, b = x % 2, y % 2
        x, y = math.floor(x / 2), math.floor(y / 2)
        if (a + b) == 2 then
            r = r + p
        end
        p = 2 * p
    end
    return r
end
bit32.bor = function(x, y)
    if y == 255 then
        return (x - (x % 256)) + 255
    end
    if y == 65535 then
        return (x - (x % 65536)) + 65535
    end
    if y == 4294967295 then
        return 4294967295
    end
    x, y = x % P, y % P
    local r = 0
    local p = 1
    for i = 1, N do
        local a, b = x % 2, y % 2
        x, y = math.floor(x / 2), math.floor(y / 2)
        if (a + b) >= 1 then
            r = r + p
        end
        p = 2 * p
    end
    return r
end
bit32.bxor = function(x, y)
    x, y = x % P, y % P
    local r = 0
    local p = 1
    for i = 1, N do
        local a, b = x % 2, y % 2
        x, y = math.floor(x / 2), math.floor(y / 2)
        if (a + b) == 1 then
            r = r + p
        end
        p = 2 * p
    end
    return r
end
bit32.lshift = function(x, s_amount)
    if math.abs(s_amount) >= N then
        return 0
    end
    x = x % P
    if s_amount < 0 then
        return math.floor(x * (2 ^ s_amount))
    else
        return (x * (2 ^ s_amount)) % P
    end
end
bit32.rshift = function(x, s_amount)
    if math.abs(s_amount) >= N then
        return 0
    end
    x = x % P
    if s_amount > 0 then
        return math.floor(x * (2 ^ -s_amount))
    else
        return (x * (2 ^ -s_amount)) % P
    end
end
bit32.arshift = function(x, s_amount)
    if math.abs(s_amount) >= N then
        return 0
    end
    x = x % P
    if s_amount > 0 then
        local add = 0
        if x >= (P / 2) then
            add = P - (2 ^ (N - s_amount))
        end
        return math.floor(x * (2 ^ -s_amount)) + add
    else
        return (x * (2 ^ -s_amount)) % P
    end
end
if _G.MEG_SESSION then
    _G.MEG_SESSION.Unload()
    task.wait(0.2)
end
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpSvc = game:GetService("HttpService")
local TweenSvc = game:GetService("TweenService")
local LP = Players.LocalPlayer
local ASSETS = {
    ["Arrow"] = "rbxassetid://16368985219",
    ["EKey"] = "rbxassetid://84842143544040",
    ["Player"] = "rbxassetid://117259180607823",
    ["Exit"] = "rbxassetid://11472784835",
    ["Danger"] = "rbxassetid://11877677509",
}
local S = {
    ["Active"] = true,
    ["Conns"] = {},
    ["Items"] = {},
    ["Entities"] = {},
    ["PlayerESP"] = {},
    ["Registered"] = {},
    ["EntDebounce"] = {},
    ["TracerLines"] = {},
    ["ArrowCache"] = {},
    ["ArrowEntries"] = {},
    ["OrigLight"] = nil,
    ["OrigLightSaved"] = false,
    ["CharacterRef"] = nil,
}
_G.MEG_SESSION = S
local function addConn(c)
    table.insert(S.Conns, c)
end
local function updateCharRef()
    S.CharacterRef = LP.Character
end
updateCharRef()
addConn(LP.CharacterAdded:Connect(function(c)
    S.CharacterRef = c
end))
local CFG = {
    ["HighlightRange"] = 150,
    ["EntityEnabled"] = true,
    ["EntityColor"] = Color3.fromRGB(255, 30, 30),
    ["EntityMaxDist"] = 1200,
    ["PlayerESPOn"] = true,
    ["PlayerColor"] = Color3.fromRGB(0, 200, 255),
    ["PlayerFillTransp"] = 0.7,
    ["PlayerOutlineTransp"] = 0,
    ["PlayerOutlineColor"] = Color3.fromRGB(0, 200, 255),
    ["Fullbright"] = false,
    ["SpeedOn"] = false,
    ["WalkSpeed"] = 16,
    ["JumpOn"] = false,
    ["JumpPower"] = 50,
    ["NoclipOn"] = false,
    ["FlyOn"] = false,
    ["FlySpeed"] = 50,
    ["TracersOn"] = false,
    ["TracerColor"] = Color3.fromRGB(0, 255, 128),
    ["TracerThickness"] = 2,
    ["TracerTransp"] = 0,
    ["ArrowsOn"] = true,
    ["ArrowSize"] = 36,
    ["ArrowRadius"] = 160,
    ["ArrowItems"] = true,
    ["ArrowEntities"] = true,
    ["ArrowPlayers"] = false,
    ["ArrowElevator"] = true,
    ["ElevatorESPOn"] = true,
    ["IconColor"] = Color3.fromRGB(255, 255, 255),
    ["BillboardWidth"] = 188,
    ["BillboardHeight"] = 40,
    ["BillboardYOffset"] = 3.5,
    ["BillboardPanelTransp"] = 0.2,
}
local CONFIG_FILE = "MEG_ESP_Config.json"
local function c3t(c)
    return { R = c.R, G = c.G, B = c.B }
end
local function tc3(t)
    return Color3.new(t.R, t.G, t.B)
end
local CATS
local function saveConfig()
    if not writefile then
        return false
    end
    local data = {}
    for k, v in pairs(CFG) do
        if typeof(v) == "Color3" then
            data[k] = { ["_t"] = "C", v = c3t(v) }
        elseif (typeof(v) == "boolean") or (typeof(v) == "number") then
            data[k] = v
        end
    end
    data._CATS = {}
    for ck, cat in pairs(CATS) do
        data._CATS[ck] = {
            ["on"] = cat.on,
            ["fill"] = c3t(cat.fill),
            ["outline"] = c3t(cat.outline),
            ["text"] = c3t(cat.text),
            ["fillT"] = cat.fillT,
            ["outlineT"] = cat.outlineT,
        }
    end
    local ok, json = pcall(HttpSvc.JSONEncode, HttpSvc, data)
    if ok then
        pcall(writefile, CONFIG_FILE, json)
    end
    return true
end
local function loadConfig()
    if not readfile or not isfile then
        return false
    end
    local ok, exists = pcall(isfile, CONFIG_FILE)
    if not ok or not exists then
        return false
    end
    local ok2, raw = pcall(readfile, CONFIG_FILE)
    if not ok2 or not raw then
        return false
    end
    local ok3, data = pcall(HttpSvc.JSONDecode, HttpSvc, raw)
    if not ok3 or not data then
        return false
    end
    for k, v in pairs(data) do
        if k == "_CATS" then
            for ck, cd in pairs(v) do
                if CATS[ck] then
                    CATS[ck].on = cd.on
                    CATS[ck].fill = tc3(cd.fill)
                    CATS[ck].outline = tc3(cd.outline)
                    CATS[ck].text = tc3(cd.text)
                    CATS[ck].fillT = cd.fillT
                    CATS[ck].outlineT = cd.outlineT
                end
            end
        elseif (type(v) == "table") and (v._t == "C") then
            CFG[k] = tc3(v.v)
        elseif CFG[k] ~= nil then
            CFG[k] = v
        end
    end
    return true
end
CATS = {
    ["QuestItem"] = {
        ["on"] = true,
        ["label"] = "任务物品",
        ["icon"] = ASSETS.EKey,
        ["fill"] = Color3.fromRGB(0, 255, 128),
        ["outline"] = Color3.fromRGB(0, 255, 0),
        ["text"] = Color3.fromRGB(0, 255, 128),
        ["fillT"] = 0.5,
        ["outlineT"] = 0,
    },
    ["Generator"] = {
        ["on"] = true,
        ["label"] = "发电机",
        ["icon"] = ASSETS.EKey,
        ["fill"] = Color3.fromRGB(255, 200, 0),
        ["outline"] = Color3.fromRGB(255, 160, 0),
        ["text"] = Color3.fromRGB(255, 200, 0),
        ["fillT"] = 0.5,
        ["outlineT"] = 0,
    },
    ["Door"] = {
        ["on"] = true,
        ["label"] = "门",
        ["icon"] = ASSETS.EKey,
        ["fill"] = Color3.fromRGB(100, 150, 255),
        ["outline"] = Color3.fromRGB(50, 100, 255),
        ["text"] = Color3.fromRGB(100, 180, 255),
        ["fillT"] = 0.5,
        ["outlineT"] = 0,
    },
    ["Vent"] = {
        ["on"] = true,
        ["label"] = "通风口",
        ["icon"] = ASSETS.EKey,
        ["fill"] = Color3.fromRGB(160, 160, 160),
        ["outline"] = Color3.fromRGB(210, 210, 210),
        ["text"] = Color3.fromRGB(210, 210, 210),
        ["fillT"] = 0.5,
        ["outlineT"] = 0,
    },
    ["Vending"] = {
        ["on"] = true,
        ["label"] = "自动售货机",
        ["icon"] = ASSETS.EKey,
        ["fill"] = Color3.fromRGB(255, 100, 200),
        ["outline"] = Color3.fromRGB(255, 50, 180),
        ["text"] = Color3.fromRGB(255, 130, 220),
        ["fillT"] = 0.5,
        ["outlineT"] = 0,
    },
    ["Hub"] = {
        ["on"] = false,
        ["label"] = "中枢站点",
        ["icon"] = ASSETS.EKey,
        ["fill"] = Color3.fromRGB(120, 180, 255),
        ["outline"] = Color3.fromRGB(80, 140, 255),
        ["text"] = Color3.fromRGB(160, 200, 255),
        ["fillT"] = 0.6,
        ["outlineT"] = 0,
    },
    ["Elevator"] = {
        ["on"] = true,
        ["label"] = "Elevator",
        ["icon"] = ASSETS.Exit,
        ["fill"] = Color3.fromRGB(0, 255, 255),
        ["outline"] = Color3.fromRGB(0, 200, 200),
        ["text"] = Color3.fromRGB(0, 255, 255),
        ["fillT"] = 0.6,
        ["outlineT"] = 0,
    },
}
local CAT_ORDER = { "QuestItem", "Generator", "Door", "Vent", "Vending", "Hub", "Elevator" }
local CAT_NAMES = {
    ["QuestItem"] = "任务物品",
    ["Generator"] = "发电机",
    ["Door"] = "可交互门",
    ["Vent"] = "通风口",
    ["Vending"] = "自动售货机",
    ["Hub"] = "中枢设施",
    ["Elevator"] = "电梯",
}
loadConfig()
local QUEST_NAMES = {
    ["Item"] = 1,
    ["Item2"] = 1,
    ["ItemF"] = 1,
    ["ItemL"] = 1,
    ["ItemW"] = 1,
    ["ItemE"] = 1,
    ["ItemA"] = 1,
    ["Piece"] = 1,
    ["BoxPart"] = 1,
    ["Ragdoll"] = 1,
}
local VEND_NAMES = { ["AlmondVendingMachine"] = 1, ["LiquidPainVendingMachine"] = 1 }
local HUB_NAMES = { ["MainComputer"] = 1, ["ShopPanel"] = 1, ["Phone"] = 1, ["EntityComputer"] = 1, ["Radio"] = 1 }
local DOOR_ACTS = { ["Open"] = 1, ["Close"] = 1, ["Unlock"] = 1, ["Lock"] = 1 }
local DOOR_BOXES =
    { ["Door"] = 1, ["FakeDoor"] = 1, ["LockedDoubleDoors"] = 1, ["DoorLeft"] = 1, ["DoorRight"] = 1, ["DoorModel"] = 1 }
local STRUCT = { ["Rooms"] = 1, ["Elevators"] = 1, ["DeadEnds"] = 1, ["Workspace"] = 1 }
local DOOR_MAX = 60
local ENT_NAMES = {
    ["Smiler"] = "微笑者",
    ["DeathRat"] = "死亡鼠",
    ["Hound"] = "猎犬",
    ["Partygoer"] = "派对客",
    ["Howler"] = "嚎叫者",
    ["Wretch"] = "恶鬼",
    ["Skin"] = "窃皮者",
    ["Entity"] = "未知实体",
    ["Blanche"] = "布兰奇",
    ["Burster"] = "爆裂者",
    ["Clump"] = "纠缠者",
    ["Scarecrow"] = "稻草人",
    ["Dread"] = "恐惧者",
    ["Shadow"] = "影子",
    ["Crawler"] = "爬行者",
    ["Stalker"] = "潜行者",
}
local NPC_WHITELIST = { ["Rig"] = 1, ["Ragdoll"] = 1, ["Not_Wretch"] = 1, ["ItemL"] = 1 }
local REJECT_CLASS = {}
for _, cn in ipairs({
    "SpotLight",
    "PointLight",
    "SurfaceLight",
    "Sound",
    "ParticleEmitter",
    "Fire",
    "Smoke",
    "Trail",
    "Beam",
    "Animation",
    "Animator",
    "AnimationController",
    "Decal",
    "Texture",
    "SurfaceGui",
    "BillboardGui",
    "Weld",
    "WeldConstraint",
    "Motor6D",
    "BodyVelocity",
    "BodyGyro",
    "BodyForce",
    "BodyPosition",
    "Script",
    "LocalScript",
    "ModuleScript",
    "RemoteEvent",
    "RemoteFunction",
    "BindableEvent",
    "BindableFunction",
    "IntValue",
    "StringValue",
    "BoolValue",
    "NumberValue",
    "ObjectValue",
    "Color3Value",
    "CFrameValue",
    "Vector3Value",
    "Attachment",
    "Accessory",
    "Shirt",
    "Pants",
    "BodyColors",
    "CharacterMesh",
    "Hat",
    "Tool",
    "HumanoidDescription",
    "UICorner",
    "UIStroke",
    "UIListLayout",
    "UIGridLayout",
    "UIPadding",
    "UIScale",
    "UIAspectRatioConstraint",
    "UISizeConstraint",
    "UITextSizeConstraint",
    "TextLabel",
    "TextButton",
    "TextBox",
    "ImageLabel",
    "ImageButton",
    "Frame",
    "ScrollingFrame",
    "ScreenGui",
    "ViewportFrame",
    "CanvasGroup",
    "Highlight",
}) do
    REJECT_CLASS[cn] = true
end
local function shallowPart(inst, depth)
    if inst:IsA("BasePart") then
        return inst
    end
    depth = depth or 4
    local function dig(o, d)
        if d > depth then
            return nil
        end
        for _, c in ipairs(o:GetChildren()) do
            if c:IsA("BasePart") then
                return c
            end
            local r = dig(c, d + 1)
            if r then
                return r
            end
        end
    end
    return dig(inst, 1)
end
local function myHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildWhichIsA("Humanoid")
end
local function isCharDescendant(inst)
    local cr = S.CharacterRef
    return cr and inst:IsDescendantOf(cr)
end
-- Welcome/social-link popup removed intentionally.
local arrowGui, arrowFrame, arrowTemplate = nil, nil, nil
local function ensureArrowGui()
    if arrowGui and arrowGui.Parent then
        return
    end
    arrowGui = Instance.new("ScreenGui")
    arrowGui.Name = "MEG_Arrows"
    arrowGui.ResetOnSpawn = false
    arrowGui.DisplayOrder = 999991
    arrowGui.IgnoreGuiInset = true
    arrowGui.Parent = CoreGui
    arrowFrame = Instance.new("Frame", arrowGui)
    arrowFrame.Size = UDim2.new(1, 0, 1, 0)
    arrowFrame.BackgroundTransparency = 1
    arrowFrame.BorderSizePixel = 0
    arrowTemplate = Instance.new("ImageLabel")
    arrowTemplate.Size = UDim2.new(0, 36, 0, 36)
    arrowTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
    arrowTemplate.BackgroundTransparency = 1
    arrowTemplate.Image = ASSETS.Arrow
    arrowTemplate.ScaleType = Enum.ScaleType.Fit
    arrowTemplate.Visible = false
end
local function registerArrow(k, gp, gc, ge)
    S.ArrowEntries[k] = { ["getPos"] = gp, ["getColor"] = gc, ["getEnabled"] = ge }
end
local function unregisterArrow(k)
    S.ArrowEntries[k] = nil
    local c = S.ArrowCache[k]
    if c and c.Parent then
        c.Visible = false
    end
end
local function clearAllArrows()
    for _, a in pairs(S.ArrowCache) do
        if a and a.Parent then
            a:Destroy()
        end
    end
    S.ArrowCache = {}
    S.ArrowEntries = {}
end
local function startArrowLoop()
    addConn(RS.RenderStepped:Connect(function()
        if not S.Active then
            return
        end
        local cam = WS.CurrentCamera
        if not cam then
            return
        end
        ensureArrowGui()
        if not CFG.ArrowsOn then
            for _, a in pairs(S.ArrowCache) do
                if a and a.Parent then
                    a.Visible = false
                end
            end
            return
        end
        local ss = cam.ViewportSize
        local sc = Vector2.new(ss.X * 0.5, ss.Y * 0.5)
        local cL = cam.CFrame.LookVector
        local cP = cam.CFrame.Position
        local aSz = CFG.ArrowSize
        local rad = (math.min(ss.X, ss.Y) * 0.5) - CFG.ArrowRadius
        for key, e in pairs(S.ArrowEntries) do
            if not e.getEnabled() then
                local c = S.ArrowCache[key]
                if c and c.Parent then
                    c.Visible = false
                end
                continue
            end
            local pos = e.getPos()
            if not pos then
                local c = S.ArrowCache[key]
                if c and c.Parent then
                    c.Visible = false
                end
                continue
            end
            local sp, onS = cam:WorldToViewportPoint(pos)
            if onS and (sp.Z > 0) then
                local c = S.ArrowCache[key]
                if c and c.Parent then
                    c.Visible = false
                end
                continue
            end
            local ar = S.ArrowCache[key]
            if not ar or not ar.Parent then
                ar = arrowTemplate:Clone()
                ar.Parent = arrowFrame
                S.ArrowCache[key] = ar
            end
            local dir = Vector2.new(sp.X - sc.X, sp.Y - sc.Y)
            if cL:Dot((pos - cP).Unit) < 0 then
                dir = -dir
            end
            local ud = ((dir.Magnitude > 0) and dir.Unit) or Vector2.new(1, 0)
            local ap = sc + (ud * rad)
            ar.Position = UDim2.new(0, ap.X, 0, ap.Y)
            ar.Rotation = math.deg(math.atan2(ud.Y, ud.X)) - 90
            ar.Size = UDim2.new(0, aSz, 0, aSz)
            ar.ImageColor3 = e.getColor()
            ar.Visible = true
        end
    end))
end
local tracerGui = nil
local function ensureTracerGui()
    if tracerGui and tracerGui.Parent then
        return
    end
    tracerGui = Instance.new("ScreenGui")
    tracerGui.Name = "MEG_Tracers"
    tracerGui.ResetOnSpawn = false
    tracerGui.DisplayOrder = 999990
    tracerGui.IgnoreGuiInset = true
    tracerGui.Parent = CoreGui
end
local function drawTracer(key, wp, color)
    if not CFG.TracersOn then
        local l = S.TracerLines[key]
        if l and l.Parent then
            l.Visible = false
        end
        return
    end
    local cam = WS.CurrentCamera
    if not cam then
        return
    end
    local sp, vis = cam:WorldToViewportPoint(wp)
    if not vis or (sp.Z <= 0) then
        local l = S.TracerLines[key]
        if l and l.Parent then
            l.Visible = false
        end
        return
    end
    ensureTracerGui()
    local line = S.TracerLines[key]
    if not line or not line.Parent then
        line = Instance.new("Frame")
        line.BorderSizePixel = 0
        line.AnchorPoint = Vector2.new(0.5, 0)
        line.Parent = tracerGui
        S.TracerLines[key] = line
    end
    local vp = cam.ViewportSize
    local sx = vp.X * 0.5
    local sy = vp.Y
    local dx = sp.X - sx
    local dy = sp.Y - sy
    local dist = math.sqrt((dx * dx) + (dy * dy))
    line.BackgroundColor3 = color or CFG.TracerColor
    line.BackgroundTransparency = CFG.TracerTransp
    line.Size = UDim2.new(0, dist, 0, CFG.TracerThickness)
    line.Position = UDim2.new(0, sx, 0, sy)
    line.Rotation = math.deg(math.atan2(dy, dx))
    line.Visible = true
end
local function hideTracer(k)
    local l = S.TracerLines[k]
    if l and l.Parent then
        l.Visible = false
    end
end
local function clearAllTracers()
    for _, l in pairs(S.TracerLines) do
        if l and l.Parent then
            l:Destroy()
        end
    end
    S.TracerLines = {}
end
local allBillboards = {}
local function createStyledBillboard(parent, adornee, icon, labelText, catColor, studsOff)
    local w, h = CFG.BillboardWidth, CFG.BillboardHeight
    local bg = Instance.new("BillboardGui")
    bg.Name = "_IG"
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, w, 0, h)
    bg.StudsOffset = studsOff or Vector3.new(0, CFG.BillboardYOffset, 0)
    bg.MaxDistance = math.huge
    bg.Adornee = adornee
    bg.Parent = parent
    local panel = Instance.new("Frame", bg)
    panel.Name = "Panel"
    panel.Size = UDim2.new(1, 0, 1, 0)
    panel.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    panel.BackgroundTransparency = CFG.BillboardPanelTransp
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke", panel)
    stroke.Color = catColor
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    local iconImg = Instance.new("ImageLabel", panel)
    iconImg.Name = "Icon"
    iconImg.Size = UDim2.new(0, 22, 0, 22)
    iconImg.Position = UDim2.new(0, 6, 0.5, -11)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = icon or ASSETS.EKey
    iconImg.ImageColor3 = CFG.IconColor
    iconImg.ScaleType = Enum.ScaleType.Fit
    local nameLabel = Instance.new("TextLabel", panel)
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -36, 0, 19)
    nameLabel.Position = UDim2.new(0, 32, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = catColor
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Text = labelText or ""
    local distLabel = Instance.new("TextLabel", panel)
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, -36, 0, 15)
    distLabel.Position = UDim2.new(0, 32, 0, 21)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    distLabel.TextSize = 11
    distLabel.Font = Enum.Font.SourceSans
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.Text = "-- Studs"
    table.insert(allBillboards, { ["bg"] = bg, ["panel"] = panel, ["isDefault"] = (studsOff == nil) })
    return bg, nameLabel, distLabel, iconImg, stroke
end
local function refreshAllBillboards()
    local w, h = CFG.BillboardWidth, CFG.BillboardHeight
    for i = #allBillboards, 1, -1 do
        local e = allBillboards[i]
        if not e.bg or not e.bg.Parent then
            table.remove(allBillboards, i)
        else
            e.bg.Size = UDim2.new(0, w, 0, h)
            if e.isDefault then
                e.bg.StudsOffset = Vector3.new(0, CFG.BillboardYOffset, 0)
            end
            e.panel.BackgroundTransparency = CFG.BillboardPanelTransp
        end
    end
end
local function isPromptActive(p)
    return p.Enabled and (p.MaxActivationDistance > 0)
end
local function resolveDoor(prompt)
    if not isPromptActive(prompt) then
        return nil
    end
    local cur, steps = prompt.Parent, 0
    while cur and (steps < 4) do
        local pn = (cur.Parent and cur.Parent.Name) or ""
        if STRUCT[pn] or STRUCT[cur.Name] or (cur.Parent == WS) then
            return nil
        end
        if DOOR_BOXES[cur.Name] then
            local a = shallowPart(cur)
            return (a and (a.Size.Magnitude <= DOOR_MAX) and cur) or nil
        end
        local a = shallowPart(cur)
        if a and (a.Size.Magnitude > DOOR_MAX) then
            return nil
        end
        cur = cur.Parent
        steps = steps + 1
    end
    if cur and (cur.Parent ~= WS) then
        local a = shallowPart(cur)
        if a and (a.Size.Magnitude <= DOOR_MAX) then
            return cur
        end
    end
end
local function buildLabelText(item, fb)
    local p = item:FindFirstChildWhichIsA("ProximityPrompt", true)
    if p then
        local o = ((p.ObjectText ~= "") and p.ObjectText) or nil
        local a = ((p.ActionText ~= "") and p.ActionText) or nil
        if o and a then
            return o .. " - " .. a
        end
        if o then
            return o
        end
        if a then
            return a
        end
    end
    return fb
end
local function classify(inst)
    if REJECT_CLASS[inst.ClassName] then
        return nil, nil
    end
    if
        not (
            inst:IsA("Model")
            or inst:IsA("BasePart")
            or inst:IsA("MeshPart")
            or inst:IsA("ProximityPrompt")
            or inst:IsA("Folder")
            or inst:IsA("Actor")
        )
    then
        return nil, nil
    end
    local n = inst.Name
    if VEND_NAMES[n] then
        return "Vending", inst
    end
    if HUB_NAMES[n] then
        return "Hub", inst
    end
    if n == "OpenableVent" then
        return "Vent", inst
    end
    if (n == "PowerBox") and inst:FindFirstChildWhichIsA("ProximityPrompt", true) then
        return "Generator", inst
    end
    if (QUEST_NAMES[n] or NPC_WHITELIST[n]) and inst:FindFirstChildWhichIsA("ProximityPrompt", true) then
        return "QuestItem", inst
    end
    if inst:IsA("ProximityPrompt") then
        local act = inst.ActionText or ""
        if DOOR_ACTS[act] then
            local t = resolveDoor(inst)
            if t then
                return "Door", t
            end
        end
        local par = inst.Parent
        if par then
            if QUEST_NAMES[par.Name] or NPC_WHITELIST[par.Name] then
                return "QuestItem", par
            end
            if par.Name == "PowerBox" then
                return "Generator", par
            end
        end
    end
    return nil, nil
end
local function mountItemESP(item, catKey)
    if not S.Active or S.Items[item] then
        return
    end
    if item:FindFirstChild("_IH") then
        return
    end
    local cat = CATS[catKey]
    if not cat or not cat.on then
        return
    end
    local anchor = shallowPart(item)
    if not anchor then
        task.wait(0.5)
        anchor = shallowPart(item)
    end
    if not anchor then
        return
    end
    if (catKey == "Door") and (anchor.Size.Magnitude > DOOR_MAX) then
        return
    end
    if catKey == "Door" then
        local ok = false
        for _, d in ipairs(item:GetDescendants()) do
            if d:IsA("ProximityPrompt") and DOOR_ACTS[d.ActionText or ""] and isPromptActive(d) then
                ok = true
                break
            end
        end
        if not ok then
            return
        end
    end
    local lbl = buildLabelText(item, cat.label)
    local hl = Instance.new("Highlight")
    hl.Name = "_IH"
    hl.FillColor = cat.fill
    hl.FillTransparency = cat.fillT
    hl.OutlineColor = cat.outline
    hl.OutlineTransparency = cat.outlineT
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = item
    local bg, nL, dL, iI, st = createStyledBillboard(item, anchor, cat.icon, lbl, cat.text)
    local ref = item
    S.Items[item] = {
        ["hl"] = hl,
        ["bg"] = bg,
        ["nameL"] = nL,
        ["distL"] = dL,
        ["iconImg"] = iI,
        ["stroke"] = st,
        ["cat"] = catKey,
        ["lbl"] = lbl,
        ["anchor"] = anchor,
    }
    local ak = "i" .. tostring(item)
    registerArrow(ak, function()
        local d = S.Items[ref]
        return d and d.anchor and d.anchor.Parent and d.anchor.Position
    end, function()
        return CATS[(S.Items[ref] and S.Items[ref].cat) or catKey].text
    end, function()
        return CFG.ArrowItems and CATS[(S.Items[ref] and S.Items[ref].cat) or catKey].on
    end)
    item.Destroying:Connect(function()
        pcall(hl.Destroy, hl)
        pcall(bg.Destroy, bg)
        S.Items[item] = nil
        S.Registered[item] = nil
        hideTracer(ak)
        unregisterArrow(ak)
    end)
end
local elevatorESPData = {}
local function mountElevatorESP()
    for _, d in pairs(elevatorESPData) do
        pcall(d.hl.Destroy, d.hl)
        pcall(d.bg.Destroy, d.bg)
        unregisterArrow("elev_" .. tostring(d.model))
    end
    elevatorESPData = {}
    if not CFG.ElevatorESPOn then
        return
    end
    local cat = CATS.Elevator
    if not cat.on then
        return
    end
    local ef = WS:FindFirstChild("Elevators")
    if not ef then
        return
    end
    for _, child in ipairs(ef:GetChildren()) do
        if child:IsA("Model") then
            local anchor = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
            if anchor then
                local hl = Instance.new("Highlight")
                hl.Name = "_ELEV_H"
                hl.FillColor = cat.fill
                hl.FillTransparency = cat.fillT
                hl.OutlineColor = cat.outline
                hl.OutlineTransparency = cat.outlineT
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = child
                local bg, nL, dL, iI, st =
                    createStyledBillboard(child, anchor, ASSETS.Exit, "Elevator", cat.text, Vector3.new(0, 6, 0))
                table.insert(
                    elevatorESPData,
                    {
                        ["hl"] = hl,
                        ["bg"] = bg,
                        ["nameL"] = nL,
                        ["distL"] = dL,
                        ["iconImg"] = iI,
                        ["stroke"] = st,
                        ["anchor"] = anchor,
                        ["model"] = child,
                    }
                )
                local ak = "elev_" .. tostring(child)
                local aR = anchor
                registerArrow(ak, function()
                    return aR and aR.Parent and aR.Position
                end, function()
                    return CATS.Elevator.text
                end, function()
                    return CFG.ArrowElevator and CATS.Elevator.on and CFG.ElevatorESPOn
                end)
            end
        end
    end
end
local itemFrame, IT = 0, 5
local function startItemLoop()
    addConn(RS.Heartbeat:Connect(function()
        local hrp = myHRP()
        local mp = hrp and hrp.Position
        itemFrame = itemFrame + 1
        local dt = (itemFrame % IT) == 0
        for item, d in pairs(S.Items) do
            if not item.Parent then
                pcall(d.hl.Destroy, d.hl)
                pcall(d.bg.Destroy, d.bg)
                S.Items[item] = nil
                S.Registered[item] = nil
                hideTracer("i" .. tostring(item))
                unregisterArrow("i" .. tostring(item))
                continue
            end
            local cat = CATS[d.cat]
            if d.hl.Parent then
                d.hl.FillColor = cat.fill
                d.hl.FillTransparency = cat.fillT
                d.hl.OutlineColor = cat.outline
                d.hl.OutlineTransparency = cat.outlineT
            end
            d.nameL.TextColor3 = cat.text
            d.stroke.Color = cat.text
            d.iconImg.ImageColor3 = CFG.IconColor
            if not cat.on then
                d.hl.Enabled = false
                d.bg.Enabled = false
                hideTracer("i" .. tostring(item))
                continue
            end
            d.bg.Enabled = true
            if mp and d.anchor and d.anchor.Parent then
                local ap = d.anchor.Position
                local dist = (mp - ap).Magnitude
                d.hl.Enabled = dist <= CFG.HighlightRange
                if dt then
                    d.distL.Text = math.floor(dist) .. " 距离单位"
                end
                drawTracer("i" .. tostring(item), ap, cat.text)
            end
        end
        local ec = CATS.Elevator
        for _, ed in ipairs(elevatorESPData) do
            if ed.anchor and ed.anchor.Parent then
                ed.hl.FillColor = ec.fill
                ed.hl.OutlineColor = ec.outline
                ed.nameL.TextColor3 = ec.text
                ed.stroke.Color = ec.text
                ed.iconImg.ImageColor3 = CFG.IconColor
                local show = ec.on and CFG.ElevatorESPOn
                ed.hl.Enabled = show
                ed.bg.Enabled = show
                if dt and show and mp then
                    ed.distL.Text = math.floor((mp - ed.anchor.Position).Magnitude) .. " 距离单位"
                    drawTracer("e" .. tostring(ed.model), ed.anchor.Position, ec.text)
                end
            end
        end
        if not CFG.TracersOn then
            for _, l in pairs(S.TracerLines) do
                if l.Parent then
                    l.Visible = false
                end
            end
        end
    end))
end
local function tryRegItem(inst)
    local ck, tgt = classify(inst)
    if ck and tgt and not S.Registered[tgt] then
        S.Registered[tgt] = true
        mountItemESP(tgt, ck)
    end
end
local function scanItems()
    for _, d in ipairs(WS:GetDescendants()) do
        tryRegItem(d)
    end
    mountElevatorESP()
end
local function isMonster(obj)
    if not (obj:IsA("Model") or obj:IsA("Actor")) then
        return false, nil
    end
    if (obj == LP.Character) or Players:GetPlayerFromCharacter(obj) then
        return false, nil
    end
    if NPC_WHITELIST[obj.Name] then
        return false, nil
    end
    local par = obj.Parent
    if par and (QUEST_NAMES[par.Name] or NPC_WHITELIST[par.Name]) then
        return false, nil
    end
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    if obj:FindFirstChildWhichIsA("Humanoid") and root then
        return true, root
    end
    local anim = obj:FindFirstChildWhichIsA("Animator", true) or obj:FindFirstChildWhichIsA("AnimationController", true)
    if anim and root then
        local p = obj:GetFullName()
        if not p:find("MegBase") and not p:find("Elevators") and not p:find("Rooms") then
            return true, root
        end
    end
    return false, nil
end
local function mountEntityESP(ent, root)
    if ent:FindFirstChild("_EG") or S.Entities[ent] then
        return
    end
    local dn = ENT_NAMES[ent.Name] or ent.Name
    local hl = Instance.new("Highlight")
    hl.Name = "_EH"
    hl.FillColor = CFG.EntityColor
    hl.FillTransparency = 0.65
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.15
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = ent
    local bg, nL, dL, iI, st =
        createStyledBillboard(root, root, ASSETS.Danger, dn:upper(), CFG.EntityColor, Vector3.new(0, 5, 0))
    bg.Name = "_EG"
    S.Entities[ent] = {
        ["root"] = root,
        ["bg"] = bg,
        ["nameL"] = nL,
        ["distL"] = dL,
        ["iconImg"] = iI,
        ["stroke"] = st,
        ["hl"] = hl,
        ["name"] = dn,
    }
    local ak = "m" .. tostring(ent)
    local ref = ent
    registerArrow(ak, function()
        local d = S.Entities[ref]
        return d and d.root and d.root.Parent and d.root.Position
    end, function()
        return CFG.EntityColor
    end, function()
        return CFG.ArrowEntities and CFG.EntityEnabled
    end)
    ent.Destroying:Connect(function()
        pcall(bg.Destroy, bg)
        pcall(hl.Destroy, hl)
        S.Entities[ent] = nil
        S.EntDebounce[ent] = nil
        hideTracer(ak)
        unregisterArrow(ak)
    end)
end
local function scanEntities()
    for _, d in ipairs(WS:GetDescendants()) do
        local ok, root = isMonster(d)
        if ok and not S.EntDebounce[d] then
            S.EntDebounce[d] = true
            mountEntityESP(d, root)
        end
    end
end
local eF, ET = 0, 3
local function startEntLoop()
    addConn(RS.Heartbeat:Connect(function()
        if not CFG.EntityEnabled then
            return
        end
        local hrp = myHRP()
        if not hrp then
            return
        end
        local mp = hrp.Position
        eF = eF + 1
        local dt = (eF % ET) == 0
        for ent, d in pairs(S.Entities) do
            if not ent.Parent or not d.root or not d.root.Parent then
                pcall(d.bg.Destroy, d.bg)
                pcall(d.hl.Destroy, d.hl)
                S.Entities[ent] = nil
                hideTracer("m" .. tostring(ent))
                unregisterArrow("m" .. tostring(ent))
                continue
            end
            d.bg.Enabled = true
            d.hl.Enabled = true
            d.nameL.TextColor3 = CFG.EntityColor
            d.stroke.Color = CFG.EntityColor
            d.hl.FillColor = CFG.EntityColor
            d.iconImg.ImageColor3 = CFG.EntityColor
            if dt then
                d.distL.Text = math.floor((mp - d.root.Position).Magnitude) .. " 距离单位"
            end
            drawTracer("m" .. tostring(ent), d.root.Position, CFG.EntityColor)
        end
    end))
end
local function mountPlayerESP(player)
    if (player == LP) or S.PlayerESP[player] then
        return
    end
    local function build(char)
        if not char then
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then
            char.ChildAdded:Wait()
            task.wait(0.2)
            root = char:FindFirstChild("HumanoidRootPart")
        end
        if not root then
            return
        end
        local old = S.PlayerESP[player]
        if old then
            pcall(old.bg.Destroy, old.bg)
            pcall(old.hl.Destroy, old.hl)
            unregisterArrow("p" .. tostring(player.UserId))
        end
        local hl = Instance.new("Highlight")
        hl.Name = "_PH"
        hl.FillColor = CFG.PlayerColor
        hl.FillTransparency = CFG.PlayerFillTransp
        hl.OutlineColor = CFG.PlayerOutlineColor
        hl.OutlineTransparency = CFG.PlayerOutlineTransp
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        local bg, nL, dL, iI, st =
            createStyledBillboard(root, root, ASSETS.Player, player.Name, CFG.PlayerColor, Vector3.new(0, 3, 0))
        bg.Name = "_PG"
        S.PlayerESP[player] = {
            ["hl"] = hl,
            ["bg"] = bg,
            ["nameL"] = nL,
            ["distL"] = dL,
            ["iconImg"] = iI,
            ["stroke"] = st,
            ["root"] = root,
        }
        local ak = "p" .. tostring(player.UserId)
        local ref = player
        registerArrow(ak, function()
            local d = S.PlayerESP[ref]
            return d and d.root and d.root.Parent and d.root.Position
        end, function()
            return CFG.PlayerColor
        end, function()
            return CFG.ArrowPlayers and CFG.PlayerESPOn
        end)
    end
    task.spawn(function()
        build(player.Character)
        addConn(player.CharacterAdded:Connect(function(c)
            task.wait(0.5)
            build(c)
        end))
    end)
end
local function removePlayerESP(player)
    local d = S.PlayerESP[player]
    if d then
        pcall(d.bg.Destroy, d.bg)
        pcall(d.hl.Destroy, d.hl)
    end
    S.PlayerESP[player] = nil
    hideTracer("p" .. tostring(player.UserId))
    unregisterArrow("p" .. tostring(player.UserId))
end
local function startPlayerLoop()
    addConn(RS.Heartbeat:Connect(function()
        if not CFG.PlayerESPOn then
            return
        end
        local hrp = myHRP()
        if not hrp then
            return
        end
        local mp = hrp.Position
        for plr, d in pairs(S.PlayerESP) do
            if not plr.Parent then
                removePlayerESP(plr)
                continue
            end
            d.hl.Enabled = true
            d.hl.FillColor = CFG.PlayerColor
            d.hl.FillTransparency = CFG.PlayerFillTransp
            d.hl.OutlineColor = CFG.PlayerOutlineColor
            d.hl.OutlineTransparency = CFG.PlayerOutlineTransp
            d.bg.Enabled = true
            d.nameL.TextColor3 = CFG.PlayerColor
            d.stroke.Color = CFG.PlayerColor
            d.iconImg.ImageColor3 = CFG.IconColor
            if d.root and d.root.Parent then
                d.distL.Text = math.floor((mp - d.root.Position).Magnitude) .. " 距离单位"
                drawTracer("p" .. tostring(plr.UserId), d.root.Position, CFG.PlayerColor)
            end
        end
    end))
    for _, plr in ipairs(Players:GetPlayers()) do
        mountPlayerESP(plr)
    end
    addConn(Players.PlayerAdded:Connect(function(p)
        mountPlayerESP(p)
    end))
    addConn(Players.PlayerRemoving:Connect(function(p)
        removePlayerESP(p)
    end))
end
local function purgeAll()
    for _, d in pairs(S.Items) do
        pcall(d.hl.Destroy, d.hl)
        pcall(d.bg.Destroy, d.bg)
    end
    S.Items = {}
    S.Registered = {}
    for _, d in pairs(S.Entities) do
        pcall(d.bg.Destroy, d.bg)
        pcall(d.hl.Destroy, d.hl)
    end
    S.Entities = {}
    S.EntDebounce = {}
    for _, d in pairs(elevatorESPData) do
        pcall(d.hl.Destroy, d.hl)
        pcall(d.bg.Destroy, d.bg)
    end
    elevatorESPData = {}
    clearAllTracers()
    clearAllArrows()
    allBillboards = {}
end
local function setupTransition()
    addConn(WS.ChildRemoved:Connect(function(child)
        if not S.Active then
            return
        end
        if (child.Parent ~= WS) and (child.Parent ~= nil) then
            return
        end
        if child:IsA("Folder") or child:IsA("Model") then
            task.wait(1)
            if not S.Active then
                return
            end
            purgeAll()
            task.wait(2)
            if not S.Active then
                return
            end
            scanItems()
            scanEntities()
        end
    end))
    addConn(WS.ChildAdded:Connect(function(child)
        if not S.Active then
            return
        end
        if child.Parent ~= WS then
            return
        end
        if child:IsA("Folder") or child:IsA("Model") then
            task.wait(2)
            if not S.Active then
                return
            end
            scanItems()
            scanEntities()
        end
    end))
end
local function listenSpawns()
    addConn(WS.DescendantAdded:Connect(function(desc)
        if not S.Active then
            return
        end
        if REJECT_CLASS[desc.ClassName] then
            return
        end
        if
            not (
                desc:IsA("Model")
                or desc:IsA("BasePart")
                or desc:IsA("MeshPart")
                or desc:IsA("ProximityPrompt")
                or desc:IsA("Folder")
                or desc:IsA("Actor")
            )
        then
            return
        end
        if isCharDescendant(desc) then
            return
        end
        task.wait(0.2)
        if not desc or not desc.Parent then
            return
        end
        tryRegItem(desc)
        if CFG.EntityEnabled then
            local ok, root = isMonster(desc)
            if ok and not S.EntDebounce[desc] then
                S.EntDebounce[desc] = true
                mountEntityESP(desc, root)
            end
        end
    end))
end
local fbConn = nil
local function saveOrigLighting()
    if S.OrigLightSaved then
        return
    end
    S.OrigLightSaved = true
    S.OrigLight = {
        ["Brightness"] = Lighting.Brightness,
        ["Ambient"] = Lighting.Ambient,
        ["OutdoorAmbient"] = Lighting.OutdoorAmbient,
        ["FogEnd"] = Lighting.FogEnd,
        ["FogStart"] = Lighting.FogStart,
        ["ClockTime"] = Lighting.ClockTime,
        ["Atmo"] = {},
        ["Effects"] = {},
    }
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmo then
        S.OrigLight.Atmo = {
            ["Density"] = atmo.Density,
            ["Offset"] = atmo.Offset,
            ["Haze"] = atmo.Haze,
            ["Glare"] = atmo.Glare,
            ["Color"] = atmo.Color,
            ["Decay"] = atmo.Decay,
        }
    end
    for _, c in ipairs(Lighting:GetChildren()) do
        if c:IsA("PostEffect") then
            S.OrigLight.Effects[c] = { ["Enabled"] = c.Enabled }
        end
    end
end
local function setFullbright(on)
    if fbConn then
        fbConn:Disconnect()
        fbConn = nil
    end
    if on then
        saveOrigLighting()
        local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmo then
            atmo.Density = 0
            atmo.Offset = 0
            atmo.Haze = 0
            atmo.Glare = 0
        end
        for _, c in ipairs(Lighting:GetChildren()) do
            if c:IsA("PostEffect") then
                pcall(function()
                    c.Enabled = false
                end)
            end
        end
        fbConn = RS.RenderStepped:Connect(function()
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
            Lighting.ClockTime = 14
        end)
    else
        local o = S.OrigLight
        if not o then
            return
        end
        Lighting.Brightness = o.Brightness
        Lighting.Ambient = o.Ambient
        Lighting.OutdoorAmbient = o.OutdoorAmbient
        Lighting.FogEnd = o.FogEnd
        Lighting.FogStart = o.FogStart
        Lighting.ClockTime = o.ClockTime
        local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmo and o.Atmo.Density then
            atmo.Density = o.Atmo.Density
            atmo.Offset = o.Atmo.Offset
            atmo.Haze = o.Atmo.Haze
            atmo.Glare = o.Atmo.Glare
            atmo.Color = o.Atmo.Color
            atmo.Decay = o.Atmo.Decay
        end
        for c, props in pairs(o.Effects) do
            if c and c.Parent then
                pcall(function()
                    c.Enabled = props.Enabled
                end)
            end
        end
    end
end
local sGC, jGC = nil, nil
local function applyMovement()
    local h = getHum()
    if not h then
        return
    end
    h.WalkSpeed = (CFG.SpeedOn and CFG.WalkSpeed) or 16
    h.JumpPower = (CFG.JumpOn and CFG.JumpPower) or 50
end
local function setupSpeedGuard()
    if sGC then
        sGC:Disconnect()
    end
    if jGC then
        jGC:Disconnect()
    end
    sGC = nil
    jGC = nil
    local h = getHum()
    if not h then
        return
    end
    if CFG.SpeedOn then
        sGC = h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if CFG.SpeedOn and (h.WalkSpeed ~= CFG.WalkSpeed) then
                h.WalkSpeed = CFG.WalkSpeed
            end
        end)
    end
    if CFG.JumpOn then
        jGC = h:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if CFG.JumpOn and (h.JumpPower ~= CFG.JumpPower) then
                h.JumpPower = CFG.JumpPower
            end
        end)
    end
end
local nCC = nil
local function setNoclip(on)
    if nCC then
        nCC:Disconnect()
        nCC = nil
    end
    if on then
        nCC = RS.RenderStepped:Connect(function()
            local char = LP.Character
            if not char then
                return
            end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end)
    else
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                end
            end
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum and (hum:GetState() ~= Enum.HumanoidStateType.Freefall) then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end
local fC, fV, fG = nil, nil, nil
local function setFly(on)
    if fC then
        fC:Disconnect()
        fC = nil
    end
    if fV then
        pcall(fV.Destroy, fV)
        fV = nil
    end
    if fG then
        pcall(fG.Destroy, fG)
        fG = nil
    end
    local hrp = myHRP()
    if not hrp then
        return
    end
    local hum = getHum()
    if on then
        if hum then
            hum.PlatformStand = true
        end
        fV = Instance.new("BodyVelocity")
        fV.MaxForce = Vector3.new(100000, 100000, 100000)
        fV.Velocity = Vector3.zero
        fV.Parent = hrp
        fG = Instance.new("BodyGyro")
        fG.MaxTorque = Vector3.new(100000, 100000, 100000)
        fG.P = 10000
        fG.CFrame = hrp.CFrame
        fG.Parent = hrp
        fC = RS.Heartbeat:Connect(function()
            local h2 = myHRP()
            if not h2 or not fV or not fV.Parent then
                return
            end
            local cam = WS.CurrentCamera
            if not cam then
                return
            end
            local cf = cam.CFrame
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                dir = dir + cf.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                dir = dir - cf.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                dir = dir + cf.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                dir = dir - cf.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                dir = dir + Vector3.new(0, 1, 0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                dir = dir - Vector3.new(0, 1, 0)
            end
            fV.Velocity = ((dir.Magnitude > 0) and (dir.Unit * CFG.FlySpeed)) or Vector3.zero
            fG.CFrame = cf
        end)
    elseif hum then
        hum.PlatformStand = false
    end
end
addConn(LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyMovement()
    setupSpeedGuard()
    if CFG.FlyOn then
        setFly(true)
    end
    if CFG.NoclipOn then
        setNoclip(true)
    end
end))
if LP.Character then
    applyMovement()
    setupSpeedGuard()
end
local function doTeleport()
    local hrp = myHRP()
    if not hrp then
        return false, "角色尚未加载。"
    end
    local spawn = WS:FindFirstChildOfClass("SpawnLocation")
    if not spawn then
        for _, d in ipairs(WS:GetDescendants()) do
            if d:IsA("SpawnLocation") then
                spawn = d
                break
            end
        end
    end
    if not spawn then
        return false, "未找到出生点。"
    end
    hrp.CFrame = CFrame.new(spawn.Position + Vector3.new(0, (spawn.Size.Y / 2) + 3, 0))
    return true, "传送完成。"
end
S.Unload = function()
    S.Active = false
    for _, c in ipairs(S.Conns) do
        pcall(function()
            c:Disconnect()
        end)
    end
    S.Conns = {}
    if fbConn then
        fbConn:Disconnect()
    end
    if nCC then
        nCC:Disconnect()
    end
    if fC then
        fC:Disconnect()
    end
    if sGC then
        sGC:Disconnect()
    end
    if jGC then
        jGC:Disconnect()
    end
    if fV and fV.Parent then
        fV:Destroy()
    end
    if fG and fG.Parent then
        fG:Destroy()
    end
    if tracerGui and tracerGui.Parent then
        tracerGui:Destroy()
    end
    if arrowGui and arrowGui.Parent then
        arrowGui:Destroy()
    end
    local wg = CoreGui:FindFirstChild("MEG_Welcome")
    if wg then
        wg:Destroy()
    end
    purgeAll()
    for _, d in pairs(S.PlayerESP) do
        pcall(d.bg.Destroy, d.bg)
        pcall(d.hl.Destroy, d.hl)
    end
    S.PlayerESP = {}
    pcall(setFullbright, false)
    local h = getHum()
    if h then
        h.WalkSpeed = 16
        h.JumpPower = 50
        h.PlatformStand = false
    end
    local char = LP.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
    end
    for _, d in ipairs(WS:GetDescendants()) do
        local n = d.Name
        if
            (n == "_IH")
            or (n == "_IG")
            or (n == "_EG")
            or (n == "_EH")
            or (n == "_PH")
            or (n == "_PG")
            or (n == "_ELEV_H")
            or (n == "_ELEV_G")
        then
            pcall(d.Destroy, d)
        end
    end
    if _G.MEG_SESSION == S then
        _G.MEG_SESSION = nil
    end
    print("[MEG v1.0] Session unloaded.")
end
local W = Rayfield:CreateWindow({
    ["Name"] = "M.E.G. 无尽现实 v1.0",
    ["LoadingTitle"] = "M.E.G. 框架",
    ["LoadingSubtitle"] = "作者：SkidGod",
    ["ConfigurationSaving"] = { ["Enabled"] = false },
    ["KeySystem"] = false,
    ["Theme"] = {
        ["TextColor"] = Color3.fromRGB(220, 225, 220),
        ["Background"] = Color3.fromRGB(12, 14, 15),
        ["Topbar"] = Color3.fromRGB(18, 22, 24),
        ["Shadow"] = Color3.fromRGB(5, 5, 5),
        ["NotificationBackground"] = Color3.fromRGB(18, 22, 24),
        ["NotificationActionsBackground"] = Color3.fromRGB(0, 160, 110),
        ["TabBackground"] = Color3.fromRGB(16, 20, 22),
        ["TabStroke"] = Color3.fromRGB(30, 36, 40),
        ["TabBackgroundSelected"] = Color3.fromRGB(0, 140, 95),
        ["TabTextColor"] = Color3.fromRGB(130, 140, 135),
        ["SelectedTabTextColor"] = Color3.fromRGB(255, 255, 255),
        ["ElementBackground"] = Color3.fromRGB(18, 22, 24),
        ["ElementBackgroundHover"] = Color3.fromRGB(24, 30, 32),
        ["SecondaryElementBackground"] = Color3.fromRGB(14, 16, 18),
        ["ElementStroke"] = Color3.fromRGB(32, 40, 44),
        ["SecondaryElementStroke"] = Color3.fromRGB(26, 32, 35),
        ["SliderBackground"] = Color3.fromRGB(25, 32, 35),
        ["SliderProgress"] = Color3.fromRGB(0, 100, 70),
        ["SliderStroke"] = Color3.fromRGB(0, 140, 95),
        ["ToggleBackground"] = Color3.fromRGB(22, 26, 28),
        ["ToggleEnabled"] = Color3.fromRGB(0, 160, 110),
        ["ToggleDisabled"] = Color3.fromRGB(38, 44, 46),
        ["ToggleEnabledStroke"] = Color3.fromRGB(0, 200, 130),
        ["ToggleDisabledStroke"] = Color3.fromRGB(50, 58, 60),
        ["ToggleEnabledOuterStroke"] = Color3.fromRGB(0, 100, 70),
        ["ToggleDisabledOuterStroke"] = Color3.fromRGB(26, 30, 32),
        ["DropdownSelected"] = Color3.fromRGB(26, 34, 36),
        ["DropdownUnselected"] = Color3.fromRGB(18, 22, 24),
        ["InputBackground"] = Color3.fromRGB(14, 16, 18),
        ["InputStroke"] = Color3.fromRGB(32, 40, 44),
        ["PlaceholderColor"] = Color3.fromRGB(90, 105, 100),
    },
})
local T1 = W:CreateTab("物品透视")
T1:CreateSlider({
    ["Name"] = "高亮范围",
    ["Range"] = { 50, 1000 },
    ["Increment"] = 10,
    ["CurrentValue"] = CFG.HighlightRange,
    ["Flag"] = "HR",
    ["Callback"] = function(v)
        CFG.HighlightRange = v
    end,
})
T1:CreateButton({
    ["Name"] = "立即重新扫描",
    ["Callback"] = function()
        scanItems()
        Rayfield:Notify({ ["Title"] = "完成", ["Content"] = "已重新扫描。", ["Duration"] = 3 })
    end,
})
T1:CreateButton({
    ["Name"] = "清除全部标记",
    ["Callback"] = function()
        for _, d in pairs(S.Items) do
            pcall(d.hl.Destroy, d.hl)
            pcall(d.bg.Destroy, d.bg)
        end
        S.Items = {}
        S.Registered = {}
        clearAllTracers()
        clearAllArrows()
        allBillboards = {}
    end,
})
T1:CreateSection("分类设置")
for _, ck in ipairs(CAT_ORDER) do
    local c = CATS[ck]
    local fn = CAT_NAMES[ck]
    T1:CreateToggle({
        ["Name"] = fn,
        ["CurrentValue"] = c.on,
        ["Flag"] = (ck .. "_T"),
        ["Callback"] = function(v)
            c.on = v
            for item, d in pairs(S.Items) do
                if d.cat == ck then
                    if d.hl and d.hl.Parent then
                        d.hl.Enabled = v
                    end
                    if d.bg and d.bg.Parent then
                        d.bg.Enabled = v
                    end
                end
            end
            if ck == "Elevator" then
                mountElevatorESP()
            end
            if v then
                scanItems()
            end
        end,
    })
    T1:CreateColorPicker({
        ["Name"] = (fn .. " Fill"),
        ["Color"] = c.fill,
        ["Flag"] = (ck .. "_F"),
        ["Callback"] = function(v)
            c.fill = v
        end,
    })
    T1:CreateColorPicker({
        ["Name"] = (fn .. " Outline"),
        ["Color"] = c.outline,
        ["Flag"] = (ck .. "_O"),
        ["Callback"] = function(v)
            c.outline = v
        end,
    })
    T1:CreateColorPicker({
        ["Name"] = (fn .. " Text"),
        ["Color"] = c.text,
        ["Flag"] = (ck .. "_TX"),
        ["Callback"] = function(v)
            c.text = v
        end,
    })
    T1:CreateSlider({
        ["Name"] = (fn .. " Fill Tr"),
        ["Range"] = { 0, 100 },
        ["Increment"] = 5,
        ["CurrentValue"] = math.floor(c.fillT * 100),
        ["Flag"] = (ck .. "_FT"),
        ["Callback"] = function(v)
            c.fillT = v / 100
        end,
    })
    T1:CreateSlider({
        ["Name"] = (fn .. " Out Tr"),
        ["Range"] = { 0, 100 },
        ["Increment"] = 5,
        ["CurrentValue"] = math.floor(c.outlineT * 100),
        ["Flag"] = (ck .. "_OT"),
        ["Callback"] = function(v)
            c.outlineT = v / 100
        end,
    })
end
local T2 = W:CreateTab("实体透视")
T2:CreateToggle({
    ["Name"] = "实体透视",
    ["CurrentValue"] = CFG.EntityEnabled,
    ["Flag"] = "EE",
    ["Callback"] = function(v)
        CFG.EntityEnabled = v
        for _, d in pairs(S.Entities) do
            if d.bg and d.bg.Parent then
                d.bg.Enabled = v
            end
            if d.hl and d.hl.Parent then
                d.hl.Enabled = v
            end
        end
        if v then
            scanEntities()
        end
    end,
})
T2:CreateColorPicker({
    ["Name"] = "实体颜色",
    ["Color"] = CFG.EntityColor,
    ["Flag"] = "EC",
    ["Callback"] = function(v)
        CFG.EntityColor = v
    end,
})
T2:CreateSlider({
    ["Name"] = "最大显示距离",
    ["Range"] = { 100, 2000 },
    ["Increment"] = 50,
    ["CurrentValue"] = CFG.EntityMaxDist,
    ["Flag"] = "EMD",
    ["Callback"] = function(v)
        CFG.EntityMaxDist = v
        for _, d in pairs(S.Entities) do
            if d.bg and d.bg.Parent then
                d.bg.MaxDistance = v
            end
        end
    end,
})
local T3 = W:CreateTab("玩家透视")
T3:CreateToggle({
    ["Name"] = "玩家透视",
    ["CurrentValue"] = CFG.PlayerESPOn,
    ["Flag"] = "PE",
    ["Callback"] = function(v)
        CFG.PlayerESPOn = v
        for _, d in pairs(S.PlayerESP) do
            if d.hl and d.hl.Parent then
                d.hl.Enabled = v
            end
            if d.bg and d.bg.Parent then
                d.bg.Enabled = v
            end
        end
    end,
})
T3:CreateColorPicker({
    ["Name"] = "填充颜色",
    ["Color"] = CFG.PlayerColor,
    ["Flag"] = "PC",
    ["Callback"] = function(v)
        CFG.PlayerColor = v
    end,
})
T3:CreateColorPicker({
    ["Name"] = "轮廓颜色",
    ["Color"] = CFG.PlayerOutlineColor,
    ["Flag"] = "POC",
    ["Callback"] = function(v)
        CFG.PlayerOutlineColor = v
    end,
})
T3:CreateSlider({
    ["Name"] = "填充透明度",
    ["Range"] = { 0, 100 },
    ["Increment"] = 5,
    ["CurrentValue"] = math.floor(CFG.PlayerFillTransp * 100),
    ["Flag"] = "PFT",
    ["Callback"] = function(v)
        CFG.PlayerFillTransp = v / 100
    end,
})
T3:CreateSlider({
    ["Name"] = "轮廓透明度",
    ["Range"] = { 0, 100 },
    ["Increment"] = 5,
    ["CurrentValue"] = math.floor(CFG.PlayerOutlineTransp * 100),
    ["Flag"] = "POT",
    ["Callback"] = function(v)
        CFG.PlayerOutlineTransp = v / 100
    end,
})
local T4 = W:CreateTab("视觉设置")
T4:CreateSection("悬浮信息框")
T4:CreateSlider({
    ["Name"] = "宽度（像素）",
    ["Range"] = { 80, 400 },
    ["Increment"] = 10,
    ["CurrentValue"] = CFG.BillboardWidth,
    ["Flag"] = "BW",
    ["Callback"] = function(v)
        CFG.BillboardWidth = v
        refreshAllBillboards()
    end,
})
T4:CreateSlider({
    ["Name"] = "高度（像素）",
    ["Range"] = { 20, 100 },
    ["Increment"] = 5,
    ["CurrentValue"] = CFG.BillboardHeight,
    ["Flag"] = "BH",
    ["Callback"] = function(v)
        CFG.BillboardHeight = v
        refreshAllBillboards()
    end,
})
T4:CreateSlider({
    ["Name"] = "垂直偏移",
    ["Range"] = { 10, 80 },
    ["Increment"] = 5,
    ["CurrentValue"] = math.floor(CFG.BillboardYOffset * 10),
    ["Flag"] = "BYO",
    ["Callback"] = function(v)
        CFG.BillboardYOffset = v / 10
        refreshAllBillboards()
    end,
})
T4:CreateSlider({
    ["Name"] = "面板透明度",
    ["Range"] = { 0, 90 },
    ["Increment"] = 5,
    ["CurrentValue"] = math.floor(CFG.BillboardPanelTransp * 100),
    ["Flag"] = "BPT",
    ["Callback"] = function(v)
        CFG.BillboardPanelTransp = v / 100
        refreshAllBillboards()
    end,
})
T4:CreateSection("追踪线")
T4:CreateToggle({
    ["Name"] = "追踪线",
    ["CurrentValue"] = CFG.TracersOn,
    ["Flag"] = "TR",
    ["Callback"] = function(v)
        CFG.TracersOn = v
        if not v then
            clearAllTracers()
        end
    end,
})
T4:CreateColorPicker({
    ["Name"] = "颜色",
    ["Color"] = CFG.TracerColor,
    ["Flag"] = "TC",
    ["Callback"] = function(v)
        CFG.TracerColor = v
    end,
})
T4:CreateSlider({
    ["Name"] = "粗细",
    ["Range"] = { 1, 6 },
    ["Increment"] = 1,
    ["CurrentValue"] = CFG.TracerThickness,
    ["Flag"] = "TT",
    ["Callback"] = function(v)
        CFG.TracerThickness = v
    end,
})
T4:CreateSlider({
    ["Name"] = "透明度",
    ["Range"] = { 0, 90 },
    ["Increment"] = 5,
    ["CurrentValue"] = math.floor(CFG.TracerTransp * 100),
    ["Flag"] = "TTR",
    ["Callback"] = function(v)
        CFG.TracerTransp = v / 100
    end,
})
T4:CreateSection("方向箭头")
T4:CreateToggle({
    ["Name"] = "方向箭头",
    ["CurrentValue"] = CFG.ArrowsOn,
    ["Flag"] = "ARR",
    ["Callback"] = function(v)
        CFG.ArrowsOn = v
        if not v then
            for _, a in pairs(S.ArrowCache) do
                if a and a.Parent then
                    a.Visible = false
                end
            end
        end
    end,
})
T4:CreateSlider({
    ["Name"] = "尺寸",
    ["Range"] = { 16, 64 },
    ["Increment"] = 4,
    ["CurrentValue"] = CFG.ArrowSize,
    ["Flag"] = "ARRS",
    ["Callback"] = function(v)
        CFG.ArrowSize = v
    end,
})
T4:CreateSlider({
    ["Name"] = "屏幕边缘距离",
    ["Range"] = { 40, 200 },
    ["Increment"] = 5,
    ["CurrentValue"] = CFG.ArrowRadius,
    ["Flag"] = "ARRR",
    ["Callback"] = function(v)
        CFG.ArrowRadius = v
    end,
})
T4:CreateToggle({
    ["Name"] = "物品",
    ["CurrentValue"] = CFG.ArrowItems,
    ["Flag"] = "ARRI",
    ["Callback"] = function(v)
        CFG.ArrowItems = v
    end,
})
T4:CreateToggle({
    ["Name"] = "实体",
    ["CurrentValue"] = CFG.ArrowEntities,
    ["Flag"] = "ARRE",
    ["Callback"] = function(v)
        CFG.ArrowEntities = v
    end,
})
T4:CreateToggle({
    ["Name"] = "玩家",
    ["CurrentValue"] = CFG.ArrowPlayers,
    ["Flag"] = "ARRP",
    ["Callback"] = function(v)
        CFG.ArrowPlayers = v
    end,
})
T4:CreateToggle({
    ["Name"] = "Elevator",
    ["CurrentValue"] = CFG.ArrowElevator,
    ["Flag"] = "ARREL",
    ["Callback"] = function(v)
        CFG.ArrowElevator = v
    end,
})
T4:CreateSection("其他设置")
T4:CreateColorPicker({
    ["Name"] = "图标颜色",
    ["Color"] = CFG.IconColor,
    ["Flag"] = "IC",
    ["Callback"] = function(v)
        CFG.IconColor = v
    end,
})
T4:CreateToggle({
    ["Name"] = "全亮模式",
    ["CurrentValue"] = CFG.Fullbright,
    ["Flag"] = "FB",
    ["Callback"] = function(v)
        CFG.Fullbright = v
        setFullbright(v)
    end,
})
local T5 = W:CreateTab("实用工具")
T5:CreateSection("移动设置")
T5:CreateToggle({
    ["Name"] = "速度增强",
    ["CurrentValue"] = CFG.SpeedOn,
    ["Flag"] = "SP",
    ["Callback"] = function(v)
        CFG.SpeedOn = v
        applyMovement()
        setupSpeedGuard()
    end,
})
T5:CreateSlider({
    ["Name"] = "行走速度",
    ["Range"] = { 16, 250 },
    ["Increment"] = 2,
    ["CurrentValue"] = CFG.WalkSpeed,
    ["Flag"] = "WSS",
    ["Callback"] = function(v)
        CFG.WalkSpeed = v
        if CFG.SpeedOn then
            applyMovement()
        end
    end,
})
T5:CreateButton({
    ["Name"] = "重置速度",
    ["Callback"] = function()
        CFG.SpeedOn = false
        CFG.WalkSpeed = 16
        applyMovement()
        setupSpeedGuard()
    end,
})
T5:CreateToggle({
    ["Name"] = "跳跃增强",
    ["CurrentValue"] = CFG.JumpOn,
    ["Flag"] = "JP",
    ["Callback"] = function(v)
        CFG.JumpOn = v
        applyMovement()
        setupSpeedGuard()
    end,
})
T5:CreateSlider({
    ["Name"] = "跳跃力度",
    ["Range"] = { 50, 400 },
    ["Increment"] = 10,
    ["CurrentValue"] = CFG.JumpPower,
    ["Flag"] = "JPV",
    ["Callback"] = function(v)
        CFG.JumpPower = v
        if CFG.JumpOn then
            applyMovement()
        end
    end,
})
T5:CreateButton({
    ["Name"] = "重置跳跃",
    ["Callback"] = function()
        CFG.JumpOn = false
        CFG.JumpPower = 50
        applyMovement()
        setupSpeedGuard()
    end,
})
T5:CreateSection("穿墙与飞行")
T5:CreateToggle({
    ["Name"] = "穿墙模式",
    ["CurrentValue"] = CFG.NoclipOn,
    ["Flag"] = "NC",
    ["Callback"] = function(v)
        CFG.NoclipOn = v
        setNoclip(v)
    end,
})
T5:CreateToggle({
    ["Name"] = "飞行模式",
    ["CurrentValue"] = CFG.FlyOn,
    ["Flag"] = "FY",
    ["Callback"] = function(v)
        CFG.FlyOn = v
        setFly(v)
    end,
})
T5:CreateSlider({
    ["Name"] = "飞行速度",
    ["Range"] = { 10, 300 },
    ["Increment"] = 5,
    ["CurrentValue"] = CFG.FlySpeed,
    ["Flag"] = "FYS",
    ["Callback"] = function(v)
        CFG.FlySpeed = v
    end,
})
T5:CreateLabel("WASD / Space / Ctrl")
T5:CreateKeybind({
    ["Name"] = "穿墙快捷键",
    ["CurrentKeybind"] = "V",
    ["Flag"] = "NCK",
    ["Callback"] = function()
        CFG.NoclipOn = not CFG.NoclipOn
        setNoclip(CFG.NoclipOn)
    end,
})
T5:CreateKeybind({
    ["Name"] = "飞行快捷键",
    ["CurrentKeybind"] = "",
    ["Flag"] = "FYK",
    ["Callback"] = function()
        CFG.FlyOn = not CFG.FlyOn
        setFly(CFG.FlyOn)
    end,
})
local T6 = W:CreateTab("传送")
T6:CreateToggle({
    ["Name"] = "电梯透视",
    ["CurrentValue"] = CFG.ElevatorESPOn,
    ["Flag"] = "ELEV_ESP",
    ["Callback"] = function(v)
        CFG.ElevatorESPOn = v
        mountElevatorESP()
    end,
})
T6:CreateButton({
    ["Name"] = "传送到电梯",
    ["Callback"] = function()
        local ok, msg = doTeleport()
        Rayfield:Notify({ ["Title"] = ((ok and "成功") or "失败"), ["Content"] = msg, ["Duration"] = 4 })
    end,
})
T6:CreateKeybind({
    ["Name"] = "电梯传送快捷键",
    ["CurrentKeybind"] = "T",
    ["Flag"] = "ELK",
    ["Callback"] = function()
        local ok, msg = doTeleport()
        Rayfield:Notify({ ["Title"] = ((ok and "成功") or "失败"), ["Content"] = msg, ["Duration"] = 3 })
    end,
})
local T7 = W:CreateTab("配置管理")
T7:CreateButton({
    ["Name"] = "保存配置",
    ["Callback"] = function()
        local ok = saveConfig()
        Rayfield:Notify({
            ["Title"] = ((ok and "已保存") or "错误"),
            ["Content"] = ((ok and "操作完成。") or "当前执行器不支持文件写入。"),
            ["Duration"] = 3,
        })
    end,
})
T7:CreateButton({
    ["Name"] = "加载配置",
    ["Callback"] = function()
        local ok = loadConfig()
        Rayfield:Notify({
            ["Title"] = ((ok and "已加载") or "未找到"),
            ["Content"] = ((ok and "请重新执行脚本以应用配置。") or "配置文件不存在。"),
            ["Duration"] = 4,
        })
    end,
})
T7:CreateButton({
    ["Name"] = "删除配置",
    ["Callback"] = function()
        if delfile and isfile then
            pcall(function()
                if isfile(CONFIG_FILE) then
                    delfile(CONFIG_FILE)
                end
            end)
        end
        Rayfield:Notify({ ["Title"] = "已删除", ["Content"] = "操作完成。", ["Duration"] = 3 })
    end,
})
local T8 = W:CreateTab("脚本控制")
T8:CreateButton({
    ["Name"] = "卸载脚本",
    ["Callback"] = function()
        Rayfield:Notify({ ["Title"] = "正在关闭", ["Content"] = "正在清理资源...", ["Duration"] = 2 })
        task.wait(0.8)
        S.Unload()
        Rayfield:Destroy()
    end,
})
print("[MEG v1.0] Initializing by SkidGod...")
ensureArrowGui()
scanItems()
startItemLoop()
listenSpawns()
scanEntities()
startEntLoop()
startPlayerLoop()
setupTransition()
startArrowLoop()
-- Welcome popup disabled; main UI opens directly.
print("[MEG v1.0] All systems active.")
