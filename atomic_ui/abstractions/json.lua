---AtomicUI Pure-JSON Library
---
---Yes, you can use this outside of Love2D and AtomicUI.
---This also works with Lua 5.1+
local json = {}

setmetatable(json, {__call = function(self, data)
  if type(data) == "string" then
    -- Decode
    return self.decode(data)
  elseif type(data) == "table" then
    return self.encode(data)
  else
    error("Calling JSON only supports encoding tables and decoding strings")
  end
end})

---@param c string
local function isAscii(c)
  if c == " " then
    return true
  end

  local byte = string.byte(c)

  local a, b, c, d, e, f = string.byte("azAZ09", 1, 6)

  return (byte >= a and byte <= b) or (byte >= c and byte <= d) or (byte >= e and byte <= f)
end

---@param num integer
local function tohex(num)
  if num == 0 then
    return '0'
  end
  local hexstr = "0123456789ABCDEF"
  local result = ""
  while num > 0 do
    local n = num % 16
    result = string.sub(hexstr, n + 1, n + 1) .. result
    num = math.floor(num / 16)
  end
  return result
end

---@alias JSONSerializable number | string | boolean | (JSONSerializable[]) | {[string]: JSONSerializable}

---@alias JSONEncodingMap string[] | {[string]: JSONEncodingMap | boolean}

---@class JSONConfig
--- The indentation to use. Nil if you want it to be one line
---@field indentation? number
--- If defined, restricts what fields will be encoded out of the object.
--- If this is a string list, it will serialize just those fields.
--- If this is a table, it will encode just the fields of the table with the value being a JSONEncodingMap as well for restricting recursive objects.
--- This feature is rarely useful.
---@field encodeOnly? JSONEncodingMap

---@param t {[string]: any} | any[]
--- This function assumes it is either a valid JSON object or a valid list
function json.islist(t)
  for k, v in pairs(t) do
    if type(k) ~= "number" then
      return false
    end
  end

  return true
end

---@param str string
function json.encodestr(str)
  local s = '"'

  for i=1,#str do
    local c = str:sub(i, i)
    if c == "\\" then
      c = "\\\\"
    elseif c == "\n" then
      c = "\\n"
    elseif c == "\t" then
      c = "\\t"
    elseif c == "\"" then
      c = "\\\""
    elseif c == "\r" then
      c = "\\r"
    end

    s = s .. c
  end

  return s .. '"'
end

---@param data JSONSerializable
---@param options? JSONConfig
---@param indent? number
---@param indentInitially? boolean
---@return string
--- Encodes data to JSON.
--- Do note: This also allows the `__jsonEncode` metatable field.
function json.encode(data, options, indent, indentInitially)
  options = options or {}
  indent = indent or 0
  if indentInitially == nil then
    indentInitially = true
  end

  local indentation = ""
  for _=1, indent do
    indentation = indentation .. " "
  end

  local indentinit = indentInitially and indentation or ""

  if type(data) == "string" then
    return indentinit .. json.encodestr(data)
  end

  if type(data) == "table" then
    local meta = getmetatable(data)
    if meta and meta.__jsonEncode then
      return meta.__jsonEncode(data, options)
    end

    if json.islist(data) then
      local str = ""
      if options.indentation then
        -- Use indentation
        str = str .. "[\n"
        local l = #data
        for i, v in ipairs(data) do
          if i == l then
            str = str .. json.encode(v, options, indent + options.indentation) .. "\n" .. indentation .. "]"
          else
            str = str .. json.encode(v, options, indent + options.indentation) .. ",\n"
          end
        end
      else
        str = str .. "["
        local l = #data
        for i, v in ipairs(data) do
          if i == l then
            str = str .. json.encode(v, options) .. (options.indentation and indentation or "") .. "]"
          else
            str = str .. json.encode(v, options) .. ","
          end
        end
      end

      return indentinit .. str
    else
      local str = ""
      if options.indentation then
        -- Use indentation
        str = str .. "{\n"
        if options.encodeOnly and json.islist(options.encodeOnly) then
          for _, key in ipairs(options.encodeOnly) do
            str = str .. json.encodestr(key) .. ": " .. json.encode(data[key], options, indent + options.indentation, false) .. ",\n"
          end
        else
          for k, v in pairs(data) do
            if (not options.encodeOnly) or options.encodeOnly[k] then
              local eo = options.encodeOnly
              if options.encodeOnly and type(options.encodeOnly[k]) == "table" then
                ---@diagnostic disable-next-line: assign-type-mismatch
                options.encodeOnly = options.encodeOnly[k]
              end
              str = str .. json.encode(k, nil, indent + options.indentation) .. ": " .. json.encode(v, options, indent + options.indentation, false) .. ",\n"
              options.encodeOnly = eo
            end
          end
        end
        str = (str == "{\n") and "{}" or (str:sub(0, -3) .. "\n" .. indentation .. "}")
      else
        ---@cast data {[string]: JSONSerializable}
        str = str .. "{"
        if options.encodeOnly and json.islist(options.encodeOnly) then
          for _, key in ipairs(options.encodeOnly) do
            str = str .. json.encodestr(key) .. ":" .. json.encode(data[key]) .. ","
          end
        else
          for k, v in pairs(data) do
            if (not options.encodeOnly) or options.encodeOnly[k] then
              -- We could copy, but that would cause extra memory allocations
              -- Here, we try to make the GC not die

              local eo = options.encodeOnly
              if options.encodeOnly and type(options.encodeOnly[k]) == "table" then
                ---@diagnostic disable-next-line: assign-type-mismatch
                options.encodeOnly = options.encodeOnly[k]
              end
              str = str .. json.encodestr(k) .. ":" .. json.encode(v, options) .. ","
              options.encodeOnly = eo
            end
          end
        end
        str = (str == "{") and "{}" or (str:sub(0, -2) .. "}") -- Remove trailing , and replace it with }
      end
      return indentinit .. str
    end
  end

  if data == nil then
    return indentinit .. "nil"
  end

  return indentinit .. tostring(data)
end

---@param str string
function json.decodestr(str)
  local i = 2
  local s = ""
  while i < #str do
    local c = str:sub(i, i)
    i = i + 1
  end
  return s
end

---@param c string
local function isNum(c)
  local n = c:byte(1, 1)

  local a, b = string.byte("09", 1, 2)

  return n >= a and n <= b
end

---@param c string
local function toNum(c)
  return c:byte(1, 1) - string.byte("0", 1)
end

---@param str string
---@param transformers? (fun(val: JSONSerializable): JSONSerializable?)[]
---@return JSONSerializable
--- NOTE: This function expects valid JSON.
--- If invalid JSON is passed in, it may crash, or it may give you random garbage
--- To check if the JSON is valid, use validate.
function json.decode(str, transformers)
  local i = 1

  local function nextToken()
    local c = str:sub(i, i)
    while c == " " or c == "\t" or c == "\n" do
      i = i + 1
      c = str:sub(i, i)
      if c == nil then return end
    end
    if c == "{" then
      i = i + 1
      return c
    elseif c == "}" then
      i = i + 1
      return c
    elseif c == "[" then
      i = i + 1
      return c
    elseif c == "]" then
      i = i + 1
      return c
    elseif c == ":" then
      i = i + 1
      return c
    elseif c == "," then
      i = i + 1
      return c
    elseif c:byte(1,1) >= string.byte('0', 1, 1) and c:byte(1, 1) <= string.byte('9', 1, 1) then
      local n = 0
      while isNum(c) do
        n = n * 10
        n = n + c:byte(1, 1) - string.byte('0', 1, 1)
        i = i + 1
        c = str:sub(i, i)
      end
    end
  end
end

---@alias JSONError {column: number, line: number, charIndex: number, error: string}

---@return boolean, JSONError?
function json.validate(str)
  error("Not implemented")
end

if AtomicUI then
  AtomicUI.json = json
end

return json
