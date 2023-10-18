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
}

local textbox = AtomicUI.TextBox {
  x = 20,
  y = 20,
  width = 200,
  height = 100,
}

---@type AtomicUI.Widget
local root = AtomicUI.ListView {
  btn,
  textbox,
  width = 300,
  height = 600,
  x = 50,
  y = 50,
}

love.keyboard.setKeyRepeat(true)

function love.load()
end

function love.draw()
  love.graphics.clear()
  root:Draw()
end

function love.update(dt)
  root:Update(dt)
end

function love.textinput(t)
  root:TextInput(t)
end

function love.keypressed(key, scancode, isrepeat)
  root:KeyPress(key, scancode, isrepeat)
end

function love.wheelmoved(x, y)
  root:Scroll(love.mouse.getX(), love.mouse.getY(), x, y)
end
