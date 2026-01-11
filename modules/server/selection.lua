-- Localised Functions ------------------------------------------
local TriggerClientEvent = TriggerClientEvent

-- Local Variables ----------------------------------------------
local resourceName = GetCurrentResourceName()

-- Functions -------------------------------------------------------
---Selects the AI character for the client
---@param source number Client source
---@param characterName string Character name
local function selectCharacter(source, characterName)
    local selectedAi = characterName or 'angel'
    TriggerClientEvent(resourceName .. ':client:setAI', source, selectedAi)
end

---Selects the term of address for the client
---@param source number Client source
---@param addressal string Term of address ('male' or 'female')
local function selectAddressal(source, addressal)
    local selectedAddressal = addressal or 'female'
    TriggerClientEvent(resourceName .. ':client:setAddressal', source, selectedAddressal)
end

-- Module Exports -----------------------------------------------
return {
    selectCharacter = selectCharacter,
    selectAddressal = selectAddressal,
}
