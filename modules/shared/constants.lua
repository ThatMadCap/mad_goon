-- Localised Functions ------------------------------------------
local string = string
local lower = string.lower
local pairs = pairs

-- Types --------------------------------------------------------
---@alias CharacterName 'angel'|'haviland'|'og'
---@alias Addressal 'male'|'female'
---@alias ModelName string

-- Constants ----------------------------------------------------
---Valid AI character names
---@type table<CharacterName, boolean>
local validCharacters = {
    ['angel'] = true,
    ['haviland'] = true,
    ['og'] = true
}

---Valid addressal options
---@type table<Addressal, boolean>
local validAddressals = {
    ['male'] = true,
    ['female'] = true
}

---Character to voice name mapping
---@type table<CharacterName, string>
local characterVoices = {
    ['angel'] = 'XM25_AISECRETARY',
    ['haviland'] = 'XM25_AIBUTLER',
    ['og'] = 'XM25_AIGANG'
}

---Speech parameters
---@type table<string, string>
local speechParams = {
    default = 'SPEECH_PARAMS_FORCE'
}

---Character tablet model mappings
---@type table<CharacterName|'blank', string>
local characterTabletModels = {
    blank = 'm25_2_prop_m52_aitablet',
    og = 'm25_2_prop_m52_aitablet_01a',
    haviland = 'm25_2_prop_m52_aitablet_02a',
    angel = 'm25_2_prop_m52_aitablet_03a',
}

---Character TV model mappings
---@type table<CharacterName, string>
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
    logColours = logColours,
    isValidCharacter = isValidCharacter,
    isValidAddressal = isValidAddressal,
    getVoiceName = getVoiceName,
    getAvailableCharacters = getAvailableCharacters,
    getAvailableAddressals = getAvailableAddressals,
}
