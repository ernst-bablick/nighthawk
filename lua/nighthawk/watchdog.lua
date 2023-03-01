local statistics = require("nighthawk.statistics")

-- this module
local watchdog = {}

-- local variable
local autogrp    = nil -- autogroup used to register all autocommands
local timer      = nil -- timer handle
local buffer     = nil -- name of last buffer touched
local timestamp  = 0   -- timstamp when buffer was touched last
local inactivity = 0   -- time in which no buffer was switched or changed
local dlog       = nil -- debug log function

local AUTOCMD_GRP    = "Nighthawk" -- name of the autocommand group
local DEBUG_LOGGER   = "Nighthawk" -- name of the debug logger
local MAX_INACTIVITY = 15          -- max inactivity in seconds
local TIMER_INTERVAL = 1000        -- timer interval in milliseconds

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
        dlog("propagating %d sec for %s", delta, buffer)
    end

    -- update timestamps
    inactivity = inactivity + delta
    timestamp = now

    -- disable timer if there was no update for x seconds
    if inactivity > MAX_INACTIVITY + 1 then
        dlog("timer reset due to inactivity")
        reset_timer()
    end
end

--- Updates currently edited buffer.
---
--- @param buf number Buffer ID for a buffer that was attached or modified
--- @param has_changed boolean true if buffer contend was changed
local function update(buf, has_changed)
    local bufname = vim.api.nvim_buf_get_name(buf)
    local start_timer = false
    local is_real_file = exists(bufname)

    -- was contend changed
    if has_changed == true and is_real_file then
        start_timer = true
        dlog("buffer for a real file has changed (need timer)")
    end

    -- was the buffer switched
    if bufname ~= nil and buffer ~= bufname and is_real_file then
        dlog("buffer was switched from %s to %s (need timer)", buffer, bufname)
        buffer = bufname
        start_timer = true
    end

    -- create a timer to propagate data if it does not exist already
    if start_timer == true then
        if timer == nil then
            timer = vim.loop.new_timer()
            timer:start(TIMER_INTERVAL, TIMER_INTERVAL, vim.schedule_wrap(propagate))
            dlog("starting timer")
        end
        inactivity = 0
    end
end

--- Callback triggered when a buffer is changed.
---
--- @param _ any   String
--- @param buf any Buffer ID
local function buffer_changed_callback(_, buf)
    update(buf, true)
end

--- Triggered for each new or touched buffer
---
--- @param ev any Event with more details
local function buffer_attached_callback(ev)
    update(ev.buf, false)
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
    dlog = require("nighthawk.dlog")(DEBUG_LOGGER)
    if dlog == nil then
        return
    else
        local debuglog = require("debuglog")

        debuglog.set_config({
            log_to_file = true,
            log_to_console = false,
        })
        debuglog.enable(DEBUG_LOGGER)
    end

    -- print(require("debuglog").log_file_path())


    -- create an autogroup if it does not already exist
    if autogrp == nil then
        autogrp = vim.api.nvim_create_augroup(AUTOCMD_GRP, { clear = true })
    end

    -- add an autocommand to the group
    vim.api.nvim_create_autocmd(
        {
            "BufAdd", -- new buffers added to buffer list
            "BufNew", -- creation or rename or buffer
            "BufNewFile", -- creation of a new file 
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
