-- Global Functions --------------------------------------
---Opens a menu
---@param data table menu data
function ClientMenu.Open(data)
    lib.registerContext({
        id = data.id,
        title = data.title,
        menu = data.menu,
        canClose = data.canClose,
        onExit = data.onExit,
        options = data.options,
    })

    lib.showContext(data.id)
end

---Closes the currently opened menu
function ClientMenu.Close()
    lib.hideContext()
end

---Opens an alert dialog
---@param data table alert dialog data
function ClientMenu.AlertDialog(data)
    return lib.alertDialog({
        header = data.header,
        content = data.content,
        centered = data.centered,
        cancel = data.cancel,
        labels = data.labels,
    })
end
