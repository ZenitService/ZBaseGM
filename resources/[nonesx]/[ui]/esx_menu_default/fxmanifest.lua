fx_version 'adamant'

game 'gta5'

description 'ESX Menu Default Redesign v2 by Re1ease#0001'

shared_script{
	"@es_extended/imports.lua",
}

client_scripts {
	'@es_extended/client/wrapper.lua',
	'client/main.lua'
}

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/css/app.css',
	'html/js/mustache.min.js',
	'html/js/app.js',
	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf'
}

dependencies {
	'es_extended'
}
