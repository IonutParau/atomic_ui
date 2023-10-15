-- This is just for an example
-- If you want to run the example, clone the repo and run this with Love2D
-- If you just want to use the library, just copy the atomic_ui folder.

require("atomic_ui")

love.graphics.setColor(1, 1, 1)

local n = 0

local t = AtomicUI.Text:create {
  "Clicks 0",
  padding = 10,
  fontSize = 32,
  x = 20,
  y = 20,
}

local btn = AtomicUI.FilledButton:create {
  t,
  onClick = function()
    n = n + 1
    t.text = "Clicks " .. n
  end,
  onLongClick = function()
    n = n * 2
    t.text = "Clicks " .. n
  end,
  whileClicked = function()
    t.text = "Clicks " .. n .. " (current clicked)"
  end,
}

local root = btn

function love.load()
end

function love.draw()
  root:Draw()
end

function love.update(dt)
  root:Update(dt)
end
