-- Imports ---------------------------------------------------------
local nlp = lib.require('modules.shared.nlp_tfidf')
local cooldown = lib.require('modules.server.cooldown')
local speech = lib.require('modules.server.speech')
local selection = lib.require('modules.server.selection')
local serverConfig = lib.require('config.server')

-- Localised Functions ----------------------------------------------
local string = string
local format = string.format
local TriggerClientEvent = TriggerClientEvent

-- Local Variables ----------------------------------------------
local resourceName = GetCurrentResourceName()

-- Commands --------------------------------------------------------
---Main command to capture client input and get a response
local function talkCommand()
    if not serverConfig.commands.talk.enabled then
        return
    end

    lib.addCommand(serverConfig.commands.talk.commandName, {
        help = serverConfig.commands.talk.help,
        params = serverConfig.commands.talk.params,
        restricted = serverConfig.commands.talk.permission,
    }, function(source, args)
        if not nlp.isModelReady() then
            return
        end

        local allowed = cooldown.checkCooldown(source)
        if not allowed then
            return
        end

        local message = args?.message
        if not message or #message == 0 then
            return
        end

        lib.print.debug(format('Player %d said: "%s"', source, message))
        speech.talk(source, message)
    end)
end

---Command to select AI character
local function selectCommand()
    if not serverConfig.commands.select.enabled then
        return
    end

    lib.addCommand(serverConfig.commands.select.commandName, {
        help = serverConfig.commands.select.help,
        params = serverConfig.commands.select.params,
        restricted = serverConfig.commands.select.permission,
    }, function(source, args)
        local character = args?.character
        if not character then
            return
        end

        local allowed = cooldown.checkCooldown(source)
        if not allowed then
            return
        end

        selection.selectCharacter(source, character)
    end)
end

---Command to select AI addressal
local function addressCommand()
    if not serverConfig.commands.address.enabled then
        return
    end

    lib.addCommand(serverConfig.commands.address.commandName, {
        help = serverConfig.commands.address.help,
        params = serverConfig.commands.address.params,
        restricted = serverConfig.commands.address.permission,
    }, function(source, args)
        local addressal = args?.addressal
        if not addressal then
            return
        end

        local allowed = cooldown.checkCooldown(source)
        if not allowed then
            return
        end

        selection.selectAddressal(source, addressal)
    end)
end

---Command to play a random speech line
local function randomSpeechCommand()
    if not serverConfig.commands.randomSpeech.enabled then
        return
    end

    lib.addCommand(serverConfig.commands.randomSpeech.commandName, {
        help = serverConfig.commands.randomSpeech.help,
        params = serverConfig.commands.randomSpeech.params,
        restricted = serverConfig.commands.randomSpeech.permission,
    }, function(source, args)
        local allowed = cooldown.checkCooldown(source)
        if not allowed then
            return
        end

        TriggerClientEvent(resourceName .. ':client:playRandomSpeech', source)
    end)
end

---Command to open AI menu
local function menuCommand()
    if not serverConfig.commands.menu.enabled then
        return
    end

    lib.addCommand(serverConfig.commands.menu.commandName, {
        help = serverConfig.commands.menu.help,
        params = serverConfig.commands.menu.params,
        restricted = serverConfig.commands.menu.permission,
    }, function(source, args)
        local allowed = cooldown.checkCooldown(source)
        if not allowed then
            return
        end

        lib.print.debug(format('Player %d opened AI menu', source))
        TriggerClientEvent(resourceName .. ':client:openMenu', source)
    end)
end

---Initialise commands
local function initCommands()
    if not serverConfig.enableCommands then
        return
    end

    talkCommand()
    selectCommand()
    addressCommand()
    randomSpeechCommand()
    menuCommand()
end

-- Module Exports ------------------------------------------------
return {
    initCommands = initCommands,
}
