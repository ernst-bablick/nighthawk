--- Default configuration
---
--- Overwrites builtin defaults. All except logging parameters can before
--- overwritten by user configuration specified in the plugin configuration 
--- when Nighthawk.setup() is called.
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
    -- OVERWRITEABLE CONFIGURATION - BEGIN
    -- configuration of the Database class
    database = {
        -- path that has to end with a slash
        db_directory = "~/.local/share/nvim/nighthawk/",

        -- name of the DB file located in db_directory
        db_file = "Nighthawk.sqlite",
    },
    -- configuration of the Watchdog class
    watchdog = {
        -- Max seconds of inactivity before buffer observation stops 
        -- (number in seconds > report_interval+1)
        max_inactivity = 120,

        -- Reporting interval in milliseconds (numbers >= 1000)
        report_interval = 1000,
    },
    -- OVERWRITEABLE CONFIGURATION - END
}

return default_config
