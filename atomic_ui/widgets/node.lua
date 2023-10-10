--- A widget whos meant to have subnodes and a condition function for when its enabled
AtomicUI.Node = AtomicUI.widget {
  init = function(self, config)
    self.enabled = config.enabled
    
    for _, child in ipairs(config) do
      self:Add(child)
    end
  end,
}
