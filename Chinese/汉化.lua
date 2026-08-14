--// ================= 实时汉化系统（独立版） =================
--// 从秋辞缝合脚本中提取，可独立使用

local repo = 'https://raw.githubusercontent.com/DevSloPo/obsidian_UI/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = "实时汉化系统",
    Footer = "By 秋辞",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tab = Window:AddTab("汉化设置", "info")
local Huagn = Tab:AddLeftGroupbox("汉化功能")

--// ================= 实时汉化核心 =================
do
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = Players.LocalPlayer

    if not LocalPlayer then
        LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    end

    local MY_NAMESPACE = "EnhancedTranslator_" .. tostring(math.random(10000, 99999))
    if not _G[MY_NAMESPACE] then
        _G[MY_NAMESPACE] = {
            textData = {},
            scannedElements = {},
            translatedElements = {},
            monitorConnections = {},
            translateQueue = {},
            queuedSet = {},
            isProcessingQueue = false,
            isRunning = false,
            extractCount = 0,
            translateCount = 0,
            localizeCount = 0,
        }
    end
    local Engine = _G[MY_NAMESPACE]
    local RUNTIME = {
        translationAPI = "Google",
        translationsPerSecond = 20,
        batchSize = 5,
        scanInterval = 2,
        minTextLength = 2,
        maxTextLength = 100,
    }
    local function shouldFilterText(text)
        if not text or text:gsub("%s+", "") == "" then return true end
        if text:match("^[%p%s]+$") then return true end
        if #text < RUNTIME.minTextLength then return true end
        if #text > RUNTIME.maxTextLength then return true end
        return false
    end
    local function isOfficialChatOrInventory(element)
        if not element then return false end
        
        local fullName = element:GetFullName():lower()
        
        if fullName:find("chat") or 
           fullName:find("textchat") or 
           fullName:find("defaultchatsystem") then
            return true
        end
        
        if fullName:find("backpack") or 
           fullName:find("inventory") or 
           fullName:find("tool") or
           fullName:find("item") then
            return true
        end
        
        local parent = element.Parent
        while parent do
            local parentName = parent.Name:lower()
            if parentName:find("chat") or 
               parentName:find("backpack") or 
               parentName:find("inventory") or
               parentName:find("tool") then
                return true
            end
            parent = parent.Parent
        end
        
        return false
    end
    local function translateWithGoogle(orig)
        local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=" .. HttpService:UrlEncode(orig)
        
        local body
        local success = false
        
        for retry = 1, 3 do
            local ok, result = pcall(function()
                return game:HttpGet(url)
            end)
            if ok and result then
                body = result
                success = true
                break
            end
            task.wait(0.1 * retry)
        end
        
        if not success or not body then return "" end
        
        local parsedOk, parsed = pcall(function() 
            return HttpService:JSONDecode(body) 
        end)
        
        if not parsedOk or type(parsed) ~= "table" or type(parsed[1]) ~= "table" then
            return ""
        end
        
        local parts = {}
        for _, seg in ipairs(parsed[1]) do
            if type(seg) == "table" and seg[1] then 
                table.insert(parts, tostring(seg[1])) 
            end
        end
        
        local result = table.concat(parts)
        return result
    end

    local function translateWithMyMemory(text)
        local url = "https://api.mymemory.translated.net/get?q="
            .. HttpService:UrlEncode(text) .. "&langpair=en|zh"
        
        local body
        local success = false
        
        for retry = 1, 2 do
            local ok, result = pcall(game.HttpGet, game, url)
            if ok and result then
                body = result
                success = true
                break
            end
            task.wait(0.1)
        end
        
        if not success or not body then return "" end
        
        local s, d = pcall(HttpService.JSONDecode, HttpService, body)
        if s and d and d.responseData then
            return d.responseData.translatedText
        end
        return ""
    end

    local function translateText(orig)
        if not orig or orig == "" then return "" end
        
        if Engine.textData[orig] and Engine.textData[orig].translation and Engine.textData[orig].translation ~= "" then
            return Engine.textData[orig].translation
        end

        local translation = ""
        
        if RUNTIME.translationAPI == "Google" then
            translation = translateWithGoogle(orig)
            if translation == "" then
                translation = translateWithMyMemory(orig)
            end
        else
            translation = translateWithMyMemory(orig)
            if translation == "" then
                translation = translateWithGoogle(orig)
            end
        end

        if translation ~= "" and translation ~= orig then
            Engine.textData[orig] = Engine.textData[orig] or { translation = "", paths = {}, translated = false }
            Engine.textData[orig].translation = translation
            Engine.textData[orig].translated = true
            Engine.translateCount = Engine.translateCount + 1
        else
            Engine.textData[orig] = Engine.textData[orig] or { translation = orig, paths = {}, translated = true }
        end
        
        return translation
    end
    local function enqueueText(text)
        if not text or shouldFilterText(text) then return end
        if Engine.queuedSet[text] or (Engine.textData[text] and Engine.textData[text].translated) then return end
        
        table.insert(Engine.translateQueue, { text = text, priority = #text })
        Engine.queuedSet[text] = true
    end
    local function gethui_enhanced()
        local guis = {}
        
        if type(gethui) == "function" then
            local success, result = pcall(gethui)
            if success and result then
                table.insert(guis, result)
            end
        end
        
        local aliases = {"get_hui", "get_container", "get_roblox_gui", "_x92a", "get_gui"}
        for _, alias in ipairs(aliases) do
            if type(_G[alias]) == "function" then
                local success, result = pcall(_G[alias])
                if success and result then
                    table.insert(guis, result)
                end
            end
        end
        
        local success, result = pcall(function()
            return game:GetService("CoreGui")
        end)
        if success and result then
            table.insert(guis, result)
        end
        
        local localPlayer = Players.LocalPlayer
        if localPlayer then
            local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
            if playerGui then
                table.insert(guis, playerGui)
            end
        end
        
        return guis
    end
    local function extractElementText(element)
        if not element then return end
        if not (element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox")) then return end
        if Engine.scannedElements[element] then return end
        
        if isOfficialChatOrInventory(element) then
            Engine.scannedElements[element] = true
            return
        end
        
        local ok, txt = pcall(function() return element.Text end)
        if not ok or not txt then
            Engine.scannedElements[element] = true
            return
        end
        
        local text = tostring(txt)
        if shouldFilterText(text) then
            Engine.scannedElements[element] = true
            return
        end
        
        local path = tostring(element)
        if not Engine.textData[text] then
            Engine.textData[text] = { 
                translation = "", 
                paths = { path }, 
                translated = false 
            }
            Engine.extractCount = Engine.extractCount + 1
            enqueueText(text)
        else
            local paths = Engine.textData[text].paths or {}
            if not table.find(paths, path) then 
                table.insert(paths, path) 
                Engine.textData[text].paths = paths 
            end
        end
        
        Engine.scannedElements[element] = true
    end

    local function setupElementMonitor(element)
        if not element then return end
        if Engine.translatedElements[element] then return end
        
        if isOfficialChatOrInventory(element) then
            Engine.translatedElements[element] = true
            return
        end
        
        local ok, textConn = pcall(function()
            return element:GetPropertyChangedSignal("Text"):Connect(function()
                task.wait(0.05)
                extractElementText(element)
                -- 实时应用翻译
                local currentText = element.Text
                local data = Engine.textData[currentText]
                if data and data.translation and data.translation ~= "" and data.translation ~= currentText then
                    pcall(function() element.Text = data.translation end)
                end
            end)
        end)
        if ok and textConn then 
            table.insert(Engine.monitorConnections, textConn) 
        end
    end
    local function scanAllGuiElements()
        local guis = gethui_enhanced()
        
        for _, container in ipairs(guis) do
            if not container then continue end
            
            local descendants = {}
            pcall(function()
                descendants = container:GetDescendants()
            end)
            
            for i, desc in ipairs(descendants) do
                if desc and (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) then
                    extractElementText(desc)
                    setupElementMonitor(desc)
                end
                
                if i % 100 == 0 then
                    task.wait(0.01)
                end
            end
            
            local ok, conn = pcall(function()
                return container.DescendantAdded:Connect(function(desc)
                    if desc and (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) then
                        task.wait(0.05)
                        extractElementText(desc)
                        setupElementMonitor(desc)
                    end
                end)
            end)
            if ok and conn then
                table.insert(Engine.monitorConnections, conn)
            end
        end
    end
    local function processTranslationQueue()
        while Engine.isRunning do
            if #Engine.translateQueue > 0 then
                local batch = {}
                for i = 1, math.min(RUNTIME.batchSize, #Engine.translateQueue) do
                    local item = table.remove(Engine.translateQueue, 1)
                    if item then
                        table.insert(batch, item)
                        Engine.queuedSet[item.text] = nil
                    end
                end
                
                for _, item in ipairs(batch) do
                    task.spawn(function()
                        translateText(item.text)
                    end)
                end
                
                task.wait(1.0 / RUNTIME.translationsPerSecond)
            else
                task.wait(0.1)
            end
        end
    end
    local function applyLocalizations()
        while Engine.isRunning do
            local guis = gethui_enhanced()
            
            for _, container in ipairs(guis) do
                if not container then continue end
                
                local descendants = {}
                pcall(function()
                    descendants = container:GetDescendants()
                end)
                
                for _, desc in ipairs(descendants) do
                    if desc and (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) then
                        if isOfficialChatOrInventory(desc) then
                            continue
                        end
                        
                        if Engine.translatedElements[desc] then continue end
                        
                        local ok, text = pcall(function() return desc.Text end)
                        if not ok or not text then continue end
                        
                        local origText = tostring(text)
                        local data = Engine.textData[origText]
                        
                        if data and data.translation and data.translation ~= "" and data.translation ~= origText then
                            local success = pcall(function()
                                desc.Text = data.translation
                            end)
                            
                            if success then
                                Engine.translatedElements[desc] = true
                                Engine.localizeCount = Engine.localizeCount + 1
                            end
                        end
                    end
                end
            end
            
            task.wait(RUNTIME.scanInterval)
        end
    end
    local function manualRefresh()
        Engine.scannedElements = {}
        Engine.translatedElements = {}
        scanAllGuiElements()
    end
    local function resetCache()
        Engine.textData = {}
        Engine.scannedElements = {}
        Engine.translatedElements = {}
        Engine.translateQueue = {}
        Engine.queuedSet = {}
        Engine.extractCount = 0
        Engine.translateCount = 0
        Engine.localizeCount = 0
    end
    local function startLocalization()
        if Engine.isRunning then return end
        
        Engine.isRunning = true
        
        task.spawn(scanAllGuiElements)
        task.spawn(processTranslationQueue)
        task.spawn(applyLocalizations)
    end

    local function stopLocalization()
        if not Engine.isRunning then return end
        
        Engine.isRunning = false
        
        for _, conn in ipairs(Engine.monitorConnections) do
            pcall(function() 
                if conn and conn.Disconnect then 
                    conn:Disconnect() 
                end 
            end)
        end
        Engine.monitorConnections = {}
    end
    Huagn:AddToggle("AutoTranslate", {
        Text = "启用实时汉化",
        Default = false,
        Tooltip = "实时自动翻译TextLabel/TextButton/TextBox（含动态内容）",
        Callback = function(v)
            if v then startLocalization() else stopLocalization() end
        end
    })
    Huagn:AddDropdown("TranslationAPI", {
        Text = "翻译接口",
        Default = "Google",
        Options = {"Google", "MyMemory"},
        Callback = function(v)
            RUNTIME.translationAPI = v
        end
    })
    Huagn:AddSlider("TranslateSpeed", {
        Text = "翻译速度",
        Default = 20,
        Min = 5,
        Max = 60,
        Rounding = 0,
        Suffix = " 次/秒",
        Callback = function(v)
            RUNTIME.translationsPerSecond = v
        end
    })
    Huagn:AddSlider("ScanInterval", {
        Text = "刷新间隔",
        Default = 2,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Suffix = " 秒",
        Callback = function(v)
            RUNTIME.scanInterval = v
        end
    })
    Huagn:AddSlider("BatchSize", {
        Text = "批量翻译数",
        Default = 5,
        Min = 1,
        Max = 15,
        Rounding = 0,
        Suffix = " 条/批",
        Callback = function(v)
            RUNTIME.batchSize = v
        end
    })
    Huagn:AddButton({
        Text = "🔄 手动刷新翻译",
        Func = function()
            manualRefresh()
            Library:Notify("正在重新扫描并翻译UI…", 3)
        end
    })
    Huagn:AddButton({
        Text = "🗑️ 重置翻译缓存",
        Func = function()
            resetCache()
            Library:Notify("翻译缓存已清空，重新启动汉化即可重建", 3)
        end
    })
    Huagn:AddToggle("FilterChatInv", {
        Text = "过滤聊天 & 背包",
        Default = true,
        Tooltip = "避免翻译聊天框和背包中的文本",
        Callback = function(v)
        end
    })

    task.spawn(function()
        while wait(2) do
            if Engine.isRunning then
                local status = string.format("📊 已提取:%d | 已翻译:%d | 已应用:%d", 
                    Engine.extractCount, Engine.translateCount, Engine.localizeCount)
            end
        end
    end)
end
