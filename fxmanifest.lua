fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'Mack-Teacher - School Teacher System'
version '1.0.0'
author 'Mack'

shared_scripts {
    '@rsg-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/turn.min.js',
    'html/font/crock.ttf',
    'html/img/clipboard.png',
    'html/images/paper.png',
    'images/clockin.png',
    'images/clockout.png'
}

dependencies {
    'rsg-core',
    'ox_lib',
    'ox_target',
    'bln_notify',
    'progressbar',
    'mack-xplevels-v3'
}

lua54 'yes'

shared_script '@ox_lib/init.lua'
