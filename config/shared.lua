return {
    -- Menu system to use
    menu = 'ox_lib', -- Options: 'ox_lib', 'custom'

    -- Input system to use
    input = 'ox_lib', -- Options: 'ox_lib', 'custom'

    -- Notification Settings ----------------------------------------
    notify = {
        type = 'ox_lib', -- Options: 'ox_lib', 'qb-core', 'mad-thoughts', 'custom'
        duration = 5000 -- Duration for notifications (in milliseconds)
    },

    -- Sound Settings -------------------------------------------
    sound = {
        location = {
            distance = 2.5, -- Default distance for directional locations
            zOffset = 2.0 -- Default vertical offset for above/below
        }
    },

    -- NLP Settings ------------------------------------------------
    nlp = {
        thresholds = {
            confidence = {
                low = 0.30, -- Below this is considered low confidence
            },
            score = {
                minimum = 0.15 -- Lower = more 'guessing', Higher = more 'fallbacks'
            }
        },

        -- Terms to ignore during NLP processing
        stopwords = {
            ['the'] = true,
            ['a'] = true,
            ['an'] = true,
            ['and'] = true,
            ['or'] = true,
            ['to'] = true,
            ['of'] = true,
            ['in'] = true,
            ['is'] = true,
            ['it'] = true,
            ['i'] = true,
            ['you'] = true,
            ['me'] = true,
            ['my'] = true,
            ['we'] = true,
            ['on'] = true,
            ['for'] = true,
            ['with'] = true
        }
    }
}
