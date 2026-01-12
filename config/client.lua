return {
    -- Character Settings -----------------------------------
    -- Default character (overriden by saved setting)
    defaultCharacter = 'angel', ---@type CharacterName

    -- Object Settings --------------------------------------
    enableObjects = true, -- Enable/disable spawning objects

    -- Panel Objects
    objects = { -- Models update when changing characters
        {
            id = 'von_crasteburg_01',
            model = 'm25_2_prop_m52_aitablet_01a',
            coords = vector3(457.06, 208.06, 104.00),
            heading = 160.0,
            distance = 15.0,
        },
        {
            id = 'von_crasteburg_02',
            model = 'm25_2_prop_m52_aitablet_02a',
            coords = vector3(457.06, 208.06, 103.50),
            heading = 160.0,
            distance = 15.0,
        },
        {
            id = 'von_crasteburg_03',
            model = 'm25_2_prop_m52_aitablet_03a',
            coords = vector3(457.06, 208.06, 103.00),
            heading = 160.0,
            distance = 15.0,
        },
        {
            id = 'von_crasteburg_04',
            model = 'm25_2_prop_m52_mansiontv_havilandai',
            coords = vector3(455.10, 208.78, 102.80),
            heading = 160.0,
            distance = 15.0,
        },
        {
            id = 'von_crasteburg_05',
            model = 'm25_2_prop_m52_mansiontv_ogai',
            coords = vector3(452.19, 209.84, 102.80),
            heading = 160.0,
            distance = 15.0,
        },
        {
            id = 'von_crasteburg_07',
            model = 'm25_2_prop_m52_mansiontv_angelai',
            coords = vector3(449.30, 210.89, 102.80),
            heading = 160.0,
            distance = 15.0,
        },
        {
            id = 'vinewood_residence_01',
            model = 'm25_2_prop_m52_aitablet_03a',
            coords = vector3(554.34, 729.68, 202.66),
            heading = 72.81,
            distance = 15.0,
        },
    },

    -- Target Settings -------------------------------------
    targets = {
        distance = 2.5, -- Interaction distance
        showMenuInTargets = false, -- Show menu option in target interactions

        -- Global target models
        models = {
            'm25_2_prop_m52_aitablet',
            'm25_2_prop_m52_aitablet_01a',
            'm25_2_prop_m52_aitablet_02a',
            'm25_2_prop_m52_aitablet_03a',
            'm25_2_prop_m52_mansiontv_havilandai',
            'm25_2_prop_m52_mansiontv_angelai',
            'm25_2_prop_m52_mansiontv_ogai',
            'prop_monitor_01a',
        },

        -- Target Locations ----------------------------------
        -- Sphere zones
        sphereZones = {
            {
                coords = vec3(446.89, 211.78, 103.37),
                radius = 0.5,
                debug = false,
            },
        },

        -- Box zones
        boxZones = {
            {
                coords = vec3(443.87, 212.86, 103.37),
                size = vec3(0.5, 0.5, 0.5),
                rotation = 72.81,
                debug = false,
            },
        },
    },

    -- UI Theme Settings ------------------------------------
    theme = {
        -- Icons for interaction options
        icons = { -- https://fontawesome.com
            menu = 'fas fa-bars',
            talk = 'fas fa-comment-dots',
            select = 'fas fa-robot',
            addressal = 'fas fa-user',
            comment = 'fas fa-comments',
        },
        -- Character themes
        characters = {
            angel = {
                colour = '#ff6f91',
                icon = 'fas fa-user-nurse',
            },
            haviland = {
                colour = '#8B48D3',
                icon = 'fas fa-user-tie',
            },
            og = {
                colour = '#1964D3',
                icon = 'fas fa-user-secret',
            },
        },
        -- Addressal themes
        addressals = {
            male = {
                colour = '#3498db',
                icon = 'fa-solid fa-mars',
            },
            female = {
                colour = '#e91e63',
                icon = 'fa-solid fa-venus',
            },
        },
    },
}
