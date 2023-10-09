-- This is just for an example
-- If you want to run the example, clone the repo and run this with Love2D
-- If you just want to use the library, just copy the atomic_ui folder.

local json = require("atomic_ui.abstractions.json")

local s = json.encode({
  test = "hello",
  test2 = 53.3,
  test3 = {
    "this",
    "is",
    "a",
    "list"
  },
  recursive = {
    shit = 50,
    omgnoway = "omg no way",
  },
})

print(s)

local d = json.decode(s)

print(json.encode(d, {indentation = 2}))
