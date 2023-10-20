-- This is just for an example
-- If you want to run the example, clone the repo and run this with Love2D
-- If you just want to use the library, just copy the atomic_ui folder.

require("atomic_ui")

love.graphics.setColor(1, 1, 1)

local n = 0


---@type AtomicUI.Widget
local root

---@return AtomicUI.Widget
function BuildDemo()
  local t = AtomicUI.Text:create {
    "Clicks " .. n,
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

  return AtomicUI.ListView {
    AtomicUI.Text "Demo",
    AtomicUI.Text ("AtomicUI v"  .. tostring(AtomicUI.version)),
    btn,
    AtomicUI.Box {
      AtomicUI.Row {
        AtomicUI.Center {
          AtomicUI.Text {
            "TextBox: ",
            height = 30,
          },
        },
        textbox, 2
      },
      filled = false,
      height = 60,
    },
    AtomicUI.Box {
      AtomicUI.Row {
        AtomicUI.Text "Dark Mode: ", 4,
        AtomicUI.Switch {
          toggled = AtomicUI.CurrentTheme == AtomicUI.Themes.Nordic,
          onToggle = function(enabled)
            AtomicUI.CurrentTheme = enabled and AtomicUI.Themes.Nordic or AtomicUI.Themes.Crystal
            root = BuildDemo()
          end,
        }
      },
      filled = false,
      height = 50,
    },
    AtomicUI.Box {
      AtomicUI.Row {
        AtomicUI.Center {
          AtomicUI.Text {
            "Slider: ",
            height = 40,
          },
        },
        AtomicUI.Slider {},
      },
      filled = false,
      height = 50,
    },
    width = 400,
    height = 600,
    x = 50,
    y = 50,
    filled = true,
    rx = 7,
    ry = 10,
  }
end

root = BuildDemo()

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

function love.mousepressed(x, y, btn, istouch, presses)
  root:MousePressed(btn, istouch, presses)
end
