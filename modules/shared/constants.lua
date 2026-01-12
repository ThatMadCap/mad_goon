-- Localised Functions ------------------------------------------
local string = string
local lower = string.lower
local pairs = pairs

-- Types --------------------------------------------------------

---Available AI character names
---@alias CharacterName
---| 'angel' # Female secretary AI
---| 'haviland' # Male butler AI
---| 'og' # Male gang AI

---Player addressal preference for gendered speech lines
---@alias Addressal
---| 'male' # Use male speech variants
---| 'female' # Use female speech variants

---@alias LocationInput nil|vector3|number|string|{x:number,y:number,z:number}|number[]

---Data structure for speech playback
---@class SpeechData
---@field speechName string Base speech name (gender suffix auto-resolved)
---@field character CharacterName AI character voice to use
---@field addressal Addressal Player's gender preference for speech
---@field isNetworked? boolean Whether to play for nearby players
---@field location? LocationInput Optional location for speech playback

-- Constants ----------------------------------------------------

---Valid AI character names for validation
---@enum ValidCharacters
local validCharacters = {
    angel = true,
    haviland = true,
    og = true,
}

---Valid addressal options for validation
---@enum ValidAddressals
local validAddressals = {
    male = true,
    female = true,
}

---Character to GTA voice name mapping
---@enum CharacterVoices
local characterVoices = {
    angel = 'XM25_AISECRETARY',
    haviland = 'XM25_AIBUTLER',
    og = 'XM25_AIGANG',
}

---Speech parameters for native calls
---@enum SpeechParams
local speechParams = {
    default = 'SPEECH_PARAMS_FORCE',
}

---Character tablet prop model mappings
---@enum CharacterTabletModels
local characterTabletModels = {
    blank = 'm25_2_prop_m52_aitablet',
    og = 'm25_2_prop_m52_aitablet_01a',
    haviland = 'm25_2_prop_m52_aitablet_02a',
    angel = 'm25_2_prop_m52_aitablet_03a',
}

---Character TV prop model mappings
---@enum CharacterTVModels
local characterTVModels = {
    og = 'm25_2_prop_m52_mansiontv_ogai',
    haviland = 'm25_2_prop_m52_mansiontv_havilandai',
    angel = 'm25_2_prop_m52_mansiontv_angelai',
}

-- Functions ----------------------------------------------------
---Get list of available character names
---@return CharacterName[]
local function getCharacterList()
    local list = {}
    for name in pairs(validCharacters) do
        list[#list + 1] = name
    end

    return list
end

---Get list of available addressal options
---@return Addressal[]
local function getAddressalList()
    local list = {}
    for name in pairs(validAddressals) do
        list[#list + 1] = name
    end

    return list
end

---Check if a character name is valid
---@param name string
---@return boolean
local function isValidCharacter(name)
    return validCharacters[lower(name)] == true
end

---Check if an addressal is valid
---@param addressal string
---@return boolean
local function isValidAddressal(addressal)
    return validAddressals[lower(addressal)] == true
end

---Get voice name for a character
---@param character CharacterName
---@return string voiceName
local function getVoiceName(character)
    return characterVoices[lower(character)] or characterVoices['angel']
end

---Get list of available characters
---@return CharacterName[] table available characters
local function getAvailableCharacters()
    return getCharacterList()
end

---Get list of available addressals
---@return Addressal[] table available addressals
local function getAvailableAddressals()
    return getAddressalList()
end

-- Exports ---------------------------------------------------
exports('getAvailableCharacters', getAvailableCharacters)
exports('getAvailableAddressals', getAvailableAddressals)

-- Module Exports ---------------------------------------------
return {
    speechParams = speechParams,
    validCharacters = validCharacters,
    validAddressals = validAddressals,
    characterTabletModels = characterTabletModels,
    characterTVModels = characterTVModels,
    isValidCharacter = isValidCharacter,
    isValidAddressal = isValidAddressal,
    getVoiceName = getVoiceName,
    getAvailableCharacters = getAvailableCharacters,
    getAvailableAddressals = getAvailableAddressals,
}
