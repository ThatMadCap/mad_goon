-- Imports ---------------------------------------------------------
local sharedConfig = lib.require 'config.shared'
local clientConfig = lib.require 'config.client'
local constants = lib.require 'modules.shared.constants'
local utils = lib.require 'modules.shared.utils'

-- Localised Functions ---------------------------------------------
local string = string
local lower = string.lower
local SetResourceKvp = SetResourceKvp
local GetResourceKvpString = GetResourceKvpString
local IsPedMale = IsPedMale

-- Local Variables ----------------------------------------------
local resourceName = GetCurrentResourceName()

-- Local Functions -----------------------------------------------
---Normalise character name to canonical lowercase
---@param name string
---@return CharacterName|nil
local function normaliseCharacterName(name)
    local lowered = lower(name)
    if constants.validCharacters[lowered] then
        return lowered
    end
    return nil
end

---Normalise addressal to canonical lowercase
---@param addressal string
---@return Addressal|nil
local function normaliseAddressal(addressal)
    local lowered = lower(addressal)
    if constants.validAddressals[lowered] then
        return lowered
    end
    return nil
end

-- Functions --------------------------------------------------------
---Get current selected character
---@return CharacterName character
local function getCharacter()
    local kvp = GetResourceKvpString(resourceName .. ':character')
    if kvp and constants.isValidCharacter(kvp) then
        return kvp
    end
    return clientConfig.defaultCharacter
end

---Get current selected addressal
---@return Addressal addressal
local function getAddressal()
    local kvp = GetResourceKvpString(resourceName .. ':addressal')
    if kvp and constants.isValidAddressal(kvp) then
        return kvp
    end
    return IsPedMale(cache.ped) and 'male' or 'female'
end

---Set character voice
---@param character CharacterName 'angel', 'haviland', or 'og'
---@return boolean success
local function setCharacter(character)
    if not character then return false end
    if not constants.isValidCharacter(character) then return false end

    local normalised = normaliseCharacterName(character)
    local theme = utils.getTheme('characters', normalised)

    if not normalised then
        ClientNotify.Notify({
            title = locale('ai_selection'),
            description = locale('invalid_ai_character', character),
            icon = theme.icon,
            iconColor = theme.colour,
            type = 'error',
            duration = sharedConfig.notify.duration
        })
        return false
    end

    ClientNotify.Notify({
        title = locale('ai_updated'),
        description = locale('ai_using_voice', utils.capital(character)),
        icon = theme.icon,
        iconColor = theme.colour,
        type = 'success',
        duration = sharedConfig.notify.duration
    })

    SetResourceKvp(resourceName .. ':character', normalised)
    return true
end

---Set addressal (how the player is referred to)
---@param addressal Addressal 'male' or 'female'
---@return boolean success
local function setAddressal(addressal)
    if not addressal then return false end
    if not constants.isValidAddressal(addressal) then return false end

    local normalised = normaliseAddressal(addressal)
    local addrTheme = utils.getTheme('addressals', normalised)

    if not normalised then
        ClientNotify.Notify({
            title = locale('addressal_selection'),
            description = locale('invalid_addressal_choice'),
            icon = addrTheme.icon,
            iconColor = addrTheme.colour,
            type = 'error',
            duration = sharedConfig.notify.duration
        })
        return false
    end

    ClientNotify.Notify({
        title = locale('addressal_updated'),
        description = locale('addressal_now', utils.capital(addressal)),
        icon = addrTheme.icon,
        iconColor = addrTheme.colour,
        type = 'success',
        duration = sharedConfig.notify.duration
    })

    SetResourceKvp(resourceName .. ':addressal', normalised)
    return true
end

-- Exports ------------------------------------------------------
exports('setCharacter', setCharacter)
exports('setAddressal', setAddressal)
exports('getCharacter', getCharacter)
exports('getAddressal', getAddressal)

-- Module Exports -----------------------------------------------
return {
    getCharacter = getCharacter,
    getAddressal = getAddressal,
    setCharacter = setCharacter,
    setAddressal = setAddressal,
}