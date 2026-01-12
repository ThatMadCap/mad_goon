-- Imports ---------------------------------------------------------
local sharedConfig = lib.require 'config.shared'
local clientConfig = lib.require 'config.client'

-- Localised Functions ----------------------------------------------
local string = string
local lower = string.lower
local gsub = string.gsub
local gmatch = string.gmatch
local upper = string.upper
local sub = string.sub
local math = math
local rad = math.rad
local cos = math.cos
local sin = math.sin
local sqrt = math.sqrt
local pairs = pairs
local ipairs = ipairs
local GetEntityHeading = GetEntityHeading
local DoesEntityExist = DoesEntityExist

-- Text Helpers ----------------------------------------------------
---Normalises text
---@param text string input text
---@return string text normalised text
local function normaliseText(text)
    text = lower(text)
    text = gsub(text, '%?', ' questionmark ') -- because punctuation can be meaningful in some contexts
    text = gsub(text, '[^%w%s\']', ' ')
    text = gsub(text, '%s+', ' ')
    text = gsub(text, '^%s+', '')
    text = gsub(text, '%s+$', '')
    return text
end

---Tokenises normalised text
---@param normalised string
---@return string[] tokens
local function tokenise(normalised)
    local tokens = {}

    for term in gmatch(normalised, '%S+') do
        term = gsub(term, '\'s$', '')
        term = gsub(term, '\'$', '')

        if #term > 1 and not sharedConfig.nlp.stopwords[term] then
            tokens[#tokens + 1] = term
        end
    end

    return tokens
end

---Counts term frequencies in token list
---@param tokens string[]
---@return table<Term, integer> counts
local function countTerms(tokens)
    local counts = {}
    for _, term in ipairs(tokens) do
        counts[term] = (counts[term] or 0) + 1
    end
    return counts
end

---Capitalise first letter of a string and lowercases the rest
---@param text string
local function capital(text)
    return upper(sub(text, 1, 1)) .. lower(sub(text, 2))
end

-- Vector math helpers --------------------------------
---Calculates the dot product of two vectors
---@param a table<Term, number>
---@param b table<Term, number>
---@return number dotProduct
local function dotProduct(a, b)
    local sum = 0.0
    for term, wa in pairs(a) do
        local wb = b[term]
        if wb then
            sum = sum + wa * wb
        end
    end

    return sum
end

---Calculates the Euclidean norm of a vector
---@param vec table<Term, number>
---@return number norm Euclidean norm
local function vectorNorm(vec)
    local sum = 0.0
    for _, w in pairs(vec) do
        sum = sum + (w * w)
    end

    return sqrt(sum)
end

---Calculates the cosine similarity between two vectors
---@param a table<Term, number>
---@param normA number
---@param b table<Term, number>
---@param normB number
---@return number similarity cosine similarity
local function cosineSimilarity(a, normA, b, normB)
    if normA == 0 or normB == 0 then return 0.0 end
    return dotProduct(a, b) / (normA * normB)
end

---Check if a value is a vector3
---@param v any Value to check
---@return boolean isVector True if the value is a vector3
local function isVec3(v)
    return type(v) == 'vector3'
end

---Check if a value is a valid entity
---@param v any Value to check
---@return boolean isEntity True if the value is a valid entity handle
local function isEntity(v)
    return type(v) == 'number' and v > 0 and DoesEntityExist(v)
end

---Check if a value is an offset table
---@param v any Value to check
---@return boolean isOffset True if the value is an offset table {x, y, z}
local function isOffset(v)
    return type(v) == 'table' and
        type(v[1]) == 'number' and type(v[2]) == 'number' and type(v[3]) == 'number'
end

---Get coords offset from player based on heading
---@param distance number Distance from player
---@param angle number Angle offset in degrees (0 = forward, 90 = right, etc.)
---@param zOffset? number Vertical offset (default 0)
---@return vector3 coords Calculated world coordinates
local function getDirectionalOffset(distance, angle, zOffset)
    local pedCoords = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)

    local adjustedAngle = rad(heading - angle)
    local x = pedCoords.x + (distance * sin(adjustedAngle))
    local y = pedCoords.y + (distance * cos(adjustedAngle))
    local z = pedCoords.z + (zOffset or 0.0)

    return vector3(x, y, z)
end

---Get theme by type and name
---@param themeType string The theme type ('characters', 'addressals', etc.)
---@param name string The theme name/key
---@return table theme Theme table with colour and icon, or empty table if not found
local function getTheme(themeType, name)
    if not name or not themeType then return {} end
    return clientConfig.theme[themeType]?[name] or {}
end

-- Module Exports ----------------------------------------------------
return {
    normaliseText = normaliseText,
    tokenise = tokenise,
    countTerms = countTerms,
    capital = capital,
    dotProduct = dotProduct,
    vectorNorm = vectorNorm,
    cosineSimilarity = cosineSimilarity,
    isVec3 = isVec3,
    isEntity = isEntity,
    isOffset = isOffset,
    getDirectionalOffset = getDirectionalOffset,
    getTheme = getTheme
}
