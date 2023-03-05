-- import additional Lua modules
local Nighthawk = require("nighthawk.Nighthawk")
local health = require("nighthawk.health")
local dlog = require("nighthawk.dlog")
local default_config = require("nighthawk.config")

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

--- Setup function called by the plugin framework
function module.setup(config)
    -- merge default config and user config defined for the plugin
    module.config = vim.tbl_deep_extend('force', {}, default_config, config or {})

    -- startup Nighthawk
    nighthawk = Nighthawk:new()
    nighthawk:setup(module.config)
    setup_commands()
    dlog("Nighthawk setup completed")
end

--- Cleaup function that terminates the plugin
function module.cleanup()
    nighthawk = nil
end

--- Returns editing time for path
function module.get(path)
    return nighthawk:get(path)
end

--- Healthcheck that can be triggered by checkhealth-command
function module.check()
    health.check()
end

-- return the module
return module
