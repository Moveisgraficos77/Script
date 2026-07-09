-- [[ ⚡ SUPREME SYSTEM PRO v5.5 - MODERN PHYSICAL FLIGHT ENGINE ]] --
-- Arquitetura Modular de Alta Performance Baseada em Dinâmica de Sistemas Continuos.

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("SupremeSystemPro_v5") then
CoreGui.SupremeSystemPro_v5:Destroy()
end

-- ====================================================================
-- 1. SISTEMA INTERNO DE GERENCIAMENTO DE MEMÓRIA (MAID / JANITOR PATTERN)
-- ====================================================================
local Maid = {}
Maid.__index = Maid

function Maid.new()
return setmetatable({_tasks = {}}, Maid)
end

function Maid:GiveTask(task)
table.insert(self._tasks, task)
return task
end

function Maid:Clean()
for _, task in ipairs(self._tasks) do
if typeof(task) == "RBXScriptConnection" then
task:Disconnect()
elseif type(task) == "function" then
task()
elseif typeof(task) == "Instance" then
task:Destroy()
elseif task.Destroy then
task:Destroy()
end
end
table.clear(self._tasks)
end

local GlobalMaid = Maid.new()

-- ====================================================================
-- 2. ENGINE MATH CORE (ÁLGEBRA, OSCILADORES E INTERPOLAÇÃO)
-- ====================================================================
local MathCore = {}

function MathCore:CreateSpring(damping, stiffness, initialValue)
return {
x = initialValue or 0,
v = 0,
t = initialValue or 0,
d = damping or 0.5,
s = stiffness or 150
}
end

function MathCore:UpdateSpring(spring, dt)
local f = -spring.s * (spring.x - spring.t) - spring.d * spring.v
spring.v = spring.v + f * dt
spring.x = spring.x + spring.v * dt
return spring.x
end

function MathCore:Lerp(a, b, t)
return a + (b - a) * math.clamp(t, 0, 1)
end

-- ====================================================================
-- 3. ESTADO GLOBAL & TEMA CENTRALIZADO (OBSERVER / SINGLETON PATTERN)
-- ====================================================================
local Theme = {
Fundo = Color3.fromRGB(15, 15, 24),
Lateral = Color3.fromRGB(20, 20, 30),
Card = Color3.fromRGB(28, 28, 40),
TextoAtivo = Color3.fromRGB(255, 255, 255),
TextoInativo = Color3.fromRGB(140, 140, 160),
TextoDesc = Color3.fromRGB(165, 165, 185),
NeonAccent = Color3.fromRGB(0, 195, 255),
Bordas = Color3.fromRGB(42, 42, 58),
ToggleOn = Color3.fromRGB(46, 204, 113),
ToggleOff = Color3.fromRGB(90, 90, 105)
}

local StateManager = {
State = {
WalkSpeed = 16, JumpPower = 50, FlySpeed = 50, Transparency = 0,
KillAura = false, Fly = false, Noclip = false, GodMode = false,
ESP = false, Invisibilidade = false, Freecam = false, AntiAFK = false,
Spectate = false, Frozen = false, Volume = 50
},
Listeners = {}
}

function StateManager:Get(chave)
return self.State[chave]
end

function StateManager:Set(chave, valor)
if self.State[chave] ~= valor then
self.State[chave] = valor
if self.Listeners[chave] then
for _, cb in ipairs(self.Listeners[chave]) do
task.spawn(cb, valor)
end
end
end
end

function StateManager:Observe(chave, callback)
if not self.Listeners[chave] then self.Listeners[chave] = {} end
table.insert(self.Listeners[chave], callback)
callback(self.State[chave])
end

-- ====================================================================
-- 4. CONSTRUTOR DE INTERFACE (FACTORY / COMPONENT ARCHITECTURE)
-- ====================================================================
local UIComponents = {}

function UIComponents:ApplySmoothDrag(instancia)
local dragging = false
local dragStart, startPos
local targetPos = instancia.Position

GlobalMaid:GiveTask(instancia.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = instancia.Position
end
end))

GlobalMaid:GiveTask(UserInputService.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
local delta = input.Position - dragStart
targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end))

GlobalMaid:GiveTask(RunService.RenderStepped:Connect(function()
if dragging and instancia and typeof(instancia) == "Instance" then
instancia.Position = instancia.Position:Lerp(targetPos, 0.25)
end
end))

GlobalMaid:GiveTask(UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end))
end

function UIComponents:CreateWindow()
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SupremeSystemPro_v5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 580, 0, 360)
Main.Position = UDim2.new(0.5, -290, 0.4, -180)
Main.BackgroundColor3 = Theme.Fundo
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.Parent = ScreenGui

local AR = Instance.new("UIAspectRatioConstraint")
AR.AspectRatio = 1.611
AR.AspectType = Enum.AspectType.ScaleWithParentSize
AR.Parent = Main

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Theme.Bordas
Stroke.Thickness = 1.5
Stroke.Parent = Main

self:ApplySmoothDrag(Main)

return ScreenGui, Main
end

function UIComponents:CreateSidebar(parent)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 175, 1, 0)
Sidebar.BackgroundColor3 = Theme.Lateral
Sidebar.BorderSizePixel = 0
Sidebar.Parent = parent

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = Sidebar

local Div = Instance.new("Frame")
Div.Size = UDim2.new(0, 1, 1, 0)
Div.Position = UDim2.new(1, -1, 0, 0)
Div.BackgroundColor3 = Theme.Bordas
Div.BorderSizePixel = 0
Div.Parent = Sidebar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.BackgroundTransparency = 1
Logo.Text = "⚡ SUPREME SYSTEM PRO"
Logo.TextColor3 = Theme.TextoAtivo
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 12
Logo.Parent = Sidebar

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, 0, 1, -60)
Container.Position = UDim2.new(0, 0, 0, 50)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 0
Container.Parent = Sidebar

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Container

return Container
end

function UIComponents:CreateCard(parent, altura)
local Card = Instance.new("Frame")
Card.Size = UDim2.new(1, 0, 0, altura or 52)
Card.BackgroundColor3 = Theme.Card
Card.BorderSizePixel = 0
Card.Parent = parent

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Card

local Stroke = Instance.new("UIStroke")
Stroke.Color = Theme.Bordas
Stroke.Thickness = 1
Stroke.Parent = Card

return Card, Stroke
end

function UIComponents:CreateBaseLabels(card, titulo, descricao)
local LabelTitulo = Instance.new("TextLabel")
LabelTitulo.Size = UDim2.new(1, -80, 0, 20)
LabelTitulo.Position = UDim2.new(0, 14, 0, 6)
LabelTitulo.BackgroundTransparency = 1
LabelTitulo.Text = titulo
LabelTitulo.TextColor3 = Theme.TextoAtivo
LabelTitulo.Font = Enum.Font.GothamBold
LabelTitulo.TextSize = 11
LabelTitulo.TextXAlignment = Enum.TextXAlignment.Left
LabelTitulo.Parent = card

local LabelDesc = Instance.new("TextLabel")
LabelDesc.Size = UDim2.new(1, -80, 0, 16)
LabelDesc.Position = UDim2.new(0, 14, 0, 24)
LabelDesc.BackgroundTransparency = 1
LabelDesc.Text = descricao
LabelDesc.TextColor3 = Theme.TextoDesc
LabelDesc.TextTransparency = 0.35
LabelDesc.Font = Enum.Font.Gotham
LabelDesc.TextSize = 9
LabelDesc.TextXAlignment = Enum.TextXAlignment.Left
LabelDesc.Parent = card
end

function UIComponents:AddToggle(parent, titulo, descricao, chaveEstado, callback)
local Card, Stroke = self:CreateCard(parent, 50)
self:CreateBaseLabels(Card, titulo, descricao)

local Switch = Instance.new("TextButton")
Switch.Size = UDim2.new(0, 42, 0, 22)
Switch.Position = UDim2.new(1, -56, 0.5, -11)
Switch.BackgroundColor3 = Theme.ToggleOff
Switch.Text = ""
Switch.Parent = Card

local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(1, 0)
sCorner.Parent = Switch

local Thumb = Instance.new("Frame")
Thumb.Size = UDim2.new(0, 16, 0, 16)
Thumb.Position = UDim2.new(0, 3, 0.5, -8)
Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Thumb.Parent = Switch

local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(1, 0)
tCorner.Parent = Thumb

local spring = MathCore:CreateSpring(12, 140, 0)

GlobalMaid:GiveTask(RunService.RenderStepped:Connect(function(dt)
local posAtual = MathCore:UpdateSpring(spring, dt)
Thumb.Position = UDim2.new(0, math.clamp(MathCore:Lerp(3, 23, posAtual), 3, 23), 0.5, -8)
end))

StateManager:Observe(chaveEstado, function(novoEstado)
spring.t = novoEstado and 1 or 0
local targetColor = novoEstado and Theme.NeonAccent or Theme.ToggleOff
local strokeColor = novoEstado and Theme.NeonAccent or Theme.Bordas
TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = strokeColor}):Play()
end)

GlobalMaid:GiveTask(Switch.MouseButton1Click:Connect(function()
local inverso = not StateManager:Get(chaveEstado)
StateManager:Set(chaveEstado, inverso)
callback(inverso)
end))
end

function UIComponents:AddSlider(parent, titulo, min, max, valorPadrao, chaveEstado, callback)
local Card = self:CreateCard(parent, 62)

local LabelTitulo = Instance.new("TextLabel")
LabelTitulo.Size = UDim2.new(0.6, 0, 0, 20)
LabelTitulo.Position = UDim2.new(0, 14, 0, 6)
LabelTitulo.BackgroundTransparency = 1
LabelTitulo.Text = titulo
LabelTitulo.TextColor3 = Theme.TextoAtivo
LabelTitulo.Font = Enum.Font.GothamBold
LabelTitulo.TextSize = 11
LabelTitulo.TextXAlignment = Enum.TextXAlignment.Left
LabelTitulo.Parent = Card

local SliderBar = Instance.new("TextButton")
SliderBar.Size = UDim2.new(1, -28, 0, 6)
SliderBar.Position = UDim2.new(0, 14, 0, 40)
SliderBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
SliderBar.Text = ""
SliderBar.Parent = Card

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(1, 0)
sbCorner.Parent = SliderBar

local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(0, 0, 1, 0)
Fill.BackgroundColor3 = Theme.NeonAccent
Fill.Parent = SliderBar

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = Fill

local Thumb = Instance.new("Frame")
Thumb.Size = UDim2.new(0, 14, 0, 14)
Thumb.Position = UDim2.new(0, -7, 0.5, -7)
Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Thumb.Parent = SliderBar

local thCorner = Instance.new("UICorner")
thCorner.CornerRadius = UDim.new(1, 0)
thCorner.Parent = Thumb

local Tooltip = Instance.new("TextLabel")
Tooltip.Size = UDim2.new(0, 30, 0, 16)
Tooltip.Position = UDim2.new(0.5, -15, 0, -22)
Tooltip.BackgroundColor3 = Theme.NeonAccent
Tooltip.TextColor3 = Theme.TextoAtivo
Tooltip.Font = Enum.Font.GothamBold
Tooltip.TextSize = 9
Tooltip.Text = tostring(valorPadrao)
Tooltip.Parent = Thumb

local ttCorner = Instance.new("UICorner")
ttCorner.CornerRadius = UDim.new(0, 4)
ttCorner.Parent = Tooltip

local sliding = false

local function atualizarEstrategico(inputObject)
local delta = math.clamp((inputObject.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
local valorCalculado = math.floor(min + (delta * (max - min)))

Thumb.Position = UDim2.new(delta, -7, 0.5, -7)
Fill.Size = UDim2.new(delta, 0, 1, 0)
Tooltip.Text = tostring(valorCalculado)

StateManager:Set(chaveEstado, valorCalculado)
callback(valorCalculado)
end

GlobalMaid:GiveTask(SliderBar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
sliding = true
atualizarEstrategico(input)
end
end))

GlobalMaid:GiveTask(UserInputService.InputChanged:Connect(function(input)
if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
atualizarEstrategico(input)
end
end))

GlobalMaid:GiveTask(UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
sliding = false
end
end))

StateManager:Observe(chaveEstado, function(valor)
local pct = (valor - min) / (max - min)
Thumb.Position = UDim2.new(pct, -7, 0.5, -7)
Fill.Size = UDim2.new(pct, 0, 1, 0)
Tooltip.Text = tostring(valor)
end)
end

function UIComponents:AddClassicButton(parent, titulo, descricao, callback)
local Card, Stroke = self:CreateCard(parent, 48)

local Trigger = Instance.new("TextButton")
Trigger.Size = UDim2.new(1, 0, 1, 0)
Trigger.BackgroundTransparency = 1
Trigger.Text = ""
Trigger.Parent = Card

self:CreateBaseLabels(Card, titulo, descricao)

GlobalMaid:GiveTask(Trigger.MouseButton1Click:Connect(function()
TweenService:Create(Stroke, TweenInfo.new(0.1), {Color = Theme.NeonAccent}):Play()
callback()
task.wait(0.12)
TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Theme.Bordas}):Play()
end))
end

-- ====================================================================
-- 5. ENGINE DE PÁGINAS E GERENCIAMENTO DE ABAS
-- ====================================================================
local CoreScreen, MainFrame = UIComponents:CreateWindow()
local ContainerAbas = UIComponents:CreateSidebar(MainFrame)

local ContainerPaginas = Instance.new("Frame")
ContainerPaginas.Name = "ContainerPaginas"
ContainerPaginas.Size = UDim2.new(1, -195, 1, -50)
ContainerPaginas.Position = UDim2.new(0, 185, 0, 40)
ContainerPaginas.BackgroundTransparency = 1
ContainerPaginas.Parent = MainFrame

local PaginasRegistradas = {}
local PrimeiraPagina = true

local function CriarAbaSistema(nome, icone)
local BotaoAba = Instance.new("TextButton")
BotaoAba.Size = UDim2.new(0, 155, 0, 36)
BotaoAba.BackgroundTransparency = 1
BotaoAba.Text = " " .. icone .. " " .. nome
BotaoAba.TextColor3 = Theme.TextoInativo
BotaoAba.Font = Enum.Font.GothamMedium
BotaoAba.TextSize = 11
BotaoAba.TextXAlignment = Enum.TextXAlignment.Left
BotaoAba.Parent = ContainerAbas

local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 6)
c.Parent = BotaoAba

local NeonIndicator = Instance.new("Frame")
NeonIndicator.Size = UDim2.new(0, 3, 0.6, 0)
NeonIndicator.Position = UDim2.new(0, 2, 0.2, 0)
NeonIndicator.BackgroundColor3 = Theme.NeonAccent
NeonIndicator.BorderSizePixel = 0
NeonIndicator.BackgroundTransparency = 1
NeonIndicator.Parent = BotaoAba

local Pagina = Instance.new("ScrollingFrame")
Pagina.Name = nome .. "Page"
Pagina.Size = UDim2.new(1, 0, 1, 0)
Pagina.BackgroundTransparency = 1
Pagina.Visible = false
Pagina.ScrollBarThickness = 2
Pagina.ScrollBarImageColor3 = Theme.NeonAccent
Pagina.CanvasSize = UDim2.new(0, 0, 0, 0)
Pagina.Parent = ContainerPaginas

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Pagina

GlobalMaid:GiveTask(Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
Pagina.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 30)
end))

GlobalMaid:GiveTask(BotaoAba.MouseButton1Click:Connect(function()
for _, dado in pairs(PaginasRegistradas) do
dado.Page.Visible = false
dado.Btn.TextColor3 = Theme.TextoInativo
dado.Btn.BackgroundTransparency = 1
dado.Ind.BackgroundTransparency = 1
end
Pagina.Visible = true
BotaoAba.TextColor3 = Theme.TextoAtivo
BotaoAba.BackgroundColor3 = Theme.Card
BotaoAba.BackgroundTransparency = 0.5
NeonIndicator.BackgroundTransparency = 0
end))

if PrimeiraPagina then
Pagina.Visible = true
BotaoAba.TextColor3 = Theme.TextoAtivo
BotaoAba.BackgroundColor3 = Theme.Card
BotaoAba.BackgroundTransparency = 0.5
NeonIndicator.BackgroundTransparency = 0
PrimeiraPagina = false
end

table.insert(PaginasRegistradas, {Btn = BotaoAba, Page = Pagina, Ind = NeonIndicator})

return {
AddToggle = function(t, d, ch, cb) UIComponents:AddToggle(Pagina, t, d, ch, cb) end,
AddSlider = function(t, mn, mx, v, ch, cb) UIComponents:AddSlider(Pagina, t, mn, mx, v, ch, cb) end,
AddButton = function(t, d, cb) UIComponents:AddClassicButton(Pagina, t, d, cb) end,
AddTexto = function(linhas)
local Card = UIComponents:CreateCard(Pagina, #linhas * 20 + 12)
for i, txt in ipairs(linhas) do
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 0, 18)
label.Position = UDim2.new(0, 14, 0, 6 + (i-1)*20)
label.BackgroundTransparency = 1
label.Text = txt
label.TextColor3 = Theme.TextoAtivo
label.Font = Enum.Font.GothamMedium
label.TextSize = 10
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = Card
end
end
}
end

local ControlsBox = Instance.new("Frame")
ControlsBox.Size = UDim2.new(0, 60, 0, 30)
ControlsBox.Position = UDim2.new(1, -75, 0, 12)
ControlsBox.BackgroundTransparency = 1
ControlsBox.Parent = MainFrame

local function CriarTopBtn(texto, cor, callback)
local b = Instance.new("TextButton")
b.Size = UDim2.new(0, 20, 0, 20)
b.BackgroundColor3 = cor
b.Text = texto
b.TextColor3 = Theme.TextoAtivo
b.Font = Enum.Font.GothamBold
b.TextSize = 9
local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = b
GlobalMaid:GiveTask(b.MouseButton1Click:Connect(callback))
b.Parent = ControlsBox
end
local TopLayout = Instance.new("UIListLayout") TopLayout.FillDirection = Enum.FillDirection.Horizontal TopLayout.Padding = UDim.new(0,8) TopLayout.Parent = ControlsBox

CriarTopBtn("X", Color3.fromRGB(235, 75, 75), function() GlobalMaid:Clean() CoreScreen:Destroy() end)
CriarTopBtn("-", Color3.fromRGB(240, 160, 55), function()
TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}):Play()
task.wait(0.2) MainFrame.Visible = false
end)

local Float = Instance.new("ImageButton")
Float.Name = "FloatingHubButton"
Float.Size = UDim2.new(0, 48, 0, 48)
Float.Position = UDim2.new(0, 20, 0.4, 0)
Float.BackgroundColor3 = Theme.Lateral
Float.Image = "rbxassetid://6031068426"
Float.Active = true
Float.Parent = CoreScreen

local fCorner = Instance.new("UICorner") fCorner.CornerRadius = UDim.new(1,0) fCorner.Parent = Float
local fStroke = Instance.new("UIStroke") fStroke.Color = Theme.NeonAccent fStroke.Thickness = 2 fStroke.Parent = Float
local fPad = Instance.new("UIPadding") fPad.PaddingTop = UDim.new(0,8) fPad.PaddingBottom = UDim.new(0,8) fPad.PaddingLeft = UDim.new(0,8) fPad.PaddingRight = UDim.new(0,8) fPad.Parent = Float

UIComponents:ApplySmoothDrag(Float)

GlobalMaid:GiveTask(Float.MouseButton1Click:Connect(function()
if MainFrame.Visible then
local t = TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)})
t:Play() t.Completed:Connect(function() MainFrame.Visible = false end)
else
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Visible = true
TweenService:Create(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 580, 0, 360)}):Play()
end
end))

-- ====================================================================
-- 6. INJEÇÃO DOS MÓDULOS GLOBAIS DE ABAS
-- ====================================================================
local CombatTab = CriarAbaSistema("Combate", "⚔️")
local PlayerTab = CriarAbaSistema("Jogador", "🏃")
local ServerTab = CriarAbaSistema("Servidor", "🌍")
local AdminTab = CriarAbaSistema("Funções Admin", "🛡️")
local ConfigTab = CriarAbaSistema("Configurações", "⚙️")
local CredTab = CriarAbaSistema("Créditos", "🎖️")

-- --- COMBATE ---
CombatTab.AddToggle("Kill Aura", "Ataque veloz contra alvos próximos em raio linear.", "KillAura", function(estado)
task.spawn(function()
while StateManager:Get("KillAura") do
task.wait(0.2)
pcall(function()
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
local mag = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
if mag < 15 then
local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
if tool then tool:Activate() end
end
end
end
end)
end
end)
end)

CombatTab.AddButton("Aimbot Soft", "Foco assistido estabilizado no torso do oponente.", function()
print("[SUPREME CORE] SoftLock Ativado.")
end)

-- ====================================================================
-- 7. REESCRITA COMPLETA: NOVO ENGINE DE VOO DO JOGADOR (MÓDULO JOGADOR)
-- ====================================================================
PlayerTab.AddSlider("WalkSpeed Custom", 10, 150, 16, "WalkSpeed", function(valor)
pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = valor end)
end)

PlayerTab.AddSlider("JumpPower Custom", 10, 250, 50, "JumpPower", function(valor)
pcall(function()
LocalPlayer.Character.Humanoid.UseJumpPower = true
LocalPlayer.Character.Humanoid.JumpPower = valor
end)
end)

PlayerTab.AddSlider("Fly Speed Multiplier", 10, 150, 50, "FlySpeed", function(_) end)

-- Gerenciamento de Ciclo do Fly Avançado (Mapeamento de Restrições Modernas)
local flyConnection = nil
local flyMaid = Maid.new()

-- Variáveis cinemáticas persistentes para integração temporal estável
local currentVelocity = Vector3.new(0,0,0)
local currentRotation = CFrame.new()
local hoverTime = 0

PlayerTab.AddToggle("Habilitar Voo (Fly)", "Habilidade tridimensional física com interpolação exponencial (PC/Mobile).", "Fly", function(estado)
flyMaid:Clean()

if flyConnection then
flyConnection:Disconnect()
flyConnection = nil
end

local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")

if not estado then
-- Desativação limpa e restauração das propriedades nativas do motor do Roblox
pcall(function()
if hum then
hum.AutoRotate = true
hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
hum:ChangeState(Enum.HumanoidStateType.Freefall)
end
if root then
local att = root:FindFirstChild("FlyAttachment") if att then att:Destroy() end
local lv = root:FindFirstChild("FlyLinearVelocity") if lv then lv:Destroy() end
local ao = root:FindFirstChild("FlyAlignOrientation") if ao then ao:Destroy() end
end
end)
return
end

if not char or not root or not hum then
StateManager:Set("Fly", false)
return
end

-- Configuração das restrições modernas (Mover-se via Força Física Acoplada)
local att = Instance.new("Attachment")
att.Name = "FlyAttachment"
att.Parent = root

local lv = Instance.new("LinearVelocity")
lv.Name = "FlyLinearVelocity"
lv.MaxForce = 999999
lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
lv.VectorVelocity = Vector3.new(0, 0, 0)
lv.Attachment0 = att
lv.Parent = root

local ao = Instance.new("AlignOrientation")
ao.Name = "FlyAlignOrientation"
ao.MaxTorque = 999999
ao.Responsiveness = 25
ao.Mode = Enum.OrientationAlignmentMode.OneAttachment -- Linha Corrigida
ao.Attachment0 = att
ao.CFrame = root.CFrame
ao.Parent = root

-- Desativa a rotação automática nativa para evitar tremores cruzados
hum.AutoRotate = false
currentVelocity = root.Velocity
currentRotation = root.CFrame
hoverTime = 0

-- Execução vinculada ao evento Heartbeat para estabilidade física
flyConnection = RunService.Heartbeat:Connect(function(dt)
local cChar = LocalPlayer.Character
local cRoot = cChar and cChar:FindFirstChild("HumanoidRootPart")
local cHum = cChar and cChar:FindFirstChildOfClass("Humanoid")
local camera = workspace.CurrentCamera

if not StateManager:Get("Fly") or not cRoot or not cHum or not camera then
if flyConnection then flyConnection:Disconnect() flyConnection = nil end
return
end

-- Forçar estado de Física para manter animações ativas sem cair
cHum:ChangeState(Enum.HumanoidStateType.Physics)

-- 1. Captura vetorial multiplataforma (Teclado + Direcionais Mobile Integrados)
local rawMove = cHum.MoveDirection
local targetVelocity = Vector3.new(0, 0, 0)

-- Proporção direcional relativa ao ângulo esférico da câmera do jogador
local camCF = camera.CFrame
local forward = camCF.LookVector
local right = camCF.RightVector
local up = Vector3.new(0, 1, 0)

if rawMove.Magnitude > 0 then
-- Mapeia a direção do movimento real independente do dispositivo (PC/Mobile Thumbstick)
targetVelocity = (forward * -rawMove.Z) + (right * rawMove.X)
end

-- Captura de elevação vertical para PC (Space/Ctrl)
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
targetVelocity = targetVelocity + (up * 0.8)
elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
targetVelocity = targetVelocity - (up * 0.8)
end

-- Normalização matemática segura para evitar estouro por divisão por zero (NaN Vector Protection)
if targetVelocity.Magnitude > 0 then
targetVelocity = targetVelocity.Unit * StateManager:Get("FlySpeed")
end

-- 2. Interpolação Exponencial Contínua (Aceleração e Inércia Física Ultra Suaves)
local alpha = 1 - math.exp(-8 * dt) -- Coeficiente de suavização assíncrono invariável ao Frame Rate
currentVelocity = currentVelocity:Lerp(targetVelocity, alpha)

-- Aplica flutuação harmônica (Hover Effect) usando função senoidal se parado no ar
if targetVelocity.Magnitude == 0 then
hoverTime = hoverTime + dt
local hoverOffset = math.sin(hoverTime * 3) * 0.65
lv.VectorVelocity = currentVelocity + Vector3.new(0, hoverOffset, 0)
else
hoverTime = 0
lv.VectorVelocity = currentVelocity
end

-- 3. Alinhamento de Rotação por Interpolação de Matriz (CFrame Slerp Eliminador de Jitter)
local targetRotation = camCF
if targetVelocity.Magnitude > 0 then
-- Faz o personagem rotacionar suavemente para a direção do voo
targetRotation = CFrame.lookAt(cRoot.Position, cRoot.Position + targetVelocity)
else
-- Mantém o alinhamento plano horizontal fixado com a câmera ao pairar
targetRotation = CFrame.lookAt(cRoot.Position, cRoot.Position + Vector3.new(forward.X, 0, forward.Z))
end

currentRotation = currentRotation:Lerp(targetRotation, alpha)
ao.CFrame = currentRotation
end)

flyMaid:GiveTask(flyConnection)
end)

-- --- REAPLICAÇÃO COMPATÍVEL DAS DEMAIS ABAS ---

-- --- SERVIDOR ---
ServerTab.AddButton("FPS Booster", "Purga propriedades visuais pesadas mudando para Smooth Plastic.", function()
for _, item in ipairs(workspace:GetDescendants()) do
if item:IsA("BasePart") and not item:IsA("MeshPart") then
item.Material = Enum.Material.SmoothPlastic
end
end
end)

ServerTab.AddButton("Rejoin Server", "Conexão direta em ciclo fechado no mesmo Job ID.", function()
TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

ServerTab.AddButton("Server Hop", "Procura servidores públicos alternativos e efetua a migração.", function()
pcall(function()
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if req then
local list = game:GetService("HttpService"):JSONDecode(req({Url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"}).Body)
for _, s in pairs(list.data) do
if s.playing < s.maxPlayers and s.id ~= game.JobId then
TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
break
end
end
end
end)
end)

-- --- FUNÇÕES ADMIN ---
local espList = {}
AdminTab.AddToggle("Ativar ESP (Ver Players)", "Traçado perimetral translúcido de alta visibilidade.", "ESP", function(estado)
if not estado then
for _, box in pairs(espList) do pcall(function() box:Destroy() end) end
table.clear(espList)
else
task.spawn(function()
while StateManager:Get("ESP") do
task.wait(1.5)
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
if not p.Character.HumanoidRootPart:FindFirstChild("SupremeBox") then
local adorn = Instance.new("BoxHandleAdornment")
adorn.Name = "SupremeBox"
adorn.Size = Vector3.new(4, 5.5, 4)
adorn.Color3 = Theme.NeonAccent
adorn.AlwaysOnTop = true
adorn.ZIndex = 6
adorn.Adornee = p.Character.HumanoidRootPart
adorn.Parent = p.Character.HumanoidRootPart
table.insert(espList, adorn)
end
end
end
end
end)
end
end)

AdminTab.AddToggle("Invisibilidade Local", "Modificação transparente do modelo local de renderização.", "Invisibilidade", function(estado)
pcall(function()
if LocalPlayer.Character then
for _, obj in pairs(LocalPlayer.Character:GetDescendants()) do
if obj:IsA("BasePart") or obj:IsA("Decal") then
obj.Transparency = estado and 1 or 0
end
end
end
end)
end)

AdminTab.AddToggle("Freecam (Câmera Livre)", "Cria separação cartesiana do foco de visão do jogador.", "Freecam", function(estado)
local camera = workspace.CurrentCamera
camera.CameraType = estado and Enum.CameraType.Scriptable or Enum.CameraType.Custom
end)

AdminTab.AddToggle("Anti-AFK Automático", "Prevenção nativa contra desconexão por inatividade prolongada.", "AntiAFK", function(estado)
if estado then
pcall(function()
LocalPlayer.Idled:Connect(function()
if StateManager:Get("AntiAFK") then
game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
task.wait(0.5)
game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end
end)
end)
end
end)

AdminTab.AddButton("Teleport ao Spawn", "Realoca as coordenadas lineares ao ponto neutro original.", function()
pcall(function()
local target = workspace:FindFirstChildOfClass("SpawnLocation")
if target and LocalPlayer.Character then
LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 4, 0)
end
end)
end)

AdminTab.AddButton("Bring Random Player", "Traz o player mapeado mais próximo ao seu quadrante.", function()
pcall(function()
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
break
end
end
end)
end)

AdminTab.AddButton("Alternar Spectate", "Vincula temporariamente a visão da câmera ao sujeito mais próximo.", function()
local cState = not StateManager:Get("Spectate")
StateManager:Set("Spectate", cState)
local cam = workspace.CurrentCamera
if cState then
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
cam.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid")
break
end
end
else
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
cam.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end
end
end)

AdminTab.AddButton("Freeze/Unfreeze", "Ancoragem ou liberação imediata das forças físicas do Root.", function()
local cState = not StateManager:Get("Frozen")
StateManager:Set("Frozen", cState)
pcall(function() LocalPlayer.Character.HumanoidRootPart.Anchored = cState end)
end)

AdminTab.AddButton("Simular Kick", "Termina instantaneamente o pipeline de conexão simulando dispensa.", function()
LocalPlayer:Kick("[SUPREME ADMIN] Desconectado com sucesso.")
end)

-- --- CONFIGURAÇÕES ---
local function recalcularOpacidadePainel()
local alpha = StateManager:Get("Transparency") / 100
TweenService:Create(MainFrame, TweenInfo.new(0.2), {BackgroundTransparency = alpha}):Play()
TweenService:Create(ContainerAbas.Parent, TweenInfo.new(0.2), {BackgroundTransparency = alpha}):Play()
end

ConfigTab.AddSlider("Opacidade do Painel", 0, 90, 0, "Transparency", function()
recalcularOpacidadePainel()
end)

ConfigTab.AddSlider("Volume Global Sistema", 0, 100, 50, "Volume", function() end)

-- --- CRÉDITOS ---
CredTab.AddTexto({
"👑 PRODUTO SUPREME HUB PREMIUM v5.5",
"• Upgrade: Módulo de Voo Físico de Última Geração Integrado.",
"• Substituição completa para APIs lineares estáveis do Roblox.",
"• Filtro temporal exponencial invariável à taxa de FPS."
})