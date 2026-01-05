local _G = _G

local print, type, next, select, tostring, getmetatable, setmetatable
    = print, type, next, select, tostring, getmetatable, setmetatable

local int = math.floor
local concat = table.concat
local pack, unpack

local outdated = tonumber(_G._VERSION:sub(5)) <= 5.1

if outdated then
  function pack(...)
    return {..., n = select('#', ...)}
  end
  unpack = _G.unpack or require "tablex.unpack"
else
  pack = table.pack
  unpack = table.unpack
end

local Array, Table = {}, {}

-- 数组转字符串
-- 对于表的递归, 也只会取数组部分
function Array:tostring(sep, start, stop)
  if type(self) ~= "table" then
    return tostring(self)
  end

  local str_list = {}
  local index = 1
  local value = self[1]

  while value ~= nil do
    str_list[index] = value == self
      and "self"
      or Array.tostring(value)
    index = index + 1
    value = self[index]
  end

  sep   = sep or ", "
  start = start or 1
  stop  = stop or index - 1

  return "{"..concat(str_list, sep, start, stop).."}"
end

Table._TOSTRING_DEPTH = 10 -- 默认的递归深度

-- 完整的 table 转字符串
-- 内容可能很多, 需要限制递归深度
function Table:tostring(max_depth, indent)
  max_depth = max_depth or Table._TOSTRING_DEPTH
  indent = indent or 0

  local typ = type(self)

  if typ == "string" then
    return indent > 0 and ("%q"):format(self) or self
  end

  if typ ~= "table"
  or indent >= max_depth then
    return tostring(self)
  end

  local lines  = {}
  local prefix = ("  "):rep(indent)
  local key_str, val_str

  for key, val in next, self do

    key_str = (
      type(key) == "string"
      and "[%q]"
      or "[%s]"
    ):format(key)

    val_str = (val ~= _G) and (
      val ~= self and
        Table.tostring(val, max_depth, indent + 1)
      or "self"
    ) or "_G" -- 排除_G与自引用，防止栈溢出

    lines[#lines+1] = ("%s  %s = %s"):format(prefix, key_str, val_str)
  end

  return ("{\n%s\n%s}"):format(
    concat(lines, ",\n"),
    prefix
  )
end

Table._PRINT_DEPTH = 3

-- 打印 table (多参数, 类似 print)
function Table.print(...)
  local args = pack(...)
  for i = 1, args.n do
    args[i] = Table.tostring(args[i], Table._PRINT_DEPTH)
  end
  return print(unpack(args, 1, args.n))
end

-- 多数组专用 print
function Array.print(...)
  local args = pack(...)
  for i = 1, args.n do
    args[i] = Array.tostring(args[i])
  end
  return print(concat(args, '\n', 1, args.n))
end

-- 智能打印, 自动识别 tostring 模式
local function M_print(...)
  local nargs = select('#', ...)
  if nargs == 0 then return print("<no value>") end
  if nargs >= 2 then return Table.print(...) end

  if type(...) ~= "table" then
    return print(tostring(...))
  end

  local m = (nil ~= (...)[1] or not next(...)) and Array or Table
  return print(m.tostring(...))
end

local dirs_MT = {
  __tostring = Array.tostring; -- 方便直接 print 查看
}

-- 列出对象的所有字段
function Table:dir()
  self = nil ~= self and (
    type(self) == "table"
    and self
    or getmetatable(self)
    or error(("The object (%s) has no accessible namespace.")
      :format(tostring(self)), 2)
  ) or _G

  local dirs  = {}
  local index = 0

  for key in next, self do
    index = index + 1
    dirs[index] = key
  end

  dirs.n = index
  return setmetatable(dirs, dirs_MT)
end

-- 获取表中元素数量
function Table:size()
  local size = 0
  for _ in next, self do size = size + 1 end
  return size
end

-- 获取最大正整数键
Array.maxn = table.maxn

if not Array.maxn then
  function Array:maxn()
    local max = 0
    for key in next, self do
      max = type(key) == "number" -- 需要是数字
      and key > max               -- 需要最大
      and key == int(key)         -- 需要是整数
      and key or max
    end
    return max
  end
end

Table.maxn = Array.maxn

-- 用另一个表的值扩展一个表 (默认覆写)
function Table:extend(other, avoid_covering)
  for k, v in next, other do
    if not avoid_covering or self[k] == nil then
      self[k] = v
    end
  end
  return self
end

-- 合并两个表, 得到新的表 (默认覆写)
function Table:union(other, avoid_covering)
  return Table.extend(
    Table.extend({}, self),
    other,
    avoid_covering
  )
end

-- 深拷贝
function Table:clone(no_MT, copyOf)
  if type(self) ~= "table" then
    return self -- 非 table 类型直接返回自身
  end

  if copyOf and copyOf[self] then
    return copyOf[self] -- 处理循环引用
  end

  local replica = {}
  copyOf = copyOf or {} -- 记录已复制的表，避免重复
  copyOf[self] = replica

  for k, v in next, self do
    replica[k] = Table.clone(v, no_MT, copyOf) -- 递归复制
  end

   -- 是否不设置元表? 默认会设置 (no_MT = nil)
  if no_MT then return replica end
  return setmetatable(replica, getmetatable(self))
end

-- 分离 table 的常用表部分和正整数键部分
function Table:detach()
  local array = {}
  local table = {}

  for k, v in next, self do
    if type(k) == "number"
      and k > 0
      and k == int(k) then
      array[k] = v
    else
      table[k] = v
    end
  end

  return table, array
end

-- 提取 table 的纯数组 (连续正整数键) 部分
function Array:extract()
  local array = {}
  local index = 1
  local value = self[1]
  while value ~= nil do
    array[index] = value
    index = index + 1
    value = self[index]
  end
  return array
end

-- 计算数组部分的实际长度
function Array:length()
  local index = 1
  local value = self[1]
  while value ~= nil do
    index = index + 1
    value = self[index]
  end
  return index - 1
end

local M = {
  table = Table;
  array = Array;
  print = M_print;

  dir = Table.dir;   -- 拿出来方便使用
  maxn = Table.maxn; -- 全版本 maxn
  pack  = pack;      -- 全版本 pack
  unpack = unpack;   -- 全版本 unpack
}

-- 导出组
M.__exports = {
  {
    _G,
    printt = M_print;
    dir    = Table.dir;
    pack   = outdated and pack or nil;
    unpack = outdated and unpack or nil;
  };
  Table;
}
Table[1] = _G.table

return M