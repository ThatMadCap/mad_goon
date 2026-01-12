-- Imports --------------------------------------
local config = lib.require('config.shared')

-- Localised Functions --------------------------
local GetResourceState = GetResourceState
local ipairs = ipairs

-- Global Variables -----------------------------
ServerNotify = {}

-- Local Variables ------------------------------
local notify = {
    { name = 'ox_lib', bridge = 'ox' },
    { name = 'qb-core', bridge = 'qb' },
    { name = 'mad-thoughts', bridge = 'mad' },
}

local notifyFound = false
local selectedNotify = config.notify.type or 'ox_lib'

-- Logic ----------------------------------------
for _, resource in ipairs(notify) do
    if resource.name == selectedNotify and GetResourceState(resource.name) == 'started' then
        lib.load(('bridge.notify.%s.server'):format(resource.bridge))
        lib.print.debug(('Notify selected: %s'):format(resource.name))
        notifyFound = true
        break
    end
end

if config.notify.type == 'custom' then
    notifyFound = true
    lib.load('bridge.notify.custom.server')
    lib.print.debug('Custom notify selected')
end

if not notifyFound then
    lib.load('bridge.notify.custom.server')
    lib.print.warn('No notify resource found: falling back to custom')
end
