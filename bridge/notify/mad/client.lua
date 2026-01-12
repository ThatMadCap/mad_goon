-- Global Functions --------------------------------------
---Sends a notification
---@param data table notification data
function ClientNotify.Notify(data)
    local message = data.description or data.message or ''
    local duration = data.duration and math.floor(tonumber(data.duration) / 1000) or 5
    local notifType = data.type or 'info'

    if notifType == 'success' then
        exports['mad-thoughts']:success(message, duration)
    elseif notifType == 'error' then
        exports['mad-thoughts']:error(message, duration)
    elseif notifType == 'warning' then
        exports['mad-thoughts']:warning(message, duration)
    else
        exports['mad-thoughts']:info(message, duration)
    end
end
