AtomicUI.Slider = AtomicUI.widget {
  init = function(self, config)
    self.segments = config.segments
    self.radioThickness = config.radioThickness or 0.9 -- In percentages
    self.precision = config.precision
    self.radioSize = config.radioSize or 0.3
    self.backgroundColor = config.backgroundColor
    self.color = config.color
    self.value = config.value or 0
    self.onChange = config.onChange
    self.lineThickness = config.lineThickness or 0.3
    self.wasPressed = true

    -- Geometry
    self.geometry = config.geometry or self.geometry
    self.geometry.x = config.x or self.geometry.x
    self.geometry.y = config.y or self.geometry.y
    self.geometry.width = config.width or self.geometry.width
    self.geometry.height = config.height or self.geometry.height
  end,
  beginDraw = function (self)
    local old = AtomicUI.color()

    local radioSize = (self.geometry.height * self.radioSize)
    local w, h = self.geometry.width - radioSize * 2, self.geometry.height * self.lineThickness
    local ox, oy = radioSize, (self.geometry.height/2 - radioSize/2)
    
    local bg = self.backgroundColor or AtomicUI.CurrentTheme.secondaryColor
    bg:apply()
    love.graphics.rectangle("fill", self.geometry.x + ox, self.geometry.y + oy, w, h)

    local color = self.color or AtomicUI.CurrentTheme.primaryColor
    color:apply()
    love.graphics.circle("fill", self.geometry.x + w * self.value + radioSize, self.geometry.y + oy + radioSize / 2, radioSize)

    old:apply()
  end,
  update = function(self, dt)
    local radioSize = (self.geometry.height * self.radioSize)
    local w, h = self.geometry.width - radioSize * 2, self.geometry.height * self.lineThickness
    local ox, oy = radioSize, (self.geometry.height/2 - radioSize/2)
    local mx, my = AtomicUI.mousePosition()
   
    local isPressed = love.mouse.isDown(1) and mx >= self.geometry.x + ox and my >= self.geometry.y + oy and mx <= self.geometry.x + ox + w and my <= self.geometry.y + oy + h

    if isPressed then
      self.wasPressed = true
    end

    if self.wasPressed then
      -- Get x delta
      local dx = mx - self.geometry.x - ox
      local v = math.max(math.min(dx / w, 1), 0)
      if self.segments then
        local s = self.segments - 1
        v = math.floor(v * s) / s
      end
      if self.precision then
        local n = 10 ^ self.precision
        v = math.floor(v * n) / n
      end
      self.value = v
      if self.onChange then self.onChange(v) end
    end

    if not love.mouse.isDown(1) then
      self.wasPressed = false
    end
  end,
}
