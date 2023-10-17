---@diagnostic disable: undefined-field, inject-field
AtomicUI.Text = AtomicUI.widget {
  init = function(self, config)
    if type(config) == "string" then
      config = {config}
    end
    self.text = config[1] or config.text or "No text"
    self.fontSize = config.fontSize or AtomicUI.CurrentTheme.textSize
    if config.font then
      self.font = config.font and love.graphics.newFont(config.font, self.fontSize) or love.graphics.newFont(self.fontSize)
    else
      self.font = love.graphics.newFont(self.fontSize)
    end
    self.stretch = config.stretch
    self.padding = config.padding or AtomicUI.CurrentTheme.textPadding
    self.geometry:reposition(config.x or 0, config.y or 0)
    self.geometry:resize(self.font:getWidth(self.text) + self.padding * 2, self.font:getHeight() + self.padding * 2)
    self.color = config.color or AtomicUI.color()
  end,
  beginDraw = function(self)
    local sx, sy = 1, 1
    local text = type(self.text) == "string" and self.text or self.text()
    local padding = self.padding
    if self.stretch then
      sx = self.geometry.width / self.font:getWidth(text)
      sy = self.geometry.height / self.font:getHeight()
    else
      local mx = (self.geometry.width - padding * 2) / self.font:getWidth(text)
      local my = (self.geometry.height - padding * 2) / self.font:getHeight()

      local scale = math.min(mx, my, 1)
      sx, sy = scale, scale
    end

    local oldColor = AtomicUI.color()
    self.color:apply()
    local oldfont = love.graphics.getFont()
    love.graphics.setFont(self.font)

    love.graphics.print(text, self.geometry.x + padding, self.geometry.y + padding, 0, sx, sy)

    love.graphics.setFont(oldfont)
    oldColor:apply()
  end,
  updateGeometry = function (self)
    local text = type(self.text) == "string" and self.text or self.text()
    self.geometry:resize((self.font:getWidth(text)) + self.padding * 2, (self.font:getHeight()) + self.padding * 2)
  end
}
