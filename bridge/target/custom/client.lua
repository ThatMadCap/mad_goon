-- Global Functions --------------------------------------
---Creates a new targetable box zone
---@param data table zone data
function ClientTarget.AddBoxZone(data)
    lib.print.error('ClientTarget.AddBoxZone not implemented for custom target')
end

---Creates a new targetable sphere zone
---@param data table zone data
function ClientTarget.AddSphereZone(data)
    lib.print.error('ClientTarget.AddSphereZone not implemented for custom target')
end

---Removes a zone
---@param zoneId string zone name
function ClientTarget.RemoveZone(zoneId)
    lib.print.error('ClientTarget.RemoveZone not implemented for custom target')
end

---Creates new targetable options for a specific entity handle or list of entity handles.
---@param entity number|number[] entity handle
---@param options table target options
function ClientTarget.AddLocalEntity(entity, options)
    lib.print.error('ClientTarget.AddLocalEntity not implemented for custom target')
end

---Removes all options from the entities list with the option names.
---@param entity number|number[] entity handle
---@param options string|string[] option names to remove
function ClientTarget.RemoveLocalEntity(entity, optionNames)
    lib.print.error('ClientTarget.RemoveLocalEntity not implemented for custom target')
end

---Creates new targetable options for a specific model or list of models.
---@param models number|string|table<number, string> model or list of models
---@param options table TargetOptions
function ClientTarget.AddModel(models, options)
    lib.print.error('ClientTarget.AddModel not implemented for custom target')
end
