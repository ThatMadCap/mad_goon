-- Global Functions --------------------------------------
-- Sends a notification
---@param target number target player ID
---@param data table notification data
function ServerNotify.Notify(target, data)
    local text = {
        text = data.title or '',
        caption = data.description or '',
    }
    local notifyType = data.type or 'primary'
    if notifyType == 'info' or notifyType == 'inform' then
        notifyType = 'primary'
    elseif notifyType == 'warning' then
        notifyType = 'error'
    end

    local duration = data.duration or 5000

    TriggerClientEvent('QBCore:Notify', target, text, notifyType, duration)
end
