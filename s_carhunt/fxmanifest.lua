fx_version 'adamant'

game 'gta5'

description 'Vehicle hunt by Slerbamonsteri'

version '6.9.0'

client_scripts {
    'cl.lua',
}

server_script {
    '@mysql-async/lib/MySQL.lua',
    'sv.lua'
}
