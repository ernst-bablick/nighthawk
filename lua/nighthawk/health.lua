local Nighthawk = require("nighthawk.Nighthawk")

local health = {}

function health.check()
    local fns = vim.fn
    local report_ok = fns['health#report_ok']
    local report_warn = fns['health#report_warn']
    local report_error = fns['health#report_error']

    local has_debuglog, _ = pcall(require, "debuglog")
    if has_debuglog then
        report_ok("Debug logger plugin is available")
    else
        report_warn("Debug logger plugin is not available. Debugging not possible.")
    end

    local has_sqlite, _ = require("sqlite")
    if has_sqlite then
        report_ok("SQLite plugin is available")
    else
        report_error("SQLite plugin is not available. Nighthawk will not work.")
    end
end

return health
