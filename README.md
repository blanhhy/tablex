# Table Extension

**Tablex** 是一个 Lua 模块，为 `table` 库补充了一些常用函数。

## 导入方式

### 侵入式导入

可以使用 [packagex](https://github.com/blanhhy/packagex) 进行导入：

```lua
include "tablex"
```

也可以用普通的方式：

```lua
require "tablex"
```

### 非侵入式导入

如果你不希望模块修改全局环境和 `table` 标准库，可以这样导入：

```lua
local tablex = requirex "tablex"
```

或者单文件导入（普通方式）：

```lua
local tablex = require "tablex.tablex"
```

## 函数一览

`[]` 表示可选参数，` = ?` 表示默认值

```lua
-- tostring 函数
local str = tablex.array.tostring(tb [, sep, [start, stop]])
local str = tablex.table.tostring(tb [, max_depth = 1])

-- table.tostring = tablex.table.tostring

-- 打印函数
tablex.array.print(...) -- 数组部分
tablex.table.print(...) -- 整个表
tablex.print(...)       -- 自动判断

-- table.print = tablex.table.print
-- _G.printt = tablex.print

-- 跨版本兼容函数 (内置或兼容实现)
tablex.pack(...)
tablex.unpack(tbl[, start, stop])

-- (仅在 Lua 5.1 上)
-- _G.pack = tablex.pack
-- _G.unpack = tablex.unpack

-- 列出对象所有字段
local list = tablex.table.dir(obj)
tablex.dir = tablex.table.dir -- 等价

-- table.dir = tablex.table.dir
-- _G.dir = tablex.dir

-- 获取table元素数量
local size = tablex.table.size(tbl)

-- table.size = tablex.table.size

-- 获取最大正整数键
local n = tablex.array.maxn(tb)
tablex.table.maxn = table.table.maxn -- 等价

-- table.maxn = tablex.table.maxn
-- 注: 如果有内置的 table.maxn, 则上面这些都是内置的 maxn

-- 用表2扩展表1, 返回表1, 默认覆写
[local tbl1 = ] tablex.table.extend(tbl1, tbl2[, avoid_covering])

-- table.extend = tablex.table.extend

-- 合并两个表 (默认覆写, 相同键后一个覆盖前一个), 得到新的表
local res = tablex.table.union(tbl1, tbl2)

-- table.union = tablex.table.union

-- 深拷贝, 默认保持相同的元表, 可以阻止设置元表
local replica = tablex.table.clone(tbl[, no_MT])

-- table.clone = tablex.table.clone

-- 分离纯表部分和可能数组部分
-- 可能数组部分: 正整数键部分, 如果填充了空洞就会变成数组
-- 纯表部分: 非正整数键部分
local tbl, arr = tablex.table.detach(tb)

-- table.detach = tablex.table.detach

-- 提取 table 中的数组 (连续正整数键部分)
local arr = tablex.array.extract(tb)

```