AtomicUI.Switch = AtomicUI.widget {
  init = function(self, config)
    self.toggled = config.toggled
    self.backgroundColor = config.backgroundColor or AtomicUI.CurrentTheme.secondaryColor or AtomicUI.color()
    self.color = config.color or AtomicUI.CurrentTheme.primaryColor or AtomicUI.color()

    self.brx = config.brx or AtomicUI.CurrentTheme.switchButtonRoundedCorners
    self.bry = config.bry or AtomicUI.CurrentTheme.switchButtonRoundedCorners
    self.spacing = config.spacing or 5
  
    self.geometry = config.geometry or self.geometry
    self.geometry.x = config.x or self.geometry.x
    self.geometry.y = config.y or self.geometry.y
    self.geometry.width = config.width or self.geometry.width
    self.geometry.height = config.height or self.geometry.height
    self.onToggle = config.onToggle
    self.dotSize = (config.dotSize or 30) / 100
  end,
  beginDraw = function(self)
    local old = AtomicUI.color()

    self.backgroundColor:apply()
    love.graphics.rectangle("fill", self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height, self.brx, self.bry)

    self.color:apply()
    local spacing = self.spacing
    local w, h = self.geometry.width - spacing * 2, self.geometry.height - spacing * 2
    local s = math.min(w * self.dotSize, h * self.dotSize)
    local off = self.toggled and (w/2 + s/2 + spacing) or (w/2 - s/2 - spacing)
    
    love.graphics.circle("fill", self.geometry.x + spacing + off, self.geometry.y + spacing + h/2, s)

    old:apply()
  end,
  onMousePress = function(self, btn, istouch, presses)
    local mx, my = AtomicUI.mousePosition()

    if btn == 1 and mx >= self.geometry.x and mx <= self.geometry.x + self.geometry.width and my >= self.geometry.y and my <= self.geometry.y + self.geometry.height then
      self.toggled = not self.toggled
      if self.onToggle then self.onToggle(self.toggled) end
    end
  end,
}

AtomicUI.CheckBox = AtomicUI.widget {
  init = function(self, config)
    self.toggled = config.toggled
    self.backgroundColor = config.backgroundColor
    self.color = config.color
    self.thickness = config.thickness
    self.padding = config.padding
  end,
  beginDraw = function(self)
    local old = AtomicUI.color()

    local backgroundColor = config.backgroundColor or AtomicUI.CurrentTheme.secondaryColor
    backgroundColor:apply()
    love.graphics.rectangle("fill", self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height)
    
    local padding = self.padding or 10
    local thickness = self.thickness or 5

    local color = config.color or AtomicUI.CurrentTheme.primaryColor
    color:apply()

    do
      local lw = love.graphics.getLineWidth()
      love.graphics.setLineWidth(thickness)
      love.graphics.rectangle("line", self.geometry.x + thickness/2, self.geometry.y + thickness/2, self.geometry.width - thickness, self.geometry.height - thickness)
    end
    old:apply()
  end,
}
