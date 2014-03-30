-- Vasara 1.0 ALPHA (HUD script)
-- by Hopper and Ares Ex Machina

-- testing stuff here
-- change these in Lua script too, else bad stuff will happen

vert_range = 30   -- max: 30
horiz_range = 70  -- max: 160

vert_size = 325   -- max: 430
horiz_size = 600  -- max: 640

vert_offset = 65
horiz_offset = 20


-- PREFERENCES

-- Displayed names for texture collections
collection_names = {
[0] = "Landscapes",
[17] = "Water",
[18] = "Lava",
[19] = "Sewage",
[20] = "Jjaro",
[21] = "Pfhor"
}


-- END PREFERENCES -- no user serviceable parts below ;)

Triggers = {}

g_scriptChecked = false
g_initMode = 0

function Triggers.draw()
  if Player.life ~= 409 then
    if not g_scriptChecked then
      g_scriptChecked = true
      error "Vasara HUD requires Vasara Script"
    end
    return
  end
  
  if g_initMode < 2 then
    if g_initMode == 1 then
      HCollections.update()
      HMenu.draw_menu("choose_" .. HCollections.current_collection)
    end
    Screen.fill_rect(0, 0, Screen.width, Screen.height, { 0, 0, 0, 1 })
    local txt = "Loading textures..."
    local fw, fh = HGlobals.fontn:measure_text(txt)
    HGlobals.fontn:draw_text(txt,
      Screen.width/2 - fw/2, Screen.height/2 - fh/2,
      { 1, 1, 1, 1 })
    g_initMode = g_initMode + 1
    return
  end
  
  HMode.update()
  HKeys.update()
  HApply.update()
  HStatus.update()
  HCollections.update()
  HCounts.update()
  HLights.update()
  HPlatforms.update()
  HTeleport.update()
  
  if HMode.changed then layout() end

  -- keys
  local x = HGlobals.xoff
  local xspots = { x + 106*HGlobals.scale, x + 320*HGlobals.scale, x + 533*HGlobals.scale }
  local y = HGlobals.yoff + 48*HGlobals.scale
  local yspots = { y - 4*HGlobals.fheight, y - 3*HGlobals.fheight, y - 2*HGlobals.fheight, y - HGlobals.fheight }
  
  local lfont = HGlobals.fontn
  local lback = HGlobals.fwidth

  local labels = HMode.labels[HMode.current]
    
  for _, info in pairs(labels) do
    local lcolor = { 0, 1, 0, 1}
    local acolor = { 1, 1, 1, 1}
    local down
    if info[4] then
      if not HKeys.down(HKeys.mic) then
        lcolor = { 0.0, 0.5, 0.0, 1 }
        acolor = { 0.5, 0.5, 0.5, 1 }
      else
        down = HKeys.down(info[1])
      end
    elseif (info[1] ~= HKeys.mic) and HKeys.down(HKeys.mic) then
      down = false
      lcolor = { 0.0, 0.5, 0.0, 1 }
      acolor = { 0.5, 0.5, 0.5, 1 }
    else
      down = HKeys.down(info[1])
    end
    if down then
      lcolor = { 1, 0, 0, 1}
      acolor = { 1, 1, 0, 1}
    end
    
    local ltxt
    if info[4] then
      ltxt = "Mic + " .. HKeys.shortnames[info[1]] .. ":"
    else
      ltxt = HKeys.names[info[1]] .. ":"
    end
    local atxt = info[5]
    
    lfont:draw_text(ltxt, xspots[info[2]] - lback - lfont:measure_text(ltxt), yspots[info[3]], lcolor)
    lfont:draw_text(atxt, xspots[info[2]], yspots[info[3]], acolor)
  end
  
  -- teleport notices
  if HMode.is(HMode.teleport) then
--     local txt = "Current polygon:"
--     local ifont = HGlobals.fonti
--     ifont:draw_text(txt, xspots[2] - lback - ifont:measure_text(txt), yspots[2], { 0.6, 0.6, 0.6, 1})
--     ifont:draw_text(HTeleport.poly, xspots[2], yspots[2], { 0.6, 0.6, 0.6, 1})

    local yp = HGlobals.cpos[2]
    local xp = HGlobals.cpos[1]
    
    local fw, fh = HGlobals.fontn:measure_text(HTeleport.poly)
    local xf = xp - fw/2
    local yf = yp - fh - 15*HGlobals.scale
    Screen.fill_rect(xf - 5*HGlobals.scale, yf, fw + 10*HGlobals.scale, fh, { 0, 0, 0, 0.6 })
    HGlobals.fontn:draw_text(HTeleport.poly, xf, yf, { 0, 1, 0, 1 })
    
    if not Screen.map_overlay_active then
      HGlobals.fonti:draw_text("Please turn on Overlay Map mode in Graphics preferences",
        Screen.world_rect.x + 10*HGlobals.scale,
        Screen.world_rect.y + Screen.world_rect.height - 2*HGlobals.fheight,
        { 0, 1, 0, 1 })
    end
  end
  
  local cxoff = 0
  local cyoff = 0
  
  -- menus
  if HMode.is(HMode.attribute) or HMode.is(HMode.recharger) or HMode.is(HMode.switch) or HMode.is(HMode.terminal) or HMode.is(HMode.choose) then
    local m = HMode.current
    if HMode.is(HMode.choose) then
      m = "choose_" .. HCollections.current_collection
    end
    if HMenu.menus[m] then
      HMenu.draw_menu(m)
      cxoff, cyoff = HMenu.cursorpos()
    end
  end
  
  -- lower area
  if HMode.is(HMode.attribute) then
    local xp = HGlobals.xoff + 460*HGlobals.scale
    local yp = HGlobals.yoff + 225*HGlobals.scale
    local yf = yp + 88*HGlobals.scale
    
    local coll = HCollections.current_coll()
    local tex = Player.texture_palette.slots[coll].texture_index
    local bct = Collections[coll].bitmap_count
--     local nm = HCollections.names[coll + 1]
--     if bct > 1 then
--       nm = nm .. " #" .. tex
--     end
    
    if HApply.down(HApply.use_texture) then
      HCollections.draw(coll, tex, xp, yp, 120*HGlobals.scale)
      if HApply.current_transfer ~= 5 and HApply.current_transfer ~= 4 then
        local val = HLights.adj(HApply.current_light)
        Screen.fill_rect(xp, yp, 120*HGlobals.scale, 120*HGlobals.scale, { 0, 0, 0, 1 - val })
      end
    elseif HApply.down(HApply.use_light) then 
      local val = HLights.val(HApply.current_light)
      Screen.fill_rect(xp, yp, 160*HGlobals.scale, 160*HGlobals.scale, { val, val, val, 1 })
    end

  end
  if HMode.is(HMode.apply) then
    local xp = HGlobals.xoff + 20*HGlobals.scale
    local yp = HGlobals.yoff + 380*HGlobals.scale
    local yf = yp + 88*HGlobals.scale
    
    local coll = HCollections.current_coll()
    local tex = Player.texture_palette.slots[coll].texture_index
    local bct = Collections[coll].bitmap_count
--     local nm = HCollections.names[coll + 1]
--     if bct > 1 then
--       nm = nm .. " #" .. tex
--     end
    
    -- lower left: current texture
    if HApply.down(HApply.use_texture) then
      HCollections.draw(coll, tex, xp, yp, 85*HGlobals.scale)
      if HApply.current_transfer ~= 5 and HApply.current_transfer ~= 4 then
        local val = HLights.adj(HApply.current_light)
        Screen.fill_rect(xp, yp, 85*HGlobals.scale, 85*HGlobals.scale, { 0, 0, 0, 1 - val })
      end
    elseif HApply.down(HApply.use_light) then 
      local val = HLights.val(HApply.current_light)
      Screen.fill_rect(xp, yp, 85*HGlobals.scale, 85*HGlobals.scale, { val, val, val, 1 })
    end
    
    -- lower middle: attributes
    local xm = xp + 110*HGlobals.scale
    local ym = yp
    local yplus = HGlobals.fheight + 4*HGlobals.scale
    local att
    
    att = "Apply Light: " .. HApply.current_light
    draw_mode(att, xm, ym, (HApply.down(HApply.use_light) and HApply.current_transfer ~= 5))
    ym = ym + yplus

    att = "Apply Texture"
    local tmode = HApply.transfer_modes[HApply.current_transfer + 1]
    if HCollections.current_collection == 0 then
      if HApply.current_transfer == 5 then tmode = nil end
    else
      if HApply.current_transfer == 0 then tmode = nil end
    end
    if tmode ~= nil then
      att = att .. ": " .. tmode
    end
    draw_mode(att, xm, ym, HApply.down(HApply.use_texture))
    ym = ym + yplus
    
    draw_mode("Align adjacent", xm, ym, HApply.down(HApply.align))
    ym = ym + yplus
    
    draw_mode("Edit switches and panels", xm, ym, HApply.down(HApply.edit_panels))
    ym = ym + yplus
    
    draw_mode("Edit transparent sides", xm, ym, HApply.down(HApply.transparent))
    ym = ym + yplus
    
    att = "Snap to grid: " .. HApply.snap_modes[HApply.current_snap + 1]
    draw_mode(att, xm, ym, HApply.current_snap ~= 0)
    ym = ym + yplus
    
    -- lower right: full collection
    HMenu.draw_menu("preview_" .. HCollections.current_collection, true)
  end
  
  -- cursor
  draw_cursor(HMode.apply, "apply")
  draw_cursor(HMode.teleport, "teleport")
  draw_cursor(HMode.choose, "menu", cxoff, cyoff)
  draw_cursor(HMode.attribute, "menu", cxoff, cyoff)
  draw_cursor(HMode.switch, "menu", cxoff, cyoff)
  draw_cursor(HMode.recharger, "menu", cxoff, cyoff)
  draw_cursor(HMode.terminal, "menu", cxoff, cyoff)  
  
end

function draw_mode(label, x, y, active)
  local clr = { 0.5, 0.5, 0.5, 1 }
  local img = imgs["fcheck_off"]
  if active then
    clr = { 1, 1, 1, 1 }
    img = imgs["fcheck_on"]
  end
  img:draw(x - 2*HGlobals.scale, y)
  HGlobals.fontn:draw_text(label, x + 13*HGlobals.scale, y, clr)
end

function draw_cursor(mode, name, xoff, yoff, abs)
  if not HMode.is(mode) then return end
  if xoff == nil then xoff = 0 end
  if yoff == nil then yoff = 0 end
  local n = "cursor_" .. name
  if HKeys.down(HKeys.primary) and (not HKeys.down(HKeys.mic)) then n = n .. "_down" end
  if not abs then
    xoff = xoff + HGlobals.cpos[1]
    yoff = yoff + HGlobals.cpos[2]
  end
  imgs[n]:draw(xoff - HGlobals.coff[1], yoff - HGlobals.coff[2])
end

imgs = {}
function Triggers.init()
  Screen.crosshairs.lua_hud = true
  g_initMode = 0
  
  for _, nm in pairs({ "cursor_menu", "cursor_menu_down",
                       "cursor_apply", "cursor_apply_down",
                       "cursor_teleport", "cursor_teleport_down",
                       "bcheck_on", "bcheck_off", "bcheck_dis",
                       "bradio_on", "bradio_off", "bradio_dis",
                       "dradio_on", "dradio_off", "dradio_dis",
                       "fcheck_on", "fcheck_off" }) do
    imgs[nm] = Images.new{path = "resources/" .. nm .. ".png"}
  end

  Triggers.resize()
end

HGlobals = {}
function Triggers.resize()
  HGlobals.scale = math.min(Screen.width / 640, Screen.height / 480)
  HGlobals.xoff = math.floor((Screen.width - (640 * HGlobals.scale)) / 2)
  HGlobals.yoff = math.floor((Screen.height - (480 * HGlobals.scale)) / 2)
  
  HGlobals.fontb = Fonts.new{file = "dejavu/DejaVuLGCSansCondensed-Bold.ttf", size = 12 * HGlobals.scale}
  HGlobals.fontn = Fonts.new{file = "dejavu/DejaVuLGCSansCondensed-Bold.ttf", size = 9 * HGlobals.scale}
  HGlobals.fonti = Fonts.new{file = "dejavu/DejaVuLGCSansCondensed-BoldOblique.ttf", size = 9 * HGlobals.scale}
  HGlobals.fontm = Fonts.new{file = "dejavu/DejaVuLGCSansCondensed-Bold.ttf", size = 7 * HGlobals.scale}
  
  HGlobals.fwidth, HGlobals.fheight = HGlobals.fontn:measure_text("  ")
  HGlobals.bwidth, HGlobals.bheight = HGlobals.fontb:measure_text("  ")
  
  for _, i in pairs(imgs) do
    rescale(i, HGlobals.scale / 3)
  end
  
  layout()
end

function rescale(img, scale)
  if not img then return end
  local w = math.max(1, img.unscaled_width * scale)
  local h = math.max(1, img.unscaled_height * scale)
  img:rescale(w, h)
end

function layout()
  local x = HGlobals.xoff
  local y = HGlobals.yoff
  local w = 640*HGlobals.scale
  local h = 480*HGlobals.scale
  
  Screen.clip_rect.x = x
  Screen.clip_rect.y = y
  Screen.clip_rect.width = w
  Screen.clip_rect.height = h
  
  y = y + 50*HGlobals.scale
  h = math.floor(w / 2)
  
  Screen.term_rect.x = x
  Screen.term_rect.y = y
  Screen.term_rect.width = w
  Screen.term_rect.height = h
  
  local halfh = math.floor(215*HGlobals.scale)
  Screen.map_rect.x = x
  Screen.map_rect.y = y + halfh
  Screen.map_rect.width = w
  Screen.map_rect.height = halfh
  
  Screen.world_rect.x = x
  Screen.world_rect.y = y
  Screen.world_rect.width = w
  Screen.world_rect.height = h
  
  if Screen.map_active then
    local halfw = halfh * 2
    Screen.world_rect.x = x + (w - halfw)/2
    Screen.world_rect.width = halfw
    Screen.world_rect.height = halfh
  end
--  Screen.map_rect.x = x
--  Screen.map_rect.y = y
--  local halfw = math.floor(w / 2)
--  Screen.map_rect.width = halfw
--  Screen.map_rect.height = h
--  
--  Screen.world_rect.x = x
--  Screen.world_rect.y = y
--  Screen.world_rect.width = w
--  Screen.world_rect.height = h
--  
--  if Screen.map_active then
--    local halfh = math.floor(h / 2)
--    Screen.world_rect.x = x + halfw
--    Screen.world_rect.width = w - halfw
--    Screen.world_rect.y = y + halfh/2
--    Screen.world_rect.height = halfh
--  end
  
  HGlobals.cpos = {
    Screen.world_rect.x + Screen.world_rect.width/2,
    Screen.world_rect.y + Screen.world_rect.height/2 }

  HGlobals.coff = { imgs["cursor_menu"].width/2,
                    imgs["cursor_menu"].height/2 }
  
end

function hasbit(field, which)
  local test = 2 ^ (which - 1)
  return field % (test + test) >= test
end

function PIN(v, min, max)
  if v < min then return min end
  if v > max then return max end
  return v
end

HKeys = {}
HKeys.bitfield = 0
HKeys.primary = 1
HKeys.secondary = 2
HKeys.mic = 3
HKeys.prev_weapon = 4
HKeys.next_weapon = 5
HKeys.action = 6
HKeys.map = 7
HKeys.names = {"Trigger", "2nd Trigger", "Microphone", "Previous Weapon", "Next Weapon", "Action", "Auto Map"}
HKeys.shortnames = {"Trigger", "2nd", "Mic", "Previous", "Next", "Action", "Map"}
function HKeys.update()
  HKeys.bitfield = Player.texture_palette.slots[39].texture_index
end
function HKeys.down(k)
  return hasbit(HKeys.bitfield, k)
end

HApply = {}
HApply.bitfield = 0
HApply.use_texture = 1
HApply.use_light = 2
HApply.align = 3
HApply.transparent = 4
HApply.edit_panels = 5
HApply.current_light = 0
HApply.current_transfer = 0
HApply.current_snap = 0
HApply.transfer_modes = { "Normal", "Pulsate", "Wobble", "Fast wobble", "Static", "Landscape", "Horizontal slide", "Fast horizontal slide", "Vertical slide", "Fast vertical slide", "Wander", "Fast wander" }
HApply.snap_modes = { "Off", "1/4 WU", "1/5 WU", "1/8 WU" }
function HApply.update()
  HApply.bitfield = Player.texture_palette.slots[46].texture_index
  HApply.current_light = Player.texture_palette.slots[43].texture_index
  HApply.current_transfer = Player.texture_palette.slots[44].texture_index
  HApply.current_snap = Player.texture_palette.slots[45].texture_index

  local lbls = HMode.labels[HMode.apply]
--   if HCounts.num_lights > 0 then
--     lbls[7][5] = "Previous Light (" .. tostring((HApply.current_light - 1) % HCounts.num_lights) .. ")"
--     lbls[8][5] = "Next Light (" .. tostring((HApply.current_light + 1) % HCounts.num_lights) .. ")"
--   end
  
  if HApply.down(HApply.use_texture) then
    if HApply.down(HApply.use_light) then
      lbls[3][5] = "Apply Light + Texture"
    else
      lbls[3][5] = "Apply Texture"
    end
  elseif HApply.down(HApply.use_light) then
    lbls[3][5] = "Apply Light"
  else
    lbls[3][5] = "Move Texture"
  end

end
function HApply.down(k)
  return hasbit(HApply.bitfield, k)
end

HStatus = {}
HStatus.bitfield = 0
HStatus.frozen = 1
HStatus.undo_active = 2
HStatus.redo_active = 3
HStatus.action_active = 4
HStatus.saved_direction = 0
HStatus.current_menu_item = 0
function HStatus.update()
  HStatus.bitfield = Player.texture_palette.slots[41].texture_index
  HStatus.saved_direction = 2 * Player.texture_palette.slots[42].texture_index
  HStatus.current_menu_item = Player.texture_palette.slots[47].texture_index
  
  local lbls = HMode.labels[HMode.apply]
  local lbls2 = HMode.labels[HMode.teleport]
  
  if HStatus.down(HStatus.frozen) then
    lbls[6][5] = "Unfreeze"
  else
    lbls[6][5] = "Freeze"
  end
  
  if HStatus.down(HStatus.undo_active) then
    lbls[1][5] = "Undo"
    lbls[9][5] = "Undo"
  else
    lbls[1][5] = "(Can't Undo)"
    lbls[9][5] = "(Can't Undo)"
  end
  if HStatus.down(HStatus.redo_active) then
    lbls[2][5] = "Redo"
    lbls[9][5] = "Redo"
  else
    lbls[2][5] = "(Can't Redo)"
  end
  if HStatus.down(HStatus.action_active) then
    lbls[10][5] = "Activate"
    lbls2[7][5] = "Activate"
  else
    lbls[10][5] = "Choose Texture"
    lbls2[7][5] = "Choose Texture"
  end
  
  
end
function HStatus.down(k)
  return hasbit(HStatus.bitfield, k)
end

HMode = {}
HMode.current = 0
HMode.apply = 0
HMode.choose = 1
HMode.attribute = 2
HMode.teleport = 3
HMode.switch = 4
HMode.recharger = 5
HMode.terminal = 6
HMode.changed = false

HMode.labels = {}
HMode.labels[HMode.apply] = {
    { HKeys.primary,     1, 1, true,  "Undo" },
    { HKeys.secondary,   1, 2, true,  "Redo" },
    { HKeys.primary,     1, 3, false, "Apply Texture" },
    { HKeys.secondary,   1, 4, false, "Sample Light + Texture" },
    { HKeys.prev_weapon, 2, 1, true,  "Jump" },
    { HKeys.next_weapon, 2, 2, true,  "Freeze" },
    { HKeys.prev_weapon, 2, 3, false, "Previous Light" },
    { HKeys.next_weapon, 2, 4, false, "Next Light" },
    { HKeys.action,      3, 1, true,  "Undo" },
    { HKeys.action,      3, 2, false, "Choose Texture / Action" },
    { HKeys.mic,         3, 3, false, "Options" },
    { HKeys.map,         3, 4, false, "Teleport" } }
HMode.labels[HMode.choose] = {
    { HKeys.primary,     1, 1, true,  "Cycle Textures" },
    { HKeys.secondary,   1, 2, true,  "Cycle Collections" },
    { HKeys.primary,     1, 3, false, "Select Texture" },
    { HKeys.secondary,   1, 4, false, "Return" },
    { HKeys.prev_weapon, 2, 1, true,  "Previous Texture" },
    { HKeys.next_weapon, 2, 2, true,  "Next Texture" },
    { HKeys.prev_weapon, 2, 3, false, "Previous Collection" },
    { HKeys.next_weapon, 2, 4, false, "Next Collection" },
    { HKeys.action,      3, 2, false, "Return" },
    { HKeys.mic,         3, 3, false, "Options" },
    { HKeys.map,         3, 4, false, "Teleport" } }
HMode.labels[HMode.attribute] = {
    { HKeys.primary,     1, 3, false, "Select Option" },
    { HKeys.secondary,   1, 4, false, "Return" },
    { HKeys.prev_weapon, 2, 3, false, "Previous Option" },
    { HKeys.next_weapon, 2, 4, false, "Next Option" },
    { HKeys.action,      3, 2, false, "Choose Texture" },
    { HKeys.mic,         3, 3, false, "Return" },
    { HKeys.map,         3, 4, false, "Teleport" } }
HMode.labels[HMode.teleport] = {
    { HKeys.primary,     1, 1, true,  "Rewind Polygon" },
    { HKeys.secondary,   1, 2, true,  "Fast Forward Polygon" },
    { HKeys.primary,     1, 3, false, "Teleport" },
    { HKeys.secondary,   1, 4, false, "Return" },
    { HKeys.prev_weapon, 2, 3, false, "Previous Polygon" },
    { HKeys.next_weapon, 2, 4, false, "Next Polygon" },
    { HKeys.action,      3, 2, false, "Choose Texture / Action" },
    { HKeys.mic,         3, 3, false, "Options" },
    { HKeys.map,         3, 4, false, "Return" } }
HMode.labels[HMode.switch]    = HMode.labels[HMode.attribute]
HMode.labels[HMode.recharger] = HMode.labels[HMode.attribute]
HMode.labels[HMode.terminal]  = HMode.labels[HMode.attribute]

function HMode.update()
  local newstate = Player.texture_palette.slots[40].texture_index
  if newstate ~= HMode.current then
    HMode.current = newstate
    HMode.changed = true
  else
    HMode.changed = false
  end
end
function HMode.is(k)
  return k == HMode.current
end

HMenu = {}
HMenu.menus = {}
HMenu.menus[HMode.attribute] = {
  { "label", nil, 20, 65, 155, 18, "Attributes" },
  { "checkbox", "apply_light", 20, 85, 155, 18, "Apply light" },
  { "checkbox", "apply_tex", 20, 105, 155, 18, "Apply texture" },
  { "checkbox", "apply_align", 20, 125, 155, 18, "Align adjacent" },
  { "checkbox", "apply_edit", 20, 145, 155, 18, "Edit switches and panels" },
  { "checkbox", "apply_xparent", 20, 165, 155, 18, "Edit transparent sides" },
  { "label", "nil", 20, 205, 155, 18, "Snap to grid" },
  { "radio", "snap_0", 20, 225, 155, 18, "Off" },
  { "radio", "snap_1", 20, 245, 155, 18, "1/4 WU" },
  { "radio", "snap_2", 20, 265, 155, 18, "1/5 WU" },
  { "radio", "snap_3", 20, 285, 155, 18, "1/8 WU" },
  { "label", nil, 200, 65, 150, 18, "Light" },
  { "label", nil, 200, 205, 235, 18, "Texture mode" },
  { "radio", "transfer_0", 200, 225, 116, 18, "Normal" },
  { "radio", "transfer_1", 200, 245, 116, 18, "Pulsate" },
  { "radio", "transfer_2", 200, 265, 116, 18, "Wobble" },
  { "radio", "transfer_6", 200, 285, 116, 18, "Horizontal slide" },
  { "radio", "transfer_8", 200, 305, 116, 18, "Vertical slide" },
  { "radio", "transfer_10", 200, 325, 116, 18, "Wander" },
  { "radio", "transfer_5", 318, 225, 117, 18, "Landscape" },
  { "radio", "transfer_4", 318, 245, 117, 18, "Static" },
  { "radio", "transfer_3", 318, 265, 117, 18, "Fast wobble" },
  { "radio", "transfer_7", 318, 285, 117, 18, "Fast horizontal slide" },
  { "radio", "transfer_9", 318, 305, 117, 18, "Fast vertical slide" },
  { "radio", "transfer_11", 318, 325, 117, 18, "Fast wander" },
  { "label", nil, 460, 205, 160, 18, "Preview" } }
-- HMenu.menus[HMode.choose] = {
--   { "dbutton", "coll_17", 20, 380, 98, 18, "Water" },
--   { "dbutton", "coll_18", 120, 380, 98, 18, "Lava" },
--   { "dbutton", "coll_19", 220, 380, 98, 18, "Sewage" },
--   { "dbutton", "coll_20", 320, 380, 98, 18, "Jjaro" },
--   { "dbutton", "coll_21", 420, 380, 98, 18, "Pfhor" },
--   { "dbutton", "coll_0", 520, 380, 98, 18, "Landscapes" } }
  
HMenu.inited = {}
HMenu.inited[HMode.attribute] = false
function HMenu.draw_menu(mode, transparent)
  if not HMenu.inited[mode] then HMenu.init_menu(mode) end
  local u = HGlobals.scale
  local m = HMenu.menus[mode]
  local xp = HGlobals.xoff
  local yp = HGlobals.yoff
  
  if not transparent then
    Screen.fill_rect(Screen.world_rect.x, Screen.world_rect.y,
                     Screen.world_rect.width, Screen.world_rect.height,
                     { 0, 0, 0, 1 })
  end
  
  for idx, item in ipairs(m) do
    local x = xp + item[3]*u
    local y = yp + item[4]*u
    local w = item[5]*u
    local h = item[6]*u
    
    if item[1] == "label" then
      HGlobals.fontn:draw_text(item[7],
                               math.floor(x + 5*u), math.floor(y + 5*u),
                               { 1, 1, 1, 1 })
    elseif item[1] == "texture" or item[1] == "dtexture" then
      local cc, ct = string.match(item[2], "(%d+)_(%d+)")
      local state = "enabled"
      if item[1] == "texture" then state = HMenu.button_state(item[2]) end
      if state == "active" then
        Screen.frame_rect(x - 2*u, y - 2*u, w + 4*u, h + 4*u, { 0, 1, 0, 1 }, 2*u)
      end
     HCollections.draw(cc + 0, ct + 0, x, y, w)      
    elseif HMenu.clickable(item[1]) then
      if HStatus.current_menu_item == idx then
        Screen.frame_rect(x - 2*u, y - 2*u, w + 4*u, h + 4*u, { 0, 1, 0, 1 }, 2*u)
      end
      local state = HMenu.button_state(item[2])
      if state == "enabled" then
        local lt, md, dk, tx = 0.9, 0.7, 0.6
        local tr, tg, tb = 0, 0, 0
        if item[1] == "dradio" or item[1] == "dbutton" then
          lt, md, dk = 0.1, 0.1, 0.1
          tr, tg, tb = 0.5, 0.5, 0.5
        end
        Screen.fill_rect(x, y, w, h, { md, md, md, 1 })
        Screen.fill_rect(x, y, w, 2*u, { lt, lt, lt, 1 })
        Screen.fill_rect(x, y + 2*u, 2*u, h - 2*u, { lt, lt, lt, 1 })
        Screen.fill_rect(x + 2*u, y + h - 2*u,
                         w - 2*u, 2*u,
                         { dk, dk, dk, 1 })
        Screen.fill_rect(x + w - 2*u, y + 2*u,
                         2*u, h - 2*u,
                         { dk, dk, dk, 1 })
        local xo = 7
        if item[1] == "checkbox" then
          xo = 17
          imgs["bcheck_off"]:draw(x + 4*u, y + h/2 - imgs["bcheck_off"].width/2)
        elseif item[1] == "radio" then
          xo = 17
          imgs["bradio_off"]:draw(x + 4*u, y + h/2 - imgs["bradio_off"].width/2)
        elseif item[1] == "dradio" then
          xo = 17
          imgs["dradio_dis"]:draw(x + 4*u, y + h/2 - imgs["dradio_dis"].width/2)
        elseif item[1] == "light" then
          local fw, fh = HGlobals.fontn:measure_text(item[7])
          xo = item[5] - 7 - fw/u
          local val = HLights.val(tonumber(string.sub(item[2], 7)))
          Screen.fill_rect(x + 2*u, y + 2*u, h - 4*u, h - 4*u, { val, val, val, 1 })
        elseif item[1] == "dbutton" then
          local fw, fh = HGlobals.fontn:measure_text(item[7])
          xo = (w/u - fw/u)/2         
        end
        HGlobals.fontn:draw_text(item[7],
                                 math.floor(x + xo*u), math.floor(y + h/2 - HGlobals.fheight/2),
                                 { tr, tg, tb, 1 })
      elseif state == "disabled" then
        local md = 0.7
        local tr, tg, tb = 0.5, 0.5, 0.5
        if item[1] == "dradio" or item[1] == "dbutton" then
          md = 0.0
        end
        Screen.fill_rect(x, y, w, h, { md, md, md, 1 })
        local xo = 7
        if item[1] == "checkbox" then
          xo = 17
          imgs["bcheck_dis"]:draw(x + 4*u, y + h/2 - imgs["bcheck_dis"].width/2)
        elseif item[1] == "radio" then
          xo = 17
          imgs["bradio_dis"]:draw(x + 4*u, y + h/2 - imgs["bradio_dis"].width/2)
        elseif item[1] == "dradio" then
          xo = 17
          imgs["dradio_dis"]:draw(x + 4*u, y + h/2 - imgs["dradio_dis"].width/2)
        elseif item[1] == "light" then
          local fw, fh = HGlobals.fontn:measure_text(item[7])
          xo = item[5] - 7 - fw/u
        elseif item[1] == "dbutton" then
          local fw, fh = HGlobals.fontn:measure_text(item[7])
          xo = (w/u - fw/u)/2         
        end
        HGlobals.fontn:draw_text(item[7],
                                 math.floor(x + xo*u), math.floor(y + h/2 - HGlobals.fheight/2),
                                 { tr, tg, tb, 1 })
      
      elseif state == "active" then
        local lt, md, dk = 0.9, 1.0, 0.6
        local tr, tg, tb = 0.0, 0.0, 0.3
        if item[1] == "dradio" or item[1] == "dbutton" then
          lt, md, dk = 0.15, 0.2, 0.25
          tr, tg, tb = 0.0, 1.0, 0.0
        end
        Screen.fill_rect(x, y, w, h, { md, md, md, 1 })
        Screen.fill_rect(x, y, w, 2*u, { lt, lt, lt, 1 })
        Screen.fill_rect(x, y + 2*u, 2*u, h - 2*u, { lt, lt, lt, 1 })
        Screen.fill_rect(x + 2*u, y + h - 2*u,
                         w - 2*u, 2*u,
                         { dk, dk, dk, 1 })
        Screen.fill_rect(x + w - 2*u, y + 2*u,
                         2*u, h - 2*u,
                         { dk, dk, dk, 1 })
        local xo = 7
        if item[1] == "checkbox" then
          xo = 17
          imgs["bcheck_on"]:draw(x + 4*u, y + h/2 - imgs["bcheck_on"].width/2)
        elseif item[1] == "radio" then
          xo = 17
          imgs["bradio_on"]:draw(x + 4*u, y + h/2 - imgs["bradio_on"].width/2)
        elseif item[1] == "dradio" then
          xo = 17
          imgs["dradio_on"]:draw(x + 4*u, y + h/2 - imgs["dradio_on"].width/2)
        elseif item[1] == "light" then
          local fw, fh = HGlobals.fontn:measure_text(item[7])
          xo = item[5] - 7 - fw/u
          local val = HLights.val(tonumber(string.sub(item[2], 7)))
          Screen.fill_rect(x + 2*u, y + 2*u, h - 4*u, h - 4*u, { val, val, val, 1 })
        elseif item[1] == "dbutton" then
          local fw, fh = HGlobals.fontn:measure_text(item[7])
          xo = (w/u - fw/u)/2         
        end
        HGlobals.fontn:draw_text(item[7],
                                 math.floor(x + xo*u), math.floor(y + h/2 - HGlobals.fheight/2),
                                 { tr, tg, tb, 1 })
      end
    end
  end
end
function HMenu.coord()
  local y = vert_offset + vert_size/(vert_range*2) * PIN(vert_range - Player.pitch, 0, vert_range*2)
  local x = horiz_offset + horiz_size/(horiz_range*2) * PIN(horiz_range + Player.direction - 180, 0, horiz_range*2)
  
  return x, y
end
function HMenu.cursorpos()
  local x, y = HMenu.coord()
  local xa = (x*HGlobals.scale) + HGlobals.xoff - HGlobals.cpos[1]
  local ya = (y*HGlobals.scale) + HGlobals.yoff - HGlobals.cpos[2]
  return xa, ya
end
function HMenu.button_state(name)
  local state = "enabled"
  
  if name == "apply_tex" then
    if HApply.down(HApply.use_texture) then state = "active" end
  elseif name == "apply_light" then
    if HApply.down(HApply.use_light) then state = "active" end
  elseif name == "apply_align" then
    if HApply.down(HApply.align) then state = "active" end
  elseif name == "apply_xparent" then
    if HApply.down(HApply.transparent) then state = "active" end
  elseif name == "apply_edit" then
    if HApply.down(HApply.edit_panels) then state = "active" end
  elseif string.sub(name, 1, 5) == "snap_" then
    local mode = tonumber(string.sub(name, 6))
    if HApply.current_snap == mode then state = "active" end
  elseif string.sub(name, 1, 9) == "transfer_" then
    local mode = tonumber(string.sub(name, 10))
    if HApply.current_transfer == mode then state = "active" end
    if HCollections.current_collection == 0 then state = "disabled" end
  elseif string.sub(name, 1, 6) == "light_" then
    local mode = tonumber(string.sub(name, 7))
    if HApply.current_light == mode then state = "active" end
  elseif string.sub(name, 1, 5) == "coll_" then
    local mode = tonumber(string.sub(name, 6))
    if HCollections.current_collection == mode then state = "active" end
  elseif string.sub(name, 1, 7) == "choose_" then
    local cc, ct = string.match(name, "(%d+)_(%d+)")
    cc = cc + 0
    ct = ct + 0
    if cc == HCollections.current_coll() and ct == Player.texture_palette.slots[cc].texture_index then
      state = "active"
    end
  end
  
  return state
end
function HMenu.init_menu(mode)
  local menu = HMenu.menus[mode]
  if mode == HMode.attribute then
    if HCounts.num_lights > 0 then
      for i = 1,math.min(HCounts.num_lights, 50) do
        local l = i - 1
--       local yoff = (l % 10) * 20
--       local xoff = math.floor(l / 10) * 32
--       local yoff = math.floor(l / 10) * 20
--       local xoff = (l % 10) * 42
      local yoff = (l % 5) * 20
      local xoff = math.floor(l / 5) * 42
      table.insert(menu, 13 + l,
        { "light", "light_" .. l, 200 + xoff, 85 + yoff, 40, 18, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  elseif mode == HMode.choose then
    -- tbd
  end
end
function HMenu.clickable(item_type)
  return item_type == "button" or item_type == "checkbox" or item_type == "radio" or item_type == "texture" or item_type == "light" or item_type == "dradio" or item_type == "dbutton"
end

HChoose = {}
function HChoose.gridsize(bct)
  local rows = 1
  local cols = 4
  while (rows * cols) < bct do
    rows = rows + 1
    cols = 2 + (2*rows)
  end
  return rows, math.ceil(bct / rows)
end


HCollections = {}
HCollections.inited = false
HCollections.current_collection = 0
HCollections.current_texture = 0
HCollections.current_landscape_collection = 0
HCollections.current_type = nil
HCollections.wall_collections = {}
HCollections.landscape_offsets = {}
HCollections.landscape_textures = {}
HCollections.all_shapes = {}
HCollections.names = {"Coll 0", "Coll 1", "Coll 2", "Coll 3", "Coll 4",
                     "Coll 5", "Coll 6", "Coll 7", "Coll 8", "Coll 9",
                     "Coll 10", "Coll 11", "Coll 12", "Coll 13", "Coll 14",
                     "Coll 15", "Coll 16", "Coll 17", "Coll 18", "Coll 19",
                     "Coll 20", "Coll 21", "Coll 22", "Coll 23", "Coll 24",
                     "Coll 25", "Coll 26", "Coll 27", "Coll 28", "Coll 29",
                     "Coll 30", "Coll 31"}

function HCollections.init()
  for k,v in pairs(collection_names) do
    HCollections.names[k + 1] = v
  end
  
  local landscape = false
  local landscape_offset = 0
  for i = 0,31 do
    local collection = Player.texture_palette.slots[i].collection
    if collection == 0 then
      if landscape then break end
      landscape = true
    else
      local bct = Collections[collection].bitmap_count
      if landscape then
        HCollections.landscape_offsets[collection] = landscape_offset
        landscape_offset = landscape_offset + bct
      end
      HCollections.all_shapes[collection] = {}
      local ttype = TextureTypes["wall"]
      if landscape then
        ttype = TextureTypes["landscape"]
      else
        table.insert(HCollections.wall_collections, collection)
      end
      for j = 0,bct-1 do
        HCollections.all_shapes[collection][j] = Shapes.new{collection = Collections[collection], texture_index = j, type = ttype}
        if landscape then
          table.insert(HCollections.landscape_textures, { collection, j })
          HCollections.all_shapes[collection][j].crop_rect.width = HCollections.all_shapes[collection][j].unscaled_width / 2
          HCollections.all_shapes[collection][j].crop_rect.height = HCollections.all_shapes[collection][j].unscaled_height / 2
        end
      end
    end
  end
  
  
  local num_walls = #HCollections.wall_collections
  local num_land = #HCollections.landscape_textures

  local menu_colls = {}
  for _,cnum in pairs(HCollections.wall_collections) do
    local bct = Collections[cnum].bitmap_count
    local rows, cols = HChoose.gridsize(bct)
    table.insert(menu_colls, { cnum = cnum, bct = bct, rows = rows, cols = cols })
  end
  if num_land > 0 then
    local rows, cols = HChoose.gridsize(num_land)
    table.insert(menu_colls, { cnum = 0, bct = num_land, rows = rows, cols = cols })
  end
  
  -- set up apply-mode previews
  for i = 1,#menu_colls do
    local preview = {}
    local cinfo = menu_colls[i]
    local cnum, bct, rows, cols = cinfo.cnum, cinfo.bct, cinfo.rows, cinfo.cols
    
    local w = 180
    local h = 90
    local tsize = math.min(w / cols, h / rows)
    local x = 620 - (tsize * cols)
    local y = 380
    for j = 1,bct do
      local col = (j - 1) % cols
      local row = math.floor((j - 1) / cols)
      local xt = x + (tsize * col)
      local yt = y + (tsize * row)
      
      local cc = cnum
      local ct = j - 1
      if cnum == 0 then
        cc = HCollections.landscape_textures[j][1]
        ct = HCollections.landscape_textures[j][2]
      end
      table.insert(preview,
        { "dtexture", "display_" .. cc .. "_" .. ct, 
          xt, yt, tsize, tsize, cc .. ", " .. ct })
    end
    HMenu.menus["preview_" .. cnum] = preview
  end  

  -- set up collection buttons
  local cbuttons = {}
  if #menu_colls > 0 then
    local n = #menu_colls
    local w = math.floor(600 / n)
    
    local x = 20
    local y = 372
    for i = 1,n do
      local cinfo = menu_colls[i]
      local cnum = cinfo.cnum
      local cname = HCollections.names[cnum + 1]
      table.insert(cbuttons,
        { "dbutton", "coll_" .. cnum, x, y, w - 2, 18, cname })
        
      -- collection preview
      if true then
        local xx = x + 2
        local yy = y + 20
        local ww = w - 4
        local hh = 75
        
        local bct, rows, cols = cinfo.bct, cinfo.rows, cinfo.cols
        local tsize = math.min(ww / cols, hh / rows)
        xx = xx + (ww - (tsize * cols))/2
        
        for j = 1,bct do
          local col = (j - 1) % cols
          local row = math.floor((j - 1) / cols)
          local xt = xx + (tsize * col)
          local yt = yy + (tsize * row)
          
          local cc = cnum
          local ct = j - 1
          if cnum == 0 then
            cc = HCollections.landscape_textures[j][1]
            ct = HCollections.landscape_textures[j][2]
          end
          table.insert(cbuttons,
            { "dtexture", "display_" .. cc .. "_" .. ct, 
              xt, yt, tsize, tsize, cc .. ", " .. ct })
        end
      end
      
      x = x + w
    end
  end  
  
  -- set up grid
  for _,cinfo in ipairs(menu_colls) do
    local cnum, bct, rows, cols = cinfo.cnum, cinfo.bct, cinfo.rows, cinfo.cols
    
    local buttons = {}
    local tsize = math.min(600 / cols, 300 / rows)
    
    for i = 1,bct do
      local col = (i - 1) % cols
      local row = math.floor((i - 1) / cols)
      local x = 20 + (tsize * col) + (600 - (tsize * cols))/2
      local y = 65 + (tsize * row) + (300 - (tsize * rows))/2
      
      local cc = cnum
      local ct = i - 1
      if cnum == 0 then
        cc = HCollections.landscape_textures[i][1]
        ct = HCollections.landscape_textures[i][2]
      end
      table.insert(buttons,
        { "texture", "choose_" .. cc .. "_" .. ct, 
          x, y, tsize - 2, tsize - 2, cc .. ", " .. ct })
    end
    for _,v in ipairs(cbuttons) do
      table.insert(buttons, v)
    end
    
    HMenu.menus["choose_" .. cnum] = buttons
  end
    
  HCollections.inited = true
end
function HCollections.update()
  local slots = Player.texture_palette.slots
  HCollections.current_collection = slots[32].collection
  HCollections.current_texture = slots[32].texture_index
  HCollections.current_type = slots[HCollections.current_collection].type
  HCollections.current_landscape_collection = slots[0].texture_index
  
  if not HCollections.inited then HCollections.init() end
end
function HCollections.current_coll()
  local coll = HCollections.current_collection
  if coll == 0 then
    coll = HCollections.current_landscape_collection
  end
  return coll
end
function HCollections.shape(coll, tex)
  if coll == nil then
    coll = HCollections.current_coll()
  end
  if coll == 0 then
    coll = HCollections.current_landscape_collection
  end
  if tex == nil then
    tex = Player.texture_palette.slots[coll].texture_index
  end
  return HCollections.all_shapes[coll][tex]
end
function HCollections.is_landscape(coll)
  if coll == nil then
    coll = HCollections.current_coll()
  end
  if coll == 0 then
    coll = HCollections.current_landscape_collection
  end
  return Player.texture_palette.slots[coll].type.mnemonic == "landscape"
end
function HCollections.draw(coll, tex, x, y, size)
  local shp = HCollections.shape(coll, tex)
  if HCollections.is_landscape(coll) then
    size = size * 2
  end
  shp:rescale(size, size)
  shp:draw(x, y)
end

HCounts = {}
HCounts.num_lights = 0
HCounts.num_polys = 0
HCounts.num_platforms = 0
HCounts.num_tags = 0
HCounts.num_scripts = 0
function HCounts.update()
  local ct = Player.texture_palette.slots[33].texture_index + 128*Player.texture_palette.slots[34].texture_index
  local turn = (Game.ticks - 1) % 5
  if     turn == 0 then HCounts.num_lights = ct
  elseif turn == 1 then HCounts.num_polys = ct
  elseif turn == 2 then HCounts.num_platforms = ct
  elseif turn == 3 then HCounts.num_tags = ct
  elseif turn == 4 then HCounts.num_scripts = ct
  end
end


HLights = {}
HLights.inited = false
HLights.intensities = {}
function HLights.update()
  if HCounts.num_lights < 1 then return end
  for i = 1,math.min(HCounts.num_lights, 50) do
    HLights.intensities[i] = Player.texture_palette.slots[199 + i].texture_index / 128
  end
  HLights.inited = true
end
function HLights.val(idx)
  if not HLights.inited then return 1 end
  return HLights.intensities[idx + 1]
end
function HLights.adj(idx)
  if not HLights.inited then return 1 end
  return 0.5 + HLights.intensities[idx + 1]/2
end

HPlatforms = {}
HPlatforms.indexes = {}
function HPlatforms.update()
  if HCounts.num_platforms < 1 then return end
  local poly = Player.texture_palette.slots[35].texture_index + 128*Player.texture_palette.slots[36].texture_index
  local turn = (Game.ticks - 1) % HCounts.num_platforms
  HPlatforms.indexes[turn] = poly
end


HTeleport = {}
HTeleport.poly = 0
function HTeleport.update()
  HTeleport.poly = Player.texture_palette.slots[37].texture_index + 128*Player.texture_palette.slots[38].texture_index
  
--   if HMode.is(HMode.teleport) then
--     local lbls = HMode.labels[HMode.teleport]
--     lbls[5][5] = "Previous Polygon (" .. ((HTeleport.poly - 1) % HCounts.num_polys) .. ")"
--     lbls[6][5] = "Next Polygon (" .. ((HTeleport.poly + 1) % HCounts.num_polys) .. ")"
--   end
end
