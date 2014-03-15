-- Vasara 1.0 ALPHA (HUD script)
-- by Hopper and Ares Ex Machina

-- testing stuff here
-- change these in Lua script too, else bad stuff will happen

vert_range = 30   -- max: 30
horiz_range = 70  -- max: 160

vert_size = 400   -- max: 430
horiz_size = 600  -- max: 640

vert_offset = 50 + (430 - vert_size)/2
horiz_offset = 0 + (640 - horiz_size)/2


-- PREFERENCES

-- no preferences currently!

-- END PREFERENCES -- no user serviceable parts below ;)

Triggers = {}

g_scriptChecked = false

function Triggers.draw()
  if Player.life ~= 409 then
    if not g_scriptChecked then
      g_scriptChecked = true
      error "Vasara HUD requires Vasara Script"
    end
    return
  end
  
  HMode.update()
  HKeys.update()
  HApply.update()
  HStatus.update()
  HCollections.update()
  HCounts.update()
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
  if HMode.is(HMode.attribute) or HMode.is(HMode.recharger) or HMode.is(HMode.switch) or HMode.is(HMode.terminal) then
    if HMenu.menus[HMode.current] then
      HMenu.draw_menu(HMode.current)
      cxoff, cyoff = HMenu.cursorpos(HMode.current)

  -- debug
--   local r = {
--     horiz_offset*HGlobals.scale + HGlobals.xoff,
--     vert_offset*HGlobals.scale + HGlobals.yoff,
--     horiz_size*HGlobals.scale,
--     vert_size*HGlobals.scale }
--     
--     
--   Screen.frame_rect(r[1], r[2], r[3], r[4], { 1, 0.5, 0.5, 1 }, 2*HGlobals.scale)
  -- end debug
  
    end
  end
  
  -- texture options
  if HMode.is(HMode.choose) then
    Screen.fill_rect(Screen.world_rect.x, Screen.world_rect.y, Screen.world_rect.width, Screen.world_rect.height, {0, 0, 0, 1})
    
    Screen.clip_rect.x = Screen.world_rect.x
    Screen.clip_rect.y = Screen.world_rect.y
    Screen.clip_rect.width = Screen.world_rect.width
    Screen.clip_rect.height = Screen.world_rect.height
    
    local xa, ya = draw_palette(HCollections.current_collection,
                 Screen.world_rect.x + Screen.world_rect.width/2,
                 Screen.world_rect.y + Screen.world_rect.height/2,
                 Screen.world_rect.width, Screen.world_rect.height,
                 "center", "middle", true)
    cxoff = -xa
    cyoff = -ya
    
    Screen.clip_rect.x = 0
    Screen.clip_rect.y = 0
    Screen.clip_rect.width = Screen.width
    Screen.clip_rect.height = Screen.height
  end
  
  -- lower area
  if HMode.is(HMode.choose) then
    local xp = HGlobals.xoff + 10*HGlobals.scale
    local yp = HGlobals.yoff + 380*HGlobals.scale
    local yf = yp + 88*HGlobals.scale
    
    local cct = #HCollections.wall_collections + 1
    local maxw = math.floor(HGlobals.scale * (620 - (5*(cct - 1)))/cct)
    local maxh = 90*HGlobals.scale
    yp = yp + maxh/2
    
    local sel
    local clr
    
    for _, coll in pairs(HCollections.wall_collections) do
      if HCollections.current_collection == coll then
        sel = true
        clr = { 0, 1, 0, 1 }
      else
        sel = false
        clr = { 0.5, 0.5, 0.5, 1 }
      end
      
      draw_palette(coll, xp, yp, maxw, maxh, "left", "middle")
      HGlobals.fontm:draw_text(HCollections.names[coll + 1], xp, yf, clr)
      xp = xp + maxw + 5*HGlobals.scale
    end
    
    if HCollections.current_collection == 0 then
      sel = true
      clr = { 0, 1, 0, 1 }
    else
      sel = false
      clr = { 0.5, 0.5, 0.5, 1 }
    end
    draw_palette(0, xp, yp, maxw, maxh, "left", "middle")
    HGlobals.fontm:draw_text(HCollections.names[1], xp, yf, clr)

  end
  if HMode.is(HMode.apply) then
    local xp = HGlobals.xoff + 10*HGlobals.scale
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
    elseif HApply.down(HApply.use_light) then 
      Screen.fill_rect(xp, yp, 85*HGlobals.scale, 85*HGlobals.scale, { 1, 1, 1, 1 })
    end
    
    -- lower middle: attributes
    local xm = xp + 100*HGlobals.scale
    local ym = yp
    local yplus = HGlobals.fheight + 2*HGlobals.scale
    local att
    
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
    
    att = "Apply Light: " .. HApply.current_light
    draw_mode(att, xm, ym, (HApply.down(HApply.use_light) and HApply.current_transfer ~= 5))
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
    draw_palette(HCollections.current_collection,
                 xp + 620*HGlobals.scale, yp + 45*HGlobals.scale,
                 200*HGlobals.scale, 90*HGlobals.scale,
                 "right", "middle")
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
  if active then
    clr = { 1, 1, 1, 1 }
  end
  HGlobals.fontn:draw_text(label, x, y, clr)
end

function draw_palette(coll, x, y, w, h, halign, valign, show_cur)

  local tex = Player.texture_palette.slots[coll].texture_index
  local bct = Collections[coll].bitmap_count
  if coll == 0 then
    bct = #HCollections.landscape_textures
  end

  local rows, cols = HChoose.gridsize(bct)
  local xa, ya = HChoose.gridpos(rows, cols)
  local tsize = math.min(w / cols, h / rows)
  xa = xa * tsize
  ya = ya * tsize
  
  local xp = x
  if halign == "center" then xp = xp - (tsize*cols)/2 end
  if halign == "right"  then xp = xp - (tsize*cols)/1 end

  local yp = y
  if valign == "middle" then yp = yp - (tsize*rows)/2 end
  if valign == "bottom" then yp = yp - (tsize*rows)/1 end
  
  local off = math.max(HGlobals.scale/2, math.min(w / 640, h / 320))
  local ccoll = coll
  local t
  for t = 0,bct-1 do
    local ctex = t
    if coll == 0 then
      local tbl = HCollections.landscape_textures[t+1]
      ccoll = tbl[1]
      ctex = tbl[2]
    end
    local xoff = t % cols
    local yoff = math.floor(t / cols)
    
    local cur = false
    if show_cur then
      cur = (t == tex)
      if coll == 0 then
        cur = (ccoll == HCollections.current_landscape_collection)
      end
    end
    if cur then
      Screen.frame_rect(xp + (xoff*tsize) - off, yp + (yoff*tsize) - off, tsize + (2 * off), tsize + (2 * off), { 0, 1, 0, 1 }, 2*off)
    end
    HCollections.draw(ccoll, ctex, xp + (xoff*tsize) + off, yp + (yoff*tsize) + off, tsize - (2 * off))
  end
  
  return xa, ya
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
  imgs["cursor_menu"] = Images.new{path = "resources/cursor_menu.png"}
  imgs["cursor_menu_down"] = Images.new{path = "resources/cursor_menu_down.png"}
  imgs["cursor_apply"] = Images.new{path = "resources/cursor_apply.png"}
  imgs["cursor_apply_down"] = Images.new{path = "resources/cursor_apply_down.png"}
  imgs["cursor_teleport"] = Images.new{path = "resources/cursor_teleport.png"}
  imgs["cursor_teleport_down"] = Images.new{path = "resources/cursor_teleport_down.png"}

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
  local w = math.max(1, math.floor(img.unscaled_width * scale))
  local h = math.max(1, math.floor(img.unscaled_height * scale))
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
      lbls[3][5] = "Apply Texture + Light"
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
    { HKeys.secondary,   1, 4, false, "Sample Texture + Light" },
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
  { "label", nil, 250, 67, 200, 23, "Attributes" },
  { "checkbox", "apply_tex", 250, 90, 200, 26, "Apply texture" },
  { "checkbox", "apply_light", 250, 120, 200, 26, "Apply light" },
  { "checkbox", "apply_align", 250, 150, 200, 26, "Align adjacent" },
  { "checkbox", "apply_edit", 250, 180, 200, 26, "Edit switches and panels" },
  { "checkbox", "apply_xparent", 250, 210, 200, 26, "Edit transparent sides" },
  { "label", "nil", 250, 247, 150, 23, "Snap to grid" },
  { "radio", "snap_0", 250, 270, 200, 26, "Off" },
  { "radio", "snap_1", 250, 300, 200, 26, "1/4 WU" },
  { "radio", "snap_2", 250, 330, 200, 26, "1/5 WU" },
  { "radio", "snap_3", 250, 360, 200, 26, "1/8 WU" },
  { "label", nil, 30, 67, 200, 23, "Texture mode" },
  { "radio", "transfer_0", 30, 90, 200, 26, "Normal" },
  { "radio", "transfer_1", 30, 120, 200, 26, "Pulsate" },
  { "radio", "transfer_2", 30, 150, 200, 26, "Wobble" },
  { "radio", "transfer_3", 30, 180, 200, 26, "Fast wobble" },
  { "radio", "transfer_6", 30, 210, 200, 26, "Horizontal slide" },
  { "radio", "transfer_7", 30, 240, 200, 26, "Fast horizontal slide" },
  { "radio", "transfer_8", 30, 270, 200, 26, "Vertical slide" },
  { "radio", "transfer_9", 30, 300, 200, 26, "Fast vertical slide" },
  { "radio", "transfer_10", 30, 330, 200, 26, "Wander" },
  { "radio", "transfer_11", 30, 360, 200, 26, "Fast wander" },
  { "radio", "transfer_4", 30, 390, 200, 26, "Static" },
  { "radio", "transfer_5", 30, 420, 200, 26, "Landscape" },
  { "label", nil, 470, 67, 200, 23, "Light" } }
HMenu.inited = {}
HMenu.inited[HMode.attribute] = false
function HMenu.draw_menu(mode)
  if not HMenu.inited[mode] then HMenu.init_menu(mode) end
  local u = HGlobals.scale
  local m = HMenu.menus[mode]
  local xp = HGlobals.xoff
  local yp = HGlobals.yoff
  
  Screen.fill_rect(Screen.world_rect.x, Screen.world_rect.y,
                   Screen.world_rect.width, Screen.world_rect.height,
                   { 0, 0, 0, 1 })
  --Screen.frame_rect(xp, yp, m[1][5]*u, m[1][6]*u, { 0, 1, 0, 1 }, 2*u)
  
  for idx, item in ipairs(m) do
    local x = xp + item[3]*u
    local y = yp + item[4]*u
    local w = item[5]*u
    local h = item[6]*u
    
    if item[1] == "label" then
      HGlobals.fontb:draw_text(item[7],
                               math.floor(x + 5*u), math.floor(y + 5*u),
                               { 1, 1, 1, 1 })
    elseif HMenu.clickable(item[1]) then
      if HStatus.current_menu_item == idx then
        Screen.frame_rect(x - 2*u, y - 2*u, w + 4*u, h + 4*u, { 0, 1, 0, 1 }, 2*u)
      end
      local state = HMenu.button_state(item[2])
      if state == "enabled" then
        Screen.fill_rect(x, y, w, h, { 0.7, 0.7, 0.7, 1 })
        Screen.fill_rect(x, y, w, 2*u, { 0.9, 0.9, 0.9, 1 })
        Screen.fill_rect(x, y + 2*u, 2*u, h - 2*u, { 0.9, 0.9, 0.9, 1 })
        Screen.fill_rect(x + 2*u, y + h - 2*u,
                         w - 2*u, 2*u,
                         { 0.6, 0.6, 0.6, 1 })
        Screen.fill_rect(x + w - 2*u, y + 2*u,
                         2*u, h - 2*u,
                         { 0.6, 0.6, 0.6, 1 })
        HGlobals.fontb:draw_text(item[7],
                                 math.floor(x + 7*u), math.floor(y + 6*u),
                                 { 0, 0, 0, 1 })
      elseif state == "disabled" then
        Screen.fill_rect(x, y, w, h, { 0.7, 0.7, 0.7, 1 })
        HGlobals.fontb:draw_text(item[7],
                                 math.floor(x + 7*u), math.floor(y + 6*u),
                                 { 0.5, 0.5, 0.5, 1 })
      
      elseif state == "active" then
        Screen.fill_rect(x, y, w, h, { 1.0, 1.0, 1.0, 1 })
        Screen.fill_rect(x, y, w, 2*u, { 0.9, 0.9, 0.9, 1 })
        Screen.fill_rect(x, y + 2*u, 2*u, h - 2*u, { 0.9, 0.9, 0.9, 1 })
        Screen.fill_rect(x + 2*u, y + h - 2*u,
                         w - 2*u, 2*u,
                         { 0.6, 0.6, 0.6, 1 })
        Screen.fill_rect(x + w - 2*u, y + 2*u,
                         2*u, h - 2*u,
                         { 0.6, 0.6, 0.6, 1 })
        HGlobals.fontb:draw_text(item[7],
                                 math.floor(x + 7*u), math.floor(y + 6*u),
                                 { 0, 0, 0.3, 1 })
      end
    end
  end
end
function HMenu.coord()
  local y = vert_offset + vert_size/(vert_range*2) * PIN(vert_range - Player.pitch, 0, vert_range*2)
  local x = horiz_offset + horiz_size/(horiz_range*2) * PIN(horiz_range + Player.direction - 180, 0, horiz_range*2)
  
  return x, y
end
function HMenu.cursorpos(mode)
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
  end
  
  return state
end
function HMenu.init_menu(mode)
  local menu = HMenu.menus[mode]
  if mode == HMode.attribute then
    if HCounts.num_lights > 0 then
      for i = 1,HCounts.num_lights do
        local l = i - 1
      local yoff = (l % 10) * 20
      local xoff = math.floor(l / 10) * 32
      table.insert(menu,
        { "radio", "light_" .. l, 470 + xoff, 90 + yoff, 28, 18, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  end
end
function HMenu.clickable(item_type)
  return item_type == "button" or item_type == "checkbox" or item_type == "radio" or item_type == "texture" end
end

HChoose = {}
function HChoose.gridsize(bct)
  local rows = 1
  local cols = 2
  while (rows * cols) < bct do
    if (cols % 2) == 0 then
      cols = cols + 1
    else
      rows = rows + 1
      cols = math.floor(rows * 2)
    end
  end
  if (rows * cols) >= (bct + rows) then
    rows = rows - 1
  end
  return rows, cols
end
function HChoose.gridpos(rows, cols)
  local ya = (rows - 0.5) * Player.pitch / 60

  local xa = 0
  local fov = 60
  local dir = Player.direction - 180
--   if dir < 0 then dir = dir + 360 end    
--   if dir > 180 then dir = dir - 180 end
--   if dir > 90 then dir = dir - 180 end
  if dir > fov then
    xa = -(cols-0.5) / 2
  elseif dir < -fov then
    xa = (cols-0.5) / 2
  else
    xa = (-(cols-0.5) / 2) * (dir / fov)
  end
  return xa, ya
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
HCollections.names = {"Landscapes", "Coll 1", "Coll 2", "Coll 3", "Coll 4",
                     "Coll 5", "Coll 6", "Coll 7", "Coll 8", "Coll 9",
                     "Coll 10", "Coll 11", "Coll 12", "Coll 13", "Coll 14",
                     "Coll 15", "Coll 16", "Water", "Lava", "Sewage",
                     "Jjaro", "Pfhor", "Coll 22", "Coll 23", "Coll 24",
                     "Coll 25", "Coll 26", "Dayscape", "Nightscape", "Moonscape",
                     "Starscape", "Coll 31"}

function HCollections.update()
  local slots = Player.texture_palette.slots
  HCollections.current_collection = slots[32].collection
  HCollections.current_texture = slots[32].texture_index
  HCollections.current_type = slots[HCollections.current_collection].type
  HCollections.current_landscape_collection = slots[0].texture_index
  
  if HCollections.inited then return end
  
  local landscape = false
  local landscape_offset = 0
  for i = 0,31 do
    local collection = slots[i].collection
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
    
  HCollections.inited = true
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


HPlatforms = {}
HPlatforms.indexes = {}
function HPlatforms.update()
  if HCounts.num_platforms < 1 then return end
  local poly = Player.texture_palette.slots[35].texture_index + 256*Player.texture_palette.slots[36].texture_index
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
