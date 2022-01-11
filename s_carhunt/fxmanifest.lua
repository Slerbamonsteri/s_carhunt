fx_version 'adamant'

games { 'gta5' }

description 'Slerban autohunt'

version '6.9.0'

client_scripts {
    'cl.lua',
}

server_script {
     'sv.lua',
     '@mysql-async/lib/MySQL.lua',
}