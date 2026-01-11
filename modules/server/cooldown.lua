-- Imports ---------------------------------------------------------
local serverConfig = lib.require 'config.server'

-- Local Variables ----------------------------------------------
local playerCooldowns = {} ---@type table<number, number> Player source, last use timestamp

-- Localised Functions ----------------------------------------------
local string = string
local format = string.format
local GetGameTimer = GetGameTimer

-- Functions ----------------------------------------------------
---Check if player is on cooldown
---@param source number Player source
---@return boolean isOnCooldown
local function isOnCooldown(source)
    if not serverConfig.rateLimit.enabled then return false end

    local now = GetGameTimer()
    local lastUse = playerCooldowns[source]

    if lastUse and (now - lastUse) < serverConfig.rateLimit.cooldown then
        return true
    end

    playerCooldowns[source] = now
    return false
end

---Get remaining cooldown time
---@param source number Player source
---@return number remainingMs
local function getRemainingCooldown(source)
    if not playerCooldowns[source] then return 0 end
    local remaining = serverConfig.rateLimit.cooldown - (GetGameTimer() - playerCooldowns[source])
    return remaining > 0 and remaining or 0
end

--- Check cooldown for player
---@param source number Player source
---@return boolean allowed Whether the player is allowed to proceed
local function checkCooldown(source)
    if isOnCooldown(source) then
        lib.print.debug(format('Player %d on cooldown (%dms remaining)', source, getRemainingCooldown(source)))
        return false
    end

    return true
end

-- Module Exports ------------------------------------------------
return {
    playerCooldowns = playerCooldowns,
    isOnCooldown = isOnCooldown,
    getRemainingCooldown = getRemainingCooldown,
    checkCooldown = checkCooldown,
}