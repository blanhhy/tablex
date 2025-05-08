local require = require
local _G = require "_G"
local string = require "string"
local table = require "table"
local print = _G.print
local next = _G.next
local rep = string.rep
local f = string.format
local join = table.concat
local pack = table.pack
local unpack = table.unpack
local str = _G.tostring
local int = require("math").floor
local setmt = _G.setmetatable
local getmt = _G.getmetatable

-- require "unifuncex"
local type = rawtype or type
local check = checktype


-- 列出完整表格
local function tb_to_str(tb, max_depth, indent)
  if type(tb) ~= "table" then
    return str(tb)
  end
  indent = indent or 0
  max_depth = max_depth or 10 -- 默认最大递归深度 10
  if indent >= max_depth then
    return str(tb) -- 超过最大深度时省略，防止栈溢出
  end
  local str_list = {}
  local prefix = rep("  ", indent)
  for key, value in next, tb do
    local key_str = type(key) == "string" and f("[\"%s\"]", key) or f("[%s]", str(key))
    local value_str = value ~= _G and (value ~= tb and tb_to_str(value, max_depth, indent + 1) or "__self") or "_G" -- 排除_G与自引用，防止栈溢出
    str_list[#str_list + 1] = f("%s%s = %s", prefix, key_str, value_str)
  end
  return f("{\n%s\n%s}", join(str_list, ",\n"), rep("  ", indent - 1))
end



-- 数组转字符串
local function arr_to_str(tb, sep, _start, _end)
  if type(tb) ~= "table" then
    return str(tb)
  end
  local str_list = {}
  for i = 1, #tb do
    str_list[i] = str(tb[i])
  end
  return sep and join(str_list, sep, _start, _end) or f("{ %s }", join(str_list, ", ", _start, _end))
end


-- 打印完整表格（支持多个参数）
local function print_table(...)
  local params = pack(...)
  for i = 1, params.n do
    params[i] = tb_to_str(params[i])
  end
  print(unpack(params, 1, params.n))
end



-- 打印完整表格（支持指定深度）
local function table_print(tb, max_depth)
  if nil == max_depth and nil ~= tb[1] then
    print(arr_to_str(tb))
   else
    print(tb_to_str(tb, max_depth))
  end
end



-- 列出对象的所有字段
local function dir(tb)
  tb = nil ~= tb and (type(tb) == "table" and tb or getmt(tb)
  or error(f(
    "The object (%s) has no accessible namespace.",
    str(tb)
  ), 2)) or _ENV or getfenv()
  local list = {}
  local i = 0
  for k in next, tb do
    i = i + 1
    list[i] = k
  end
  list.n = i
  return list
end



-- 获取表中元素数量
local function get_len(tb)
  local len = 0
  for _ in next, tb do
    len = len + 1
  end
  return len
end



-- 获取表中最大正整数索引
local function maxn(tb)
  local _ = check and check(type, tb, "table")
  local max = 0
  for index in next, tb do
    max = type(index) == "number" and index > max and index == int(index) and index or max
  end
  return max
end



-- 用表2的值覆盖表1
local function override(tb1, tb2)
  local _ = check and check(type, tb1, tb2, "table", "table")
  for key, value in next, tb2 do
    tb1[key] = value
  end
  return tb1
end



-- 合并table（索引相同的后一个覆盖前一个）
local function collect(tb1, tb2)
  local result = override({}, tb1)
  for key, value in next, tb2 do
    result[key] = value
  end
  return result
end



-- 完全复制 table（不继承元表）
local function deepcopy(tb, seen)
  if type(tb) ~= "table" then
    return tb -- 非 table 类型直接返回自身
  end
  if seen and seen[tb] then
    return seen[tb] -- 处理循环引用
  end
  local new = {}
  seen = seen or {} -- 记录已复制的表，避免重复
  seen[tb] = new
  for key, value in next, tb do
    new[key] = deepcopy(value, seen)
  end
  return new
end



-- 完全复制 table（继承元表）
local function clone(tb)
  return setmt(deepcopy(tb), getmt(tb))
end



-- 分离table的非数组部分与数组部分
local function detach(tb)
  local array = {}
  local hash = {}
  for key, value in next, tb do
    if type(key) == "number" and key > 0 and key == int(key) then
      array[key] = value
     else
      hash[key] = value
    end
  end
  return hash, array
end



return {
  tostring = arr_to_str,
  dump = tb_to_str,
  print = table_print,
  printt = print_table,
  dir = dir,
  size = get_len,
  maxn = maxn,
  override = override,
  collect = collect,
  copy = deepcopy,
  clone = clone,
  detach = detach
}