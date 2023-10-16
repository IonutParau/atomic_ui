--- A widget whos meant to have subnodes and a condition function for when its enabled
AtomicUI.Node = AtomicUI.widget {
  init = function(self, config)
    self.enabled = config.enabled
    
    for _, child in ipairs(config) do
      self:Add(child)
    end
  end,
}

--- Navigators allow for navigation across an AtomicUI.Menu.
AtomicUI.Navigator = AtomicUI.widget {
  ---@param router AtomicUI.Router
  init = function(self, router)
    self.router = router
    for k, v in pairs(router.paths) do
      self:Add(v)
      v.enabled = function() return router:current() == k end
    end
  end,
}

---@class AtomicUI.Router
---@field paths {[string]: AtomicUI.Widget}
---@field pathStack string[]
local Router = {}

---@param path string
---@param widget AtomicUI.Widget
function Router:addPath(path, widget)
  self.paths[path] = widget
end

---@param path string
function Router:switch(path)
  self.pathStack[#self.pathStack] = path
end

---@param path string
function Router:push(path)
  self.pathStack[#self.pathStack+1] = path
end

function Router:pop()
  self.pathStack[#self.pathStack] = nil
end

function Router:current()
  return self.pathStack[#self.pathStack]
end

---@param paths {[string]: AtomicUI.Widget}
---@param initialPath? string
function Router:new(paths, initialPath)
  return setmetatable({paths = paths, currentPath = initialPath or "/"}, {__index = Router, __call = Router.new})
end

AtomicUI.Router = Router
