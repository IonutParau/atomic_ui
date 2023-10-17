---@class AtomicUI.Color
---@field r number
---@field g number
---@field b number
---@field a number
local Color = {}

---@overload fun(hex: string): AtomicUI.Color
---@overload fun(r: number, g: number, b: number, a?: number): AtomicUI.Color
---@overload fun(): AtomicUI.Color
local function color(r, g, b, a)
  if r == nil then
    ---@diagnostic disable-next-line: redefined-local
    local r, g, b, a = love.graphics.getColor()
    return setmetatable({r = r * 255, g = g * 255, b = b * 255, a = a * 255}, {__index = Color})
  end

  if type(r) == "number" then
    return setmetatable({r = r, g = g, b = b, a = a or 255}, {__index = Color})
  end
  
  if type(r) == "string" then
    local r, g, b, a = tonumber(r:sub(1, 2), 16), tonumber(r:sub(3, 4), 16), tonumber(r:sub(5, 6), 16), tonumber(r:sub(7, 8)) or 255
    return setmetatable({r = r, g = g, b = b, a = a}, {__index = Color})
  end
end

function Color:apply()
  love.graphics.setColor(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
end

---@param other AtomicUI.Color
---@param t number
---@return AtomicUI.Color
function Color:lerp(other, t)
  local dr = other.r - self.r
  local dg = other.g - self.g
  local db = other.b - self.b

  return color(self.r + dr * t, self.g + dg * t, self.b + db * t)
end

---@generic T
---@param fn fun(): T
---@return T
function Color:scoped(fn)
  local old = color()
  self:apply()
  
  local x = fn()
  
  old:apply()
  return x
end

---@class AtomicUI.Theme
---@field primaryColor? AtomicUI.Color
---@field secondaryColor? AtomicUI.Color
---@field ternaryColor? AtomicUI.Color
---@field buttonColor? AtomicUI.Color
---@field pressedButtonColor? AtomicUI.Color
---@field textColor? AtomicUI.Color
---@field textSize? number
---@field buttonPadding? number
---@field textPadding? number
---@field listSpacing? number
---@field filledButtonRoundedCorners? number
---@field filledButtonRoundedSegments? number
---@field inheritsFrom? AtomicUI.Theme

---@param config AtomicUI.Theme
---@return AtomicUI.Theme
local function theme(config)
  config.inheritsFrom = config.inheritsFrom or AtomicUI.DefaultTheme

  for k, v in pairs(config) do
    if k ~= "inheritsFrom" then
      config[k] = v or config.inheritsFrom[k]
    end
  end

  return config
end

AtomicUI.theme = theme
AtomicUI.color = color

AtomicUI.DefaultTheme = theme {
  -- Here is the default theme
  primaryColor = color(54, 76, 97),
  secondaryColor = color(47, 62, 77),
  ternaryColor = color(37, 50, 59),
  textSize = 16,
  textColor = color(255, 255, 255),
  buttonPadding = 8,
  listSpacing = 10,
  filledButtonRoundedCorners = 15,
  textPadding = 3,
}

AtomicUI.CurrentTheme = AtomicUI.DefaultTheme
