-- Imports ---------------------------------------------------------
lib.locale()
local constants = lib.require('modules.shared.constants')
local clientConfig = lib.require('config.client')
local state = lib.require('modules.client.state')
local speech = lib.require('modules.client.speech')
local target = lib.require('modules.client.target')
local object = lib.require('modules.client.object')

-- Localised Functions ----------------------------------------------
local string = string
local format = string.format
local RegisterNetEvent = RegisterNetEvent
local GetClockHours = GetClockHours
local AddEventHandler = AddEventHandler
local GetCurrentResourceName = GetCurrentResourceName
local GetGameBuildNumber = GetGameBuildNumber
local assert = assert

-- Global Variables ----------------------------------------------
MenuEnabled = false ---@type boolean cached menu enabled state
TargetEnabled = false ---@type boolean cached target enabled state
Characters = nil ---@type CharacterName[] cached available characters
Addressals = nil ---@type Addressal[] cached available addressals

-- Local Variables ----------------------------------------------
local resourceName = GetCurrentResourceName()

-- Event Registration ------------------------------------------------
-- Handles playing voice response
---@param data SpeechData
RegisterNetEvent(resourceName .. ':client:playVoice', function(data, message)
    if not data then
        return
    end

    speech.playResponse(data, message)
end)

-- Handles setting character
RegisterNetEvent(resourceName .. ':client:setAI', function(character, location)
    if not character then
        return
    end

    local success = state.setCharacter(character)
    if not success then
        return
    end

    speech.playSpeech('XM25_GENERIC_HI', character, state.getAddressal(), location)
    target.updateTargets()
    object.updateObjectForCharacter(character)
end)

-- Handles setting addressal
RegisterNetEvent(resourceName .. ':client:setAddressal', function(addressal, location)
    if not addressal then
        return
    end

    local success = state.setAddressal(addressal)
    if not success then
        return
    end

    speech.playSpeech('XM25_GENERIC_POSITIVE', state.getCharacter(), addressal, location)
end)

-- Handles opening menu
RegisterNetEvent(resourceName .. ':client:openMenu', function()
    OpenMenu()
end)

-- Handles playing random speech line
RegisterNetEvent(resourceName .. ':client:playRandomSpeech', function()
    if source ~= 65535 then
        return
    end

    speech.playRandomLine()
end)

-- Receive networked speech and play if within range
RegisterNetEvent(resourceName .. ':client:playSpeechAtLocation')
AddEventHandler(resourceName .. ':client:playSpeechAtLocation', function(sourcePlayer, data)
    if source ~= 65535 then
        return
    end

    if sourcePlayer == cache.serverId then
        return
    end

    local sourceCoords = data.location
    local playerCoords = GetEntityCoords(cache.ped)
    local distance = #(playerCoords - sourceCoords)
    local maxDistance = 20.0

    if distance < maxDistance then
        PlayAmbientSpeechFromPositionNative(data.speechName, data.voiceName, data.location.x, data.location.y, data.location.z, data.speechParams)
    end
end)

-- Callback Registration -----------------------------------------------
-- Provide current player state to server
lib.callback.register(resourceName .. ':client:getState', function()
    local addressal = state.getAddressal()
    return {
        isMale = (addressal == 'male'),
        hour = GetClockHours(),
    }
end)

-- Initialisation -----------------------------------------------------
---Assert that the game build is sufficient
local function assertGameBuild()
    local gameBuild = GetGameBuildNumber()
    local requiredBuild = 3717
    local message = resourceName .. ' requires game build %d or higher (current: %d)'
    assert(gameBuild >= requiredBuild, format(message, requiredBuild, gameBuild))
end

---Get and cache enabled features from server
local function getFeatures()
    local features = lib.callback.await(resourceName .. ':server:getEnabledFeatures', false) or {}
    MenuEnabled = features.menuEnabled or false
    TargetEnabled = features.targetEnabled or false
end

---Cache constant data
local function cacheConstants()
    Characters = constants.getAvailableCharacters()
    Addressals = constants.getAvailableAddressals()
end

---Initialise objects from config
local function initObjects()
    if not clientConfig.enableObjects then
        return
    end

    if not clientConfig.objects then
        return
    end

    for _, objConfig in ipairs(clientConfig.objects) do
        -- because we don't want to dupe target options
        if not lib.table.contains(clientConfig.targets.models or {}, objConfig.model) then
            objConfig.target = target.targetOptions()
        end
        object.addObject(objConfig)
    end
end

---Initialise targets
local function initTargets()
    if not TargetEnabled then
        return
    end

    target.initSphereZones()
    target.initBoxZones()
    target.initTargetModels()
end

---Initialise
local function init()
    assertGameBuild()
    getFeatures()
    cacheConstants()
    initObjects()
    initTargets()
end

-- Cleanup ---------------------------------------------------------
local function cleanup()
    for id, _ in pairs(object.getObjects()) do
        object.removeObject(id)
    end
end

-- Event Handlers --------------------------------------------------
AddEventHandler('onClientResourceStart', function(resName)
    if GetCurrentResourceName() ~= resName then
        return
    end

    init()
end)

AddEventHandler('onResourceStop', function(resName)
    if GetCurrentResourceName() ~= resName then
        return
    end

    cleanup()
end)
