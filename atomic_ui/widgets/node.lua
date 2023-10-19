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

AtomicUI.Animator = AtomicUI.widget {
  init = function(self, config)
    self.duration = config.duration or 1
    self.time = 0
    self.curve = config.curve or function(x) return x end
    self.animator = config.animator
    self.playing = config.playing
  end,
  update = function(self, dt)
    local playing = type(self.playing) == "function" and self.playing(self) or self.playing

    if playing then
      self.time = self.time + dt
      if self.time > self.duration then self.time = 0 end
      local x = self.time / self.duration
      x = self.curve(x)
      self.animator(x)
    end
  end,
}

local function lerp(a, b, t)
  return a + (b - a) * t
end

function AtomicUI.Animator.move(config)
  local widget = config[1]
  local sx = config.x or widget.geometry.x
  local sy = config.y or widget.geometry.y
  local dx = config.dx or (config.ex - sx)
  local dy = config.dy or (config.ey - sy)

  return function(x)
    widget.geometry:reposition(sx + dx * x, sy + dy * x)
  end
end

function AtomicUI.Animator.scale(config)
  local widget = config[1]
  local w, h = config.width or widget.geometry.width, config.height or widget.geometry.height
  local sw, sh = config.widthScale or (config.finalWidth / w), config.heightScale or (config.finalHeight / h)
  return function(x)
    local a = lerp(1, sw, x)
    local b = lerp(1, sw, x)
    widget.geometry:resize(w * a, h * b)
  end
end
