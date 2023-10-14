---@class AtomicUI.LayoutConfig
---@field processWidgets fun(self: AtomicUI.Layout, parentWidth: number, parentHeight: number)
---@field addWidget fun(self: AtomicUI.Layout, ...)
---@field updateGeometry fun(self: AtomicUI.Layout)
---@field init fun(self: AtomicUI.Layout, ...)
---@field update? fun(self: AtomicUI.Layout, dt: number)

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
    onInsert = function (self, parent)
      self:UpdateGeometry()
      ---@cast self AtomicUI.Layout
      config.processWidgets(self, parent.geometry.width, parent.geometry.height)
    end
  }

  ---@cast w AtomicUI.Layout

  if config.addWidget then
    local oldAdd = w.Add
    w.Add = function(self, subwidget)
      oldAdd(self, subwidget)
      ---@cast self AtomicUI.Layout
      config.addWidget(self, subwidget)
    end
  end

  return w
end

AtomicUI.layout = layout
