package.path = "./?.lua;./?/init.lua;" .. package.path

local tablex = require "tablex"

print(dir(tablex))