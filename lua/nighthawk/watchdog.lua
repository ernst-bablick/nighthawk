local statistics = require("nighthawk.statistics")

-- this module
local watchdog = {}

-- local variable
local autogrp    = nil -- autogroup used to register all autocommands
local timer      = nil -- timer handle
local buffer     = nil -- name of last buffer touched
local timestamp  = 0   -- timstamp when buffer was touched last
local inactivity = 0   -- time in which no buffer was switched or changed

local AUTOCMD_GRP    = "Nighthawk" -- name of the autocommand group
local MAX_INACTIVITY = 300         -- max inactivity in seconds
local TIMER_INTERVAL = 1000        -- timer interval in milliseconds

--- Reset timer parameters
local function reset_timer()
    -- terminate the timer
    timer:close()

    -- reset variables to defaults
    timer = nil
    timestamp = 0
    inactivity = 0
end

--- Reports time to the statistics module.
---
--- Calculates the time between the last time this function was callend
--- and now and reports that delta to the statistics module for that
--- file that was changed last.
--- Also disabels the timer after a certain amount of inactivity
--- The timer otherwise continues to call this function.
local function propagate()
    local now = os.time()

    -- seconds since last call
    local delta = 0
    if timestamp > 0 then
        delta = now - timestamp
    end

    -- propagate time to statistics module
    if buffer ~= nil and delta > 0 then
        statistics.add(buffer, delta)
    end

    -- update timestamps
    inactivity = inactivity + delta
    timestamp = now

    -- disable timer if there was no update for x seconds
    if inactivity > MAX_INACTIVITY + 1  then
        reset_timer()
    end
end

--- Updates currently edited buffer.
---
--- @param buf number Buffer ID for a buffer that was attached or modified
local function update(buf)
    local bufname = vim.api.nvim_buf_get_name(buf)

    -- remember the buffer if it is a new one
    if bufname ~= nil and bufname ~= "" and buffer ~= bufname then
        buffer = bufname
    end

    -- create a timer to propagate data if it does not exist already
    if timer == nil then
        timer = vim.loop.new_timer()
        timer:start(TIMER_INTERVAL, TIMER_INTERVAL, vim.schedule_wrap(propagate))
    end
end

--- Callback triggered when a buffer is changed.
---
--- @param _ any   String
--- @param buf any Buffer ID
local function buffer_changed_callback(_, buf)
    update(buf)
end

--- Triggered for each new or touched buffer
---
--- @param ev any Event with more details
local function buffer_attached_callback(ev)
    update(ev.buf)
    vim.api.nvim_buf_attach(0, false, {
        on_bytes = buffer_changed_callback
    })
end

--- Registers for certain buffer and windows events
---
--- This function creates an autogroup and adds an autocommand that will
--- trigger the registered callback on certain vim buffer and windows
--- events that indicate that the user is processing a new file.
function watchdog.setup()
    -- create an autogroup if it does not already exist
    if autogrp == nil then
        autogrp = vim.api.nvim_create_augroup(AUTOCMD_GRP, { clear = true })
    end

    -- add an autocommand to the group
    vim.api.nvim_create_autocmd(
        {
            "BufAdd", -- new buffers added to buffer list
            "BufNew", -- creation or rename or buffer
            "BufEnter", -- buffer is entered or edit is started
            "BufLeave", -- leaving a buffer also when a window is closed
            "BufWinEnter" -- display of a hidden buffer
        },
        {
            group = autogrp,
            pattern = { "*" },
            callback = buffer_attached_callback
        }
    )
end

--- Unregister from buffer and windows events
function watchdog.cleanup()
    -- stop the timer
    if timer ~= nil then
        reset_timer();
    end

    -- destroy autogrp and autocmds
    if autogrp ~= nil then
        vim.api.nvim_del_augroup_by_id(autogrp)
        autogrp = nil
    end

    -- reset statistics
    statistics.clear()
end

return watchdog
