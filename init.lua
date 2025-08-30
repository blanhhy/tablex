local _M = require "tablex.tablex"
local packagex = package.loaded.packagex

if packagex and packagex.inited then
  tablex = _M
  __exports = _M.__exports

  else
    local env = _M.__exports[1][1]
    for k, v in next, _M.__exports[1] do
      if k ~= 1 then
        env[k] = env[k] or v
      end
    end
    
    local env = _M.__exports[2][1]
    for k, v in next, _M.__exports[2] do
      if k ~= 1
        and not _M.__exports[1][k] then
        env[k] = env[k] or v
      end
    end
end

return _M