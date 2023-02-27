-- import additional Lua modules
local health = require("nighthawk.health")
local statistics = require("nighthawk.statistics")
local watchdog = require("nighthawk.watchdog")

-- declare the module
local nighthawk = {}

-- route module calls to Lua submodules
nighthawk.setup = watchdog.setup
nighthawk.get_time = statistics.get_time
nighthawk.check = health.check

-- return the module
return nighthawk
