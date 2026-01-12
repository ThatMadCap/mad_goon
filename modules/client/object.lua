-- Imports ----------------------------------------------------
local constants = lib.require('modules.shared.constants')

-- Localised Functions ------------------------------------
local string = string
local find = string.find
local pairs = pairs
local DoesEntityExist = DoesEntityExist
local CreateObject = CreateObject
local SetEntityHeading = SetEntityHeading
local PlaceObjectOnGroundProperly = PlaceObjectOnGroundProperly
local FreezeEntityPosition = FreezeEntityPosition
local SetEntityCollision = SetEntityCollision
local SetCanClimbOnEntity = SetCanClimbOnEntity
local SetEntityCanBeDamaged = SetEntityCanBeDamaged
local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local DeleteEntity = DeleteEntity
local SetEntityVisible = SetEntityVisible
local SetEntityAlpha = SetEntityAlpha

-- Types -----------------------------------------------------
---@class CPoint
---@field coords vector3

---@class ManagedObject
---@field id string
---@field entity number?
---@field model string|number
---@field coords vector3
---@field heading number? defaults to 0.0
---@field snapGround boolean? defaults to false
---@field freeze boolean? defaults to true
---@field visible boolean? defaults to true
---@field alpha number? 0-255
---@field collision boolean? defaults to true
---@field canClimb boolean? defaults to false
---@field invincible boolean? defaults to true
---@field target table? target options
---@field distance number? defaults to 400.0
---@field resource string?
---@field point CPoint?

-- Local Variables -----------------------------------------
local objects = {} ---@type table<string, ManagedObject>

-- Functions -----------------------------------------------
---Find object by ID
---@param id string
---@return ManagedObject?
local function getObject(id)
    return objects[id]
end

---Get all managed objects
---@return table<string, ManagedObject> objects All managed objects
local function getObjects()
    return objects
end

---Create the entity for an object
---@param obj ManagedObject the object to create entity for
---@return number? entity the created entity
local function createEntity(obj)
    if obj.entity and DoesEntityExist(obj.entity) then
        return obj.entity
    end

    lib.requestModel(obj.model)

    local entity = CreateObject(obj.model, obj.coords.x, obj.coords.y, obj.coords.z, false, true, true)

    if obj.heading then
        SetEntityHeading(entity, obj.heading)
    end

    if obj.snapGround then
        PlaceObjectOnGroundProperly(entity)
    end

    if obj.freeze ~= false then
        FreezeEntityPosition(entity, true)
    end

    if obj.visible ~= false then
        SetEntityVisible(entity, true, false)
    end

    if obj.alpha ~= nil then
        SetEntityAlpha(entity, obj.alpha, false)
    end

    if obj.collision ~= false then
        SetEntityCollision(entity, true, true)
    end

    if obj.canClimb == true then
        SetCanClimbOnEntity(entity, true)
    end

    if obj.invincible ~= false then
        SetEntityCanBeDamaged(entity, false)
    end

    if obj.target then
        ClientTarget.AddLocalEntity(entity, obj.target)
    end

    SetModelAsNoLongerNeeded(obj.model)
    obj.entity = entity

    return entity
end

---Delete the entity for an object
---@param obj ManagedObject the object to delete entity for
local function deleteEntity(obj)
    if obj.entity and DoesEntityExist(obj.entity) then
        if obj.target then
            ClientTarget.RemoveLocalEntity(obj.entity, obj.target)
        end

        DeleteEntity(obj.entity)
        obj.entity = nil
    end
end

---Add a new object to management
---@param data table Object data
---@return boolean success Whether the object was created successfully
local function addObject(data)
    if not data.id then
        return false
    end

    if not data.model then
        return false
    end

    if not data.coords then
        return false
    end

    if objects[data.id] then
        return false
    end

    ---@type ManagedObject
    local obj = {
        id = data.id,
        model = data.model,
        coords = data.coords,
        heading = data.heading or 0.0,
        freeze = data.freeze,
        visible = data.visible,
        alpha = data.alpha,
        collision = data.collision,
        invincible = data.invincible,
        snapGround = data.snapGround,
        canClimb = data.canClimb,
        distance = data.distance or 400.0,
        target = data.target,
        resource = GetInvokingResource() or GetCurrentResourceName(),
    }

    objects[data.id] = obj

    if obj.distance then
        obj.point = lib.points.new({
            coords = obj.coords,
            distance = obj.distance,
            onEnter = function()
                createEntity(obj)
            end,
            onExit = function()
                deleteEntity(obj)
            end,
        })
    else
        createEntity(obj)
    end

    return true
end

---Remove an object from management
---@param id string The ID of the object to remove
---@return boolean success Whether the object was removed successfully
local function removeObject(id)
    local obj = getObject(id)
    if not obj then
        return false
    end

    if obj.point then
        obj.point:remove()
        obj.point = nil
    end

    deleteEntity(obj)
    objects[id] = nil

    return true
end

---Update object properties
---@param id string The ID of the object to update
---@param data table The data to update
---@return boolean success Whether the object was updated successfully
local function updateObject(id, data)
    local obj = getObject(id)
    if not obj then
        return false
    end

    local needsRecreate = false

    if data.model and data.model ~= obj.model then
        obj.model = data.model
        needsRecreate = true
    end

    if data.coords and data.coords ~= obj.coords then
        obj.coords = data.coords
        needsRecreate = true

        if obj.point then
            obj.point:remove()
            obj.point = lib.points.new({
                coords = obj.coords,
                distance = obj.distance,
                onEnter = function()
                    createEntity(obj)
                end,
                onExit = function()
                    deleteEntity(obj)
                end,
            })
        end
    end

    if data.heading and data.heading ~= obj.heading then
        obj.heading = data.heading
        needsRecreate = true
    end

    if needsRecreate then
        deleteEntity(obj)
        createEntity(obj)
    else
        if data.freeze ~= nil and obj.entity then
            FreezeEntityPosition(obj.entity, data.freeze)
            obj.freeze = data.freeze
        end

        if data.collision ~= nil and obj.entity then
            SetEntityCollision(obj.entity, data.collision, obj.collision)
            obj.collision = data.collision
        end
    end

    return true
end

---Update all objects to use model for character
---@param character CharacterName
local function updateObjectForCharacter(character)
    if not character then
        return
    end

    for id, obj in pairs(getObjects()) do
        local isTV = obj.model and find(obj.model, 'mansiontv')

        local newModel
        if isTV then
            newModel = constants.characterTVModels[character]
        else
            newModel = constants.characterTabletModels[character]
        end
        if newModel then
            updateObject(id, { model = newModel })
        end
    end
end

---Get entity handle for an object
---@param id string The ID of the object
---@return number? entity The entity handle, or nil if not found
local function getEntity(id)
    local obj = getObject(id)
    return obj and obj.entity or nil
end

---Get all objects within distance of coords
---@param coords vector3 The center coordinates to check from
---@param distance number The radius distance to check within
---@return table<string, ManagedObject> nearby The objects found within the area
local function getObjectsInArea(coords, distance)
    local nearby = {}
    for id, obj in pairs(objects) do
        if #(obj.coords - coords) <= distance then
            nearby[id] = obj
        end
    end

    return nearby
end

---Get object by entity handle
---@param entity number The entity handle
---@return string? id The ID of the object, or nil if not found
local function getObjectByEntity(entity)
    for id, obj in pairs(objects) do
        if obj.entity == entity then
            return id
        end
    end

    return nil
end

-- Module Exports -----------------------------------------------
return {
    getObject = getObject,
    getObjects = getObjects,
    addObject = addObject,
    removeObject = removeObject,
    updateObject = updateObject,
    updateObjectForCharacter = updateObjectForCharacter,
    getEntity = getEntity,
    getObjectsInArea = getObjectsInArea,
    getObjectByEntity = getObjectByEntity,
}
