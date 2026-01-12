-- Localised Functions -----------------------------------
local GetCurrentResourceName = GetCurrentResourceName

-- Local Variables --------------------------------------
local target = exports.ox_target
local resourceName = GetCurrentResourceName()

-- Helper Functions --------------------------------------
---Fixes targeting options to handle different target system formats
---@param options table options to fix
---@return table options fixed options
local function fixOptions(options)
    for _, opt in pairs(options) do
        local handler = opt.onSelect or opt.action

        if handler then
            opt.onSelect = function(input)
                return handler(input)
            end
        end

        opt.groups = opt.job or opt.groups

        if opt.canInteract then
            local interactCheck = opt.canInteract
            opt.canInteract = function(...)
                return interactCheck(...)
            end
        end
    end

    return options
end

-- Global Functions --------------------------------------
---Creates a new targetable box zone
---@param data table zone data
function ClientTarget.AddBoxZone(data)
    local options = fixOptions(data.options)
    return target:addBoxZone({
        coords = data.coords,
        name = data.name or ('%s_box_%s'):format(resourceName, math.random(1000, 9999)),
        size = data.size or vec3(2, 2, 2),
        rotation = data.rotation or 0,
        debug = data.debug or false,
        drawSprite = data.drawSprite or false,
        options = options,
    })
end

---Creates a new targetable sphere zone
---@param data table zone data
function ClientTarget.AddSphereZone(data)
    local options = fixOptions(data.options)
    return target:addSphereZone({
        coords = data.coords,
        name = data.name or ('%s_sphere_%s'):format(resourceName, math.random(1000, 9999)),
        radius = data.radius or 2.0,
        debug = data.debug or false,
        drawSprite = data.drawSprite or false,
        options = options,
    })
end

---Removes a zone
---@param zoneId string zone name
function ClientTarget.RemoveZone(zoneId)
    target:removeZone(zoneId)
end

---Creates new targetable options for a specific entity handle or list of entity handles.
---@param entity number|number[] entity handle
---@param options table target options
function ClientTarget.AddLocalEntity(entity, options)
    options = fixOptions(options)
    target:addLocalEntity(entity, options)
end

---Removes all options from the entities list with the option names.
---@param entity number|number[] entity handle
---@param options string|string[] option names to remove
function ClientTarget.RemoveLocalEntity(entity, optionNames)
    optionNames = fixOptions(optionNames)
    target:removeLocalEntity(entity, optionNames)
end

---Creates new targetable options for a specific model or list of models.
---@param models number|string|table<number, string> model or list of models
---@param options table TargetOptions
function ClientTarget.AddModel(models, options)
    options = fixOptions(options)
    target:addModel(models, options)
end
