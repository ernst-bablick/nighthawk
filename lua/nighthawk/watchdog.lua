local statistics = require("nighthawk.statistics")

-- this module
local watchdog = {}

-- local variables
local buffer = nil  -- name of last buffer touched
local timestamp = 0 -- timstamp when buffer was touched last
local seconds = 0   -- accumulated time for buffer in seconds

--- updates local variables and propagates values when buffer changes
local function update(buf)
    local now = os.time()
    local delta = now - timestamp

    -- add the elapsed seconds if there was no major break
    if delta <= 300 then
        seconds = seconds + delta
    end

    -- propagate updates to the statistics module
    -- but do this only if the user changed the focus to a new, valid buffer
    if buffer ~= buf and buf ~= "" then
        if buffer ~= nil then
            statistics.buffer_add_time(buffer, seconds)
        end

        -- begin accumulating seconds for the new buffer now
        buffer = buf
        seconds = 0
    end

    -- remember the current time
    timestamp = now
end

---Triggered when a buffer is changed.
---
---@param _ any   String
---@param buf any Buffer ID
local function buffer_changed_callback(_, buf)
    update(vim.api.nvim_buf_get_name(buf))
end

---Triggered for each new or touched  buffer
---
---@param ev any Event with more details
local function buffer_attached_callback(ev)
    update(vim.api.nvim_buf_get_name(ev.buf))
    vim.api.nvim_buf_attach(0, false, {
        on_lines = buffer_changed_callback
    })
end

---Creates autocmd's which then attach to buffers waiting for change events
function watchdog.setup()
    vim.api.nvim_create_autocmd(
        {
            "BufAdd",     -- new buffers added to buffer list
            "BufNew",     -- creation or rename or buffer
            "BufEnter",   -- buffer is entered or edit is started
            "BufLeave",   -- leaving a buffer also when a window is closed
            "BufWinEnter" -- display of a hidden buffer
        },
        {
            pattern = {"*"},
            callback = buffer_attached_callback
        }
    )
end

return watchdog
