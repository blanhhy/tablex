local tablex = require "tablex.tablex"

local function import_to(src, dest)
  for k, v in next, src do
    if not dest[k] then
      dest[k] = v
    end
  end
end


local printt = tablex.printt
tablex.printt = nil


import_to(tablex, table)


_ENV.printt = printt
tablex.printt = printt


return tablex