local Database = require("nighthawk.Database")

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

    local ok = Database.check_access()
    if ok then
        report_ok("SQLite Database accessable")
    else
        report_error("SQLite Database not accessable")
    end

end

return health
