-- import additional Lua modules
local health = require("nighthawk.health")
local statistics = require("nighthawk.statistics")
local watchdog = require("nighthawk.watchdog")

-- declare the module
local nighthawk = {}
local commands_initialized = false

local function setup_commands()
    if commands_initialized == false then
        vim.api.nvim_create_user_command('NighthawkCleanup', nighthawk.cleanup, {bang=true})
        vim.api.nvim_create_user_command('NighthawkSetup', nighthawk.setup, {bang=true})
    end
end

function nighthawk.setup()
    watchdog.setup()
    setup_commands()
end

function nighthawk.cleanup()
    watchdog.cleanup()
end

function nighthawk.get(path)
    return statistics.get(path)
end

function nighthawk.check()
    health.check()
    watchdog.cleanup()
end

-- return the module
return nighthawk
