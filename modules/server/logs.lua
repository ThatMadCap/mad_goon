-- Imports ---------------------------------------------------------
local serverConfig = lib.require('config.server')

-- Localised Functions ----------------------------------------------
local os = os
local date = os.date
local json = json
local encode = json.encode
local string = string
local format = string.format
local match = string.match
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local PerformHttpRequest = PerformHttpRequest
local GetPlayerName = GetPlayerName
local GetPlayerIdentifiers = GetPlayerIdentifiers

-- Local Variables ----------------------------------------------
---Webhook URLs for different log types
---@type table<string, string>
local webhooks = {
    ['talk'] = serverConfig.logs.talk.webhook or '',
}

local authorName = serverConfig.logs.authorName
local username = serverConfig.logs.username
local iconUrl = serverConfig.logs.iconUrl
local tagType = serverConfig.logs.tagType

---Colour mappings for logs
---@type table<string, number>
local colors = { -- https://www.spycolor.com/
    ['default'] = 14423100,
    ['blue'] = 255,
    ['red'] = 16711680,
    ['green'] = 65280,
    ['white'] = 16777215,
    ['black'] = 0,
    ['orange'] = 16744192,
    ['yellow'] = 16776960,
    ['pink'] = 16737996,
    ['lightgreen'] = 65309,
}

local logQueue = {} ---@type table<string, table[]> Queue for logs to be posted

-- Functions --------------------------------------------------------
---Creates a log entry
---@param name string Name of the webhook to use
---@param title string Title of the log
---@param color string Color of the log embed
---@param tagEveryone boolean Whether to tag everyone
---@param message string Message content
---@param messagelabel string Label for the message field
---@param message2 string Second message content
---@param messagelabel2 string Label for the second message field
local function createLog(name, title, color, tagEveryone, message, messagelabel, message2, messagelabel2)
    local postData = {}
    local tag = tagEveryone or false

    if not webhooks[name] then
        lib.print.warn('Tried to call a log that is not configured: ' .. name)
        return
    end

    local webHook = webhooks[name] ~= '' and webhooks[name] or webhooks['default']
    local embedData = {
        {
            ['title'] = title,
            ['color'] = colors[color] or colors['default'],
            ['footer'] = {
                ['text'] = date('%c'),
            },
            ['author'] = {
                ['name'] = authorName,
                ['icon_url'] = iconUrl,
            },
            ['fields'] = {
                {
                    ['name'] = messagelabel or '',
                    ['value'] = message or '',
                    ['inline'] = false,
                },
                {
                    ['name'] = messagelabel2 or '',
                    ['value'] = message2 or '',
                    ['inline'] = false,
                },
            },
        },
    }

    if not logQueue[name] then
        logQueue[name] = {}
    end

    logQueue[name][#logQueue[name] + 1] = { webhook = webHook, data = embedData }

    if #logQueue[name] >= 10 then
        if tag then
            postData = { username = username, content = tagType, embeds = {} }
        else
            postData = { username = username, embeds = {} }
        end

        for i = 1, #logQueue[name] do
            postData.embeds[#postData.embeds + 1] = logQueue[name][i].data[1]
        end

        PerformHttpRequest(logQueue[name][1].webhook, function() end, 'POST', encode(postData), { ['Content-Type'] = 'application/json' })
        logQueue[name] = {}
    end
end

---Posts all queued logs
local function postLogs()
    for name, queue in pairs(logQueue) do
        if #queue > 0 then
            local postData = { username = username, embeds = {} }
            for i = 1, #queue do
                postData.embeds[#postData.embeds + 1] = queue[i].data[1]
            end
            PerformHttpRequest(queue[1].webhook, function() end, 'POST', encode(postData), { ['Content-Type'] = 'application/json' })
            logQueue[name] = {}
        end
    end
end

---Builds and sends the 'talk' log
---@param source number Client source
---@param message string Message to log
local function talk(source, message)
    if source then
        local playerName = GetPlayerName(source)
        local identifiers = GetPlayerIdentifiers(source)
        local idMap = {
            steam = nil,
            license = nil,
            discord = nil,
            fivem = nil,
            xbl = nil,
            live = nil,
            ip = nil,
        }

        for _, id in ipairs(identifiers) do
            local prefix, value = match(id, '(.-):(.*)')
            if idMap[prefix] == nil then
                idMap[prefix] = id
            end
        end

        local formattedIdentifiers = format(
            [[
                **Server ID:** %s
                **Steam:** %s
                **License:** %s
                **Discord:** %s
                **FiveM:** %s
                **XBL:** %s
                **Live:** %s
                **IP:** %s
            ]],
            tostring(source),
            idMap.steam or 'N/A',
            idMap.license or 'N/A',
            idMap.discord or 'N/A',
            idMap.fivem or 'N/A',
            idMap.xbl or 'N/A',
            idMap.live or 'N/A',
            idMap.ip or 'N/A'
        )

        createLog(
            'talk',
            playerName .. ' sent message to AI',
            'pink',
            serverConfig.logs.talk.tag,
            '"' .. message .. '"',
            '**Message**',
            formattedIdentifiers,
            '**Identifiers**'
        )
    end
end

-- Module Exports ----------------------------------------------------
return {
    createLog = createLog,
    postLogs = postLogs,
    talk = talk,
}
