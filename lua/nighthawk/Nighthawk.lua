local Watchdog = require("nighthawk.Watchdog")
local Database = require("nighthawk.Database")
local dlog = require("nighthawk.dlog")

local Nighthawk = {
    --- Watchdog that obswerves buffer switches or changes
    watchdog = nil,
    database = nil,
}

--- Creates a new instance of a Nighthawk class
function Nighthawk:new(o)
    -- Object setup
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Destructor
    self.__gc = function ()
        self:cleanup()
    end
    return o
end

--- Initializes members for instances of Nighthawk
function Nighthawk:setup(config)
    -- start observing buffer changes
    self.watchdog = Watchdog:new()
    if not self.watchdog then
        dlog("unable to initialize watchdog in class Nighthawk")
        return
    end

    self.watchdog:setup(config["watchdog"])

    -- get connection to DB
    self.database = Database:new()
    if not self.watchdog then
        self.watchdog = nil
        dlog("unable to initialize database in class Nighthawk")
        return
    end

    -- establish DB connection
    self.database:setup(config["database"])

    -- register DB as listener for buffer changes
    self.watchdog:register_add_time(function (bufname, time)
        self.database:add(bufname, time)
    end)
end

--- Called when object is garbage collected
function Nighthawk:cleanup()
    self.watchdog = nil
    self.database = nil
end

--- Returns timestring for path
function Nighthawk:get(path)
    return self.database:get(path)
end

return Nighthawk
