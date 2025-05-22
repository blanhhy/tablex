local require = require
local _G = _G

local print = _G.print
local next = _G.next
local pcall = _G.pcall

local concat = _G.table.concat
local pack = _G.table.pack
local unpack = _G.table.unpack

local str = _G.tostring
local int = _G.math.floor

local setmt = _G.setmetatable
local getmt = _G.getmetatable

local type = _G.rawtype or _G.type


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
  local prefix = ("  "):rep(indent)
  for key, value in next, tb do
    local key_str = type(key) == "string" and ("[\"%s\"]"):format(key) or ("[%s]"):format(str(key))
    local value_str = value ~= _G and (value ~= tb and tb_to_str(value, max_depth, indent + 1) or "__self") or "_G" -- 排除_G与自引用，防止栈溢出
    str_list[#str_list + 1] = ("%s%s = %s"):format(prefix, key_str, value_str)
  end
  return ("{\n%s\n%s}"):format(
  concat(str_list, ",\n"), ("  "):format(indent - 1))
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
  return sep and concat(str_list, sep, _start, _end)
  or ("{ %s }"):format(concat(str_list, ", ", _start, _end))
end


-- 打印完整表格（支持多个参数）
local print_table
if unpack then
  function print_table(...)
    local params = pack(...)
    for i = 1, params.n do
      params[i] = tb_to_str(params[i], 1)
    end
    print(unpack(params, 1, params.n))
  end
end


-- 打印完整表格（支持指定深度）
local function table_print(tb, max_depth)
  if type(tb) ~= "table" then
    print(str(tb))
   elseif nil == max_depth and nil ~= tb[1] then
    print(arr_to_str(tb))
   else
    print(tb_to_str(tb, max_depth or 1))
  end
end



-- 列出对象的所有字段
local function dir(tb)
  tb = nil ~= tb and (type(tb) == "table" and tb or getmt(tb)
  or error(("The object (%s) has no accessible namespace.")
  :format(str(tb)), 2)) or _ENV or getfenv()
  local list = {}
  local i = 0
  for k in next, tb do
    i = i + 1
    list[i] = k
  end
  list.n = i
  return list
end



local err_msg = "bad argument #%s to '%s' (table expected, got %s)"

local function TypeError(pos, got)
  local caller = debug.getinfo(2, "n")
  local func_name = caller 
  and caller.name or "func ?"
  error(err_msg:format(
  pos, func_name, got), 3)
end




-- 获取表中元素数量
local function get_len(tb)
  local t = type(tb)
  if t ~= "table" then
    TypeError(1, t)
  end

  local len = 0
  for _ in next, tb do
    len = len + 1
  end
  return len
end



-- 获取表中最大正整数索引
local function maxn(tb)
  local t = type(tb)
  if t ~= "table" then
    TypeError(1, t)
  end

  local max = 0
  for index in next, tb do
    max = type(index) == "number" 
    and index > max
    and index == int(index) 
    and index or max
  end
  return max
end



-- 用表2的值覆盖表1
local function override(tb1, tb2)
  local t1, t2 = type(tb1), type(tb2)
  if t1 ~= "table" then
    TypeError(1, t1)
   elseif t2 ~= "table" then
    TypeError(2, t2)
  end

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
    if type(key) == "number" 
      and key > 0
      and key == int(key) then
      array[key] = value
     else
      hash[key] = value
    end
  end
  
  return hash, array
end


local _M = {
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
  detach = detach,
}

_M.__exports = {
  { _G,
    printt = print_table,
    dir = dir
  }, { _G.table,
    tostring = arr_to_str,
    dump = tb_to_str,
    print = table_print,
    size = get_len,
    maxn = maxn,
    override = override,
    collect = collect,
    copy = deepcopy,
    clone = clone,
    detach = detach,
  }
}

return _M