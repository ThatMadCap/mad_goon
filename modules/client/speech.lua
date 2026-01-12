-- Imports ---------------------------------------------------------
local sharedConfig = lib.require('config.shared')
local constants = lib.require('modules.shared.constants')
local utils = lib.require('modules.shared.utils')
local state = lib.require('modules.client.state')

-- Localised Functions ---------------------------------------------
local string = string
local format = string.format
local gsub = string.gsub
local type = type
local GetEntityCoords = GetEntityCoords
local vector3 = vector3
local PlayAmbientSpeechFromPositionNative = PlayAmbientSpeechFromPositionNative

-- Local Variables ----------------------------------------------
local resourceName = GetCurrentResourceName()

-- Functions --------------------------------------------------------
---Resolve location for speech playback
---@param location? LocationInput Location to resolve
---@return vector3 coords Resolved world coordinates
local function resolveLocation(location)
    local pedCoords = GetEntityCoords(cache.ped)

    if not location then
        return pedCoords
    end

    if utils.isVec3(location) then
        return vector3(location.x, location.y, location.z)
    end

    if utils.isEntity(location) then
        ---@diagnostic disable-next-line: param-type-mismatch
        return GetEntityCoords(location)
    end

    if utils.isOffset(location) then
        return vector3(pedCoords.x + location[1], pedCoords.y + location[2], pedCoords.z + location[3])
    end

    local locationDistance = sharedConfig.sound.location.distance
    local locationZOffset = sharedConfig.sound.location.zOffset

    if type(location) == 'string' then
        if location == 'above' then
            return vector3(pedCoords.x, pedCoords.y, pedCoords.z + locationZOffset)
        elseif location == 'below' then
            return vector3(pedCoords.x, pedCoords.y, pedCoords.z - locationZOffset)
        elseif location == 'front' then
            return utils.getDirectionalOffset(locationDistance, 0)
        elseif location == 'behind' then
            return utils.getDirectionalOffset(locationDistance, 180)
        elseif location == 'left' then
            return utils.getDirectionalOffset(locationDistance, 270)
        elseif location == 'right' then
            return utils.getDirectionalOffset(locationDistance, 90)
        end
    end

    lib.print.warn(format('Unknown location type: %s, using player coords', type(location)))

    return pedCoords
end

---Resolve speech name with proper suffix based on addressal
---@param baseSpeechName string Base speech name without gender suffix
---@param addressal Addressal Player's addressal preference
---@return string completeSpeechName Complete speech name with gender suffix
local function resolveSpeechName(baseSpeechName, addressal)
    -- because sometimes because R* uses a different pattern
    if baseSpeechName:match('_[MF]_') then
        local wantsFemale = (addressal == 'female')
        local hasFemale = baseSpeechName:match('_F_')

        if (wantsFemale and hasFemale) or (not wantsFemale and not hasFemale) then
            return baseSpeechName
        end

        if wantsFemale then
            return (baseSpeechName:gsub('_M_', '_F_'))
        else
            return (baseSpeechName:gsub('_F_', '_M_'))
        end
    end

    if baseSpeechName:match('_MALE') or baseSpeechName:match('_FEMALE') then
        local wantsFemale = (addressal == 'female')
        local hasFemale = baseSpeechName:match('_FEMALE')

        if (wantsFemale and hasFemale) or (not wantsFemale and not hasFemale) then
            return baseSpeechName
        end

        if wantsFemale then
            return (baseSpeechName:gsub('_MALE', '_FEMALE'))
        else
            return (baseSpeechName:gsub('_FEMALE', '_MALE'))
        end
    end

    -- because R* uses _M/_F for these instead of _MALE/_FEMALE
    local useShortSuffix = (
        baseSpeechName == 'XM25_REQUEST_LUXURY_VEH'
        or baseSpeechName == 'XM25_VAULT_IDLE_BILLIONAIRE'
        or baseSpeechName == 'XM25_VAULT_IDLE_MONEY_LOW'
        or baseSpeechName == 'XM25_VAULT_IDLE_MONEY_HIGH'
        or baseSpeechName == 'XM25_MANSION_DEFEND_COMPLETE'
    )

    -- because R* uses no gender variants for this
    local noGenderSuffix = (baseSpeechName == 'XM25_THROW_PARTY_IDLES')
    if noGenderSuffix then
        return baseSpeechName
    end

    local suffix = useShortSuffix and ((addressal == 'female') and '_F' or '_M') or ((addressal == 'female') and '_FEMALE' or '_MALE')

    return baseSpeechName .. suffix
end

---Strip gender suffix to get base speech name
---@param speechName string Speech name potentially with gender suffix
---@return string baseName Base speech name without suffix
local function getBaseSpeechName(speechName)
    local baseName = gsub(speechName, '_MALE$', '')
    baseName = gsub(baseName, '_FEMALE$', '')
    baseName = gsub(baseName, '_M$', '')
    baseName = gsub(baseName, '_F$', '')

    return baseName
end

---Play speech line
---@param speechName string Base speech name
---@param character CharacterName Character voice to use
---@param addressal Addressal Player's addressal preference
---@param isNetworked boolean Whether to play for nearby players
---@param location? LocationInput Optional location for speech playback
local function playSpeech(speechName, character, addressal, isNetworked, location)
    assert(type(speechName) == 'string', 'speechName must be a string')
    assert(type(character) == 'string', 'character must be a string')
    assert(constants.isValidCharacter(character), 'invalid character name: ' .. tostring(character))
    assert(type(addressal) == 'string', 'addressal must be a string')
    assert(constants.isValidAddressal(addressal), 'invalid addressal: ' .. tostring(addressal))

    local baseName = getBaseSpeechName(speechName)
    local finalName = resolveSpeechName(baseName, addressal)
    local voiceName = constants.getVoiceName(character)
    local finalLocation = resolveLocation(location)

    PlayAmbientSpeechFromPositionNative(finalName, voiceName, finalLocation.x, finalLocation.y, finalLocation.z, constants.speechParams.default)
    lib.print.debug(format('Playing Speech: "%s" | Location: %s | Voice: "%s"', finalName, tostring(finalLocation), voiceName))

    if isNetworked == nil then
        isNetworked = true
    end

    if not isNetworked then
        return
    end

    TriggerServerEvent(resourceName .. ':server:playSpeech', {
        speechName = finalName,
        voiceName = voiceName,
        location = finalLocation,
        speechParams = constants.speechParams.default,
    })
end

---Play voice response for an intent/topic
---@param data table Data containing speechName, topic, location
local function playResponse(data, message)
    if not data.speechName then
        return
    end

    if not data.topic then
        data.topic = locale('unknown')
    end

    local currentCharacter = state.getCharacter()
    local currentAddressal = state.getAddressal()

    lib.print.debug(
        format(
            'AI: "%s" | Responding to: "%s" | Message: "%s" | Topic: "%s"',
            utils.capital(currentCharacter),
            utils.capital(currentAddressal),
            message or 'no message',
            utils.capital(data.topic)
        )
    )

    local theme = utils.getTheme('characters', currentCharacter)
    ClientNotify.Notify({
        title = utils.capital(currentCharacter),
        description = locale('ai_responding'),
        icon = theme.icon,
        iconColor = theme.colour,
        type = 'info',
        duration = sharedConfig.notify.duration,
    })

    playSpeech(data.speechName, currentCharacter, currentAddressal, data.isNetworked, data.location)
end

---Send a message to the AI and get a voice response (routes to server NLP processing)
---@param message string The message to send to the AI
---@param isNetworked boolean Whether to play for nearby players
---@param location? LocationInput Optional location for speech playback (defaults to player ped)
---@return boolean success Whether the request was successful
local function talk(message, isNetworked, location)
    if not message or type(message) ~= 'string' or #message == 0 then
        lib.print.warn('talk: Invalid message')
        return false
    end

    local success = lib.callback.await(resourceName .. ':server:talk', false, message, isNetworked, location)

    return success or false
end

---Plays a random voice line
local function playRandomLine(isNetworked, location)
    local speechName = lib.callback.await(resourceName .. ':server:getRandomLine', false)
    if not speechName then
        lib.print.warn('Failed to get random line')
        return
    end

    local currentCharacter = state.getCharacter()
    local currentAddressal = state.getAddressal()

    playSpeech(speechName, currentCharacter, currentAddressal, isNetworked, location)
end

-- Exports -----------------------------------------------------------
exports('talk', talk)
exports('playSpeech', playSpeech)
exports('playRandomLine', playRandomLine)

-- Module Exports -----------------------------------------------
return {
    resolveSpeechName = resolveSpeechName,
    playSpeech = playSpeech,
    playResponse = playResponse,
    talk = talk,
    playRandomLine = playRandomLine,
}
