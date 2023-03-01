local statistics = {}   -- this module
local buffer_table = {} -- map of paths that holds the time in seconds
local last_file = nil   -- last real filepath that was touched

--- clears local statistics
function statistics.clear()
    buffer_table = {}
    last_file = nil
end

--- Add time for a buffer that was touched
--- If the buffer_name is not an existing file or dir then
--- add the time to the last real file that was previously
--- handled.
---
--- @param buffer_name string Name of a vim buffer.
--- @param time number seconds that should be added.
function statistics.add(buffer_name, time)
    last_file = buffer_name

    -- Add the time to the last existing file or dir that was touched.
    if last_file ~= nil then
        if buffer_table[last_file] == nil then
            buffer_table[last_file] = 0
        end
        buffer_table[last_file] = buffer_table[last_file] + time
    end
end

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

--- Returns the accrued handling time as hour/minute/second string
---
--- @param path any
--- @return boolean true when entry for path exists
--- @return string time in the format of [[HH:]MM:]SS
function statistics.get(path)
    -- early exit
    if path == nil then
        return false, "0"
    end

    -- file entries are aprt of the map
    if buffer_table[path] ~= nil then
        return true, sec2time(buffer_table[path])
    end

    -- accumulate all numbers that belong to a directory
    local sec = 0
    for key, value in pairs(buffer_table) do
        if string.sub(key, 1, #path) == path then
            sec = sec + value
        end
    end
    return true, sec2time(sec)
end

return statistics
