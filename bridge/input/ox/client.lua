-- Global Functions --------------------------------------
---Opens an input dialog
---@param title string dialog title
---@param rows table[] input rows
---@return table|nil input results or nil if cancelled
function ClientInput.InputDialog(title, rows)
    return lib.inputDialog(title, rows)
end
