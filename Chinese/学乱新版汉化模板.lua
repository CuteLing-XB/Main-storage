do
    local Translations = {
        -- 导航栏与大标题（包含所有大小写）
        ["MAIN"] = "主要",
        ["Main"] = "主要",
        ["PARRY"] = "招架",
        ["Parry"] = "招架",
        ["PLAYER"] = "玩家",
        ["Player"] = "玩家",
        ["TELEPORT"] = "传送",
        ["Teleport"] = "传送",
        ["FUN"] = "娱乐",
        ["Fun"] = "娱乐",
        ["AUTO FARM"] = "自动刷取",
        ["Auto Farm"] = "自动刷取",
        ["VISUAL"] = "视觉透视",
        ["Visual"] = "视觉透视",
        ["SETTINGS"] = "设置",
        ["Settings"] = "设置",
        ["SYSTEM MENU"] = "系统菜单",
        ["System Menu"] = "系统菜单",

        -- 通用操作、状态与控制词汇
        ["Enabled"] = "开启",
        ["ENABLED"] = "已开启",
        ["Disabled"] = "禁用",
        ["DISABLED"] = "已禁用",
        ["OFF"] = "关闭",
        ["ON"] = "开启",
        ["ACTION"] = "操作",
        ["Action"] = "操作",
        ["STATE"] = "状态",
        ["State"] = "状态",
        ["SWITCH"] = "开关",
        ["Switch"] = "开关",
        ["ASSIGNMENT"] = "按键绑定",
        ["Assignment"] = "按键绑定",
        ["EXECUTE"] = "执行",
        ["Execute"] = "执行",
        ["NO ERROR"] = "无错误",
        ["No Error"] = "无错误",
        ["COPY"] = "复制",
        ["Copy"] = "复制",
        ["SELECTION"] = "选择",
        ["Selection"] = "选择",
        ["SAVE"] = "保存",
        ["Save"] = "保存",
        ["LOAD"] = "加载",
        ["Load"] = "加载",
        ["DELETE"] = "删除",
        ["Delete"] = "删除",
        ["REFRESH"] = "刷新",
        ["Refresh"] = "刷新",
        ["AUTOLOAD"] = "自动加载",
        ["Autoload"] = "自动加载",
        ["CLEAR"] = "清除",
        ["Clear"] = "清除",
        ["PARAMETER"] = "参数",
        ["Parameter"] = "参数",
        ["VALUE"] = "数值",
        ["Value"] = "数值",
        ["DEFAULT"] = "默认",
        ["Default"] = "默认",
        ["studs"] = "米/单位",
        ["0 studs"] = "0 米",
        ["15 studs"] = "15 米/单位",
        ["300 studs"] = "300 米",
        ["15 米/单位"] = "15 米/单位",
        ["No additional information is available."] = "无额外可用信息。",
        ["INFO"] = "信息",
        ["Info"] = "信息",
        ["DATA"] = "数据",
        ["Data"] = "数据",
        ["系统 DATA"] = "系统数据",

        -- 【MAIN】主页
        ["INTERIUM"] = "INTERIUM",
        ["Interium for Gakuran"] = "Gakuran 专用的 Interium",
        ["Made by .int3rtia"] = "作者：.int3rtia",
        ["Discord invite copied"] = "Discord 邀请链接已复制",
        ["COPY DISCORD INVITE"] = "复制 Discord 邀请链接",
        ["Copy Discord Invite"] = "复制 Discord 邀请链接",
        ["Copy the official Interium Discord invite to your clipboard."] = "复制 Interium 官方 Discord 邀请链接到剪贴板。",

        -- 【PARRY】招架设置
        ["AUTO PARRY"] = "自动招架",
        ["Auto Parry"] = "自动招架",
        ["Parry Rotation"] = "招架旋转角度",
        ["Pause M1 for Parry"] = "招架时暂停左键攻击(M1)",
        ["M2 Assist"] = "右键辅助(M2)",
        ["Rear Dodge"] = "向后闪避",
        ["Select Priority"] = "选择优先级",
        ["SELECT PRIORITY"] = "选择优先级",
        ["SELECTED"] = "已选择",
        ["Selected"] = "已选择",
        ["0 已选择"] = "0 已选择",
        ["2 已选择"] = "2 已选择",
        ["Block"] = "格挡",
        ["Dodge"] = "闪避",
        ["M2"] = "右键(M2)",
        ["M1"] = "左键(M1)",
        ["none"] = "无",
        ["Dodge Priority"] = "闪避优先级",
        ["Select Dodge Directional"] = "选择闪避方向",
        ["Parry Chance %"] = "招架概率 %",
        ["招架 Chance %"] = "招架概率 %",
        ["Parry Distance"] = "招架距离",
        ["Parry 距离"] = "招架距离",
        ["Show Parry Distance"] = "显示招架距离",
        ["Show Parry 距离"] = "显示招架距离",
        ["Force Facing"] = "强制朝向敌人",
        ["Look Speed"] = "朝向转向速度",
        ["Whitelist Players"] = "白名单玩家",
        ["Whitelist 玩家s"] = "白名单玩家",
        ["1st Priority: Block"] = "第一优先级：格挡",
        ["2nd Priority: Dodge"] = "第二优先级：闪避",
        ["3rd Priority: none"] = "第三优先级：无",
        ["1st Priority: M1"] = "第一优先级：左键(M1)",
        ["2nd Priority: M2"] = "第二优先级：右键(M2)",
        ["1st Priority: M2"] = "第一优先级：右键(M2)",
        ["2nd Priority: M1"] = "第二优先级：左键(M1)",
        ["第一优先级：格挡"] = "第一优先级：格挡",
        ["第二优先级：闪避"] = "第二优先级：闪避",
        ["第三优先级：无"] = "第三优先级：无",
        ["SYSTEM"] = "系统",
        ["System"] = "系统",
        ["AUTO PUNISH"] = "自动惩罚",
        ["Auto Punish"] = "自动惩罚",

        -- 【PLAYER】玩家属性与功能
        ["Infinite Stamina"] = "无限体力",
        ["No Dash CD"] = "冲刺无冷却",
        ["No Parry CD"] = "招架无冷却",
        ["Auto Sprint"] = "自动冲刺",
        ["Instant Respawn"] = "瞬间重生",
        ["No Ragdoll"] = "防摔倒/物理击飞",
        ["No Stun"] = "防眩晕",
        ["Disable Glasses Knocked"] = "禁用眼镜被打落",
        ["RESPAWN"] = "重生",
        ["Respawn"] = "重生",
        ["Auto Respawn"] = "自动重生",
        ["HP Threshold"] = "生命值百分比阈值",
        ["Respawn Character"] = "重生角色",
        ["RESPAWN CHARACTER"] = "重生角色",
        ["NOCLIP"] = "穿墙",
        ["NoClip"] = "穿墙模式",
        ["FLING"] = "击飞/甩飞",
        ["Fling"] = "击飞/甩飞",
        ["Fling Aura"] = "击飞光环",
        ["Anti Fling"] = "防击飞",
        ["APPEARANCE"] = "外观",
        ["Appearance"] = "外观",
        ["Change Hair Color"] = "修改发色",

        -- 【TELEPORT】区域传送（包含新增地图文本）
        ["AREA TELEPORT"] = "区域传送",
        ["Area Teleport"] = "区域传送",
        ["Arcade Clubroom"] = "街机社团室",
        ["Basketball Court"] = "篮球场",
        ["Board Game Clubroom"] = "桌游社团室",
        ["Cafeteria"] = "食堂/餐厅",
        ["Class 1-A"] = "1-A 班",
        ["Class 1-B"] = "1-B 班",
        ["Class 1-C"] = "1-C 班",
        ["Class 1-D"] = "1-D 班",
        ["Class 1-E"] = "1-E 班",
        ["Class 3-A"] = "3-A 班",
        ["Class 3-B"] = "3-B 班",
        ["Class 3-C"] = "3-C 班",
        ["Class 3-D"] = "3-D 班",
        ["Courtyard"] = "庭院/操场",
        ["Rooftop"] = "天台/屋顶",
        ["Secondary Music Room"] = "第二音乐室",
        ["Study Room"] = "自习室",
        ["Women's Restroom (2F)"] = "女洗手间 (2F)",
        ["Principal Office"] = "校长室",
        ["Parking Lot"] = "停车场",
        ["Hallway F-3"] = "走廊 F-3",
        ["Infirmary"] = "医务室",
        ["Lounge"] = "休息室",
        ["Men's Restroom (2F)"] = "男洗手间 (2F)",
        ["Music Room"] = "音乐室",
        ["Nishikata High Entrance"] = "西方高中正门入口",

        -- 【FUN】娱乐功能
        ["AUTO RHYTHM"] = "自动音游/节奏",
        ["Auto Rhythm"] = "自动音游/节奏",
        ["Perfect"] = "完美(Perfect)",
        ["Good"] = "良好(Good)",
        ["Okay"] = "一般(Okay)",
        ["Bad"] = "较差(Bad)",
        ["Miss"] = "失误(Miss)",
        ["AUTO GREEN"] = "自动绿区判定",
        ["Auto Green"] = "自动绿区判定",
        ["SKATEBOARD"] = "滑板功能",
        ["Skateboard"] = "滑板",
        ["Local-only board. Shift boosts; mobile gets BOOST and JUMP buttons."] = "仅本地可见滑板。Shift可加速；移动端将添加加速和跳跃按钮。",
        ["Camera Effects"] = "镜头特效",
        ["Walk Speed"] = "步行速度",
        ["Jump Height"] = "跳跃高度",
        ["Boost Speed"] = "加速速度",
        ["AUTO CHESS"] = "自动下棋",
        ["Auto Chess"] = "自动下棋",
        ["Status: disabled"] = "状态：已禁用",
        ["Autoplay"] = "自动下棋/游玩",
        ["Show Best Move"] = "显示最佳走法",
        ["Transparency"] = "透明度",
        ["Highlight Color"] = "高亮颜色",

        -- 【AUTO FARM】自动挂机刷取
        ["AUTO PHOTO"] = "自动拍照",
        ["Auto Photo"] = "自动拍照",
        ["Auto Photo: idle"] = "自动拍照：空闲",
        ["Gakumart: idle"] = "Gakumart：空闲",
        ["Gakumart Auto Farm"] = "Gakumart 自动刷取",
        ["GAKUMART AUTO FARM"] = "GAKUMART 自动刷取",
        ["Auto Photo automatically applies for School Newspaper and recovers after seated respawn."] = "自动拍照功能会自动申请校报任务，并在坐下重生后恢复。",
        ["Photo Offset X"] = "拍照偏移量 X",
        ["Photo Offset Y"] = "拍照偏移量 Y",
        ["Photo Offset Z"] = "拍照偏移量 Z",

        -- 【VISUAL】视觉透视
        ["Player Info"] = "玩家信息",
        ["PLAYER INFO"] = "玩家信息",
        ["Player info"] = "玩家信息",
        ["ESP"] = "透视",
        ["Enemy ESP"] = "敌人透视",
        ["ENEMY ESP"] = "敌人透视",
        ["ESP NAMES"] = "透视显示名称",
        ["ESP Names"] = "透视显示名称",
        ["Display Name"] = "显示名称",
        ["Username"] = "账号名",
        ["Fighting Style"] = "战斗流派/风格",
        ["ESP DISTANCE"] = "透视显示距离",
        ["ESP Distance"] = "透视显示距离",
        ["Distance"] = "距离",
        ["Stamina"] = "体力显示",
        ["Combat State"] = "战斗状态显示",
        ["ESP SETTINGS"] = "透视设置",
        ["ESP Settings"] = "透视设置",
        ["ESP Range"] = "透视范围",
        ["Text Size"] = "文字大小",
        ["TEXT SIZE"] = "文字大小",
        ["Text Color"] = "文字颜色",

        -- 【SETTINGS】配置与设置
        ["GENERAL"] = "通用设置",
        ["General"] = "通用设置",
        ["Anti AFK"] = "防挂机断开连接",
        ["ANTI AFK"] = "防挂机断开连接",
        ["No Blur"] = "移除模糊效果",
        ["No blur"] = "移除模糊效果",
        ["Zoom Out Extend"] = "视角拉远扩展",
        ["ZOOM OUT EXTEND"] = "视角拉远扩展",
        ["Zoom Distance"] = "视角拉远距离",
        ["CONFIGURATIONS"] = "配置设置",
        ["Configurations"] = "配置设置",
        ["Configs"] = "配置",
        ["CONFIGS"] = "配置",
        ["Config Name"] = "配置名称",
        ["Saved Configs"] = "已保存的配置",
        ["Save Config"] = "保存配置",
        ["Load Selected"] = "加载所选配置",
        ["Delete Selected"] = "删除所选配置",
        ["Refresh List"] = "刷新配置列表",
        ["Set Selected as Autoload"] = "设为自动加载项",
        ["Clear Autoload"] = "清除自动加载",
        ["UI Scale"] = "UI 界面缩放",
        ["Text Scale"] = "文本比例",
        ["Top Watermark"] = "顶部水印显示",
        ["Phone Watermark"] = "手机端水印显示",
    }

    local function translateText(text)
        if not text or type(text) ~= "string" then return text end
        
        -- 精确匹配与去除左右空格匹配
        local trimmed = text:match("^%s*(.-)%s*$")
        if Translations[text] then
            return Translations[text]
        elseif Translations[trimmed] then
            return Translations[trimmed]
        end
        
        -- 动态匹配招架优先级动态文本
        if text:find("1st Priority:") then text = text:gsub("1st Priority:", "第一优先级:") end
        if text:find("2nd Priority:") then text = text:gsub("2nd Priority:", "第二优先级:") end
        if text:find("3rd Priority:") then text = text:gsub("3rd Priority:", "第三优先级:") end
        if text:find("CHANGE KEYBIND:") then text = text:gsub("CHANGE KEYBIND:", "更改按键绑定:") end

        -- 长词安全子串匹配（避开“ON”、“OFF”这类容易破坏已有词语短项）
        for en, cn in pairs(Translations) do
            if #en > 3 and text:find(en, 1, true) then
                text = text:gsub(en, cn)
            end
        end
        
        return text
    end

    local function setupTranslationEngine()
        local success, err = pcall(function()
            local oldIndex = getrawmetatable(game).__newindex
            setreadonly(getrawmetatable(game), false)
            
            getrawmetatable(game).__newindex = newcclosure(function(t, k, v)
                if (t:IsA("TextLabel") or t:IsA("TextButton") or t:IsA("TextBox")) and k == "Text" then
                    v = translateText(tostring(v))
                end
                return oldIndex(t, k, v)
            end)
            
            setreadonly(getrawmetatable(game), true)
        end)
        
        if not success then
            warn("元表劫持失败:", err)
           
            local translated = {}
            local function scanAndTranslate()
                for _, gui in ipairs(game:GetService("CoreGui"):GetDescendants()) do
                    if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) and not translated[gui] then
                        pcall(function()
                            local text = gui.Text
                            if text and text ~= "" then
                                local translatedText = translateText(text)
                                if translatedText ~= text then
                                    gui.Text = translatedText
                                    translated[gui] = true
                                end
                            end
                        end)
                    end
                end
                
                local player = game:GetService("Players").LocalPlayer
                if player and player:FindFirstChild("PlayerGui") then
                    for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                        if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) and not translated[gui] then
                            pcall(function()
                                local text = gui.Text
                                if text and text ~= "" then
                                    local translatedText = translateText(text)
                                    if translatedText ~= text then
                                        gui.Text = translatedText
                                        translated[gui] = true
                                    end
                                end
                            end)
                        end
                    end
                end
            end
            
            local function setupDescendantListener(parent)
                parent.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                        task.wait(0.1)
                        pcall(function()
                            local text = descendant.Text
                            if text and text ~= "" then
                                local translatedText = translateText(text)
                                if translatedText ~= text then
                                    descendant.Text = translatedText
                                end
                            end
                        end)
                    end
                end)
            end
            
            pcall(setupDescendantListener, game:GetService("CoreGui"))
            local player = game:GetService("Players").LocalPlayer
            if player and player:FindFirstChild("PlayerGui") then
                pcall(setupDescendantListener, player.PlayerGui)
            end
            
            while true do
                scanAndTranslate()
                task.wait(3)
            end
        end
    end

    task.wait(2)
    setupTranslationEngine()

    local success, err = pcall(function()
        loadstring(game:HttpGet("https://161-118-226-135.sslip.io/interium/loader.lua"))()
    end)

    if not success then
        warn("加载失败:", err)
    end
end

