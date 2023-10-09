---@class AtomicUI.Widget
---@field enabled boolean
---@field internal table
---@field config AtomicUI.WidgetConfig
---@field subwidget AtomicUI.Widget[]
---@field geometry? AtomicUI.Geometry
local Widget = {}

---@class AtomicUI.WidgetConfig
---@field endDraw? fun(self: AtomicUI.Widget)
---@field beginDraw? fun(self: AtomicUI.Widget)
---@field update? fun(self: AtomicUI.Widget, delta: number)
---@field keypress? fun(self: AtomicUI.Widget, keycode: love.KeyConstant, scancode: love.Scancode, continuous: boolean)
---@field keyrelease? fun(self: AtomicUI.Widget, keycode: love.KeyConstant, scancode: love.Scancode, continuous: boolean)
---@field onParentResize? fun(self: AtomicUI.Widget, newWidth: number, newHeight: number)
---@field onResize? fun(self: AtomicUI.Widget, newWidth: number, newHeight: number)
---@field updateGeometry? fun(self: AtomicUI.Widget)
---@field init? fun(self: AtomicUI.Widget, ...)

---@param config AtomicUI.WidgetConfig
---@return AtomicUI.Widget
---Creates a new Widget class based on the config.
---The config controls the instances of this class.
---Example:
---```lua
---local MyWidget = widget {
--- beginDraw = function(self)
---   -- Draw code here
--- end,
---}
---```
function AtomicUI.widget(config)
  return setmetatable({
    config = config,
  }, {__index = Widget})
end

---@return AtomicUI.Widget
function Widget:create(...)
  local w = setmetatable({
    internal = {},
    enabled = true,
    subwidget = {},
    geometry = AtomicUI.geometry {x = 0, y = 0, width = 0, height = 0},
  }, {__index = self})

  if self.config.init then
    w.config.init(w, ...)
  end

  return w
end

---@param name string
function Widget:InvokeConfigFunction(name, ...)
  -- Because all configs are optinal, we need to check if it exists
  if self.config[name] then self.config[name](self, ...) end

  for _, subwidget in ipairs(self.subwidget) do
    subwidget:InvokeConfigFunction(name, ...)
  end
end

---@param name string
function Widget:InvokeConfigFunctionInverse(name, ...)
  for _, subwidget in ipairs(self.subwidget) do
    subwidget:InvokeConfigFunctionInverse(name, ...)
  end

  if self.config[name] then self.config[name](self, ...) end
end

function Widget:UpdateGeometry()
  self.config.updateGeometry(self)
end

function Widget:Draw()
  self:InvokeConfigFunction("beginDraw")
  self:InvokeConfigFunctionInverse("endDraw")
end

---@param dt number
function Widget:Update(dt)
  self:InvokeConfigFunction("update", dt)
end

---@param subwidget AtomicUI.Widget
function Widget:Add(subwidget)
  table.insert(self.subwidget, subwidget)
end

---@param newWidth number
---@param newHeight number
function Widget:Resize(newWidth, newHeight)
  self.geometry:resize(newWidth, newHeight)
  self.config.onResize(self, newWidth, newHeight)

  for _, subwidget in ipairs(self.subwidget) do
    subwidget.config.onParentResize(subwidget, newWidth, newHeight)
  end
end
