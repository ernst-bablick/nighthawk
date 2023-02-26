-- import additional Lua modules
local watchdog = require("nighthawk.watchdog")
local statistics = require("nighthawk.statistics")

-- declare the module
local nighthawk = {}

-- route module calls to Lua submodules
nighthawk.setup = watchdog.setup
nighthawk.get_time = statistics.get_time

-- return the module
return nighthawk
