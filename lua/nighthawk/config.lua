--- Default configuration
---
--- Overwrites builtin defaults. Can be overwritten by user configuration
--- specified in the plugin configuration when Nighthawk.setup() is called
local default_config = {
    -- Settings for the logger. Parameters in this section cannot be overwritten by user.
    log = {
        -- Name of the logger
        name = "Nighthawk",

        -- Log to logfile
        to_file = true,

        -- Log to console
        to_console = false,
    },
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

return default_config
