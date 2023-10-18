---@class AtomicUI.LayoutConfig
---@field processWidgets fun(self: AtomicUI.Layout, parentWidth: number, parentHeight: number)
---@field addWidget fun(self: AtomicUI.Layout, ...)
---@field updateGeometry fun(self: AtomicUI.Layout)
---@field init fun(self: AtomicUI.Layout, ...)
---@field update? fun(self: AtomicUI.Layout, dt: number)

---@class AtomicUI.Layout: AtomicUI.Widget
---@field Add fun(self: AtomicUI.Layout, ...)
---@field parent AtomicUI.Widget
---@field oldParentGeometry AtomicUI.Geometry

---@param config AtomicUI.LayoutConfig
---@return AtomicUI.Layout
local function layout(config)
  local w = AtomicUI.widget {
    updateGeometry = config.updateGeometry,
    init = function(self, ...)
      if config.init then config.init(self, ...) end
      self.oldGeometry = AtomicUI.geometry {}
    end,
    update = function(self, dt)
      ---@cast self AtomicUI.Layout

      if not self.oldParentGeometry:sameAs(self.parent.geometry) then
        self:UpdateGeometry()
        config.processWidgets(self, self.parent.geometry.width, self.parent.geometry.height)
        self.parent.geometry:copyInto(self.oldParentGeometry)
      elseif not self.oldGeometry:sameAs(self.geometry) then
        self.geometry:copyInto(self.oldGeometry)
        config.processWidgets(self, self.parent.geometry.width, self.parent.geometry.height)
      end
      if config.update then
        config.update(self, dt)
      end
    end,
    onInsert = function (self, parent)
      ---@cast self AtomicUI.Layout
      
      self.parent = parent
      self.oldParentGeometry = parent.geometry:copy()
      self:UpdateGeometry()
      ---@cast self AtomicUI.Layout
      config.processWidgets(self, parent.geometry.width, parent.geometry.height)
    end
  }

  ---@cast w AtomicUI.Layout

  if config.addWidget then
    local oldAdd = w.Add
    w.Add = function(self, subwidget, ...)
      oldAdd(self, subwidget, ...)
      ---@cast self AtomicUI.Layout
      config.addWidget(self, subwidget, ...)
    end
  end

  return w
end

AtomicUI.layout = layout
