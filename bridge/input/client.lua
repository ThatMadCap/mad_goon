-- Imports --------------------------------------
local config = lib.require('config.shared')

-- Localised Functions --------------------------
local GetResourceState = GetResourceState
local ipairs = ipairs

-- Global Variables -----------------------------
ClientInput = {}

-- Local Variables ------------------------------
local inputs = {
    { name = 'ox_lib', bridge = 'ox' },
}

local inputFound = false
local selectedInput = config.input or 'ox_lib'

-- Logic ----------------------------------------
for _, resource in ipairs(inputs) do
    if resource.name == selectedInput and (resource.name == 'ox_lib' or GetResourceState(resource.name) == 'started') then
        lib.load(('bridge.input.%s.client'):format(resource.bridge))
        lib.print.debug(('Input system selected: %s'):format(resource.name))
        inputFound = true
        break
    end
end

if not inputFound then
    lib.load('bridge.input.custom.client')
    lib.print.warn('Configured input system not found: falling back to custom')
end
