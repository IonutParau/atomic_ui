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
require(path .. ".widgets.listview")
require(path .. ".widgets.textbox")

AtomicUI.offX = 0 -- Accumualted offsets
AtomicUI.offY = 0

function AtomicUI.mousePosition()
  local mx, my = love.mouse.getPosition()

  return mx - AtomicUI.offX, my - AtomicUI.offY
end

--- TODO: particle emitting
function AtomicUI.emit()

end

return AtomicUI
