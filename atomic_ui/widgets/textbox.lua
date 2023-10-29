AtomicUI.TextBox = AtomicUI.widget {
  init = function (self, config)
    self.current = config.text or config[1] or ""
    self.cursor = 0

    self.geometry = config.geometry or self.geometry
    self.geometry.x = config.x or self.geometry.x
    self.geometry.y = config.y or self.geometry.y
    self.geometry.width = config.width or self.geometry.width
    self.geometry.height = config.height or self.geometry.height
    self.selected = false

    self.rx = config.rx or AtomicUI.CurrentTheme.textBoxRoundedCorners or 0
    self.ry = config.ry or AtomicUI.CurrentTheme.textBoxRoundedCorners or 0
    self.fillColor = config.fillColor or AtomicUI.CurrentTheme.primaryColor or AtomicUI.color()
    self.boundaryColor = config.boundaryColor or AtomicUI.CurrentTheme.secondaryColor or AtomicUI.color()
    self.boundaryThickness = config.boundaryThickness or AtomicUI.CurrentTheme.textBoxThickness or 5
    self.padding = config.padding or AtomicUI.CurrentTheme.textPadding or 2
    self.tmpcanvas = love.graphics.newCanvas(self.geometry.width, self.geometry.height)
    self.textQuality = config.textQuality or AtomicUI.CurrentTheme.textSize
    if config.font then
      self.font = love.graphics.newFont(config.font, self.textQuality)
    else
      self.font = love.graphics.newFont(self.textQuality)
    end

    self.validator = config.validator
    self.isPassword = config.isPassword
  end,
  update = function (self, delta)
    local mx, my = AtomicUI.mousePosition()

    if love.mouse.isDown(1) then
      self.selected = mx >= self.geometry.x and my >= self.geometry.y and mx <= self.geometry.x + self.geometry.width and my <= self.geometry.y + self.geometry.height
    end
  end,
  beginDraw = function (self)
    local t, t2 = self.boundaryThickness, self.boundaryThickness / 2

    local old = AtomicUI.color()

    -- Background
    self.fillColor:apply()
    love.graphics.rectangle("fill", self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height, self.rx, self.ry)
    
    -- Text
    old:apply()

    local padding = t + self.padding
    local w, h = self.geometry.width - padding * 2, self.geometry.height - padding * 2
    if w * h == 0 then return end

    if w ~= self.tmpcanvas:getWidth() or h ~= self.tmpcanvas:getHeight() then
      self.tmpcanvas:release()
      self.tmpcanvas = love.graphics.newCanvas(w, h)
    end

    local textScale = h / self.font:getHeight()
    local cursorX = self.font:getWidth(self.current:sub(1, self.cursor)) * textScale
    local off = cursorX < w and 0 or -(cursorX - w)

    local oldcanv = love.graphics.getCanvas()
    love.graphics.setCanvas(self.tmpcanvas)
    love.graphics.clear()

    local oldfont = love.graphics.getFont()
    love.graphics.setFont(self.font)
    local text = self.current
    if self.isPassword then
      local password = ""
      
      for i=1,#text do
        password = password .. "*"
      end

      if type(self.isPassword) == "function" then
        if self.isPassword() then
          text = password
        end
      else
        text = password
      end
    end
    love.graphics.print(self.current, off, 0, 0, textScale, textScale)

    old:apply()
    if self.selected then love.graphics.rectangle("fill", cursorX + off, 0, self.font:getWidth("a") * textScale / 4, h) end

    love.graphics.setFont(oldfont)
    love.graphics.setCanvas(oldcanv)
    love.graphics.draw(self.tmpcanvas, self.geometry.x + padding, self.geometry.y + padding)

    -- Border
    self.boundaryColor:apply()
    love.graphics.setLineWidth(t)
    love.graphics.rectangle("line", self.geometry.x + t2, self.geometry.y + t2, self.geometry.width - t, self.geometry.height - t, self.rx, self.ry)

    old:apply()
  end,
  onTextInput = function(self, text)
    if not self.selected then return end
    if self.validator then
      if not self.validator(text) then return end
    end
    local behind = self.current:sub(1, self.cursor)
    local after = self.current:sub(self.cursor + 1, -1)

    self.current = behind .. text .. after
    self.cursor = self.cursor + 1
  end,
  onKeyPress = function(self, key, scancode, isrepeat)
    if not self.selected then return end
    if key == "backspace" then
      local behind = self.current:sub(1, self.cursor - 1)
      local after = self.current:sub(self.cursor + 1, -1)

      self.current = behind .. after
      self.cursor = math.max(self.cursor - 1, 0)
    elseif key == "left" then
      self.cursor = math.max(self.cursor - 1, 0)
    elseif key == "right" then
      self.cursor = math.min(self.cursor + 1, #self.current)
    elseif key == "v" and love.keyboard.isDown("lctrl") then
      local behind = self.current:sub(1, self.cursor)
      local after = self.current:sub(self.cursor + 1, -1)
      local paste = love.system.getClipboardText()

      self.current = behind .. paste .. after
      self.cursor = self.cursor + #paste
    end
  end
}

AtomicUI.TextBox.numberOnly = function(text)
  local byte = string.byte(text, 1, 1)
  local a, b = string.byte("09", 1, 2)

  return byte >= a and byte <= b
end
