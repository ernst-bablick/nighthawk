local default_config = require("nighthawk.config")

--- Read more at https://github.com/smartpde/debuglog#shim
local has_debuglog, debuglog = pcall(require, "debuglog")

if has_debuglog then
    local dlog = nil
    local log_config = default_config["log"]
    local name = log_config["name"]
    local to_file = log_config["to_file"]
    local to_console = log_config["to_console"]

    debuglog.set_config({
        log_to_file = to_file,
        log_to_console = to_console
    })
    if to_file or to_console then
        debuglog.enable(name)
        dlog = debuglog.logger_for_shim_only(name)
        if dlog then
           dlog("dlog %s initialized", name)
        end
        return dlog
    else
        return function(...) end
    end
else
    return function(...) end
end
