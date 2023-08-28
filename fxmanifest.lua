fx_version "adamant"

games { 'rdr3', 'gta5' }

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54       	'yes'

shared_scripts	{
	'@ox_lib/init.lua',
	'config.lua',
} 

client_scripts {
	'client/main.lua',
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	'server/main.lua',
}
