resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

Discription "boringwolf"

Version "1.0"

server_scripts {
    '@es_extended/locale.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    'config.lua',
    '@es_extended/locale.lua',
    'client/main.lua'
}
