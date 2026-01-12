-- Imports --------------------------------------
local config = lib.require('config.shared')

-- Localised Functions --------------------------
local GetResourceState = GetResourceState
local ipairs = ipairs

-- Global Variables -----------------------------
ClientMenu = {}

-- Local Variables ------------------------------
local menus = {
    { name = 'ox_lib', bridge = 'ox' },
}

local menuFound = false
local selectedMenu = config.menu or 'ox_lib'

-- Logic ----------------------------------------
for _, resource in ipairs(menus) do
    if resource.name == selectedMenu and (resource.name == 'ox_lib' or GetResourceState(resource.name) == 'started') then
        lib.load(('bridge.menu.%s.client'):format(resource.bridge))
        lib.print.debug(('Menu system selected: %s'):format(resource.name))
        menuFound = true
        break
    end
end

if not menuFound then
    lib.load('bridge.menu.ox.client')
    lib.print.warn('Configured menu system not found: falling back to ox_lib')
end
