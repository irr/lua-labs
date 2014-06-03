package = "underscore.lua"
version = "0.4-0"
source = {
	url = "http://github.com/irr/lua-labs/raw/master/rocks/"..package.."-"..version..".zip"
}
description = {
	summary = "An utility library adding functional programming support",
	detailed = [[
		An utility library adding functional programming support
	]],
	homepage = "https://github.com/irr/underscore.lua/", 
	license = "MIT/X11" -- same a Lua
}
dependencies = {
	"lua >= 5.1"
}
build = {
	type = "builtin";
	modules = {
		underscore = 'lib/underscore.lua';
	}
}
