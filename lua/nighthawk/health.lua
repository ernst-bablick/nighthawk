local health = {}

function health.check()
   local fns = vim.fn
   local report_ok = fns['health#report_ok']
   -- local report_error = fns['health#report_error']
   local report_warn = fns['health#report_warn']

    local has_debuglog, _ = pcall(require, "debuglog")
    if has_debuglog then
        report_ok("Debug logger is available")
    else
        report_warn("Debug logger is not available. Debugging not possible.")
    end
end

return health
