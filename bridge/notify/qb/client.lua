-- Global Functions --------------------------------------
-- Sends a notification
---@param data table notification data
function ClientNotify.Notify(data)
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

    TriggerEvent('QBCore:Notify', text, notifyType, duration)
end