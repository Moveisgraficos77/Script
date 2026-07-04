local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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