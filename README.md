# Table Extension

**Tablex** 是一个 Lua 模块，为 `table` 库补充了一些常用函数。

## 导入方式

### 侵入式导入

推荐使用 [packagex](https://github.com/blanhhy/packagex) 模块进行导入：

```lua
require "packagex".init()

include "tablex"
```

也可以用普通的方式：

```lua
require "tablex"
```

### 非侵入式导入

如果你不希望模块修改全局环境和 `table` 标准库，可以这样导入：

```lua
require "packagex".init()

local tablex = requirex "tablex"
```

或者单文件导入（普通方式）：

```lua
local tablex = require "tablex.tablex"
```

## 函数一览

`[]` 表示可选参数，` = ?` 表示默认值

```lua
-- 数组转字符串
local str = tablex.tostring(tb [, sep, [_start, _end]])
local str = table.tostring(tb [, sep, [_start, _end]])

-- table转字符串
local str = tablex.dump(tb [, max_depth = 10])
local str = table.dump(tb [, max_depth = 10])

-- 打印完整表格（多参数，类似print）
tablex.printt(...)
printt(...)

-- 打印完整表格（支持指定深度，不指定深度时只打印数组部分）
tablex.print(tb [, max_depth])
table.print(tb [, max_depth])

-- 列出对象所有字段
local list = tablex.dir(obj)
local list = dir(obj)

-- 获取table元素数量
local size = tablex.size(tb)
local size = table.size(tb)

-- 获取最大正整数键
local n = tablex.maxn(tb)
local n = table.maxn(tb)

-- 用表2覆盖表1，返回表1
[local tb1 = ] tablex.override(tb1, tb2)
[local tb1 = ] table.override(tb1, tb2)

-- 按后覆盖前的规则合并两个table，得到新的table
local result = tablex.collect(tb1, tb2)
local result = table.collect(tb1, tb2)

-- 深拷贝table
local replica = tablex.copy(tb)
local replica = table.copy(tb)

-- 深拷贝table，同时继承metatable
local replica = tablex.clone(tb)
local replica = table.clone(tb)

-- 分离table的非数组部分与数组部分
local hash, array = tablex.detach(tb)
local hash, array = table.detach(tb)
```