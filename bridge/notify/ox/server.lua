-- Global Functions --------------------------------------
---Sends a notification
---@param target number target player ID
---@param data table notification data
function ServerNotify.Notify(target, data)
    TriggerClientEvent('ox_lib:notify', target, data)
end
