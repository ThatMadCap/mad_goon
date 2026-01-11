lib.locale()
return {
    -- General Settings ------------------------------------------
    enableCommands = true, -- Enable/disable commands use
    enableMenu = true, -- Enable/disable menu use
    enableTarget = true, -- Enable/disable target system use

    -- Sound Settings --------------------------------------------
    sound = {
        enableNetworked = true, -- Enable/disable networked sound playback
        maxDistance = 300.0, -- Maximum distance for networked sound playback
    },

    -- Command Settings ------------------------------------------
    commands = {
        -- Talk to AI command
        talk = {
            enabled = true, -- Enable/disable the command
            permission = false, ---@type boolean|string|string[] Permission group to use command
            commandName = 'ai_talk', -- Command name
            help = locale('command_desc_talk'), -- Help text for the command
            params = { -- Parameters for the command
                { name = 'message', type = 'longString', help = 'Message to send' },
            },
        },
        -- Select AI character command
        select = {
            enabled = true,
            permission = false,
            commandName = 'ai_select',
            help = locale('command_desc_select'),
            params = {
                { name = 'character', type = 'string', help = '"angel" or "haviland" or "og"' },
            },
        },
        -- Set addressal command
        address = {
            enabled = true,
            permission = false,
            commandName = 'ai_callme',
            help = locale('command_desc_address'),
            params = {
                { name = 'addressal', type = 'string', help = '"male" or "female"' },
            },
        },
        -- Random speech command
        randomSpeech = {
            enabled = true,
            permission = false,
            commandName = 'ai_speak',
            help = locale('command_desc_random'),
        },
        -- Open AI menu command
        menu = {
            enabled = true,
            permission = false,
            commandName = 'ai_menu',
            help = locale('command_desc_menu'),
        },
    },

    -- Input Settings ----------------------------------------------
    -- Cooldown
    rateLimit = {
        enabled = true, -- Enable/disable rate limiting
        cooldown = 2000, -- Cooldown between voice commands per player (milliseconds)
    },

    -- Limits
    input = {
        maxLength = 200, -- Maximum character length for NLP input
    },

    -- Logging Settings -------------------------------------------
    logs = {
        authorName = '💦 mad_goon', -- Name to display on logs
        username = 'mad_goon Logs', -- Username to display on logs
        iconUrl = 'https://files.fivemerr.com/images/55b79155-7dd4-461f-8d52-e9c2fdf34b08.webp', -- Icon URL to display on logs
        tagType = '@everyone', -- Role to ping in tagged logs

        talk = {
            enabled = true, -- Enable/disable talk logs
            webhook = '', -- Webhook URL for talk logs (add your webhook here)
            tag = false, -- Whether to tag a role on talk logs (tagType)
        },
    },
}