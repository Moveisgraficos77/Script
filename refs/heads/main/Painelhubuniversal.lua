local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeamsService = game:GetService("Teams")

local function getLocalPlayer()
    local player = Players.LocalPlayer
    if player then
        return player
    end

    local success, result = pcall(function()
        return Players:WaitForChild("LocalPlayer", 10)
    end)

    if success and result then
        return result
    end

    return nil
end

local localPlayer = getLocalPlayer()
if not localPlayer then
    warn("Não foi possível obter o LocalPlayer. O script será encerrado.")
    return
end

repeat task.wait() until game:IsLoaded()

local function waitForCamera()
    local cam = workspace.CurrentCamera
    while not cam do
        task.wait()
        cam = workspace.CurrentCamera
    end
    return cam
end

local camera = waitForCamera()
local playerGui = localPlayer:WaitForChild("PlayerGui", 10)

if playerGui:FindFirstChild("DebugStudioPanel") then
    playerGui.DebugStudioPanel:Destroy()
end

-- =============================================================================
-- CONFIGURAÇÃO DE INTERFACE (UI/UX) OTIMIZADA PARA DELTA EXECUTOR
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DebugStudioPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 380)
MainFrame.Position = UDim2.new(0.5, -230, 0.35, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.45, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "STUDIO DEBUG PANEL"
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(0.4, 0, 1, 0)
PageTitle.Position = UDim2.new(0.5, 0, 0, 0)
PageTitle.Text = "Main"
PageTitle.TextColor3 = Color3.fromRGB(170, 220, 255)
PageTitle.Font = Enum.Font.Gotham
PageTitle.TextSize = 14
PageTitle.TextXAlignment = Enum.TextXAlignment.Center
PageTitle.BackgroundTransparency = 1
PageTitle.Parent = Header

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleBtn.Position = UDim2.new(1, -40, 0, 5)
ToggleBtn.Text = "-"
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = Header

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

local SideMenuFrame = Instance.new("Frame")
SideMenuFrame.Size = UDim2.new(0, 120, 1, -45)
SideMenuFrame.Position = UDim2.new(0, 0, 0, 45)
SideMenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
SideMenuFrame.BorderSizePixel = 0
SideMenuFrame.Parent = MainFrame

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 12)
SidePadding.PaddingLeft = UDim.new(0, 8)
SidePadding.PaddingRight = UDim.new(0, 8)
SidePadding.Parent = SideMenuFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.FillDirection = Enum.FillDirection.Vertical
SideLayout.Padding = UDim.new(0, 8)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = SideMenuFrame

local PagesFrame = Instance.new("Frame")
PagesFrame.Size = UDim2.new(1, -130, 1, -45)
PagesFrame.Position = UDim2.new(0, 130, 0, 45)
PagesFrame.BackgroundTransparency = 1
PagesFrame.Parent = MainFrame

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, 0, 1, 0)
ContentScroll.Position = UDim2.new(0, 0, 0, 0)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 6
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.Parent = PagesFrame

local PageListLayout = Instance.new("UIListLayout")
PageListLayout.Padding = UDim.new(0, 8)
PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PageListLayout.Parent = ContentScroll

local PagePadding = Instance.new("UIPadding")
PagePadding.PaddingTop = UDim.new(0, 12)
PagePadding.PaddingLeft = UDim.new(0, 8)
PagePadding.PaddingRight = UDim.new(0, 8)
PagePadding.PaddingBottom = UDim.new(0, 12)
PagePadding.Parent = ContentScroll

local function UpdateCanvasSize()
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + 12)
end
PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
UpdateCanvasSize()

local isMinimized = false
ToggleBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 460, 0, 40) or UDim2.new(0, 460, 0, 380)
    ToggleBtn.Text = isMinimized and "+" or "-"
    SideMenuFrame.Visible = not isMinimized
    PagesFrame.Visible = not isMinimized
    PageTitle.Visible = not isMinimized
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
end)

local pageButtons = {}
local activePage = "Main"

local function ClearPageContent()
    for _, child in ipairs(ContentScroll:GetChildren()) do
        if child ~= PageListLayout and child ~= PagePadding then
            child:Destroy()
        end
    end
end

local function CreatePageButton(pageName, buttonText)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 34)
    Button.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    Button.BorderSizePixel = 0
    Button.Text = buttonText
    Button.TextColor3 = Color3.fromRGB(220, 220, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 13
    Button.Parent = SideMenuFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        if activePage ~= pageName then
            activePage = pageName
            PageTitle.Text = buttonText
            for name, btn in pairs(pageButtons) do
                btn.BackgroundColor3 = (name == pageName) and Color3.fromRGB(45, 50, 70) or Color3.fromRGB(30, 35, 45)
            end
            if pageBuilders[pageName] then
                pageBuilders[pageName]()
            end
        end
    end)

    pageButtons[pageName] = Button
    return Button
end

local function CreateSectionLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(140, 180, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ContentScroll
    return Label
end

local function CreateActionButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 34)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(240, 240, 240)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 13
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = true
    Button.Parent = ContentScroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = Button

    Button.MouseButton1Click:Connect(callback)
    return Button
end

local function CreateToggleButton(text, initialState, callback)
    local button = CreateActionButton(text .. (initialState and " [ON]" or " [OFF]"), function()
        local newState = callback()
        button.Text = text .. (newState and " [ON]" or " [OFF]")
    end)
    return button
end

local function CreateSlider(text, minValue, maxValue, startValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 70)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentScroll

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 18)
    title.Text = text
    title.TextColor3 = Color3.fromRGB(220, 220, 220)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Gotham
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 18)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.Text = tostring(startValue)
    valueLabel.TextColor3 = Color3.fromRGB(170, 220, 255)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 18)
    sliderTrack.Position = UDim2.new(0, 0, 0, 28)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = frame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 6)
    trackCorner.Parent = sliderTrack

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(90, 160, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fill

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 14, 0, 14)
    handle.Position = UDim2.new(0, -7, 0, 2)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    handle.Parent = sliderTrack

    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 7)
    handleCorner.Parent = handle

    local dragging = false
    local range = maxValue - minValue

    local function setSlider(value)
        value = math.clamp(value, minValue, maxValue)
        local ratio = range > 0 and (value - minValue) / range or 0
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        handle.Position = UDim2.new(ratio, -7, 0, 2)
        valueLabel.Text = tostring(value)
        callback(value)
    end

    local function updateFromInput(inputPosition)
        local trackPos = sliderTrack.AbsolutePosition.X
        local trackSize = sliderTrack.AbsoluteSize.X
        local raw = (inputPosition.X - trackPos) / trackSize
        setSlider(minValue + raw * range)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input.Position)
        end
    end)

    sliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input.Position)
        end
    end)

    task.spawn(function()
        setSlider(startValue)
    end)

    return frame
end

local pageBuilders = {}

local godModeEnabled = false
local aimbotEnabled = false
local killAuraEnabled = false
local killAuraRadius = 35
local aimbotFov = 45
local playerSpeed = 16
local playerJump = 50
local noclipEnabled = false
local ghostEnabled = false

local aimbotConnection = nil
local killAuraConnection = nil
local godModeConnection = nil
local noclipStateCache = {}

local function GetLocalHumanoid()
    local character = localPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function ApplyPlayerMovement()
    local humanoid = GetLocalHumanoid()
    if not humanoid then
        return
    end

    humanoid.WalkSpeed = playerSpeed
    humanoid.JumpPower = playerJump
end

local function ApplyGodMode()
    local humanoid = GetLocalHumanoid()
    if not humanoid then
        return
    end

    if godModeEnabled then
        humanoid.MaxHealth = 9e8
        humanoid.Health = humanoid.MaxHealth
    else
        humanoid.MaxHealth = humanoid.MaxHealth < 100 and 100 or humanoid.MaxHealth
    end
end

local function ApplyGhostMode()
    local character = localPlayer.Character
    if not character then
        return
    end

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Transparency = ghostEnabled and 0.55 or 0
        end
    end
end

local function ApplyNoclip(state)
    noclipEnabled = state
    local character = localPlayer.Character
    if not character then
        return
    end

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            if state then
                noclipStateCache[obj] = obj.CanCollide
                obj.CanCollide = false
            else
                if noclipStateCache[obj] ~= nil then
                    obj.CanCollide = noclipStateCache[obj]
                end
            end
        end
    end

    if not state then
        table.clear(noclipStateCache)
    end
end

local function ToggleNoclip()
    noclipEnabled = not noclipEnabled
    ApplyNoclip(noclipEnabled)
    return noclipEnabled
end

local function ToggleGhostMode()
    ghostEnabled = not ghostEnabled
    ApplyGhostMode()
    return ghostEnabled
end

local function UpdateGodModeState()
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end

    if godModeEnabled then
        godModeConnection = RunService.RenderStepped:Connect(function()
            local humanoid = GetLocalHumanoid()
            if humanoid then
                humanoid.MaxHealth = 9e8
                if humanoid.Health < 5 then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end)
    end
end

local function GetAimbotTarget()
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end

    local bestTarget = nil
    local bestDistance = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and targetPart then
                local screenPoint, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (screenCenter - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                    if distance < bestDistance and distance <= aimbotFov then
                        bestDistance = distance
                        bestTarget = player
                    end
                end
            end
        end
    end

    return bestTarget
end

local function UpdateAimbotState()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end

    if aimbotEnabled then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local target = GetAimbotTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end)
    end
end

local function UpdateKillAuraState()
    if killAuraConnection then
        killAuraConnection:Disconnect()
        killAuraConnection = nil
    end

    if killAuraEnabled then
        killAuraConnection = RunService.RenderStepped:Connect(function()
            local character = localPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root then
                return
            end

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetHumanoid and targetHumanoid.Health > 0 and targetRoot then
                        local distance = (targetRoot.Position - root.Position).Magnitude
                        if distance <= killAuraRadius then
                            targetHumanoid:TakeDamage(5)
                        end
                    end
                end
            end
        end)
    end
end

local function ResetPlayerState()
    playerSpeed = 16
    playerJump = 50
    killAuraRadius = 35
    aimbotFov = 45
    godModeEnabled = false
    aimbotEnabled = false
    killAuraEnabled = false
    ghostEnabled = false
    noclipEnabled = false
    UpdateGodModeState()
    UpdateAimbotState()
    UpdateKillAuraState()
    ApplyPlayerMovement()
    ApplyGhostMode()
    ApplyNoclip(false)
end

local function BuildMainPage()
    CreateSectionLabel("Principal")
    CreateToggleButton("God Mode Immortal", godModeEnabled, function()
        godModeEnabled = not godModeEnabled
        UpdateGodModeState()
        return godModeEnabled
    end)

    CreateToggleButton("Aimbot", aimbotEnabled, function()
        aimbotEnabled = not aimbotEnabled
        UpdateAimbotState()
        return aimbotEnabled
    end)

    CreateToggleButton("Kill Aura", killAuraEnabled, function()
        killAuraEnabled = not killAuraEnabled
        UpdateKillAuraState()
        return killAuraEnabled
    end)

    CreateActionButton("Resetar Configurações", function()
        ResetPlayerState()
        ClearPageContent()
        SetPage(activePage)
    end)
end

local function BuildPlayerPage()
    CreateSectionLabel("Jogador")
    CreateSlider("Velocidade", 16, 120, playerSpeed, function(value)
        playerSpeed = math.floor(value)
        ApplyPlayerMovement()
    end)

    CreateSlider("Força do Pulo", 50, 200, playerJump, function(value)
        playerJump = math.floor(value)
        ApplyPlayerMovement()
    end)

    CreateToggleButton("Noclip", noclipEnabled, ToggleNoclip)
    CreateToggleButton("Ghost Mode", ghostEnabled, ToggleGhostMode)
end

local function BuildCombatPage()
    CreateSectionLabel("Combate")
    CreateSlider("Raio Kill Aura", 5, 120, killAuraRadius, function(value)
        killAuraRadius = math.floor(value)
    end)

    CreateSlider("Aimbot FOV", 5, 90, aimbotFov, function(value)
        aimbotFov = math.floor(value)
    end)

    CreateActionButton("Resetar Câmera / FOV", function()
        camera.FieldOfView = 70
    end)
end

local function BuildCreditsPage()
    CreateSectionLabel("Créditos")

    local creditLabel = Instance.new("TextLabel")
    creditLabel.Size = UDim2.new(1, -10, 0, 60)
    creditLabel.Text = "Painel criado por FoxnameHub\nAdaptado para sidebar com modos de combate, ajustes de jogador e créditos."
    creditLabel.TextColor3 = Color3.fromRGB(210, 210, 255)
    creditLabel.BackgroundTransparency = 1
    creditLabel.Font = Enum.Font.Gotham
    creditLabel.TextSize = 13
    creditLabel.TextWrapped = true
    creditLabel.TextYAlignment = Enum.TextYAlignment.Top
    creditLabel.TextXAlignment = Enum.TextXAlignment.Left
    creditLabel.Parent = ContentScroll
end

pageBuilders["Main"] = BuildMainPage
pageBuilders["Player"] = BuildPlayerPage
pageBuilders["Combat"] = BuildCombatPage
pageBuilders["Credits"] = BuildCreditsPage

local function CreatePageButtons()
    CreatePageButton("Main", "Main")
    CreatePageButton("Player", "LocalPlayer")
    CreatePageButton("Combat", "Combat")
    CreatePageButton("Credits", "Créditos")
end

CreatePageButtons()
SetPage("Main")

localPlayer.CharacterAdded:Connect(function()
    task.wait(0.25)
    ApplyPlayerMovement()
    ApplyGhostMode()
    ApplyNoclip(noclipEnabled)
    UpdateGodModeState()
    UpdateAimbotState()
    UpdateKillAuraState()
end)

local function CleanupConnections()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    if killAuraConnection then
        killAuraConnection:Disconnect()
        killAuraConnection = nil
    end
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
end

ResetPlayerState()