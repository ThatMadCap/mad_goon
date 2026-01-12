-- Imports ---------------------------------------------------------
local constants = lib.require('modules.shared.constants')
local clientConfig = lib.require('config.client')
local state = lib.require('modules.client.state')
local utils = lib.require('modules.shared.utils')
local speech = lib.require('modules.client.speech')

-- Local Variables ----------------------------------------------
local resourceName = GetCurrentResourceName()
local submenusRegistered = false

-- Functions ------------------------------------------------------
---Get current AI character name
local function getName()
    return utils.capital(state.getCharacter())
end

---Build character selection menu options
local function buildCharacterOptions()
    local charOptions = {}

    for _, character in ipairs(constants.getAvailableCharacters()) do
        local theme = utils.getTheme('characters', character)
        table.insert(charOptions, {
            title = utils.capital(character),
            icon = theme.icon,
            iconColor = theme.colour,
            onSelect = function()
                TriggerEvent(resourceName .. ':client:setAI', character)
                OpenMenu()
            end,
        })
    end

    return charOptions
end

---Build addressal selection menu options
local function buildAddressalOptions()
    local addressalOptions = {}

    for _, addressalOption in ipairs(constants.getAvailableAddressals()) do
        local addrTheme = utils.getTheme('addressals', addressalOption)
        table.insert(addressalOptions, {
            title = utils.capital(addressalOption),
            icon = addrTheme.icon,
            iconColor = addrTheme.colour,
            onSelect = function()
                TriggerEvent(resourceName .. ':client:setAddressal', addressalOption)
                OpenMenu()
            end,
        })
    end

    return addressalOptions
end

---Registers submenus if not already registered
local function ensureSubmenusRegistered()
    if submenusRegistered then
        return
    end

    ClientMenu.Open({
        id = resourceName .. '_select_character',
        menu = resourceName .. '_main',
        title = locale('change_ai_character'),
        options = buildCharacterOptions(),
    })
    ClientMenu.Close()

    ClientMenu.Open({
        id = resourceName .. '_change_addressal',
        menu = resourceName .. '_main',
        title = locale('change_addressal'),
        options = buildAddressalOptions(),
    })
    ClientMenu.Close()

    submenusRegistered = true
end

---Opens the AI interaction menu
function OpenMenu()
    if not MenuEnabled then
        return
    end

    ensureSubmenusRegistered()

    local icons = clientConfig.theme.icons
    local talkTo = locale('talk_to', getName())

    local options = {
        {
            title = talkTo,
            icon = icons.talk,
            canClose = false,
            onSelect = function()
                local heading = talkTo
                local rows = {
                    {
                        type = 'input',
                        label = locale('your_message'),
                        required = true,
                        min = 1,
                        max = 200,
                    },
                }

                local input = ClientInput.InputDialog(heading, rows)
                if not input then
                    OpenMenu()
                    return
                end

                speech.talk(tostring(input[1]))
                OpenMenu()
            end,
        },
        {
            title = locale('change_ai_character'),
            icon = icons.select,
            menu = resourceName .. '_select_character',
        },
        {
            title = locale('change_addressal'),
            icon = icons.addressal,
            menu = resourceName .. '_change_addressal',
        },
        {
            title = locale('get_random_comment', getName()),
            icon = icons.comment,
            onSelect = function()
                speech.playRandomLine()
                OpenMenu()
            end,
        },
    }

    ClientMenu.Open({
        id = resourceName .. '_main',
        title = locale('menu_title', utils.capital(state.getCharacter()), getName()),
        options = options,
    })
end

-- Exports --------------------------------------------------------
exports('openMenu', OpenMenu)
