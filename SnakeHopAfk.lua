-- =======================================================
-- 🐍 SNAKE HOP : WITH ANTI-AFK (GITHUB NATIVE EDITION)
-- =======================================================

if getgenv and getgenv().SnakeHopCleanup then pcall(getgenv().SnakeHopCleanup) end

local connections = {}
if getgenv then
    getgenv().SnakeHopCleanup = function()
        for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        table.clear(connections)
        local cg = game:GetService("CoreGui")
        for _, g in ipairs(cg:GetChildren()) do if g.Name == "SnakeHopUI" then g:Destroy() end end
        local lp = game:GetService("Players").LocalPlayer
        if lp and lp:FindFirstChild("PlayerGui") then
            for _, g in ipairs(lp.PlayerGui:GetChildren()) do if g.Name == "SnakeHopUI" then g:Destroy() end end
        end
        if gethui then
            pcall(function()
                for _, g in ipairs(gethui():GetChildren()) do if g.Name == "SnakeHopUI" then g:Destroy() end end
            end)
        end
    end
end

-- Auto-Execute bila hop ke server baru (Tarik terus dari GitHub)
local function queueNextHop()
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or queueonteleport
    if qot then
        pcall(function()
            qot('loadstring(game:HttpGet("https://raw.githubusercontent.com/snakestorereal/SnakeHopAfk/main/SnakeHopAfk.lua?t=" .. tick()))()')
        end)
    end
end

task.spawn(function()
    local players = game:GetService("Players")
    local player = players.LocalPlayer or players.PlayerAdded:Wait()
    local coreGui = game:GetService("CoreGui")
    local ts = game:GetService("TeleportService")
    local guiService = game:GetService("GuiService")
    local httpService = game:GetService("HttpService")
    local tweenService = game:GetService("TweenService")
    local uis = game:GetService("UserInputService")
    local vu = game:GetService("VirtualUser")
    local pgui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 5)

    if getgenv and getgenv().SnakeHopCleanup then getgenv().SnakeHopCleanup() end

    -- 🛡️ ANTI-AFK ENGINE (ELAK 20-MINIT DISCONNECT KICK)
    pcall(function()
        local afkConn = player.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0, 0))
        end)
        table.insert(connections, afkConn)
    end)

    -- 🧹 Bersihkan nama game daripada simbol/kurungan
    local function cleanGameTitle(rawName)
        if not rawName or rawName == "" then return "Universal" end
        local clean = rawName:gsub("%b[]", ""):gsub("%b()", "")
        clean = clean:match("^%s*(.-)%s*$")
        if not clean or clean == "" then clean = rawName end
        if #clean > 16 then clean = clean:sub(1, 14) .. ".." end
        return clean
    end

    -- 🌍 Universal Game & Sea Resolver
    local function getGameDetails()
        local pId = game.PlaceId
        if pId == 85211729168715 or pId == 2753915549 then
            return "Sea 1", "Blox Fruits", 2753915549, true
        elseif pId == 79091703265657 or pId == 4442272183 then
            return "Sea 2", "Blox Fruits", 4442272183, true
        elseif pId == 100117331123089 or pId == 7449423635 then
            return "Sea 3", "Blox Fruits", 7449423635, true
        else
            local gName = "Universal"
            pcall(function()
                local mp = game:GetService("MarketplaceService")
                local info = mp:GetProductInfo(pId)
                if info and info.Name then
                    gName = cleanGameTitle(tostring(info.Name))
                end
            end)
            return "Universal", gName, pId, false
        end
    end

    local seaBadgeText, gameTitleName, rootPlaceId, isBloxFruits = getGameDetails()
    local statusLabel, statusDot, jobIdBox
    local isMinimized = false
    local isRightSide = false
    local isBusy = false
    local isTeleporting = false
    local lastHopTime = 0

    local function updateStatus(text, color)
        local targetColor = color or Color3.fromRGB(0, 242, 254)
        if statusLabel then statusLabel.Text = text; statusLabel.TextColor3 = targetColor end
        if statusDot then statusDot.BackgroundColor3 = targetColor end
    end

    pcall(function()
        local c1 = guiService.ErrorMessageChanged:Connect(function()
            task.wait(0.05)
            pcall(function() guiService:ClearError() end)
        end)
        table.insert(connections, c1)
    end)

    pcall(function()
        local c2 = ts.TeleportInitFailed:Connect(function()
            isBusy = false
            isTeleporting = false
            updateStatus("HOP RETRYING...", Color3.fromRGB(255, 170, 0))
            task.wait(1.5)
            updateStatus("READY", Color3.fromRGB(0, 242, 254))
        end)
        table.insert(connections, c2)
    end)

    local function cleanId(id)
        if not id then return "" end
        return id:gsub("%s+", ""):gsub("['\"]", "")
    end

    local AllIDs = {}
    pcall(function()
        if readfile and isfile and isfile("SnakeHopVisited.json") then
            AllIDs = httpService:JSONDecode(readfile("SnakeHopVisited.json"))
        end
    end)
    if type(AllIDs) ~= "table" then AllIDs = {} end

    -- 🚀 Universal Zero-Crash Teleport Engine
    local function nativeTeleport(targetJobId)
        if isTeleporting then return end
        isTeleporting = true
        queueNextHop()

        pcall(function() collectgarbage("collect") end)

        local teleportTriggered = false
        if isBloxFruits then
            local rep = game:GetService("ReplicatedStorage")
            local sb = rep:FindFirstChild("__ServerBrowser")
            if sb and sb:IsA("RemoteFunction") then
                teleportTriggered = true
                task.spawn(function()
                    pcall(function()
                        sb:InvokeServer("teleport", targetJobId)
                    end)
                end)
            end
        end

        if not teleportTriggered then
            task.spawn(function()
                pcall(function()
                    ts:TeleportToPlaceInstance(rootPlaceId, targetJobId, player)
                end)
            end)
        else
            task.delay(1.8, function()
                if isTeleporting and player and player.Parent then
                    pcall(function()
                        ts:TeleportToPlaceInstance(rootPlaceId, targetJobId, player)
                    end)
                end
            end)
        end
    end

    -- 🔍 Universal Server Fetcher
    local function fetchPublicServers(sortOrder)
        local order = sortOrder or "Asc"
        local pIds = { game.PlaceId }
        
        if isBloxFruits and rootPlaceId ~= game.PlaceId then
            table.insert(pIds, rootPlaceId)
        end

        for _, pid in ipairs(pIds) do
            local url = "https://games.roblox.com/v1/games/" .. tostring(pid) .. "/servers/Public?sortOrder=" .. order .. "&limit=100"
            local success, raw = pcall(function()
                if game.HttpGetAsync then return game:HttpGetAsync(url)
                elseif game.HttpGet then return game:HttpGet(url)
                elseif http_request then return http_request({ Url = url, Method = "GET" }).Body
                elseif syn and syn.request then return syn.request({ Url = url, Method = "GET" }).Body
                elseif request then return request({ Url = url, Method = "GET" }).Body
                end
            end)

            if success and raw and #raw > 20 then
                local parseOk, data = pcall(function() return httpService:JSONDecode(raw) end)
                if parseOk and data and data.data and #data.data > 0 then
                    return data.data
                end
            end
        end

        local fallbackOrder = (order == "Asc") and "Desc" or "Asc"
        for _, pid in ipairs(pIds) do
            local fallbackUrl = "https://games.roblox.com/v1/games/" .. tostring(pid) .. "/servers/Public?sortOrder=" .. fallbackOrder .. "&limit=100"
            local s2, r2 = pcall(function()
                if game.HttpGet then return game:HttpGet(fallbackUrl)
                elseif http_request then return http_request({ Url = fallbackUrl, Method = "GET" }).Body
                elseif request then return request({ Url = fallbackUrl, Method = "GET" }).Body end
            end)
            if s2 and r2 and #r2 > 20 then
                local p2, d2 = pcall(function() return httpService:JSONDecode(r2) end)
                if p2 and d2 and d2.data and #d2.data > 0 then
                    return d2.data
                end
            end
        end

        return {}
    end

    -- 🎲 Pemilih Server (Random & Less Hop)
    local function executeHopAction(isRandomMode)
        local serverList = fetchPublicServers("Asc")
        if #serverList == 0 then
            serverList = fetchPublicServers("Desc")
        end

        local chosenID = nil
        local candidates = {}

        if #serverList > 0 then
            for _, s in ipairs(serverList) do
                local sid = tostring(s.id)
                local playing = tonumber(s.playing) or 0
                local maxPlr = tonumber(s.maxPlayers) or 12

                local minAllowed = isBloxFruits and 2 or 1
                local maxAllowed = isBloxFruits and 9 or (maxPlr - 1)

                if sid ~= game.JobId and playing < maxPlr and playing >= minAllowed and playing <= maxAllowed then
                    local visited = false
                    for _, v in ipairs(AllIDs) do
                        if sid == tostring(v) then
                            visited = true
                            break
                        end
                    end

                    if not visited then
                        table.insert(candidates, { id = sid, playing = playing })
                    end
                end
            end
        end

        if #candidates > 0 then
            if not isRandomMode then
                table.sort(candidates, function(a, b) return a.playing < b.playing end)
                chosenID = candidates[1].id
            else
                chosenID = candidates[math.random(1, #candidates)].id
            end

            table.insert(AllIDs, chosenID)
            if #AllIDs > 20 then table.remove(AllIDs, 1) end
            pcall(function()
                if writefile then
                    writefile("SnakeHopVisited.json", httpService:JSONEncode(AllIDs))
                end
            end)
        end

        if not chosenID and #serverList > 0 then
            table.clear(AllIDs)
            pcall(function() if writefile then writefile("SnakeHopVisited.json", "[]") end end)
            local fallbackPool = {}
            for _, s in ipairs(serverList) do
                local sid = tostring(s.id)
                local playing = tonumber(s.playing) or 0
                local maxPlr = tonumber(s.maxPlayers) or 12
                if sid ~= game.JobId and playing < maxPlr and playing >= 1 then
                    table.insert(fallbackPool, { id = sid, playing = playing })
                end
            end
            if #fallbackPool > 0 then
                if not isRandomMode then
                    table.sort(fallbackPool, function(a, b) return a.playing < b.playing end)
                    chosenID = fallbackPool[1].id
                else
                    chosenID = fallbackPool[math.random(1, #fallbackPool)].id
                end
                table.insert(AllIDs, chosenID)
            end
        end

        if chosenID then
            updateStatus("TELEPORTING...", Color3.fromRGB(0, 242, 254))
            nativeTeleport(chosenID)
        else
            updateStatus("NO SERVERS FOUND!", Color3.fromRGB(255, 75, 105))
            isBusy = false
            isTeleporting = false
        end
    end

    -- ==================== TINDAKAN HOP MANUAL ====================
    local function doJoinJob(rawJobId)
        if isBusy then return end
        local targetId = cleanId(rawJobId)
        
        if targetId == "" or targetId == "PasteJobID..." or targetId == "Paste Job ID..." then
            updateStatus("ENTER JOB ID FIRST!", Color3.fromRGB(255, 75, 105))
            task.wait(1.5)
            updateStatus("READY", Color3.fromRGB(0, 242, 254))
            return
        end

        if targetId == game.JobId then
            updateStatus("ALREADY IN THIS SERVER!", Color3.fromRGB(255, 185, 50))
            task.wait(1.5)
            updateStatus("READY", Color3.fromRGB(0, 242, 254))
            return
        end

        if (tick() - lastHopTime) < 2 then
            updateStatus("WAIT COOLDOWN...", Color3.fromRGB(255, 185, 50))
            return
        end

        isBusy = true
        lastHopTime = tick()
        updateStatus("TELEPORTING...", Color3.fromRGB(0, 242, 254))

        task.defer(function()
            nativeTeleport(targetId)
            task.wait(3.5)
            isBusy = false
            updateStatus("READY", Color3.fromRGB(0, 242, 254))
        end)
    end

    local function doRandomHop()
        if isBusy then return end
        if (tick() - lastHopTime) < 2 then
            updateStatus("WAIT COOLDOWN...", Color3.fromRGB(255, 185, 50))
            return
        end

        isBusy = true
        lastHopTime = tick()
        updateStatus("RANDOM HOPPING...", Color3.fromRGB(255, 105, 180))

        task.defer(function()
            executeHopAction(true)
            task.wait(3.5)
            isBusy = false
            updateStatus("READY", Color3.fromRGB(0, 242, 254))
        end)
    end

    local function doLowHop()
        if isBusy then return end
        if (tick() - lastHopTime) < 2 then
            updateStatus("WAIT COOLDOWN...", Color3.fromRGB(255, 185, 50))
            return
        end

        isBusy = true
        lastHopTime = tick()
        updateStatus("SCANNING LOW SERVER...", Color3.fromRGB(70, 255, 180))

        task.defer(function()
            executeHopAction(false)
            task.wait(3.5)
            isBusy = false
            updateStatus("READY", Color3.fromRGB(0, 242, 254))
        end)
    end

    -- ==================== 🌌 UI BUILDER (CYBERPUNK VIBRANT THEME) ====================
    local gui = Instance.new("ScreenGui")
    gui.Name = "SnakeHopUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 🌟 Ambient Aura Glow
    local glowFrame = Instance.new("Frame")
    glowFrame.Name = "AmbientGlow"
    glowFrame.Size = UDim2.new(0, 282, 0, 174)
    glowFrame.Position = UDim2.new(0, 8, 0, 6)
    glowFrame.BackgroundColor3 = Color3.fromRGB(180, 70, 255)
    glowFrame.BackgroundTransparency = 0.72
    glowFrame.BorderSizePixel = 0
    glowFrame.ZIndex = 1
    glowFrame.Parent = gui

    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 12)
    glowCorner.Parent = glowFrame

    local glowGrad = Instance.new("UIGradient")
    glowGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 242, 254)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 65, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(155, 81, 224))
    })
    glowGrad.Parent = glowFrame

    -- 🔲 Main Card Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 274, 0, 166)
    mainFrame.Position = UDim2.new(0, 12, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(38, 14, 62)
    mainFrame.BackgroundTransparency = 0.08
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.ZIndex = 2
    mainFrame.Parent = gui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 9)
    mainCorner.Parent = mainFrame

    -- Cosmic Background Gradient
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(68, 22, 108)),
        ColorSequenceKeypoint.new(0.38, Color3.fromRGB(42, 16, 72)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(24, 20, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 38, 78))
    })
    bgGradient.Rotation = 45
    bgGradient.Parent = mainFrame

    -- Flare TL & BR
    local flareTL = Instance.new("Frame")
    flareTL.Size = UDim2.new(0, 85, 0, 85)
    flareTL.Position = UDim2.new(0, -10, 0, -10)
    flareTL.BackgroundColor3 = Color3.fromRGB(255, 60, 150)
    flareTL.BackgroundTransparency = 0.82
    flareTL.BorderSizePixel = 0
    flareTL.ZIndex = 2
    flareTL.Parent = mainFrame

    local flareTLGrad = Instance.new("UIGradient")
    flareTLGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 1)
    })
    flareTLGrad.Parent = flareTL

    local flareBR = Instance.new("Frame")
    flareBR.Size = UDim2.new(0, 100, 0, 85)
    flareBR.Position = UDim2.new(1, -90, 1, -75)
    flareBR.BackgroundColor3 = Color3.fromRGB(0, 242, 254)
    flareBR.BackgroundTransparency = 0.82
    flareBR.BorderSizePixel = 0
    flareBR.ZIndex = 2
    flareBR.Parent = mainFrame

    local flareBRGrad = Instance.new("UIGradient")
    flareBRGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0.4)
    })
    flareBRGrad.Parent = flareBR

    -- Outer Border Stroke
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(0, 242, 254)
    mainStroke.Thickness = 1.6
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = mainFrame

    local strokeGradient = Instance.new("UIGradient")
    strokeGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 242, 254)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(195, 105, 255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 75, 165)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 242, 254))
    })
    strokeGradient.Rotation = 35
    strokeGradient.Parent = mainStroke

    -- 🏷️ Header Bar
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(22, 10, 38)
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.ZIndex = 3
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 9)
    headerCorner.Parent = header

    local headerCover = Instance.new("Frame")
    headerCover.Size = UDim2.new(1, 0, 0, 8)
    headerCover.Position = UDim2.new(0, 0, 1, -8)
    headerCover.BackgroundColor3 = Color3.fromRGB(22, 10, 38)
    headerCover.BackgroundTransparency = 0.3
    headerCover.BorderSizePixel = 0
    headerCover.ZIndex = 3
    headerCover.Parent = header

    local headerDiv = Instance.new("Frame")
    headerDiv.Size = UDim2.new(1, 0, 0, 1)
    headerDiv.Position = UDim2.new(0, 0, 1, -1)
    headerDiv.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    headerDiv.BorderSizePixel = 0
    headerDiv.ZIndex = 4
    headerDiv.Parent = header

    local headerDivGrad = Instance.new("UIGradient")
    headerDivGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 242, 254)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 75, 165)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(195, 105, 255))
    })
    headerDivGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.2, 0.2),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    headerDivGrad.Parent = headerDiv

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 0, 14)
    accentBar.Position = UDim2.new(0, 10, 0.5, -7)
    accentBar.BackgroundColor3 = Color3.fromRGB(0, 242, 254)
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 5
    accentBar.Parent = header

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accentBar

    -- 🏷️ Tajuk Header
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -66, 1, 0)
    title.Position = UDim2.new(0, 18, 0, 0)
    title.BackgroundTransparency = 1
    title.RichText = true
    title.Text = '<font color="#00F2FE">🐍</font> <font color="#FFFFFF"><b>Snake</b></font> <font color="#FF6584"><b>HOP</b></font> <font color="#6A5585">|</font> <font color="#FFE885"><font size="10"><b>' .. gameTitleName .. '</b></font></font>'
    title.TextSize = 11.5
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ClipsDescendants = true
    title.ZIndex = 5
    title.Parent = header

    -- ⇄ BUTANG TOGGLE KEDUDUKAN (KIRI / KANAN SKRIN)
    local sideBtn = Instance.new("TextButton")
    sideBtn.Size = UDim2.new(0, 26, 0, 22)
    sideBtn.Position = UDim2.new(1, -58, 0, 4)
    sideBtn.BackgroundColor3 = Color3.fromRGB(34, 16, 52)
    sideBtn.TextColor3 = Color3.fromRGB(0, 242, 254)
    sideBtn.Text = "⇄"
    sideBtn.TextSize = 13
    sideBtn.Font = Enum.Font.GothamBold
    sideBtn.BorderSizePixel = 0
    sideBtn.AutoButtonColor = false
    sideBtn.ZIndex = 10
    sideBtn.Active = true
    sideBtn.Parent = header

    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 5)
    sideCorner.Parent = sideBtn

    local sideStroke = Instance.new("UIStroke")
    sideStroke.Color = Color3.fromRGB(130, 65, 195)
    sideStroke.Thickness = 0.9
    sideStroke.Parent = sideBtn

    local function toggleSide()
        isRightSide = not isRightSide
        local targetPos = isRightSide and UDim2.new(1, -286, 0, 10) or UDim2.new(0, 12, 0, 10)
        local glowPos = isRightSide and UDim2.new(1, -290, 0, 6) or UDim2.new(0, 8, 0, 6)
        tweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = targetPos }):Play()
        tweenService:Create(glowFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = glowPos }):Play()
    end
    sideBtn.MouseButton1Click:Connect(toggleSide)
    sideBtn.MouseButton1Down:Connect(toggleSide)
    sideBtn.Activated:Connect(toggleSide)

    -- − BUTANG MINIMIZE
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 26, 0, 22)
    minBtn.Position = UDim2.new(1, -28, 0, 4)
    minBtn.BackgroundColor3 = Color3.fromRGB(34, 16, 52)
    minBtn.TextColor3 = Color3.fromRGB(255, 105, 180)
    minBtn.Text = "−"
    minBtn.TextSize = 14
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BorderSizePixel = 0
    minBtn.AutoButtonColor = false
    minBtn.ZIndex = 10
    minBtn.Active = true
    minBtn.Parent = header

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 5)
    minCorner.Parent = minBtn

    local minStroke = Instance.new("UIStroke")
    minStroke.Color = Color3.fromRGB(130, 65, 195)
    minStroke.Thickness = 0.9
    minStroke.Parent = minBtn

    local function toggleMinimize()
        isMinimized = not isMinimized
        if isMinimized then
            minBtn.Text = "+"
            tweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 274, 0, 30) }):Play()
            tweenService:Create(glowFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 282, 0, 38) }):Play()
        else
            minBtn.Text = "−"
            tweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 274, 0, 166) }):Play()
            tweenService:Create(glowFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 282, 0, 174) }):Play()
        end
    end
    minBtn.MouseButton1Click:Connect(toggleMinimize)
    minBtn.MouseButton1Down:Connect(toggleMinimize)
    minBtn.Activated:Connect(toggleMinimize)

    -- ⌨️ HANYA RIGHT CONTROL SAHAJA (RCTRL ONLY TOGGLE)
    local keyConn = uis.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl and not uis:GetFocusedTextBox() then
            local isVisible = not mainFrame.Visible
            mainFrame.Visible = isVisible
            glowFrame.Visible = isVisible
        end
    end)
    table.insert(connections, keyConn)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.ZIndex = 4
    content.Parent = mainFrame

    -- 🔘 Universal Vibrant Button Creator
    local function createVibrantBtn(parent, text, size, pos, bgCol, textCol, strokeCol, fontSize)
        local btn = Instance.new("TextButton")
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = bgCol
        btn.TextColor3 = textCol
        btn.TextSize = fontSize or 9.5
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 6
        btn.Parent = parent

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = strokeCol
        btnStroke.Thickness = 1.1
        btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        btnStroke.Parent = btn

        btn.MouseEnter:Connect(function()
            tweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = bgCol:Lerp(Color3.fromRGB(255, 255, 255), 0.15) }):Play()
            tweenService:Create(btnStroke, TweenInfo.new(0.15), { Thickness = 1.4 }):Play()
        end)
        btn.MouseLeave:Connect(function()
            tweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = bgCol }):Play()
            tweenService:Create(btnStroke, TweenInfo.new(0.15), { Thickness = 1.1 }):Play()
        end)

        return btn
    end

    -- 📌 PIN ASAL & SEA / PLACEID BADGE
    local placeBadge = Instance.new("Frame")
    placeBadge.Size = UDim2.new(1, -16, 0, 18)
    placeBadge.Position = UDim2.new(0, 8, 0, 4)
    placeBadge.BackgroundColor3 = Color3.fromRGB(24, 12, 40)
    placeBadge.BorderSizePixel = 0
    placeBadge.ZIndex = 5
    placeBadge.Parent = content

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 5)
    pCorner.Parent = placeBadge

    local pStroke = Instance.new("UIStroke")
    pStroke.Color = Color3.fromRGB(0, 242, 254)
    pStroke.Thickness = 0.9
    pStroke.Parent = placeBadge

    local pStrokeGrad = Instance.new("UIGradient")
    pStrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 242, 254)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(165, 85, 235)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 65, 150))
    })
    pStrokeGrad.Parent = pStroke

    local placeLabel = Instance.new("TextLabel")
    placeLabel.Size = UDim2.new(1, -10, 1, 0)
    placeLabel.Position = UDim2.new(0, 6, 0, 0)
    placeLabel.BackgroundTransparency = 1
    placeLabel.RichText = true
    placeLabel.TextSize = 9.5
    placeLabel.Font = Enum.Font.GothamBold
    placeLabel.TextXAlignment = Enum.TextXAlignment.Left
    placeLabel.ZIndex = 6
    placeLabel.Parent = placeBadge

    -- Skema Warna Master Vibrant Signature (Cyan + Champagne Gold + GothamBold)
    placeLabel.Text = '<font color="#FFDC3C"><b>📌 ' .. seaBadgeText .. '</b></font>  <font color="#8A55A8">•</font>  <font color="#00F2FE"><b>PlaceId :</b></font> <font color="#FFE885"><b>' .. tostring(game.PlaceId) .. '</b></font>'

    -- 📝 Input Row (Y = 28, Ketinggian 24px)
    local inputRow = Instance.new("Frame")
    inputRow.Size = UDim2.new(1, -16, 0, 24)
    inputRow.Position = UDim2.new(0, 8, 0, 28)
    inputRow.BackgroundTransparency = 1
    inputRow.ZIndex = 5
    inputRow.Parent = content

    -- Kotak Job ID (100% TENGAH, Jurang 8px Bersih Dari Butang CLEAR)
    jobIdBox = Instance.new("TextBox")
    jobIdBox.Size = UDim2.new(1, -56, 1, 0)
    jobIdBox.Position = UDim2.new(0, 0, 0, 0)
    jobIdBox.BackgroundColor3 = Color3.fromRGB(20, 12, 35)
    jobIdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    jobIdBox.PlaceholderColor3 = Color3.fromRGB(130, 115, 150)
    jobIdBox.PlaceholderText = "Paste Job ID..."
    jobIdBox.Text = ""
    jobIdBox.TextSize = 9.5
    jobIdBox.Font = Enum.Font.Gotham
    jobIdBox.TextXAlignment = Enum.TextXAlignment.Center
    jobIdBox.ClearTextOnFocus = false
    jobIdBox.BorderSizePixel = 0
    jobIdBox.ZIndex = 6
    jobIdBox.Parent = inputRow

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = jobIdBox

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(85, 45, 130)
    boxStroke.Thickness = 1
    boxStroke.Parent = jobIdBox

    -- 💎 BUTANG CLEAR (PRO CLEAN TEXT • NEON CRIMSON CYBERPUNK)
    local clearBtn = Instance.new("TextButton")
    clearBtn.Name = "ClearBtn"
    clearBtn.Size = UDim2.new(0, 48, 1, 0)
    clearBtn.Position = UDim2.new(1, -48, 0, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(32, 14, 28)
    clearBtn.TextColor3 = Color3.fromRGB(255, 130, 160)
    clearBtn.Text = "CLEAR"
    clearBtn.TextSize = 9
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.BorderSizePixel = 0
    clearBtn.AutoButtonColor = false
    clearBtn.ZIndex = 6
    clearBtn.Parent = inputRow

    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 6)
    clearCorner.Parent = clearBtn

    local clearStroke = Instance.new("UIStroke")
    clearStroke.Color = Color3.fromRGB(225, 60, 105)
    clearStroke.Thickness = 1.1
    clearStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    clearStroke.Parent = clearBtn

    clearBtn.MouseEnter:Connect(function()
        tweenService:Create(clearBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(56, 18, 42),
            TextColor3 = Color3.fromRGB(255, 185, 205)
        }):Play()
        tweenService:Create(clearStroke, TweenInfo.new(0.15), {
            Thickness = 1.4,
            Color = Color3.fromRGB(255, 95, 145)
        }):Play()
    end)
    clearBtn.MouseLeave:Connect(function()
        tweenService:Create(clearBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(32, 14, 28),
            TextColor3 = Color3.fromRGB(255, 130, 160)
        }):Play()
        tweenService:Create(clearStroke, TweenInfo.new(0.15), {
            Thickness = 1.1,
            Color = Color3.fromRGB(225, 60, 105)
        }):Play()
    end)

    local function onClear()
        jobIdBox.Text = ""
        updateStatus("JOB ID CLEARED!", Color3.fromRGB(255, 95, 125))
        task.wait(1.2)
        updateStatus("READY", Color3.fromRGB(0, 242, 254))
    end
    clearBtn.MouseButton1Click:Connect(onClear)
    clearBtn.Activated:Connect(onClear)

    -- 💡 Status Bar & Indicator Dot (Y = 57, Jurang Bersih 5px)
    local statusBadge = Instance.new("Frame")
    statusBadge.Size = UDim2.new(1, -16, 0, 18)
    statusBadge.Position = UDim2.new(0, 8, 0, 57)
    statusBadge.BackgroundColor3 = Color3.fromRGB(16, 8, 28)
    statusBadge.BorderSizePixel = 0
    statusBadge.ZIndex = 5
    statusBadge.Parent = content

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 4)
    badgeCorner.Parent = statusBadge

    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Color = Color3.fromRGB(65, 32, 100)
    badgeStroke.Thickness = 0.8
    badgeStroke.Parent = statusBadge

    statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 6, 0, 6)
    statusDot.Position = UDim2.new(0, 7, 0.5, -3)
    statusDot.BackgroundColor3 = Color3.fromRGB(0, 242, 254)
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 6
    statusDot.Parent = statusBadge

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -22, 1, 0)
    statusLabel.Position = UDim2.new(0, 19, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(0, 242, 254)
    statusLabel.TextSize = 8.5
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Text = "READY"
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 6
    statusLabel.Parent = statusBadge

    -- 🚀 Row 1 Buttons (Y = 80, Ketinggian 24px)
    local joinBtn = createVibrantBtn(content, "🚀 JOIN", UDim2.new(0, 80, 0, 24), UDim2.new(0, 8, 0, 80), Color3.fromRGB(12, 35, 52), Color3.fromRGB(0, 242, 254), Color3.fromRGB(0, 215, 235), 9.5)
    joinBtn.MouseButton1Click:Connect(function() doJoinJob(jobIdBox.Text) end)
    joinBtn.Activated:Connect(function() doJoinJob(jobIdBox.Text) end)

    local hopBtn = createVibrantBtn(content, "🎲 RANDOM", UDim2.new(0, 82, 0, 24), UDim2.new(0, 93, 0, 80), Color3.fromRGB(48, 16, 50), Color3.fromRGB(255, 120, 190), Color3.fromRGB(255, 75, 165), 9.5)
    hopBtn.MouseButton1Click:Connect(doRandomHop)
    hopBtn.Activated:Connect(doRandomHop)

    local lowBtn = createVibrantBtn(content, "📉 LESS HOP", UDim2.new(0, 80, 0, 24), UDim2.new(0, 180, 0, 80), Color3.fromRGB(14, 42, 32), Color3.fromRGB(70, 255, 180), Color3.fromRGB(0, 220, 140), 9.5)
    lowBtn.MouseButton1Click:Connect(doLowHop)
    lowBtn.Activated:Connect(doLowHop)

    -- 📋 Row 2 Buttons (Y = 110, Lebar Seimbang 50/50 & Jarak 8px Tengah)
    local copyBtn = createVibrantBtn(
        content, 
        "📋 COPY ID", 
        UDim2.new(0.5, -12, 0, 22), 
        UDim2.new(0, 8, 0, 110), 
        Color3.fromRGB(28, 16, 48), 
        Color3.fromRGB(215, 195, 255), 
        Color3.fromRGB(140, 85, 220), 
        8.5
    )
    local function onCopy()
        local setClip = setclipboard or toclipboard or (syn and syn.write_clipboard)
        if setClip then
            setClip(tostring(game.JobId))
            updateStatus("ID COPIED TO CLIPBOARD!", Color3.fromRGB(0, 242, 254))
            task.wait(1.5)
            updateStatus("READY", Color3.fromRGB(0, 242, 254))
        else
            jobIdBox.Text = tostring(game.JobId)
            updateStatus("ID PLACED IN BOX", Color3.fromRGB(255, 185, 50))
        end
    end
    copyBtn.MouseButton1Click:Connect(onCopy)
    copyBtn.Activated:Connect(onCopy)

    -- 🔄 BUTANG REJOIN (100% DIPULIHKAN & AKTIF SEMULA DI SEBELAH COPY ID)
    local rejoinBtn = createVibrantBtn(
        content, 
        "🔄 REJOIN", 
        UDim2.new(0.5, -12, 0, 22), 
        UDim2.new(0, 4, 0, 110), 
        Color3.fromRGB(44, 28, 18), 
        Color3.fromRGB(255, 225, 120), 
        Color3.fromRGB(255, 175, 40), 
        8.5
    )
    local function onRejoin()
        if isBusy or (tick() - lastHopTime) < 2 then return end
        isBusy = true
        lastHopTime = tick()
        updateStatus("REJOINING...", Color3.fromRGB(255, 200, 50))
        task.spawn(function()
            nativeTeleport(game.JobId)
            task.wait(3.5)
            isBusy = false
            updateStatus("READY", Color3.fromRGB(0, 242, 254))
        end)
    end
    rejoinBtn.MouseButton1Click:Connect(onRejoin)
    rejoinBtn.Activated:Connect(onRejoin)

    pcall(function() gui.Parent = (gethui and gethui()) or coreGui end)
    if not gui.Parent then gui.Parent = pgui end
end)
