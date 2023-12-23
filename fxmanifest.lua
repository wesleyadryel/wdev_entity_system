fx_version "cerulean"

description "Wdev Solutions : Props System"
author "Wdev Solutions"
lua54 'yes'

games {"gta5"}

shared_script {'config/config.lua'}
client_script {'client/propList.lua', 'client/nativeUI.lua', 'client/client.lua'}
server_script {'server/server.lua'}


ui_page 'web/build/index.html'
files {'web/build/**/*'}
