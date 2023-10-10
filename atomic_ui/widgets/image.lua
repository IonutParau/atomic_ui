AtomicUI.Image = AtomicUI.widget {
  init = function (self, config)
    self.img = love.graphics.newImage(config[1])
    self.rot = config.rot or 0
    self.color = config.color or AtomicUI.color()

    self.geometry.x = config.x or 0
    self.geometry.y = config.y or 0
    self.geometry.width = config.width or self.img:getWidth()
    self.geometry.height = config.height or self.img:getHeight()
  end,
  beginDraw = function (self)
    local oldcolor = AtomicUI.color()
    self.color:apply()

    local w2 = self.img:getWidth()/2
    local h2 = self.img:getHeight()/2

    local sw = self.geometry.width / self.img:getWidth()
    local sh = self.geometry.height / self.img:getHeight()

    love.graphics.draw(self.img, self.geometry.x + w2, self.geometry.y + h2, self.rot, sw, sh, w2, h2)

    oldcolor:apply()
  end
}
