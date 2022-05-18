fx_version 'adamant'
game 'gta5'

author 'Higor Vieira'
dependencies {
	'vrp',
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/ui.css',
	'html/*.js',
	'html/assets/*.ttf',
	'html/assets/*.svg',
}

client_script {
	"@vrp/lib/utils.lua",
	"client.lua"
}

server_scripts{ 
	"@vrp/lib/utils.lua",
	"server.lua"
}
