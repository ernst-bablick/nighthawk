--- Read more at https://github.com/smartpde/debuglog#shim
local has_debuglog, debuglog = pcall(require, "debuglog")

-- @todo make the dlog module configureable via user configuration

local DEBUG_LOGGER = "Nighthawk"
local dlog = nil

if has_debuglog then
    debuglog.set_config({
        log_to_file = true,
        log_to_console = false,
    })
    debuglog.enable(DEBUG_LOGGER)

    dlog = debuglog.logger_for_shim_only(DEBUG_LOGGER)
    dlog("dlog %s initialized", DEBUG_LOGGER)
    return dlog
else
    return function(...) end
end
