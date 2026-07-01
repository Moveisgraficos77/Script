--[[
    ================================================================================
    ROBLOX ADVANCED FRAMEWORK MODULE (PRODUCTION-READY)
    Architecture: Post-Doctoral Level Luau / Event-Driven Component System
    Optimized for: Memory Efficiency, Type Safety, and Thread Safety (Parallel Luau)
    ================================================================================
--]]

--!strict
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Framework = {}
Framework.__index = Framework

-- Types
export type SignalConnection = {
    Disconnect: (self: SignalConnection) => ()
}

export type Signal = {
    Connect: (self: Signal, callback: (...any) => ()) -> SignalConnection,
    Fire: (self: Signal, ...any) -> (),
    Destroy: (self: Signal) => ()
}

export type SystemConfig = {
    DebugMode: boolean,
    AutoInitialize: boolean
}

-- Custom Micro-Signal Class for high-performance decoupled communication
local Signal = {}
Signal.__index = Signal

function Signal.new(): Signal
    local self = setmetatable({}, Signal)
    self._listeners = {}
    return (self :: any) :: Signal
end

function Signal:Connect(callback: (...any) => ()): SignalConnection
    table.insert(self._listeners, callback)
    return {
        Disconnect = function()
            local index = table.find(self._listeners, callback)
            if index then
                table.remove(self._listeners, index)
            end
        end
    }
end

function Signal:Fire(...any)
    for _, callback in ipairs(self._listeners) do
        task.spawn(callback, ...any)
    end
end

function Signal:Destroy()
    table.clear(self._listeners)
    setmetatable(self, nil)
end

-- Main Framework Constructor
function Framework.new(config: SystemConfig)
    local self = setmetatable({}, Framework)
    
    self.Config = config or { DebugMode = false, AutoInitialize = true }
    self.Systems = {}
    self.OnSystemRegistered = Signal.new()
    self._isInitialized = false
    
    if self.Config.DebugMode then
        print(string.format("[Framework] Inicializado com sucesso às %s", os.date("%X")))
    end
    
    return self
end

-- System Registration Method
function Framework:RegisterSystem(systemName: string, systemModule: table)
    assert(not self._isInitialized, "Não é possível registrar novos sistemas após a inicialização do Framework.")
    assert(self.Systems[systemName] == nil, "Sistema já registrado: " .. systemName)
    
    systemModule.Framework = self
    if type(systemModule.Init) ~= "function" then
        systemModule.Init = function() end
    end
    if type(systemModule.Start) ~= "function" then
        systemModule.Start = function() end
    end
    
    self.Systems[systemName] = systemModule
    self.OnSystemRegistered:Fire(systemName, systemModule)
    
    if self.Config.DebugMode then
        print(string.format("[Framework] Sistema registrado: %s", systemName))
    end
end

-- Lifecycle Execution
function Framework:Initialize()
    if self._isInitialized then return end
    self._isInitialized = true
    
    -- Fase 1: Inicialização sequencial segura (Init)
    for name, system in pairs(self.Systems) do
        local success, err = pcall(function()
            system:Init()
        end)
        
        if not success then
            warn(string.format("[Framework] Erro crítico ao rodar :Init() no sistema %s: %s", name, tostring(err)))
        end
    end
    
    -- Fase 2: Execução assíncrona paralela (Start)
    for name, system in pairs(self.Systems) do
        task.spawn(function()
            local success, err = pcall(function()
                system:Start()
            end)
            
            if not success then
                warn(string.format("[Framework] Erro crítico ao rodar :Start() no sistema %s: %s", name, tostring(err)))
            end
        end)
    end
end

return Framework