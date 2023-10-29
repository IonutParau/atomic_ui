---@diagnostic disable: undefined-field, inject-field
AtomicUI.LineLayout = AtomicUI.layout {
  init = function(self, config)
    local spacing = config.spacing or AtomicUI.CurrentTheme.listSpacing

    self.spacing = spacing
    self.sizes = {}
    self.vertical = config.vertical

    self.geometry = config.geometry or self.geometry
    self.geometry.x = config.x or self.geometry.x
    self.geometry.y = config.y or self.geometry.y
    self.geometry.width = config.width or self.geometry.width
    self.geometry.height = config.height or self.geometry.height

    local i = 1
    while i <= #config do
      if type(config[i+1]) == "number" then
        local size = config[i+1]
        self:Add(config[i], size)
        i = i + 2
      else
        self:Add(config[i])
        i = i + 1
      end
    end
  end,
  addWidget = function(self, widget, size)
    table.insert(self.sizes, size or 1)
  end,
  processWidgets = function (self)
    local maxOrthogonal = self.vertical and self.geometry.width or self.geometry.height

    -- Use up-to-date geometry
    for _, subwidget in ipairs(self.subwidget) do
      subwidget:UpdateGeometry()
    end

    local total = 0
    local totalSpacing = 1 + #self.sizes
    for _, size in ipairs(self.sizes) do
      total = total + size
    end

    local maxParallel = self.vertical and self.geometry.height or self.geometry.width
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
    -- code
  end
}

AtomicUI.Row = AtomicUI.LineLayout:inherit {
  init = function(self, config)
    self.vertical = false
  end
}

AtomicUI.Column = AtomicUI.LineLayout:inherit {
  init = function(self, config)
    self.vertical = true
  end,
}
