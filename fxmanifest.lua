fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'czsquizer'
description 'SQZ Car Control'

version '1.0.4'

-- shared_scripts {
-- 	'@ox_lib/init.lua', -- Remove if you do not use ox_lib
-- 	'config.lua',
-- 	'locale.lua',
--     'locales/*.lua'
-- }

client_scripts {
	'@es_extended/locale.lua',
	'@ox_lib/init.lua', -- Remove if you do not use ox_lib
	'config.lua',
	'locale.lua',
    'locales/*.lua',
	'client/*.lua',
}
