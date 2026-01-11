-- Imports ---------------------------------------------------------
local sharedConfig = lib.require 'config.shared'
local serverConfig = lib.require 'config.server'
local utils = lib.require 'modules.shared.utils'

-- Loads -----------------------------------------------------------
local corpus = lib.loadJson 'data.topic_corpus'

-- Localised Functions ----------------------------------------------
local string = string
local format = string.format
local sub = string.sub
local gsub = string.gsub
local match = string.match
local math = math
local log = math.log
local min = math.min
local table = table
local concat = table.concat
local insert = table.insert
local sort = table.sort
local tostring = tostring
local ipairs = ipairs
local pairs = pairs
local type = type

-- Local Variables -------------------------------------------------
local model = nil

-- Types ---------------------------------------------------------
---@alias TopicName string The name of a topic
---@alias Term string A term in the vocabulary

---@class TfIdfModel The trained TF-IDF topic model
---@field idf table<Term, number> Inverse document frequency per term
---@field topicVectors table<TopicName, table<Term, number>> TF-IDF vector per topic
---@field topicNorms table<TopicName, number> Cached Euclidean norm per topic vector
---@field topicCount integer Number of topics used to train

---@class ClassificationResult The result of classifying an input text to a topic
---@field topic TopicName|nil The best-matching topic name, or nil if none
---@field score number Cosine similarity score [0..1] (usually)
---@field confidence number score / sum(scores) across topics (clamped 0..1)
---@field confidencePercent number Confidence as a percentage (0..100)
---@field scores table<TopicName, number> per-topic similarity
---@field tokens string[] tokens extracted from input

-- Helper Functions ------------------------------------------------------
---Normalise corpus shape to ensure each topic maps to a list of documents
---@param cShape table<TopicName, string|table<string>>
---@return table<TopicName, table<string>>
local function normaliseCorpusShape(cShape)
    local out = {}
    for topic, doc in pairs(cShape) do
        if type(doc) == 'string' then
            out[topic] = { doc }
        elseif type(doc) == 'table' then
            out[topic] = doc
        end
    end
    return out
end

-- Model building (training) --------------------------------
---Builds the inverse document frequency (IDF) table from the topic corpus
---@param topicCorpus table<TopicName, string[]> corpus
---@return table<Term, number> idf inverse document frequency
---@return integer topicCount number of topics
local function buildIdf(topicCorpus)
	local df = {} ---@type table<Term, integer>
	local topicCount = 0

	for _, docs in pairs(topicCorpus) do
		topicCount = topicCount + 1

		local seen = {} ---@type table<Term, boolean>

		for _, doc in ipairs(docs) do
			local tokens = utils.tokenise(utils.normaliseText(doc))
			for _, term in ipairs(tokens) do
				if not seen[term] then
					seen[term] = true
				end
			end
		end

		for term, _ in pairs(seen) do
			df[term] = (df[term] or 0) + 1
		end
	end

	local idf = {} ---@type table<Term, number>
	for term, d in pairs(df) do
		idf[term] = log((topicCount + 1) / (d + 1)) + 1
	end

	return idf, topicCount
end

---Vectorises input text using TF-IDF
---@param idf table<Term, number> inverse document frequency
---@param text string input text
---@return table<Term, number> vec TF-IDF vector
---@return number norm Euclidean norm of vector
---@return string[] tokens tokens extracted from text
local function vectoriseText(idf, text)
	local tokens = utils.tokenise(utils.normaliseText(text))
	local counts = utils.countTerms(tokens)

	local vec = {} ---@type table<Term, number>
	for term, tf in pairs(counts) do
		local termIdf = idf[term]
		if termIdf then
			vec[term] = tf * termIdf
		end
	end

	return vec, utils.vectorNorm(vec), tokens
end

---Train the TF-IDF topic model
---@param topicCorpus table<TopicName, string[]> corpus
---@return TfIdfModel model the trained model
local function trainTopicModel(topicCorpus)
	local idf, topicCount = buildIdf(topicCorpus)

	local topicVectors = {} ---@type table<TopicName, table<Term, number>>
	local topicNorms = {} ---@type table<TopicName, number>

	for topic, docs in pairs(topicCorpus) do
		local combined = concat(docs, ' ')

		local vec, norm = vectoriseText(idf, combined)
		topicVectors[topic] = vec
		topicNorms[topic] = norm
	end

	local vocabCount = 0
	for _ in pairs(idf) do vocabCount = vocabCount + 1 end

	lib.print.info(format('Trained TF-IDF Model | Topics: %d | Vocab: %d', topicCount, vocabCount))

	model = {
		idf = idf,
		topicVectors = topicVectors,
		topicNorms = topicNorms,
		topicCount = topicCount
	}

	return model
end

-- Input ---------------------------------------------
---Classify input text to best-matching topic
---@param input string input text
---@return ClassificationResult|nil class the classification result
local function classifyToTopic(input)
	if not model then return nil end
	local inputVec, inputNorm, tokens = vectoriseText(model.idf, input)

	local bestTopic ---@type TopicName|nil
	local bestScore = 0.0

	local scores = {} ---@type table<TopicName, number>

	for topic, topicVec in pairs(model.topicVectors) do
		local score = utils.cosineSimilarity(inputVec, inputNorm, topicVec, model.topicNorms[topic])
		scores[topic] = score

		if score > bestScore then
			bestScore = score
			bestTopic = topic
		end
	end

	local secondBestScore = 0.0
	for topic, score in pairs(scores) do
		if topic ~= bestTopic and score > secondBestScore then
			secondBestScore = score
		end
	end

	local confidence = 0.0
	if bestScore > 0 then
		if secondBestScore > 0 then
			confidence = lib.math.clamp((bestScore - secondBestScore) / bestScore, 0.0, 1.0)
		else
			confidence = 1.0
		end
	end

	local confidencePercent = lib.math.round(confidence * 100, 1)

	local displayInput = gsub(tostring(input), '%s+', ' ')
	if #displayInput > 80 then
		displayInput = sub(displayInput, 1, 77) .. '...'
	end

	local bestTopicStr = bestTopic or 'nil'

	local topN = {}
	do
		local tmp = {}
		for t, sc in pairs(scores) do
			insert(tmp, { t = t, s = sc })
		end
		sort(tmp, function(a, b) return a.s > b.s end)
		for i = 1, min(3, #tmp) do
			insert(topN, format('%s:%.3f', tmp[i].t, tmp[i].s))
		end
	end

	lib.print.debug(format(
		'Classifying topic from input: \nInput: "%s" \nBest: %s \nScore: %.4f \nConfidence: %s%% \nTokens: %d \nTop: {%s}',
		displayInput, bestTopicStr, bestScore, tostring(confidencePercent), #tokens, concat(topN, ', ')
	))

	if confidence > 0 and confidence < sharedConfig.nlp.thresholds.confidence.low then
		lib.print.debug(format('Low confidence (%.2f) for input: "%s"', confidence, input))
	end

	return {
		topic = bestTopic,
		score = bestScore,
		confidence = confidence,
		confidencePercent = confidencePercent,
		scores = scores,
		tokens = tokens
	}
end

---Validate and sanitise input message
---@param input string|nil Raw input
---@return string|nil sanitisedInput
---@return string|nil errorMessage
local function validateInput(input)
    if not input or type(input) ~= 'string' then
        return nil, 'Invalid input: message required'
    end

    local trimmed = match(input, '^%s*(.-)%s*$')
    if #trimmed == 0 then
        return nil, 'Invalid input: message cannot be empty'
    end

    if #trimmed > serverConfig.input.maxLength then
        trimmed = sub(trimmed, 1, serverConfig.input.maxLength)
        lib.print.debug(format('Input truncated to %d characters', serverConfig.input.maxLength))
    end

    return trimmed, nil
end

---Classify input text without playing voice
---@param input string Text to classify
---@return ClassificationResult|nil result
local function classifyInput(input)
    if not model then return nil end

    local sanitised, err = validateInput(input)
    if not sanitised then
        lib.print.warn(err)
        return nil
    end

    return classifyToTopic(sanitised)
end

---Check if model is ready
---@return boolean isReady if model is trained
local function isModelReady()
	return model ~= nil
end

-- Initialisation ---------------------------------------------------
---Initialises the NLP model
local function initNLP()
    local topicCorpus = normaliseCorpusShape(corpus)
    trainTopicModel(topicCorpus)
end

-- Exports ---------------------------------------------------------
exports('isModelReady', isModelReady)
exports('classifyInput', classifyInput)

-- Module Exports ------------------------------------------------
return {
	classifyToTopic = classifyToTopic,
	trainTopicModel = trainTopicModel,
	validateInput = validateInput,
	isModelReady = isModelReady,
	initNLP = initNLP,
}
