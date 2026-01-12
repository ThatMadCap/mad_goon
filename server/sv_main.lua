-- Imports ---------------------------------------------------------
local nlp = lib.require('modules.shared.nlp_tfidf')
local cooldown = lib.require('modules.server.cooldown')
local commands = lib.require('modules.server.commands')
local speech = lib.require('modules.server.speech')
local serverConfig = lib.require('config.server')
local logs = lib.require('modules.server.logs')

-- Localised Functions ----------------------------------------------
local string = string
local gsub = string.gsub
local match = string.match
local GetCurrentResourceName = GetCurrentResourceName
local TriggerClientEvent = TriggerClientEvent
local GetResourceMetadata = GetResourceMetadata
local AddEventHandler = AddEventHandler

-- Local Variables ----------------------------------------------
local resourceName = GetCurrentResourceName()

-- Functions ------------------------------------------------------
---Checks resource metadata for cheeky gits
local function checkResourceMeta()
    local currentAuthor = GetResourceMetadata(resourceName, 'author', 0)
    assert(currentAuthor == 'MadCap', locale('not_author', currentAuthor or 'unknown'))

    local currentResourceName = GetResourceMetadata(resourceName, 'name', 0)
    assert(currentResourceName == 'mad_goon', locale('resource_name_changed', currentResourceName or 'unknown'))
end

---Checks if the resource is a fork
---@return boolean isFork Whether the resource is a fork
---@return string repo The repository string (owner/repo)
---@return string owner The repository owner
local function isFork()
    local originalRepo = 'ThatMadCap/mad_goon'

    local repo = GetResourceMetadata(resourceName, 'repository', 0) or originalRepo
    repo = gsub(repo, 'https?://github%.com/', '')

    local owner = match(repo, '^([^/]+)/')

    return repo ~= originalRepo, repo, owner
end

---Performs version check unless forked
local function versionCheck()
    local forked, repo, owner = isFork()

    if forked then
        lib.print.warn(locale('fork_detected', owner))
        return
    end

    lib.versionCheck(repo)
end

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
    versionCheck()
    checkResourceMeta()

    if not nlp.isModelReady() then
        nlp.initNLP()
    end

    lib.cron.new('* * * * *', function()
        logs.postLogs()
    end)

    commands.initCommands()
end

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
