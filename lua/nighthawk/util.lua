local util = {}

--- Converts a number (seconds) into a time string in the format [[HH:]MM:]SS
--
--- @param seconds integer Number of seconds
--- @return string Time string in the format [[HH:]MM:]SS
function util.sec2time(seconds)
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

--- Check if a file or directory with the given name exists
---
--- @return boolean true when name is a file or directory
function util.is_file_or_dir(str)
    return os.rename(str, str) and true or false
end

return util
