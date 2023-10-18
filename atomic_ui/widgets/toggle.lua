AtomicUI.Switch = AtomicUI.widget {
  init = function(self, config)
    self.toggled = config.toggled
    self.backgroundColor = config.backgroundColor or AtomicUI.CurrentTheme.secondaryColor or AtomicUI.color()
    self.color = config.color or AtomicUI.CurrentTheme.primaryColor or AtomicUI.color()

    self.brx = config.brx or AtomicUI.CurrentTheme.filledButtonRoundedCorners or 5
    self.bry = config.bry or AtomicUI.CurrentTheme.filledButtonRoundedCorners or 5
    self.frx = config.frx or AtomicUI.CurrentTheme.filledButtonRoundedCorners or 2
    self.fry = config.fry or AtomicUI.CurrentTheme.filledButtonRoundedCorners or 2
    self.spacing = config.spacing or 5
  
    self.geometry = config.geometry or self.geometry
    self.geometry.x = config.x or self.geometry.x
    self.geometry.y = config.y or self.geometry.y
    self.geometry.width = config.width or self.geometry.width
    self.geometry.height = config.height or self.geometry.height
    self.onToggle = config.onToggle
  end,
  beginDraw = function(self)
    local old = AtomicUI.color()

    self.backgroundColor:apply()
    love.graphics.rectangle("fill", self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height, self.brx, self.bry)

    self.color:apply()
    local spacing = self.spacing
    local w, h = self.geometry.width - spacing * 2, self.geometry.height - spacing * 2
    local off = self.toggled and w/2 or 0
    
    love.graphics.rectangle("fill", self.geometry.x + spacing + off, self.geometry.y + spacing + h/4, w/2, h/2, self.frx, self.fry)

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
