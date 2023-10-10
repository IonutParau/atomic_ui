---@diagnostic disable: undefined-field, inject-field
AtomicUI.Text = AtomicUI.widget {
  init = function(self, config)
    self.text = config[1] or config.text or "No text"
    self.fontSize = config.fontSize or AtomicUI.CurrentTheme.textSize
    self.textAlign = "left"
    if config.font then
      self.font = config.font and love.graphics.newFont(config.font, self.fontSize) or love.graphics.newFont(self.fontSize)
    end
    self.stretch = config.stretch
    self.padding = config.padding or AtomicUI.CurrentTheme.textPadding
    self.geometry:reposition(config.x or 0, config.y or 0)
    self.geometry:resize(self.width or self.font:getWidth(self.text), self.height or self.font:getHeight())
  end,
  beginDraw = function(self)
    local sx, sy = 1, 1
    if self.stretch then
      sx = self.geometry.width / self.font:getWidth(self.text)
      sy = self.geometry.height / self.font:getHeight()
    end
    local padding = self.padding
    love.graphics.print(self.text, self.geometry.x + padding, self.geometry.y + padding, 0, sx, sy)
  end,
  updateGeometry = function (self)
    self.geometry:resize(self.width or self.font:getWidth(self.text), self.height or self.font:getHeight())
  end
}
