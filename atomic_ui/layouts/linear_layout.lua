---@diagnostic disable: undefined-field, inject-field
AtomicUI.LineLayout = AtomicUI.layout {
  init = function(self, config)
    local spacing = config.spacing or AtomicUI.CurrentTheme.listSpacing

    self.spacing = spacing
    self.sizes = {}
    self.vertical = config.vertical

    for _, child in ipairs(config) do
      self:Add(child)
      table.insert(self.sizes, 1)
    end
  end,
  addWidget = function(self, widget, size)
    table.insert(self.subwidget, widget)
    table.insert(self.sizes, size or 1)
  end,
  processWidgets = function (self, parentWidth, parentHeight)
    self.geometry:resize(parentWidth, parentHeight)
    self.geometry:reposition(self.parent.geometry.x, self.parent.geometry.y)
    local maxOrthogonal = 0

    -- Use up-to-date geometry
    for _, subwidget in ipairs(self.subwidget) do
      subwidget:UpdateGeometry()
      maxOrthogonal = math.max(maxOrthogonal, self.vertical and subwidget.geometry.width or subwidget.geometry.height)
    end

    local total = 0
    local totalSpacing = 1 + #self.sizes
    for _, size in ipairs(self.sizes) do
      total = total + size
    end

    local maxParallel = self.vertical and parentHeight or parentWidth
    local sizePerUnit = (maxParallel - totalSpacing * self.spacing) / total

    local i = 0
    for j, widget in ipairs(self.subwidget) do
      local geometry = widget.geometry
      geometry:reposition(self.geometry.x, self.geometry.y)

      local size = self.sizes[j]

      if self.vertical then
        geometry:move(self.spacing, i)
        geometry:resize(maxOrthogonal, size * sizePerUnit)
      else
        geometry:move(i, self.spacing)
        geometry:resize(size * sizePerUnit, maxOrthogonal)
      end
      i = i + size * sizePerUnit + self.spacing
    end
  end,
  updateGeometry = function (self)
    -- No-op
  end
}
