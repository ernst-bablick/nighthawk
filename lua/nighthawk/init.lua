-- import additional Lua modules
local Nighthawk = require("nighthawk.Nighthawk")
local health = require("nighthawk.health")
local dlog = require("nighthawk.dlog")

local module = {}
local nighthawk = nil
local commands_initialized = false

--- Default configuration
---
--- Overwrites builtin defaults. Can be overwritten by user configuration
--- specified in the plugin configuration when Nighthawk.setup() is called
local default_config = {

    -- configuration of the Watchdog class
    watchdog = {
        -- Max seconds of inactivity before timer stops
        max_inactivity = 120,

        -- Reporting interval in milliseconds
        report_interval = 1000,
    },
    -- configuration of the Database class
    database = {
        db_file = "~/Nighthawk.sqlite",
    },
}

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
end

--- Cleaup function that terminates the plugin
function module.cleanup()
    nighthawk = nil
end

function module.get(path)
    return nighthawk:get(path)
end

--- Healthcheck that can be triggered by checkhealth-command
function module.check()
    health.check()
end

-- return the module
return module
