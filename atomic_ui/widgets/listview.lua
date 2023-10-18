AtomicUI.ListView = AtomicUI.widget {
  init = function(self, config)
    self.spacing = config.spacing or AtomicUI.CurrentTheme.listSpacing or 0
    self.horizontalSpacing = config.horizontalSpacing or self.spacing

    local maxWidth = 0

    for _, child in ipairs(config) do
      self:Add(child)
      child:UpdateGeometry()
      maxWidth = math.max(maxWidth, child.geometry.width)
    end

    self.geometry = config.geometry or self.geometry
    self.geometry.x = config.x or self.geometry.x
    self.geometry.y = config.y or self.geometry.y
    self.geometry.width = config.width or (maxWidth + self.horizontalSpacing * 2)
    self.geometry.height = config.height or self.geometry.height
    self.tmpcanvas = love.graphics.newCanvas()
    self.filled = config.filled
    self.rx = config.rx
    self.ry = config.ry
    self.scrollSpeed = config.scrollSpeed or 20

    self.scrollingAmount = self.scrollingAmount or 0
  end,
  update = function(self)
    -- Reposition widgets
    local i = self.spacing
    local limit = 0
    for _, widget in ipairs(self.subwidget) do
      widget.geometry.x = self.horizontalSpacing
      widget.geometry.y = i - self.scrollingAmount
      widget.geometry.width = self.geometry.width - self.horizontalSpacing * 2
      i = i + widget.geometry.height + self.spacing

      limit = widget.geometry.y + widget.geometry.height * 2 + self.spacing * 2
    end

    self.scrollingAmount = math.max(math.min(self.scrollingAmount, limit), 0)
  end,
  sideEffects = function(self)
    AtomicUI.offX = AtomicUI.offX + self.geometry.x
    AtomicUI.offY = AtomicUI.offY + self.geometry.y
  end,
  restoreEffects = function(self)
    AtomicUI.offX = AtomicUI.offX - self.geometry.x
    AtomicUI.offY = AtomicUI.offY - self.geometry.y
  end,
  beginDraw = function (self)
    self.oldcanvas = love.graphics.getCanvas()
    local w, h = self.geometry.width, self.geometry.height
    if w ~= self.tmpcanvas:getWidth() or h ~= self.tmpcanvas:getHeight() then
      self.tmpcanvas:release()
      self.tmpcanvas = love.graphics.newCanvas(w, h)
    end
    love.graphics.setCanvas(self.tmpcanvas)
    love.graphics.clear()
    if self.filled then
      local old = AtomicUI.color()
      local color = AtomicUI.CurrentTheme.ternaryColor
      color:apply()
      love.graphics.rectangle("fill", 0, 0, w, h, self.rx, self.ry)
      old:apply()
    end
  end,
  endDraw = function (self)
    love.graphics.setCanvas(self.oldcanvas)
    love.graphics.draw(self.tmpcanvas, self.geometry.x, self.geometry.y)
  end,
  onScroll = function(self, x, y, sx, sy)
    if x >= self.geometry.x and y >= self.geometry.y and x <= self.geometry.x + self.geometry.width and y <= self.geometry.y + self.geometry.height then
      self.scrollingAmount = self.scrollingAmount + self.scrollSpeed * -sy
    end
  end,
}
