---@class AtomicUI.LayoutConfig
---@field processWidgets fun(self: AtomicUI.Layout, parentWidth: number, parentHeight: number)
---@field addWidget fun(self: AtomicUI.Layout, ...)
---@field updateGeometry fun(self: AtomicUI.Layout)
---@field init fun(self: AtomicUI.Layout, ...)
---@field update fun(self: AtomicUI.Layout, dt: number)

---@class AtomicUI.Layout: AtomicUI.Widget
---@field Add fun(self: AtomicUI.Layout, ...)

---@param config AtomicUI.LayoutConfig
---@return AtomicUI.Layout
local function layout(config)
  local w = AtomicUI.widget {
    onParentResize = function(self, w, h)
      ---@cast self AtomicUI.Layout
      self:UpdateGeometry()
      config.processWidgets(self, w, h)
    end,
    updateGeometry = config.updateGeometry,
    init = config.init,
    update = config.update,
  }

  w.Add = config.addWidget -- Intercept Add
  ---@cast w AtomicUI.Layout

  return w
end

AtomicUI.layout = layout
