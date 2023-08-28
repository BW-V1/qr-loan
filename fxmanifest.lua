-- fxmanifest.lua
-- This file defines the resource manifest for the FiveM server.

-- Resource Metadata
fx_version "adamant"

-- Supported games
games { 'rdr3', 'gta5' }

-- RedM pre-release warning
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

-- Lua version
lua54 'yes'

-- Shared scripts
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

-- Client-side scripts
client_scripts {
    'client/main.lua'
}

-- Server-side scripts
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/main.lua'
}

exports {
    'CreateLoanMenu',
	'PayLoanMenu',
}
