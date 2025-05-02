local tablex = require "tablex.tablex"

local function import_to(src, dest)
  for k, v in next, src do
    if not dest[k] then
      dest[k] = v
    end
  end
end


-- 导入到 table 库，但不覆盖原有函数
import_to(tablex, table)

printt = tablex.printt


return tablex