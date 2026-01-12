-- Imports ---------------------------------------------------------
local nlp = lib.require('modules.shared.nlp_tfidf')
local logs = lib.require('modules.server.logs')
local sharedConfig = lib.require('config.shared')
local serverConfig = lib.require('config.server')

-- Loads -----------------------------------------------------------
local voiceLines = lib.loadJson('data.voice_lines')

-- Localised Functions ----------------------------------------------
local string = string
local sub = string.sub
local format = string.format
local table = table
local insert = table.insert
local pairs = pairs
local math = math
local random = math.random
local TriggerClientEvent = TriggerClientEvent
local GetCurrentResourceName = GetCurrentResourceName
local exports = exports

-- Local Variables ----------------------------------------------
local resourceName = GetCurrentResourceName()

-- Types -----------------------------------------------------------
---@class speechBuckets table<speechName, speechBucket>
---@alias speechBucket table table<gender: gender, topics: table<topics, number>>
---@alias speechName string e.g., 'XM25_GENERIC_HI_MALE'
---@alias gender string -- 'male' or 'female'
---@alias topics string -- e.g., 'greeting', 'introduction', 'appearance', etc.

-- "XM25_GENERIC_HI_MALE": {
--     "gender": "male",
--     "topics": {
--       "greeting": 1.0,
--       "introduction": 0.8
--     }
-- },

-- Helper Functions ----------------------------------------------------
---Gets the time context based on the hour
---@param hour number Hour in 24-hour format
---@return string Time context ('morning', 'afternoon', 'evening')
local function getTimeContext(hour)
    if hour >= 5 and hour < 12 then
        return 'morning'
    elseif hour >= 12 and hour < 17 then
        return 'afternoon'
    else
        return 'evening'
    end
end

---Get a random speech line name
---@return string? speechName
local function getRandomLine()
    local buckets = voiceLines.speech_buckets
    if not buckets then
        return nil
    end

    local speechNames = {}
    for name, _ in pairs(buckets) do
        insert(speechNames, name)
    end

    if #speechNames == 0 then
        return nil
    end

    local randomIndex = random(1, #speechNames)

    return speechNames[randomIndex]
end

-- Functions -------------------------------------------------------
---Picks the best speech bucket based on NLP scores and bucket weights
---@param resScores table<TopicName, number> NLP result scores
---@param speechBuckets speechBuckets Available speech buckets
---@param genderTarget gender Target
---@param timeContext string Time context ('morning', 'afternoon', 'evening')
local function pickBestBucket(resScores, speechBuckets, genderTarget, timeContext)
    local bestBucket = nil
    local highestFinalScore = 0.0

    for topicName, nlpScore in pairs(resScores) do
        local currentScore = nlpScore

        local activeTopic = topicName
        if sub(topicName, 1, 4) == 'wake' then
            activeTopic = 'wake_' .. timeContext
        end

        for speechName, data in pairs(speechBuckets) do
            local bucketWeight = data?.topics[activeTopic]
            if data?.gender == genderTarget and bucketWeight then
                local finalScore = currentScore * bucketWeight

                if finalScore > highestFinalScore then
                    highestFinalScore = finalScore
                    bestBucket = speechName
                end
            end
        end
    end

    return bestBucket, highestFinalScore
end

-- Functions -------------------------------------------------------
---Processes player input through NLP and triggers voice response (central talking point)
---@param source number Client source
---@param message string Message to process
---@param location? any Optional location data to pass to client
---@param isNetworked boolean Whether to play for nearby players
---@return boolean success
local function talk(source, message, isNetworked, location)
    if not nlp.isModelReady() then
        lib.print.warn('NLP model not ready')
        return false
    end

    local input, err = nlp.validateInput(message)
    if not input then
        lib.print.warn(err)
        return false
    end

    local clientState = lib.callback.await(resourceName .. ':client:getState', source)
    local clientHour = clientState?.hour

    local res = nlp.classifyToTopic(input)
    local genderTarget = clientState?.isMale and 'male' or 'female'
    local timeContext = getTimeContext(clientHour)
    local bestBucket, highestFinalScore = pickBestBucket(res.scores, voiceLines.speech_buckets, genderTarget, timeContext)

    local minScoreThreshold = sharedConfig.nlp.thresholds.score.minimum
    local isFallback = (highestFinalScore < minScoreThreshold)

    if not bestBucket or isFallback then
        bestBucket = (genderTarget == 'male') and 'XM25_GENERIC_NEGATIVE_MALE' or 'XM25_GENERIC_NEGATIVE_FEMALE'
        lib.print.debug(format('Fallback triggered for: "%s" (Score: %.2f)', input, highestFinalScore))
    end

    local topic = res.topic
    TriggerClientEvent(resourceName .. ':client:playVoice', source, {
        topic = topic,
        speechName = bestBucket,
        message = message,
        isNetworked = isNetworked,
        location = location,
    })

    if serverConfig.logs.talk.enabled then
        logs.talk(source, message)
    end

    return true
end

-- Exports ---------------------------------------------------------
exports('talk', talk)

-- Module Exports ---------------------------------------------------
return {
    getRandomLine = getRandomLine,
    talk = talk,
}
