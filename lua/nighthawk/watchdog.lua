local dlog = require("nighthawk.dlog")

-- some default values for this module
local AUTOCMD_GRP    = "Nighthawk" -- name of the autocommand group

--- Check if a file or directory with the given name exists
---
--- @return boolean true when name is a file or directory
local function is_file_or_dir(str)
    return os.rename(str, str) and true or false
end

local Watchdog = {
    -- autogroup used to register all autocommands
    autogrp = nil,

    -- timer handle
    timer = nil,

    -- name of last buffer touched
    buffer = nil,

    -- timstamp when buffer was touched last
    timestamp = 0,

    -- time in which no buffer was switched or changed
    inactivity = 0,

    -- callback function of the DB module
    add_time_func = nil
}

--- Triggered for each new or touched buffer
---
--- @param ev any Event with more details
function Watchdog:buffer_attached_callback(ev)
    self:update(ev.buf, false)
    vim.api.nvim_buf_attach(0, false, {
        on_lines = function (arg1, arg2)
            self:buffer_changed_callback(arg1, arg2)
        end
    })
end

--- Callback triggered when a buffer is changed.
---
--- @param _ any   String
--- @param buf any Buffer ID
function Watchdog:buffer_changed_callback(_, buf)
    -- skip to frequent updates otherwise this will slow down editing of buffers
    if self.timestamp ~= os.time() then
        self:update(buf, true)
    end
end

--- Unregister from buffer and windows events
function Watchdog:cleanup()
    -- stop the timer
    if self.timer ~= nil then
        self:reset_timer()
    end

    -- destroy autogrp and autocmds
    if self.autogrp ~= nil then
        vim.api.nvim_del_augroup_by_id(self.autogrp)
        self.autogrp = nil
    end
end

--- Constructor of Watchdog instances
---
--- @return any New instance of Watchdog
function Watchdog:new(o)
    -- object setup
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.__newindex = self

    -- destructor
    self.__gc = function()
        self:cleanup()
    end
    return o
end

--- Reports time to the statistics module.
---
--- Calculates the time between the last time this function was callend
--- and now and reports that delta to the statistics module for that
--- file that was changed last.
--- Also disabels the timer after a certain amount of inactivity
--- The timer otherwise continues to call this function.
function Watchdog:propagate()
    local now = os.time()

    -- seconds since last call
    local delta = 0
    if self.timestamp > 0 then
        delta = now - self.timestamp
    end

    -- propagate time to statistics module
    if self.buffer ~= nil and delta > 0 then
        if self.add_time_func then
            self.add_time_func(self.buffer, delta)
            dlog("propagating %d sec for %s", delta, self.buffer)
        end
    end

    -- update timestamps
    self.inactivity = self.inactivity + delta
    self.timestamp = now

    -- disable timer if there was no update for x seconds
    if self.inactivity >= self.max_inactivity then
        dlog("timer reset due to inactivity")
        self:reset_timer()
    end
end

function Watchdog:register_add_time(add_time_func)
    self.add_time_func = add_time_func
end

--- Reset timer parameters
function Watchdog:reset_timer()
    -- terminate the timer
    self.timer:close()
    self.timer = nil

    -- reset variables to defaults
    self.timestamp = 0
    self.inactivity = 0
end

--- Registers for certain buffer and windows events
---
--- This function creates an autogroup and adds an autocommand that will
--- trigger the registered callback on certain vim buffer and windows
--- events that indicate that the user is processing a new file.
function Watchdog:setup(config)
    -- store config values for this class
    self.max_inactivity = config["max_inactivity"] or 120    -- seconds
    self.report_interval = config["report_interval"] or 1000 -- milliseconds

    -- create an autogroup if it does not already exist
    if self.autogrp == nil then
        self.autogrp = vim.api.nvim_create_augroup(AUTOCMD_GRP, { clear = true })
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
            group = self.autogrp,
            pattern = { "*" },
            callback = function (ev)
                self:buffer_attached_callback(ev)
            end
        }
    )
end

--- Updates currently edited buffer.
---
--- @param buf number Buffer ID for a buffer that was attached or modified
--- @param has_changed boolean true if buffer contend was changed
function Watchdog:update(buf, has_changed)
    -- skip to frequent updates otherwise this will slow down editing of buffers
    if self.timestamp == os.time() then
        return
    end

    local bufname = vim.api.nvim_buf_get_name(buf)
    local start_timer = false
    local is_real_file = is_file_or_dir(bufname)

    -- was contend changed
    if has_changed == true and is_real_file then
        start_timer = true
        dlog("buffer for a real file has changed")
    end

    -- was the buffer switched
    if bufname ~= nil and self.buffer ~= bufname and is_real_file then
        dlog("buffer was switched from %s to %s", self.buffer, bufname)
        self.buffer = bufname
        start_timer = true
    end

    -- create a timer to propagate data if it does not exist already
    if start_timer == true then
        if self.timer == nil then
            self.timer = vim.loop.new_timer()
            self.timer:start(self.report_interval, self.report_interval, vim.schedule_wrap(function ()
                self:propagate()
            end))
            dlog("starting timer due to user activities")
        end
        self.inactivity = 0
    end
end

return Watchdog
