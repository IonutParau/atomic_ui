AtomicUI.Button = AtomicUI.widget {
  init = function(self, config)
    self:Add(config[1])

    self.onClick = config.onClick
    self.oldGeometry = self.geometry:copy()
  end,
  update = function(self, dt)
    
  end,
}
