fx_version 'cerulean'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
game 'gta5'

name 'mad_goon'
version '0.0.0'
description 'Talk to your AI Concierge'
author 'MadCap'

-- https://madcap-scripts.tebex.io
-- https://madcap.gitbook.io
-- https://github.com/ThatMadCap
-- https://discord.gg/dTNWpmPGyc

dependencies {
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
    'modules/shared/*.lua',
}

client_scripts {
    'bridge/input/client.lua',
    'bridge/menu/client.lua',
    'bridge/notify/client.lua',
    'bridge/target/client.lua',
    'modules/client/*.lua',
    'client/*.lua'
}

server_scripts {
    'bridge/notify/server.lua',
    'server/*.lua'
}

files {
    'locales/*.json',
    'config/*.lua',
    'bridge/**/*',
    'data/*.json'
}