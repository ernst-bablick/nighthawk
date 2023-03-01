--- Read more at https://github.com/smartpde/debuglog#shim
local has_debuglog, debuglog = pcall(require, "debuglog")

if has_debuglog then
    return debuglog.logger_for_shim_only
else
    return function(_) end
end
