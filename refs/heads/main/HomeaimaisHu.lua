-- [[ ANIMAL HOSPITAL CUSTOM HUB ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
Name = "Foxname Edit: Animal Hospital",
LoadingTitle = "Carregando Painel...",
LoadingSubtitle = "by Matheus",
ConfigurationSaving = { Enabled = false }
})

-- ABAS DO PAINEL
local TabMain = Window:CreateTab("Automations", 4483362458)
local TabTeleport = Window:CreateTab("Teleports", 4483362458)
local TabVisual = Window:CreateTab("Visual/World", 4483362458)

-- --- ABA: TELEPORTES DINÂMICOS ---
-- Procura a pasta Areas no Workspace que você mencionou
local AreasFolder = workspace:FindFirstChild("Areas")

if AreasFolder then
for _, area in pairs(AreasFolder:GetChildren()) do
if area:IsA("BasePart") then
TabTeleport:CreateButton({
Name = "Teleport to: " .. area.Name,
Callback = function()
local player = game.Players.LocalPlayer
if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
-- Teleporta o jogador exatamente para a posição da BasePart da área
player.Character.HumanoidRootPart.CFrame = area.CFrame + Vector3.new(0, 3, 0)
end
end,
})
end
end
else
TabTeleport:CreateLabel("Pasta 'Areas' não encontrada no Workspace.")
end

-- --- ABA: VISUAL / PAREDES ---
local NoclipEnabled = false
TabVisual:CreateToggle({
Name = "Remover Colisão de Paredes (Noclip)",
CurrentValue = false,
Flag = "NoclipToggle",
Callback = function(Value)
NoclipEnabled = Value
if NoclipEnabled then
task.spawn(function()
while NoclipEnabled do
-- Remove colisão localmente de partes que possam ser paredes
for _, obj in pairs(workspace:GetDescendants()) do
if obj:IsA("BasePart") and (obj.Name:lower():find("wall") or obj.Name:lower():find("parede")) then
obj.CanCollide = false
end
end
task.wait(1)
end
end)
else
-- Força uma atualização para restaurar (ou o jogador pode resetar)
Rayfield:Notify({Title = "Noclip Desativado", Content = "As colisões padrão voltarão ao recarregar a área.", Duration = 3})
end
end,
})

-- --- ABA: AUTOMATIONS (Exemplo de Auto-Interact) ---
TabMain:CreateToggle({
Name = "Auto-Interagir com Animais (Proximity)",
CurrentValue = false,
Flag = "AutoInteract",
Callback = function(Value)
_G.AutoHeal = Value
task.spawn(function()
while _G.AutoHeal do
for _, desc in pairs(workspace:GetDescendants()) do
if desc:IsA("ProximityPrompt") then
-- Dispara o gatilho de proximidade simulando que você está colado no animal
fireproximityprompt(desc)
end
end
task.wait(0.5)
end
end)
end,
})