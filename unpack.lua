-- 如果没有 unpack 则实现一个麻烦点的版本
-- 这种情况应该不可能发生

local function unpacker(list, i, stop)
  if i >= stop then return list[stop] end
  return list[i], unpacker(list, i + 1, stop)
end

local error = error

function unpack(list, start, stop)
  start = start or 1
  stop  = stop  or #list
  
  -- 不知道 lua 栈多大, 保守估计 50 万
  if stop - start >= 5e6 then
    error("too many results to unpack", 2)
  end

  return unpacker(list, start, stop)
end

table.unpack = unpack

return unpack