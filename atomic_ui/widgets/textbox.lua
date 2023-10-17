-- TODO: textbox

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
  end,
  onTextInput = function(self, text)
    if not self.selected then return end
    local behind = self.current:sub(1, self.cursor)
    local after = self.cursor:sub(self.cursor + 1, -1)

    self.current = behind .. text .. after
    self.cursor = self.cursor + 1
  end,
  onKeyPress = function(self, key, scancode, isrepeat)
    if not self.selected then return end
    if key == "delete" then
      -- Delete
    elseif key == "left" then
      self.cursor = math.max(self.cursor - 1, 0)
    elseif key == "right" then
      self.cursor = math.min(self.cursor + 1, #self.current)
    end
  end
}
