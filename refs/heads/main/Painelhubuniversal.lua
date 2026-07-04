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
MainFrame.Size = UDim2.new(0, 360, 0, 300)
MainFrame.Position = UDim2.new(0.5, -180, 0.4, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "STUDIO DEBUG PANEL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

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

local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -20, 1, -55)
ContentContainer.Position = UDim2.new(0, 10, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ScrollBarThickness = 4
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 450)
ContentContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ContentContainer

local isMinimized = false
ToggleBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 360, 0, 40) or UDim2.new(0, 360, 0, 300)
    ToggleBtn.Text = isMinimized and "+" or "-"
    ContentContainer.Visible = not isMinimized
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
end)

local function CreateDebugButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -5, 0, 35)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(240, 240, 240)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 13
    Button.Parent = ContentContainer

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = Button

    Button.MouseButton1Click:Connect(callback)
    return Button
end

local function CreateSectionLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -5, 0, 18)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(120, 180, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ContentContainer
    return Label
end

local noclipEnabled = false
local noclipStateCache = {}
local speedBoostEnabled = false
local originalWalkSpeed = nil
local originalJumpPower = nil
local ghostEnabled = false
local teamButtons = {}

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
    ApplyNoclip(not noclipEnabled)
end

local function ToggleSpeedBoost()
    speedBoostEnabled = not speedBoostEnabled
    local character = localPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if speedBoostEnabled then
        originalWalkSpeed = humanoid.WalkSpeed
        originalJumpPower = humanoid.JumpPower
        humanoid.WalkSpeed = 80
        humanoid.JumpPower = 100
    else
        if originalWalkSpeed ~= nil then
            humanoid.WalkSpeed = originalWalkSpeed
        end
        if originalJumpPower ~= nil then
            humanoid.JumpPower = originalJumpPower
        end
    end
end

local function ToggleGhostMode()
    ghostEnabled = not ghostEnabled
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

local function EscapeJail()
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        return
    end

    local nearbyJailParts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            if name:find("jail") or name:find("prison") or name:find("cell") or name:find("gaol") then
                if (obj.Position - root.Position).Magnitude < 80 then
                    table.insert(nearbyJailParts, obj)
                end
            end
        end
    end

    if #nearbyJailParts > 0 then
        for _, part in ipairs(nearbyJailParts) do
            part.CanCollide = false
            part.Transparency = 1
        end
    end

    root.CFrame = root.CFrame + Vector3.new(0, 8, 0)
    humanoid.Sit = false
end

local function ClearTeamButtons()
    for _, btn in ipairs(teamButtons) do
        if btn and btn.Parent then
            btn:Destroy()
        end
    end
    teamButtons = {}
end

local function RefreshTeamsMenu()
    ClearTeamButtons()

    local header = CreateSectionLabel("JAIL / TIMES / FUN")
    header.TextSize = 13

    CreateDebugButton("Liberar do Jail / Prisão", EscapeJail)
    CreateDebugButton("Alternar Noclip (Self)", ToggleNoclip)
    CreateDebugButton("Modo Divertido: Super Speed", ToggleSpeedBoost)
    CreateDebugButton("Modo Divertido: Super Jump", function()
        local character = localPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return
        end

        humanoid.JumpPower = 120
        task.wait(0.3)
        humanoid.JumpPower = 50
    end)
    CreateDebugButton("Modo Divertido: Ghost", ToggleGhostMode)

    local teamLabel = Instance.new("TextLabel")
    teamLabel.Size = UDim2.new(1, -5, 0, 18)
    teamLabel.Text = "Times atuais:" 
    teamLabel.TextColor3 = Color3.fromRGB(255, 210, 90)
    teamLabel.BackgroundTransparency = 1
    teamLabel.Font = Enum.Font.GothamBold
    teamLabel.TextSize = 12
    teamLabel.TextXAlignment = Enum.TextXAlignment.Left
    teamLabel.Parent = ContentContainer

    local teams = {}
    for _, team in ipairs(TeamsService:GetChildren()) do
        if team:IsA("Team") then
            table.insert(teams, team)
        end
    end
    table.sort(teams, function(a, b)
        return a.Name < b.Name
    end)

    for _, team in ipairs(teams) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -5, 0, 30)
        btn.Text = "Entrar em " .. team.Name
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = ContentContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            local success, err = pcall(function()
                localPlayer.Team = team
            end)
            if not success then
                warn("Não foi possível entrar no time: " .. tostring(err))
            end
        end)

        table.insert(teamButtons, btn)
    end
end

RefreshTeamsMenu()

TeamsService.ChildAdded:Connect(function()
    RefreshTeamsMenu()
end)
TeamsService.ChildRemoved:Connect(function()
    RefreshTeamsMenu()
end)
Players.PlayerAdded:Connect(function()
    RefreshTeamsMenu()
end)
Players.PlayerRemoving:Connect(function()
    RefreshTeamsMenu()
end)

localPlayer.CharacterAdded:Connect(function(character)
    if noclipEnabled then
        task.wait(0.2)
        ApplyNoclip(true)
    end

    if ghostEnabled then
        task.wait(0.2)
        ToggleGhostMode()
    end
end)

-- =============================================================================
-- RECURSO 1: VOO
-- =============================================================================
local isFlying = false
local flySpeed = 60
local connection = nil
local bVelocity = nil
local bGyro = nil

local function CleanupFly()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if bGyro then
        bGyro:Destroy()
        bGyro = nil
    end
    if bVelocity then
        bVelocity:Destroy()
        bVelocity = nil
    end
end

local function ToggleFly()
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")

    if not root or not humanoid then
        return
    end

    isFlying = not isFlying

    if isFlying then
        humanoid.PlatformStand = true

        bGyro = Instance.new("BodyGyro")
        bGyro.P = 9e4
        bGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bGyro.cframe = root.CFrame
        bGyro.Parent = root

        bVelocity = Instance.new("BodyVelocity")
        bVelocity.velocity = Vector3.new(0, 0, 0)
        bVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bVelocity.Parent = root

        connection = RunService.RenderStepped:Connect(function()
            local direction = humanoid.MoveDirection
            local newVelocity = Vector3.new(0, 0, 0)

            if direction.Magnitude > 0 then
                newVelocity = camera.CFrame.LookVector * flySpeed
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                newVelocity = newVelocity + Vector3.new(0, flySpeed, 0)
            end

            bVelocity.velocity = newVelocity
            bGyro.cframe = camera.CFrame
        end)
    else
        CleanupFly()
        humanoid.PlatformStand = false
    end
end

localPlayer.CharacterAdded:Connect(function()
    if isFlying then
        task.wait(0.2)
        ToggleFly()
    end
end)

CreateDebugButton("Alternar Modo Voo (Fly)", ToggleFly)

-- =============================================================================
-- RECURSO 2: ESP POR TIME
-- =============================================================================
local espActive = false
local currentHighlights = {}

local function ClearESP()
    for _, hl in pairs(currentHighlights) do
        if hl then
            hl:Destroy()
        end
    end
    currentHighlights = {}
end

local function ApplyTeamESP()
    espActive = not espActive
    ClearESP()

    if not espActive then
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local teamColor = (p.Team and p.Team.TeamColor.Color) or Color3.fromRGB(255, 0, 0)

            local Highlight = Instance.new("Highlight")
            Highlight.Name = "DebugESP_" .. p.Name
            Highlight.FillColor = teamColor
            Highlight.FillTransparency = 0.5
            Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            Highlight.OutlineTransparency = 0.2
            Highlight.Adornee = p.Character
            Highlight.Parent = p.Character

            table.insert(currentHighlights, Highlight)
        end
    end
end

CreateDebugButton("Alternar ESP por Cores de Time", ApplyTeamESP)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if espActive then
            task.wait(1)
            ApplyTeamESP()
        end
    end)
end)

-- =============================================================================
-- RECURSO 3: FOV
-- =============================================================================
local fovConnection = nil

local function ToggleFOV(targetValue)
    if fovConnection then
        fovConnection:Disconnect()
        fovConnection = nil
    end

    if targetValue then
        fovConnection = RunService.RenderStepped:Connect(function()
            camera.FieldOfView = targetValue
        end)
    end
end

CreateDebugButton("Fixar FOV Ampliado (110)", function()
    ToggleFOV(110)
end)

CreateDebugButton("Resetar Câmera / FOV Padrão", function()
    ToggleFOV(nil)
    camera.FieldOfView = 70
end)

-- =============================================================================
-- RECURSO 4: RASTRO NEON
-- =============================================================================
local trailActive = false
local function ToggleTrail()
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local head = char and char:FindFirstChild("Head")

    if not root or not head then
        return
    end

    trailActive = not trailActive

    if trailActive then
        local attachment0 = Instance.new("Attachment", head)
        attachment0.Name = "TrailAttachment0"
        local attachment1 = Instance.new("Attachment", root)
        attachment1.Name = "TrailAttachment1"

        local trail = Instance.new("Trail")
        trail.Name = "DebugTrail"
        trail.Attachment0 = attachment0
        trail.Attachment1 = attachment1
        trail.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 0, 255))
        trail.LightEmission = 1
        trail.WidthScale = NumberSequence.new(1, 0)
        trail.Lifetime = 0.8
        trail.Parent = root
    else
        if head:FindFirstChild("TrailAttachment0") then
            head.TrailAttachment0:Destroy()
        end
        if root:FindFirstChild("TrailAttachment1") then
            root.TrailAttachment1:Destroy()
        end
        if root:FindFirstChild("DebugTrail") then
            root.DebugTrail:Destroy()
        end
    end
end

CreateDebugButton("Alternar Rastro Neon", ToggleTrail)

-- =============================================================================
-- RECURSO 5: GRAVIDADE
-- =============================================================================
local gravityState = 0
local function CycleGravity()
    gravityState = (gravityState + 1) % 3
    if gravityState == 1 then
        workspace.Gravity = 30
    elseif gravityState == 2 then
        workspace.Gravity = 0
    else
        workspace.Gravity = 196.2
    end
end

CreateDebugButton("Ciclar Gravidade (Padrão/Baixa/Zero)", CycleGravity)

-- =============================================================================
-- RECURSO 6: HITBOXES
-- =============================================================================
local hitboxesVisible = false
local function ToggleHitboxes()
    hitboxesVisible = not hitboxesVisible

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent ~= localPlayer.Character then
            local character = obj.Parent
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    local box = part:FindFirstChild("HitboxVisualizer")
                    if hitboxesVisible then
                        if not box then
                            local selection = Instance.new("SelectionBox")
                            selection.Name = "HitboxVisualizer"
                            selection.Color3 = Color3.fromRGB(255, 170, 0)
                            selection.LineThickness = 0.05
                            selection.Adornee = part
                            selection.Parent = part
                        end
                    else
                        if box then
                            box:Destroy()
                        end
                    end
                end
            end
        end
    end
end

CreateDebugButton("Visualizar Hitbox de NPCs", ToggleHitboxes)