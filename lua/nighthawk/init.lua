-- import additional Lua modules
local Nighthawk = require("nighthawk.Nighthawk")
local health = require("nighthawk.health")
local dlog = require("nighthawk.dlog")

local module = {}
local nighthawk = nil
local commands_initialized = false

local function setup_commands()
    if commands_initialized == false then
        vim.api.nvim_create_user_command('NighthawkCleanup', module.cleanup, {bang=true})
        vim.api.nvim_create_user_command('NighthawkSetup', module.setup, {bang=true})
        commands_initialized = false
    end
end

function module.setup()
    nighthawk = Nighthawk:new()
    setup_commands()
end

function module.cleanup()
    nighthawk = nil
end

function module.get(path)
    return nighthawk:get(path)
end

function module.check()
    health.check()
end

-- return the module
return module
