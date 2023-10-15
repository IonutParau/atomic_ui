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
    self.color = config.color or AtomicUI.CurrentTheme.secondaryColor or AtomicUI.color()
    self.rx = config.rx
    self.ry = config.ry
    self.segments = config.segments

    self.geometry = config.geometry or self.geometry
    self.geometry.x = config.x or self.geometry.x
    self.geometry.y = config.y or self.geometry.y
    self.geometry.width = config.width or self.geometry.width
    self.geometry.height = config.height or self.geometry.height

    local child = config[1]

    self:Add(AtomicUI.Padding {
      child,
      padding = self.padding,
      geometry = self.geometry,
    })
  end,
  beginDraw = function(self)
    local oldcolor = AtomicUI.color()

    love.graphics.rectangle("fill", self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height, self.rx, self.ry, self.segments)

    oldcolor:apply()
  end,
  update = function (self, dt)
    self.geometry:copyInto(self.subwidget[1].geometry)
  end
}
