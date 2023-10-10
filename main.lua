-- This is just for an example
-- If you want to run the example, clone the repo and run this with Love2D
-- If you just want to use the library, just copy the atomic_ui folder.

require("atomic_ui")

love.graphics.setColor(1, 1, 1)

local t = AtomicUI.Text:create {
  "Simple text",
  padding = 10,
  fontSize = 32,
}

function love.draw()
  t:Draw()
end

function love.update(dt)
  --t:Update(dt)
end
