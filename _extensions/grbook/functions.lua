-- Quarto filter to convert specified div classes to Typst format
-- Usage: Save as typst-div-filter.lua and add to your _quarto.yml:
-- filters:
--   - typst-div-filter.lua
--
-- In your document YAML, specify which classes to convert:
-- typst-div-classes:
--   - note
--   - callout
--   - sidebar
--   - etc

-- Debug control - set to true to see debug messages
local debug = true

-- Debug: Print when filter loads
if debug then
  print("=== FILTER LOADING ===")
  print("typst-div-filter.lua is loading...")
end

-- Global variable to store the convertible classes
local convertible_classes = {"note", "unote", "example"}  -- Default fallback

-- helper that identifies arrays (borrowed from the example)
local function tisarray(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then return false end
  end
  return true
end

-- Meta filter to capture metadata early in the process (adapted from the example)
function Meta(meta)
  if debug then
    print("\n=== META FILTER DEBUG ===")
    print("Meta filter called, checking for typst-div-classes...")
    print("Meta function IS being called!")
  end
  
  -- Look for typst-div-classes in the meta (following the example pattern)
  local class_config = meta['typst-div-classes']
  
  if class_config ~= nil then
    if debug then print("✓ Found typst-div-classes in Meta!") end
    local classes = {}
    
    if debug then
      print("Class config type:", type(class_config))
      if class_config.t then
        print("Pandoc type:", class_config.t)
      end
    end
    
    if tisarray(class_config) then
      if debug then print("Processing as array with", #class_config, "items") end
      -- read an array of strings
      for i, v in ipairs(class_config) do
        local value = pandoc.utils.stringify(v)
        table.insert(classes, value)
        if debug then print("  Added class from array: " .. value) end
      end
    else
      if debug then print("Processing as single item or key-value pairs") end
      -- Handle single item or key-value pairs
      for k, v in pairs(class_config) do
        local value = pandoc.utils.stringify(v)
        table.insert(classes, value)
        if debug then print("  Added class: " .. value) end
      end
    end
    
    -- Update global variable
    if #classes > 0 then
      convertible_classes = classes
      if debug then print("✓ Updated global convertible_classes:", table.concat(convertible_classes, ", ")) end
    end
  else
    if debug then
      print("⚠ No typst-div-classes found in Meta")
      print("Available meta keys:")
      for key, value in pairs(meta) do
        local value_type = type(value)
        local value_info = value_type
        if value_type == "table" and value.t then
          value_info = value_info .. " (pandoc " .. value.t .. ")"
        end
        print("  '" .. key .. "' = " .. value_info)
      end
    end
  end
  
  if debug then print("=== END META FILTER DEBUG ===\n") end
  
  -- Return the meta unchanged
  return meta
end

function is_measurement(str)
   return string.match(str, "^[-+]?%d+%.?%d*em$") or
          string.match(str, "^[-+]?%d+%.?%d*cm$") or
          string.match(str, "^[-+]?%d+%.?%d*pt$")
 end

-- Function to get the list of classes to convert 
function get_convertible_classes()
  if debug then print("Using convertible_classes:", table.concat(convertible_classes, ", ")) end
  return convertible_classes
end

-- Check if any of the div's classes should be converted
function should_convert_div(div_classes, convertible_classes)
  for _, conv_class in ipairs(convertible_classes) do
    if div_classes:includes(conv_class) then
      if debug then print("✓ Found convertible class: " .. conv_class) end
      return conv_class
    end
  end
  return nil
end

function Div(div)
  print("Fuck you")
  if debug then
    -- Debug: Print basic div information
    print("\n=== Processing Div ===")
    print("Classes found:", table.concat(div.classes, ", "))
    print("Number of classes:", #div.classes)
  
    -- Debug: Print all attributes with more detail
    print("Attributes:")
    local attr_count = 0
    for key, value in pairs(div.attributes) do
      print("  '" .. key .. "' = '" .. value .. "' (type: " .. type(value) .. ")")
      attr_count = attr_count + 1
    end
    print("Number of attributes:", attr_count)
  
    -- Debug: Print the raw identifier and classes for troubleshooting
    print("Div identifier:", div.identifier or "none")
    print("Raw classes table:")
    for i, class in ipairs(div.classes) do
      print("  [" .. i .. "] = '" .. class .. "'")
    end
  end
  
  -- Get the list of classes that should be converted
  local convertible_classes = get_convertible_classes()
  
  -- Check if this div has any convertible class
  local matched_class = should_convert_div(div.classes, convertible_classes)
  
  if matched_class then
    if debug then print("✓ Found div with convertible class: " .. matched_class) end
    
    -- Check if we're outputting to typst format
    if quarto.doc.is_format("typst") then
      if debug then print("✓ Output format is typst, proceeding with conversion...") end
      
      -- Extract and format attributes with proper quoting
      local attrs = {}
      for key, value in pairs(div.attributes) do
      -- ####################### DIAGNOSTIC BLOCK ####################### --
      if debug then
        print(string.format("\n  [Attribute] Key: '%s', Value: '%s'", key, value))
      end
      -- ################################################################ --
      local formatted_value
      local lower_value = value:lower()

      local no_quote_keywords = { ["true"] = true, ["false"] = true, ["none"] = true }
      local length_pattern = '^[-+]?%d*%.?%d+(em|pt|in|cm|mm|%%|fr)$'
      print(value)
      if value:match('^%d+%.?%d*$') then
        if debug then print("    - Test Result: Matched as a number.") end
        formatted_value = value
      elseif is_measurement(value) then
        if debug then print("    - Test Result: Matched as a Typst length.") end
        formatted_value = value
      elseif no_quote_keywords[lower_value] then
        if debug then print("    - Test Result: Matched as a keyword.") end
        formatted_value = lower_value
      elseif value:match('^".*"$') then
        if debug then print("    - Test Result: Matched as pre-quoted.") end
        formatted_value = value
      else
        if debug then print("    - Test Result: No match found. Adding quotes.") end
        formatted_value = '"' .. value .. '"'
      end
      if debug then print(string.format("    - Final Formatted Value: %s", formatted_value)) end
      table.insert(attrs, key .. ": " .. formatted_value)
    end
      
      -- Build the opening and closing parts of the typst command
      local opening_cmd
      if #attrs > 0 then
        local attrs_str = table.concat(attrs, ", ")
        opening_cmd = "#" .. matched_class .. "(" .. attrs_str .. ")["
        if debug then print("Generated opening with attributes: " .. opening_cmd) end
      else
        opening_cmd = "#" .. matched_class .. "["
        if debug then print("Generated opening without attributes: " .. opening_cmd) end
      end
      
      local closing_cmd = "]"
      
      -- Create new content with typst wrapper
      local new_content = {}
      table.insert(new_content, pandoc.RawInline("typst", opening_cmd))
      
      -- Add all the original content (preserving structure)
      for i, element in ipairs(div.content) do
        table.insert(new_content, element)
      end
      
      table.insert(new_content, pandoc.RawInline("typst", closing_cmd))
      
      if debug then print("✓ Returning Div with preserved content structure") end
      -- Return a new div with the typst wrapper and original content
      return pandoc.Div(new_content)
    else
      if debug then 
        print("⚠ Output format is not typst, skipping conversion")
        if quarto.doc.format_metadata and quarto.doc.format_metadata.format then
          print("Current format:", quarto.doc.format_metadata.format)
        end
      end
    end
  else
    if debug then print("⚠ Div does not have any convertible class, skipping") end
  end
  
  -- Return nil to leave the div unchanged
  if debug then print("=== End Div Processing ===\n") end
  return nil
end
-- function Div(div)
--   -- Get the list of classes that should be converted
--   local convertible_classes = get_convertible_classes()
  
--   -- Check if this div has any convertible class
--   local matched_class = should_convert_div(div.classes, convertible_classes)
  
--   if matched_class then
--     -- Check if we're outputting to typst format
--     if quarto.doc.is_format("typst") then
      
--       -- Extract and format attributes with proper quoting
--       local attrs = {}
--       for key, value in pairs(div.attributes) do
--         local formatted_value
--         local lower_value = value:lower()

--         -- Set of keywords that should not be quoted in Typst
--         local no_quote_keywords = {
--           ["true"] = true,
--           ["false"] = true,
--           ["none"] = true
--         }

--         if value:match('^%d+%.?%d*$') then
--           formatted_value = value
--         elseif no_quote_keywords[lower_value] then
--           formatted_value = lower_value
--         elseif value:match('^".*"$') then
--           formatted_value = value
--         else
--           formatted_value = '"' .. value .. '"'
--         end
        
--         table.insert(attrs, key .. ": " .. formatted_value)
--       end
      
--       -- Build the opening part of the typst command
--       local opening_cmd
--       if #attrs > 0 then
--         local attrs_str = table.concat(attrs, ", ")
--         opening_cmd = "#" .. matched_class .. "(" .. attrs_str .. ")["
--       else
--         opening_cmd = "#" .. matched_class .. "["
--       end

--       -- NEW: Convert the div's inner content to a Typst string
--       -- This correctly processes any Markdown inside the div
--       local content_doc = pandoc.Pandoc(div.content)
--       local content_str = pandoc.write(content_doc, 'typst')

--       -- NEW: Assemble the final raw Typst block as a single string
--       local final_typst_block = opening_cmd .. content_str .. "]"

--       -- NEW: Return a single RawBlock instead of a Div.
--       -- This prevents Quarto from adding an extra wrapping #block[...].
--       return pandoc.RawBlock('typst', final_typst_block)
--     end
--   end
  
--   -- Return nil to leave the div unchanged for other formats
--   return nil
-- end
-- Return separate filter objects like the working example
return {
  { Meta = Meta },
  { Div = Div }
}
