-- This is important for the other files
local path = ...

AtomicUI = {}

require(path .. ".abstractions.geometry")
require(path .. ".abstractions.widget")
require(path .. ".abstractions.layout")
require(path .. ".abstractions.theme")
require(path .. ".abstractions.json")

-- Layouts
require(path .. ".layouts.linear_layout")

-- Widgets
require(path .. ".widgets.text")
require(path .. ".widgets.image")
require(path .. ".widgets.node")
require(path .. ".widgets.button")
require(path .. ".widgets.containers")

return AtomicUI
