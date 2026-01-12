-- Localised Functions --------------------------
local GetResourceState = GetResourceState
local ipairs = ipairs

-- Global Variables -----------------------------
ClientTarget = {}

-- Local Variables ------------------------------
local targets = {
    { name = 'ox_target', bridge = 'ox' },
}

local targetFound = false

-- Logic ----------------------------------------
for _, resource in ipairs(targets) do
    if GetResourceState(resource.name) == 'started' then
        lib.load(('bridge.target.%s.client'):format(resource.bridge))
        lib.print.debug(('Target system found: %s'):format(resource.name))
        targetFound = true
        break
    end
end

if not targetFound then
    lib.load('bridge.target.custom.client')
    lib.print.warn('No target system found: falling back to custom')
end
