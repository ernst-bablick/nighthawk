" load once only
if exists("g:nighthawk_plugin_loaded")
    finish
endif
let g:nighthawk_plugin_loaded = 1

" Defines a package path for Lua. 
" This facilitates importing the Lua modules from the plugin's dependency directory.
let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/timecard/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

" Exposes the plugin's functions for use as commands in NeoVim.
command! -nargs=0 TimecardSetup lua require("nighthawk").autocmd_setup()

" Trigger the setup routine
lua require("nighthawk").setup()
