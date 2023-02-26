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

--- Add time for a buffer that was touched
--- If the buffer_name is not an existing file or dir then
--- add the time to the last real file that was previously
--- handled.
---
--- @param buffer_name string Name of a vim buffer.
--- @param time number seconds that should be added.
function statistics.buffer_add_time(buffer_name, time)

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

--- Returns the accrued handling time as hour/minute/second string
---
--- @param path any
--- @return boolean true when entry for path exists
--- @return string time in the format of [[HH:]MM:]SS
function statistics.get_time(path)
    local acc = 0 -- seconds 
    local res = "" -- output string

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
    local hours = math.floor(acc / 3600)
    local minutes = math.floor((acc - hours * 60) / 60)
    local seconds = acc % 60

    -- build the output string
    -- (leading 0's for all except the first number)
    if hours > 0 then
        res = res .. hours .. ':'
    end
    if minutes > 0 then
        if hours > 0 then
            res = res .. string.format("%02d", minutes) .. ':'
        else
            res = res .. minutes .. ':'
        end
        res = res .. string.format("%02d", seconds)
    else
        res = res .. seconds
    end

    -- return success plus the result string
    return true, res
end

return statistics
