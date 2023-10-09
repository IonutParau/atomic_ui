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
    elseif not isAscii(c) then
      local h = tohex(string.byte(c))
      if #h == 1 then h = "0" .. h end
      c = "\\x" .. h
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
        str = (str == "{") and "{}" or (str:sub(0, -3) .. "}") -- Remove trailing , and replace it with }
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
---@param transformers? (fun(val: JSONSerializable): JSONSerializable?)[]
---@return JSONSerializable
--- NOTE: This function expects valid JSON.
--- If invalid JSON is passed in, it may crash, or it may give you random garbage
--- To check if the JSON is valid, use validate.
function json.decode(str, transformers)
  local i = 1

  ---@type (number | string)?
  local field

  ---@type JSONSerializable[]
  local vals = {}
  local function decodestr()
    local s = ''
    while true do
      i = i + 1
      local c = str:sub(i, i)
      if c == '"' then break end
      if c == '\\' then
        -- Handle escape sequences
        i = i + 1
        local escape = str:sub(i, i)
        if escape == "n" then
          s = s .. '\n'
        elseif escape == "t" then
          s = s .. '\t'
        elseif escape == "r" then
          s = s .. '\r'
        elseif escape == "b" then
          s = s .. '\b'
        elseif escape == "f" then
          s = s .. '\f'
        else
          s = s .. escape
        end
      else
        s = s .. c
      end
    end
    i = i + 1

    return s
  end

  local function skipWhitespace()
    local c = str:sub(i, i)
    while c == ' ' or c == '\t' or c == '\n' do
      i = i + 1
      c = str:sub(i, i)
    end
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
  
  local decodeExpr

  ---@return JSONSerializable
  decodeExpr = function()
    skipWhitespace()
    if str:sub(i, i) == '"' then
      return decodestr()
    elseif str:sub(i, i) == "{" then
      i = i + 1
      local t = {}

      while str:sub(i, i) ~= "}" do
        skipWhitespace()
        local key = decodestr()
        print(key)
        skipWhitespace()
        local val = decodeExpr()
        skipWhitespace()
        if str:sub(i, i) == "," then
          i = i + 1
        end
        skipWhitespace()

        t[key] = val
      end
      i = i + 1

      return t
    elseif str:sub(i, i) == "[" then
      i = i + 1
      local l = {}

      while str:sub(i, i) ~= "]" do
        skipWhitespace()
        local val = decodeExpr()
        skipWhitespace()
        if str:sub(i, i) == "," then
          i = i + 1
        end
        skipWhitespace()

        table.insert(l, val)
      end
      i = i + 1

      return l
    elseif str:sub(i, i) == "t" then
      -- true
      i = i + 4
      return true
    elseif str:sub(i, i) == "f" then
      -- false
      i = i + 5
      return false
    elseif str:sub(i, i) == "n" then
      -- null
      i = i + 4
      ---@diagnostic disable-next-line: return-type-mismatch
      return nil
    elseif isNum(str:sub(i, i)) then
      local n = 0
      local frac = false
      local fracMult = 1
      while isNum(str:sub(i, i)) do
        if not frac then n = n * 10 end
        n = n + toNum(str:sub(i, i)) * fracMult
        if frac then fracMult = fracMult / 10 end
        i = i + 1
        if str:sub(i, i) == "." then
          frac = true
          fracMult = 0.1
          i = i + 1
        elseif str:sub(i, i) == "e" then
          local power = 0
          i = i + 1
          
          while isNum(str:sub(i, i)) do
            power = power * 10
            power = power + toNum(str:sub(i, i))
            i = i + 1
          end

          return n * 10 ^ power
        end
      end
      return n
    end
  end

  return decodeExpr()
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
