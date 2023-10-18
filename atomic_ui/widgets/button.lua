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

    local padding = config.padding or AtomicUI.CurrentTheme.buttonPadding or 0
    if padding > 0 then
      local padding = AtomicUI.Padding {
        padding = padding,
        config[1],
      }
      self.subwidget[1] = padding
    end
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

    local mx, my = AtomicUI.mousePosition()
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

AtomicUI.FilledButton = AtomicUI.SquareButton:inherit {
  init = function(self, config)
    self.color = config.color or AtomicUI.CurrentTheme.buttonColor or AtomicUI.CurrentTheme.primaryColor or AtomicUI.color()
    self.rx = config.rx or AtomicUI.CurrentTheme.filledButtonRoundedCorners
    self.ry = config.ry or AtomicUI.CurrentTheme.filledButtonRoundedCorners
    self.segments = config.segments or AtomicUI.CurrentTheme.filledButtonRoundedSegments
    self.pressedMargin = config.pressedMargin or 10
    self.pressedColor = config.color or AtomicUI.CurrentTheme.pressedButtonColor or AtomicUI.CurrentTheme.ternaryColor or AtomicUI.color()
  end,
  beginDraw = function(self)
    local oldColor = AtomicUI.color()

    local ox, oy, ow, oh = 0, 0, 0, 0

    local rx, ry = self.rx, self.ry

    if self.timedPress > 0 then
      local t = math.min(self.timedPress, self.longPress) / self.longPress
      
      local lc = self.color:lerp(self.pressedColor, t)
      lc:apply()

      local aspectRatio = self.geometry.width / self.geometry.height

      ox = self.pressedMargin * t
      oy = self.pressedMargin * t / aspectRatio
      ow = ox * 2
      oh = oy * 2
    else
      self.color:apply()
    end

    love.graphics.rectangle("fill", self.geometry.x + ox, self.geometry.y + oy, self.geometry.width - ow, self.geometry.height - oh, rx, ry, self.segments)
    
    oldColor:apply()
  end,
}
