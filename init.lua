local require = require

local _ENV = require "tablex.tablex"
local _G = require "_G"
local table = require "table"
local next = _G.next

local function import_to(src, dest, rule)
  if rule then
    local n = #rule
    if n ~= 0 then
      for i = 1, n do
        local k = rule[i]
        if nil == dest[k] then
          dest[k] = src[k]
        end
      end
     else
      for k, v in next, src do
        if nil == dest[k] and not rule[k] then
          dest[k] = v
        end
      end
    end
   else
    for k, v in next, src do
      if nil == dest[k] then
        dest[k] = v
      end
    end
  end
end

-- 导入到 table 库，但不覆盖原有函数
import_to(_ENV, table, {
  printt = true, dir = true
})

-- 导入到 _G
import_to(_ENV, _G, {
  "printt", "dir"
})

_import_to = import_to

return _ENV
