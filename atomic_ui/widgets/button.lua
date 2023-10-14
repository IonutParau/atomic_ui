AtomicUI.RawButton = AtomicUI.widget {
  init = function(self, config)
    self:Add(config[1])

    self.onClick = config.onClick
    self.onLongClick = config.onLongClick
    self.longPress = config.longPressTime or 0.2
    self.oldGeometry = self.geometry:copy()
    self.timedPress = 0
    self.shape = config.shape
  end,
  update = function(self, dt)
    if not self.geometry:sameAs(self.oldGeometry) then
      -- Geometry changed
      self.geometry:copyInto(self.oldGeometry)
      self.geometry:copyInto(self.subwidget[1].geometry)
    elseif not self.geometry:sameAs(self.subwidget[1].geometry) then
      -- Child geometry changed
      self.subwidget[1].geometry:copyInto(self.geometry)
    end

    local mx, my = love.mouse.getX()
    if love.mouse.isDown(1) and self.shape(self.geometry, mx, my) then
      -- Is pressed
      self.timedPress = self.timedPress + dt
    elseif self.timedPress > 0 then -- No longer pressed but was pressed
      if self.timedPress >= self.longPress then
        self.onLongClick()
      else
        self.onClick()
      end
    end
  end,
  updateGeometry = function (self)
    self.subwidget[1]:UpdateGeometry()
    self.subwidget[1].geometry:copyInto(self.geometry)
  end
}

AtomicUI.SquareButton = AtomicUI.RawButton:inherit {
  init = function(config)
    ---@param geometry AtomicUI.Geometry
    ---@param mx number
    ---@param my number
    self.shape = function(geometry, mx, my)
      return mx >= geometry.x and my >= geometry.y and mx <= geometry.x + geometry.width and my <= geometry.y + geometry.height
    end
  end,
}
