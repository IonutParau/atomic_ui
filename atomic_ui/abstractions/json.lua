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
---@return string
--- Encodes data to JSON.
--- Do note: This also allows the `__jsonEncode` metatable field.
function json.encode(data, options, indent)
  options = options or {}
  indent = indent or 0

  local indentation = ""
  for _=1, indent do
    indentation = indentation .. " "
  end

  if type(data) == "string" then
    return indentation .. json.encodestr(data)
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

      return indentation .. str
    else
      local str = ""
      if options.indentation then
        -- Use indentation
        str = str .. "{\n"
        if options.encodeOnly and json.islist(options.encodeOnly) then
          for _, key in ipairs(options.encodeOnly) do
            str = str .. json.encodestr(key) .. ":" .. json.encode(data[key], options, indent + options.indentation) .. ",\n"
          end
        else
          for k, v in pairs(data) do
            if (not options.encodeOnly) or options.encodeOnly[k] then
              local eo = options.encodeOnly
              if options.encodeOnly and type(options.encodeOnly[k]) == "table" then
                ---@diagnostic disable-next-line: assign-type-mismatch
                options.encodeOnly = options.encodeOnly[k]
              end
              str = str .. json.encode(k, nil, indent + options.indentation) .. ": " .. json.encode(v, options, indent + options.indentation) .. ",\n"
              options.encodeOnly = eo
            end
          end
        end
        str = (str == "{\n") and "{}" or (str:sub(0, -2) .. "\n" .. indentation .. "}")
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
      return indentation .. str
    end
  end

  if data == nil then
    return indentation .. "nil"
  end

  return indentation .. tostring(data)
end

---@param str string
---@param transformers (fun(val: JSONSerializable): JSONSerializable?)[]
---@return JSONSerializable
--- NOTE: This function expects valid JSON.
--- If invalid JSON is passed in, it may crash, or it may give you random garbage
function json.decode(str, transformers)
  local i = 0
  ---@type JSONSerializable
  local v
  repeat
    i = i + 1

    local function decodestr()
      local s = ''
      i = i + 1
    end
  until i == #str
  return v
end

if AtomicUI then
  AtomicUI.json = json
end

return json
