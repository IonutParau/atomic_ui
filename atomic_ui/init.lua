-- This is important for the other files
local path = ...

AtomicUI = {}

require(path .. ".abstractions.geometry")
require(path .. ".abstractions.widget")
require(path .. ".abstractions.layout")
require(path .. ".abstractions.theme")

-- Layouts
require(path .. ".layouts.linear_layout")

-- Widgets
require(path .. ".widgets.text")

return AtomicUI
