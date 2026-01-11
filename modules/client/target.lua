-- Imports ---------------------------------------------------------
local clientConfig = lib.require 'config.client'
local state = lib.require 'modules.client.state'
local speech = lib.require 'modules.client.speech'
local utils = lib.require 'modules.shared.utils'
local menu = lib.require 'modules.client.menu'
local object = lib.require 'modules.client.object'

-- Localised Functions ----------------------------------------------
local TriggerEvent = TriggerEvent

-- Local Variables ----------------------------------------------
local resourceName = GetCurrentResourceName()
local interactDistance = clientConfig.targets.distance or 2.5 ---@type number interaction distance

-- Functions -----------------------------------------------------------
---Get current AI character name
local function getName()
    return utils.capital(state.getCharacter())
end

---Generate target options for AI interaction
local function targetOptions()
    local options = {}
    local icons = clientConfig.theme.icons

    if MenuEnabled then
        if clientConfig.targets.showMenuInTargets then
            table.insert(options, {
                name = resourceName .. '_menu',
                label = locale('open_ai_menu'),
                icon = icons.menu,
                type = 'client',
                onSelect = function(data)
                    OpenMenu()
                end,
                distance = interactDistance,
            })
        end
    end

    local talkTo = locale('talk_to', getName())
    table.insert(options, {
        name = resourceName .. '_ai_talk',
        label = talkTo,
        icon = icons.talk,
        onSelect = function(data)
            local heading = talkTo
            local rows = {
                {
                    type = 'input',
                    label = locale('your_message'),
                    required = true,
                    min = 1,
                    max = 500
                }
            }

            local input = ClientInput.InputDialog(heading, rows)
            if not input then return end

            speech.talk(tostring(input[1]), data.coords or data.entity)
        end,
        distance = interactDistance,
    })

    table.insert(options, {
        name = resourceName .. '_ai_select',
        label = locale('change_ai_character'),
        icon = icons.select,
        openMenu = 'character_select',
        distance = interactDistance
    })

    if Characters then
        for _, char in ipairs(Characters) do
            local theme = utils.getTheme('characters', char)
            table.insert(options, {
                name = resourceName .. '_select_' .. char,
                label = utils.capital(char),
                icon = theme.icon,
                iconColor = theme.colour,
                menuName = 'character_select',
                onSelect = function(data)
                    TriggerEvent(resourceName .. ':client:setAI', char, data.coords or data.entity)
                end,
                distance = interactDistance
            })
        end
    end

    table.insert(options, {
        name = resourceName .. '_ai_callme',
        label = locale('change_addressal'),
        icon = icons.addressal,
        openMenu = 'addressal_select',
        distance = interactDistance
    })

    if Addressals then
        for _, addr in ipairs(Addressals) do
            local addrTheme = utils.getTheme('addressals', addr)
            table.insert(options, {
                name = resourceName .. '_select_' .. addr,
                label = utils.capital(addr),
                icon = addrTheme.icon,
                iconColor = addrTheme.colour,
                menuName = 'addressal_select',
                onSelect = function(data)
                    TriggerEvent(resourceName .. ':client:setAddressal', addr, data.coords or data.entity)
                end,
                distance = interactDistance
            })
        end
    end

    table.insert(options, {
        name = resourceName .. '_ai_speak',
        label = locale('get_random_comment', getName()),
        icon = icons.comment,
        onSelect = function(data)
            speech.playRandomLine(data.coords or data.entity)
        end,
        distance = interactDistance
    })

    return options
end

---Initialise sphere zones
local function initSphereZones()
    for _, target in pairs(clientConfig.targets.sphereZones) do
        local zoneName = resourceName .. '_sphere' .. tostring(_)
        local sphere = {
            name = zoneName,
            coords = target.coords,
            radius = target.radius,
            debug = target.debug or false,
            options = targetOptions()
        }

        ClientTarget.AddSphereZone(sphere)
    end
end

---Initialise box zones
local function initBoxZones()
    for _, target in pairs(clientConfig.targets.boxZones) do
        local zoneName = resourceName .. '_box' .. tostring(_)
        local box = {
            name = zoneName,
            coords = target.coords,
            size = target.size,
            rotation = target.rotation,
            debug = target.debug or false,
            options = targetOptions()
        }

        ClientTarget.AddBoxZone(box)
    end
end

---Initialise targets models
local function initTargetModels()
    if clientConfig.targets.models and #clientConfig.targets.models > 0 then
        local options = targetOptions()
        ClientTarget.AddModel(clientConfig.targets.models, options)
    end
end

---Update targets
local function updateTargets()
    for _, target in pairs(clientConfig.targets.sphereZones) do
        local zoneName = resourceName .. '_sphere' .. tostring(_)
        ClientTarget.RemoveZone(zoneName)
    end

    for _, target in pairs(clientConfig.targets.boxZones) do
        local zoneName = resourceName .. '_box' .. tostring(_)
        ClientTarget.RemoveZone(zoneName)
    end

    initSphereZones()
    initBoxZones()
    initTargetModels()

    local options = targetOptions()
    for id, obj in pairs(object.getObjects()) do
        -- because we don't want to dupe target options
        if not lib.table.contains(clientConfig.targets.models or {}, obj.model) then
            obj.target = options
            if obj.entity then
                ClientTarget.AddLocalEntity(obj.entity, options)
            end
        end
    end
end

-- Module Exports -----------------------------------------------
return {
    targetOptions = targetOptions,
    initSphereZones = initSphereZones,
    initBoxZones = initBoxZones,
    initTargetModels = initTargetModels,
    updateTargets = updateTargets
}