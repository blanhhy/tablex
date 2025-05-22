local _M = require "tablex.tablex"
local packagex = package.loaded.packagex

if packagex and packagex.inited then
  tablex = _M
  __exports = _M.__exports

  else
    local env = _M.__exports[1][1] or _G
    for k, v in next, _M.__exports[1] do
      if k ~= 1 then
        _G[k] = _G[k] or v
      end
    end
    
    env = _M.__exports[2][1] or table
    for k, v in next, _M.__exports[2] do
      if k~= 1 
        and not _M.__exports[1][k] then
        table[k] = table[k] or v
      end
    end
end

return _M