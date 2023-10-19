---@class AtomicUI.Widget
---@field enabled boolean | (fun(self: AtomicUI.Widget): boolean)
---@field internal table
---@field config AtomicUI.WidgetConfig
---@field subwidget AtomicUI.Widget[]
---@field geometry AtomicUI.Geometry
---@operator call(...): AtomicUI.Widget
local Widget = {}

---@class AtomicUI.WidgetConfig
---@field endDraw? fun(self: AtomicUI.Widget)
---@field beginDraw? fun(self: AtomicUI.Widget)
---@field update? fun(self: AtomicUI.Widget, delta: number)
---@field keypress? fun(self: AtomicUI.Widget, keycode: love.KeyConstant, scancode: love.Scancode, continuous: boolean)
---@field keyrelease? fun(self: AtomicUI.Widget, keycode: love.KeyConstant, scancode: love.Scancode, continuous: boolean)
---@field onResize? fun(self: AtomicUI.Widget, newWidth: number, newHeight: number)
---@field updateGeometry? fun(self: AtomicUI.Widget)
---@field init? fun(self: AtomicUI.Widget, ...)
---@field enabled? fun(self:AtomicUI.Widget): boolean
---@field onInsert? fun(self:AtomicUI.Widget, parent: AtomicUI.Widget)
---@field onScroll? fun(self: AtomicUI.Widget, x: number, y: number, scrollX: number, scrollY: number)
---@field onTextInput? fun(self: AtomicUI.Widget, text: string)
---@field onKeyPress? fun(self: AtomicUI.Widget, key: love.KeyConstant, scancode: love.Scancode, isrepeat: boolean)
---@field onMousePress? fun(self: AtomicUI.Widget, btn: number, istouch: boolean, presses: number)
---@field sideEffects? fun(self: AtomicUI.Widget)
---@field restoreEffects? fun(self: AtomicUI.Widget)

---@param config AtomicUI.WidgetConfig
---@return AtomicUI.Widget
---Creates a new Widget class based on the config.
---The config controls the instances of this class.
---Example:
---```lua
---local MyWidget = widget {
--- beginDraw = function(self)
---   -- Draw code here
--- end,
---}
---```
function AtomicUI.widget(config)
  return setmetatable({
    config = config,
  }, {__index = Widget, __call = Widget.create})
end

---@return AtomicUI.Widget
function Widget:create(...)
  local w = setmetatable({
    internal = {},
    enabled = type(self.config.enabled) == "function" and self.config.enabled or true,
    subwidget = {},
    geometry = AtomicUI.geometry {x = 0, y = 0, width = 0, height = 0},
  }, {__index = self})

  if self.config.init then
    w.config.init(w, ...)
  end

  return w
end

--- Defines a new Widget class based on an old one
---@param config AtomicUI.WidgetConfig
---@return AtomicUI.Widget
function Widget:inherit(config)
  return setmetatable({
    config = setmetatable({}, {__index = function(_, field)
      if config[field] and not self.config[field] then
        return config[field]
      end
      if not config[field] and self.config[field] then
        return self.config[field]
      end
      if type(config[field]) == "function" and type(self.config[field]) == "function" then
        return function(...)
          self.config[field](...)
          return config[field](...)
        end
      end

      return config[field]
    end}),
  }, {__index = self, __call = Widget.create})
end

---@param name string
function Widget:InvokeConfigFunction(name, ...)
  if type(self.enabled) == "function" then
    if not self:enabled() then return end
  elseif not self.enabled then
    return
  end

  if self.config.sideEffects then self.config.sideEffects(self) end

  -- Because all configs are optinal, we need to check if it exists
  if self.config[name] then self.config[name](self, ...) end

  for _, subwidget in ipairs(self.subwidget) do
    subwidget:InvokeConfigFunction(name, ...)
  end

  if self.config[name .. "_finalize"] then self.config[name .. "_finalize"](self, ...) end

  if self.config.restoreEffects then self.config.restoreEffects(self) end
end

---@param name string
function Widget:InvokeConfigFunctionInverse(name, ...)
  if type(self.enabled) == "function" then
    if not self:enabled() then return end
  elseif not self.enabled then
    return
  end

  for i=#self.subwidget, 1, -1 do
    self.subwidget[i]:InvokeConfigFunctionInverse(name, ...)
  end

  if self.config[name] then self.config[name](self, ...) end
end

function Widget:UpdateGeometry()
  if self.config.updateGeometry then self.config.updateGeometry(self) end
end

function Widget:Draw()
  self:InvokeConfigFunction("beginDraw")
  self:InvokeConfigFunctionInverse("endDraw")
end

---@param dt number
function Widget:Update(dt)
  self:InvokeConfigFunction("update", dt)
end

function Widget:TextInput(text)
  self:InvokeConfigFunction("onTextInput", text)
end

---@param key love.KeyConstant
---@param scancode love.Scancode
---@param isrepeat boolean
function Widget:KeyPress(key, scancode, isrepeat)
  self:InvokeConfigFunction("onKeyPress", key, scancode, isrepeat)
end

---@param subwidget AtomicUI.Widget
function Widget:Add(subwidget)
  table.insert(self.subwidget, subwidget)
  if subwidget.config.onInsert then subwidget.config.onInsert(subwidget, self) end
end

---@param newWidth number
---@param newHeight number
function Widget:Resize(newWidth, newHeight)
  self.geometry:resize(newWidth, newHeight)
  self.config.onResize(self, newWidth, newHeight)
end

---@param x number
---@param y number
---@param sx number
---@param sy number
function Widget:Scroll(x, y, sx, sy)
  self:InvokeConfigFunction("onScroll", x, y, sx, sy)
end

function Widget:MousePressed(btn, istouch, presses)
  self:InvokeConfigFunction("onMousePress", btn, istouch, presses)
end
