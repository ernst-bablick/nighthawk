local sqlite = require("sqlite")
local dlog = require("nighthawk.dlog")

-- @todo Move into utility module
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

-- @fixme Move the default location into a nvim dot-directory
local DB_FILE = "~/Nighthawk.sqlite"

local Database = {
    -- DB connection
    connection = nil,
}

--- Constructor for a new Database instance
function Database:new(o)
    -- object setup
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- destructor
    self.__gc = function ()
        self:cleanup()
    end

    return o
end

--- Create the DB tables if they do not exist
function Database:create_table()
    if not self.connection:exists('buffers') then
        self.connection:create(
            'buffers', {
                path = {'text', 'primary', 'key'},
                seconds = {type = 'integer', default = 0},
            }
        )
        if not self.connection:exists('buffers') then
            dlog("unable to create table buffers")
        end
    end

    -- @fix a version table might help to upgrade the database if this should be required
end

--- Connect to the DB
function Database:setup(config)
    local db_file = config["df_file"] or DB_FILE
    db_file = vim.fn.expand(db_file)

    -- establish DB connection
    if not self.connection then
        self.connection = sqlite.new(db_file, {keep_open = true})
        if not self.connection then
            dlog("unable to establish DB connection")
            return
        end
    end

    -- create table
    self:create_table()
end

--- Release a Database instance.
function Database:cleanup()
    -- close DB connection
    if self.connection then
        self.connection:close()
        self.connection = nil
    end
end

--- Add time for a buffer that was touched
---
--- @param buffer_name string Name of a vim buffer.
--- @param time number seconds that should be added.
--- @todo decople function call from database access to improve performance in edit mode
--- @todo Check if the SQLite plugin supports transactions
function Database:add(buffer_name, time)
    -- find record for path if there is one
    local records = self.connection:select("buffers", {where = {path = buffer_name}})

    -- add the seconds to the already accrued amount
    local sec
    if #records == 1 then
        sec = records[1]["seconds"] + time
    else
        sec = time
    end

    -- insert or update the record
    local ok = false
    if #records > 0 then
       ok = self.connection:update("buffers", {
           where = {path = buffer_name},
           set = {path = buffer_name, seconds = sec}
       })
    else
       ok = self.connection:insert("buffers", {
           path = buffer_name,
           seconds = sec
       })
    end

    -- log the error if there was one
    if not ok then
       dlog("insert/update of %s in DB failed", buffer_name)
    end
end

--- Returns the accrued handling time as hour/minute/second string
---
--- @param path string Absolute file or directory path
--- @return string time in the format of [[HH:]MM:]SS
function Database:get(path)
    -- early exit
    if path == nil then
        return "0"
    end

    -- if path is a file we will get exactly one row from the DB
    local record = self.connection:select("buffers", {where = {path = path}})
    if #record == 1 then
        return sec2time(record[1]["seconds"])
    end

    -- must be a directory. we need add up all records that start with path
    local sec = 0
    local records = self.connection:select("buffers")
    if #records > 0 then
        for _, row in pairs(records) do
            if string.sub(row["path"], 1, #path) == path then
                sec = sec + row["seconds"]
            end
        end
    end
    return sec2time(sec)
end

-- @todo add a clear function that either removes a file entry or all entries from one directory from the DB

return Database
