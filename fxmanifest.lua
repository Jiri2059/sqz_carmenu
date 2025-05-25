fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'czsquizer'
description 'SQZ Car Control'

version '1.0.4'

shared_scripts {
	'locale.lua',
	'@ox_lib/init.lua',
	'config.lua',
    'locales/*.lua',
}

client_script 'client/main.lua'

server_script 'server/main.lua'
