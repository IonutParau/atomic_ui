-- This is important for the other files
local path = ...

local geometry = require(path .. ".abstractions.geometry")
local widget = require(path .. ".abstractions.widget", geometry)

return {
  widget = widget,
  geometry = geometry,
}
