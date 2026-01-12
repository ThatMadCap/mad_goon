-- Imports ---------------------------------------------------------
local nlp = lib.require('modules.shared.nlp_tfidf')
local cooldown = lib.require('modules.server.cooldown')
local commands = lib.require('modules.server.commands')
local speech = lib.require('modules.server.speech')
local serverConfig = lib.require('config.server')
local logs = lib.require('modules.server.logs')

-- Localised Functions ----------------------------------------------
local AddEventHandler = AddEventHandler
local GetCurrentResourceName = GetCurrentResourceName
local TriggerClientEvent = TriggerClientEvent

-- Local Variables ----------------------------------------------
local resourceName = GetCurrentResourceName()

-- Functions ------------------------------------------------------
---Broadcast speech to nearby players
---@param src number Source player
---@param data SpeechData
local function broadcastSpeech(src, data)
    if not serverConfig.sound.enableNetworked then
        return
    end

    TriggerClientEvent(resourceName .. ':client:playSpeechAtLocation', -1, src, data)
end

-- Callbacks -------------------------------------------------------
-- Get enabled features
lib.callback.register(resourceName .. ':server:getEnabledFeatures', function(source)
    return {
        menuEnabled = serverConfig.enableMenu,
        targetEnabled = serverConfig.enableTarget,
    }
end)

-- Callback for client-side talk
lib.callback.register(resourceName .. ':server:talk', function(source, message, location)
    if cooldown.isOnCooldown(source) then
        return false
    end

    return speech.talk(source, message, location)
end)

-- Get random speech line
lib.callback.register(resourceName .. ':server:getRandomLine', function(source)
    return speech.getRandomLine()
end)

-- Event Registration ------------------------------------------------
---Handle playing speech from client
---@param data SpeechData
RegisterNetEvent(resourceName .. ':server:playSpeech', function(data)
    broadcastSpeech(source, data)
end)

-- Initialisation -----------------------------------------------------
local function init()
    if not nlp.isModelReady() then
        nlp.initNLP()
    end

    lib.cron.new('* * * * *', function()
        logs.postLogs()
    end)

    commands.initCommands()
end

lib.versionCheck('ThatMadCap/mad_goon')

-- Event Handlers --------------------------------------------------
AddEventHandler('onResourceStart', function(resName)
    if resourceName ~= resName then
        return
    end

    init()
end)

AddEventHandler('playerDropped', function()
    cooldown.playerCooldowns[source] = nil
end)
