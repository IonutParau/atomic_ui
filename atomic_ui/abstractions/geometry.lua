---@class AtomicUI.Geometry
---@field x number
---@field y number
---@field width number
---@field height number
local Geometry = {}
Geometry.__index = Geometry

---@param config AtomicUI.Geometry
---@return AtomicUI.Geometry
function AtomicUI.geometry(config)
  return setmetatable({x = config.x or 0, y = config.y or 0, width = config.width or 0, height = config.height or 0}, Geometry)
end

---@param width number
---@param height number
function Geometry:resize(width, height)
  self.width = width
  self.height = height
end

---@param x number
---@param y number
function Geometry:reposition(x, y)
  self.x = x
  self.y = y
end

---@param ox number
---@param oy number
function Geometry:move(ox, oy)
  self.x = (self.x or 0) + ox
  self.y = (self.y or 0) + oy
end

---@param sx number
---@param sy number
function Geometry:scale(sx, sy)
  self.width = (self.width or 1) * sx
  self.height = (self.height or 1) * sy
end

function Geometry:copy()
  return AtomicUI.geometry(self)
end

---@param geo AtomicUI.Geometry
function Geometry:copyInto(geo)
  geo.x = self.x
  geo.y = self.y
  geo.width = self.width
  geo.height = self.height
end

---@param geo AtomicUI.Geometry
function Geometry:sameAs(geo)
  return self.x == geo.x and self.y == geo.y and self.width == geo.width and self.height == geo.height
end
