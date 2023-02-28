local statistics = {}   -- this module
local buffer_table = {} -- map of paths that holds the time in seconds
local last_file = nil   -- last real filepath that was touched

--- Check if a file or directory with the given name exists
---
--- @param name string file or path name
--- @return boolean true when name is a file or directory
local function exists(name)
    if type(name) ~= "string" then
        return false
    end
    return os.rename(name, name) and true or false
end

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

    -- Check if buffer_name is a existing file or dir.
    if exists(buffer_name) then
        last_file = buffer_name
    end

    -- Add the time to the last existing file or dir that was touched.
    if last_file ~= nil then
        if buffer_table[last_file] == nil then
            buffer_table[last_file] = time
        else
            buffer_table[last_file] = buffer_table[last_file] + time
        end
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
    local acc = 0 -- seconds 
    local res = "" -- output string

    if path == nil then
        return false, "0"
    end

    -- accumulate all numbers that belong to the path
    if buffer_table[path] ~= nil then
        acc = buffer_table[path]
    else
        for key, value in pairs(buffer_table) do
            if string.sub(key, 1, #path) == path then
                acc = acc + value
            end
        end
    end

    -- calculate hours/minutes/seconds
    res = sec2time(acc)

    -- return success plus the result string
    return true, res
end

return statistics
