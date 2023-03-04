local sqlite = require("sqlite")
local dlog = require("nighthawk.dlog")

local function sec2time(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds - h * 3600) / 60)
    local s = seconds % 60

    local res = ""
    if h > 0 then
        res = res .. h .. ':'
    end
    if m > 0 then
        if h > 0 then
            res = res .. string.format("%02d", m) .. ':'
        else
            res = res .. m .. ':'
        end
        res = res .. string.format("%02d", s)
    else
        res = res .. s
    end
    return res
end

local Database = {
    -- DB connection
    connection = nil,

    -- map of paths that holds the time in seconds
    buffer_table = {},

    -- last real filepath that was touched
    last_file = nil,
}

function Database:new(o)
    -- object setup
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- destructor
    self.__gc = function ()
        self:cleanup()
    end

    -- instance variables
    self.buffer_table = {}

    return o
end

function Database:connect(dbfile)
    -- establish DB connection
    if not self.connection then
        self.connection = sqlite.new(dbfile, {keep_open = true})
        if not self.connection then
            dlog("unable to establish DB connection")
            return
        end
    end
end

function Database:cleanup()
    -- close DB connection
    if self.connection then
        self.connection:close()
        self.connection = nil
    end

    -- reset instance variables
    self.buffer_table = nil
    self.last_file = nil
end

--- Add time for a buffer that was touched
--- If the buffer_name is not an existing file or dir then
--- add the time to the last real file that was previously
--- handled.
---
--- @param buffer_name string Name of a vim buffer.
--- @param time number seconds that should be added.
function Database:add(buffer_name, time)
    self.last_file = buffer_name

    -- Add the time to the last existing file or dir that was touched.
    if self.last_file and self.buffer_table then
        if self.buffer_table[self.last_file] == nil then
            self.buffer_table[self.last_file] = 0
        end
        self.buffer_table[self.last_file] = self.buffer_table[self.last_file] + time
    end
end

--- Returns the accrued handling time as hour/minute/second string
---
--- @param path any
--- @return string time in the format of [[HH:]MM:]SS
function Database:get(path)
    -- early exit
    if path == nil or self.buffer_table == nil then
        return "0"
    end

    -- file entries are aprt of the map
    if self.buffer_table[path] ~= nil then
        return sec2time(self.buffer_table[path])
    end

    -- accumulate all numbers that belong to a directory
    local sec = 0
    for key, value in pairs(self.buffer_table) do
        if string.sub(key, 1, #path) == path then
            sec = sec + value
        end
    end
    return sec2time(sec)
end

return Database
