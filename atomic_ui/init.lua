-- This is important for the other files
local path = ...

AtomicUI = {}

require(path .. ".abstractions.geometry")
require(path .. ".abstractions.widget")
require(path .. ".abstractions.layout")
require(path .. ".abstractions.theme")
require(path .. ".abstractions.json")
AtomicUI.Curves = require(path .. ".abstractions.curves")

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
require(path .. ".widgets.toggle")

AtomicUI.offX = 0 -- Accumualted offsets
AtomicUI.offY = 0

function AtomicUI.mousePosition()
  local mx, my = love.mouse.getPosition()

  return mx - AtomicUI.offX, my - AtomicUI.offY
end

--- TODO: particle emitting
function AtomicUI.emit()

end

AtomicUI.version = {
  dev = true, -- Means this is a dev version
  major = 0,
  minor = 1,
  bugfix = 0,
}

setmetatable(AtomicUI.version, {
  __tostring = function(v)
    return v.major .. "." .. v.minor .. ":" .. v.bugfix .. (v.dev and " [DEV]" or "")
  end,
})

return AtomicUI
