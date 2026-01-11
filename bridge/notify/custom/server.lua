-- Global Functions --------------------------------------
---Sends a notification
---@param target number target player ID
---@param data table notification data
function ServerNotify.Notify(target, data)
    print(json.encode(target, data))
end