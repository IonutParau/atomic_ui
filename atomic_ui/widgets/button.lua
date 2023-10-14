AtomicUI.RawButton = AtomicUI.widget {
  init = function(self, config)
    self:Add(config[1])
    config[1]:UpdateGeometry()
    self.geometry = self.subwidget[1].geometry:copy()

    self.onClick = config.onClick
    self.onLongClick = config.onLongClick
    self.whileClicked = config.whileClicked
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

    local mx, my = love.mouse.getPosition()
    if love.mouse.isDown(1) and self.shape(self.geometry, mx, my) then
      -- Is pressed
      self.timedPress = self.timedPress + dt
      if self.whileClicked then self.whileClicked() end
    else
      if self.timedPress > 0 then -- No longer pressed but was pressed
        if self.timedPress >= self.longPress then
          if self.onLongClick then self.onLongClick() end
        else
          if self.onClick then self.onClick() end
        end
      end
      self.timedPress = 0
    end
  end,
  updateGeometry = function (self)
    self.subwidget[1]:UpdateGeometry()
    self.subwidget[1].geometry:copyInto(self.geometry)
  end
}

AtomicUI.SquareButton = AtomicUI.RawButton:inherit {
  init = function(self, config)
    ---@param geometry AtomicUI.Geometry
    ---@param mx number
    ---@param my number
    self.shape = function(geometry, mx, my)
      return mx >= geometry.x and my >= geometry.y and mx <= geometry.x + geometry.width and my <= geometry.y + geometry.height
    end
  end,
}
