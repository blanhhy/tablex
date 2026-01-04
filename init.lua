local M = require "tablex.tablex"
local packagex = package.loaded.packagex

if packagex and packagex.inited then
  tablex    = M
  __exports = M.__exports
  else
    local extend = M.table.extend
    local groups = M.__exports
    M.__exports  = nil
    M.__exported = true
    local src, env
    for i = 1, #groups do
      src = groups[i]
      env = src[1]
      src[1] = nil
      extend(env, src, true) -- avoid_covering = true
    end
end

return M