AtomicUI.Padding = AtomicUI.widget {
  init = function (self, config)
    self.padding = config.padding
    local child = config[1]
    child:UpdateGeometry()
    self.geometry = AtomicUI.geometry {
      x = child.geometry.x - self.padding,
      y = child.geometry.y - self.padding,
      width = child.geometry.width + self.padding * 2,
      height = child.geometry.height + self.padding * 2,
    }
    self.geometry = config.geometry or self.geometry
    self.geometry.x = config.x or self.geometry.x
    self.geometry.y = config.y or self.geometry.y
    self.geometry.width = config.width or self.geometry.width
    self.geometry.height = config.height or self.geometry.height
    self:Add(child)
  end,
  update = function(self)
    self:UpdateGeometry()
  end,
  updateGeometry = function(self)
    local child = self.subwidget[1]
    child.geometry.x = self.geometry.x + self.padding
    child.geometry.y = self.geometry.y + self.padding
    child.geometry.width = self.geometry.width - self.padding * 2
    child.geometry.height = self.geometry.height - self.padding * 2
  end
}

AtomicUI.Box = AtomicUI.widget {
  init = function(self, config)
    self.padding = config.padding
    self.color = config.color or AtomicUI.CurrentTheme.secondaryColor
    self.rx = config.rx
    self.ry = config.ry
    self.segments = config.segments
    self.filled = config.filled

    self.geometry = config.geometry or self.geometry
    self.geometry.x = config.x or self.geometry.x
    self.geometry.y = config.y or self.geometry.y
    self.geometry.width = config.width or self.geometry.width
    self.geometry.height = config.height or self.geometry.height

    local child = config[1]

    if self.padding then
      self:Add(AtomicUI.Padding {
        child,
        padding = self.padding,
        geometry = self.geometry,
      })
    else
      self:Add(child)
    end
  end,
  beginDraw = function(self)
    if not self.filled then return end
    local oldcolor = AtomicUI.color()
    self.color:apply()

    love.graphics.rectangle("fill", self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height, self.rx, self.ry, self.segments)

    oldcolor:apply()
  end,
  update = function (self, dt)
    self.geometry:copyInto(self.subwidget[1].geometry)
  end
}

AtomicUI.Tooltip = AtomicUI.widget {
  init = function(self, config)
    self:Add(config[1])
    ---@type AtomicUI.Widget
    local tooltip = config[2]

    tooltip.enabled = function(self)
      local mx, my = AtomicUI.mousePosition()
      return mx >= self.geometry.x and my >= self.geometry.y and mx <= self.geometry.x + self.geometry.width and my <= self.geometry.y + self.geometry.height
    end

    self.geometry = config.geometry or self.geometry
    self.geometry.x = config.x or self.geometry.x
    self.geometry.y = config.y or self.geometry.y
    self.geometry.width = config.width or self.geometry.width
    self.geometry.height = config.height or self.geometry.height

    self.oldGeometry = self.geometry:copy()
  end,
  update = function(self, dt)
    if not self.oldGeometry:sameAs(self.geometry) then
      self.geometry:copyInto(self.oldGeometry)
      self.geometry:copyInto(self.subwidget[1].geometry)
    elseif not self.geometry:sameAs(self.subwidget[1].geometry) then
      self.subwidget[1].geometry:copyInto(self.geometry)
    end

    local mx, my = AtomicUI.mousePosition()
    local tooltip = self.subwidget[2]

    tooltip.geometry:reposition(mx, my)
  end,
}

AtomicUI.Center = AtomicUI.widget {
  init = function(self, config)
    self:Add(config[1])
    self.centerX = config.centerX or 0.5
    self.centerY = config.centerY or 0.5
    self.childCenterX = config.childCenterX or 0.5
    self.childCenterY = config.childCenterY or 0.5
  end,
  update = function(self, dt)
    local child = self.subwidget[1]
    local cw, ch = child.geometry.width * self.childCenterX, child.geometry.height * self.childCenterY
    local sw, sh = self.geometry.width * self.centerX, self.geometry.height * self.centerY

    child.geometry:reposition(sw - cw, sh - ch)
  end,
}
