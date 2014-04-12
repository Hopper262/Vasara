-- Vasara 1.0 ALPHA (HUD script)
-- by Hopper and Ares Ex Machina

-- PREFERENCES

-- Preview full collections on Choose or Visual Mode screens
-- (set one or both to false to spend less time "Loading textures...")
preview_all_collections = true
preview_collection_when_applying = true

-- Displayed names for texture collections
collection_names = {
[0] = "Landscapes",
[17] = "Water",
[18] = "Lava",
[19] = "Sewage",
[20] = "Jjaro",
[21] = "Pfhor"
}

-- colors (RGBA, 0 to 1)
colors = {}
colors.menu_label = { 0.8, 0.8, 0.8, 1 }
colors.current_texture = { 0, 1, 0, 1 }
colors.current_light = { 0, 1, 0, 1 }
colors.noncurrent_light = { 0.5, 0.5, 0.5, 1 }

colors.commands = {}
colors.commands.enabled = {}
colors.commands.enabled.label = { 0, 1, 0, 1 }
colors.commands.enabled.key = { 1, 1, 1, 1 }
colors.commands.disabled = {}
colors.commands.disabled.label = { 0, 0.5, 0, 1 }
colors.commands.disabled.key = { 0.5, 0.5, 0.5, 1 }
colors.commands.active = {}
colors.commands.active.label = { 1, 0, 0, 1 }
colors.commands.active.key = { 1, 1, 0, 1 }

colors.button = {}
colors.button.enabled = {}
colors.button.enabled.background = { 0.1, 0.1, 0.1, 1 }
colors.button.enabled.highlight = { 0.1, 0.1, 0.1, 1 }
colors.button.enabled.shadow = { 0.1, 0.1, 0.1, 1 }
colors.button.enabled.text = { 0.8, 0.8, 0.8, 1 }
colors.button.disabled = {}
colors.button.disabled.background = { 0.0, 0.0, 0.0, 1 }
colors.button.disabled.highlight = { 0.0, 0.0, 0.0, 1 }
colors.button.disabled.shadow = { 0.0, 0.0, 0.0, 1 }
colors.button.disabled.text = { 0.5, 0.5, 0.5, 1 }
colors.button.active = {}
colors.button.active.background = { 0.2, 0.2, 0.2, 1 }
colors.button.active.highlight = { 0.25, 0.25, 0.25, 1 }
colors.button.active.shadow = { 0.15, 0.15, 0.15, 1 }
colors.button.active.text = { 0.0, 1.0, 0.0, 1 }

colors.apply = {}
colors.apply.enabled = {}
colors.apply.enabled.text = { 0.5, 0.5, 0.5, 1 }
colors.apply.active = {}
colors.apply.active.text = { 1, 1, 1, 1 }

-- other menu UI prefs
menu_prefs = {}
menu_prefs.button_indent = 1
menu_prefs.button_highlight_thickness = 2
menu_prefs.button_shadow_thickness = 2
menu_prefs.texture_choose_indent = 1
menu_prefs.texture_preview_indent = 0
menu_prefs.light_thickness = 2


-- END PREFERENCES -- no user serviceable parts below ;)

Triggers = {}

vert_range = 30   -- max: 30
horiz_range = 70  -- max: 160
vert_size = 325   -- max: 430
horiz_size = 600  -- max: 640
vert_offset = 65
horiz_offset = 20

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
  HPanel.update()
  
  if HMode.changed then layout() end

  -- keys
  HMenu.draw_menu("key_" .. HMode.current, true)
  
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
  if HMode.is(HMode.attribute) or HMode.is(HMode.panel) or HMode.is(HMode.choose) then
    local m = HMode.current
    if HMode.is(HMode.choose) then
      m = "choose_" .. HCollections.current_collection
    elseif HMode.is(HMode.panel) then
      m = HPanel.menu_name()
    end
    if HMenu.menus[m] then
      HMenu.draw_menu(m)
      cxoff, cyoff = HMenu.cursorpos()
    end
  end
  
  -- lower area
  if HMode.is(HMode.attribute) then
    local u = HGlobals.scale
    local xp = HGlobals.xoff + 460*u
    local yp = HGlobals.yoff + 270*u
    local sz = 120*u
    
    HCollections.preview_current(xp, yp, sz)
  end
  if HMode.is(HMode.apply) then
    local xp = HGlobals.xoff + 20*HGlobals.scale
    local yp = HGlobals.yoff + 380*HGlobals.scale
    
    -- lower left: current texture
    HCollections.preview_current(xp, yp, 85*HGlobals.scale)
    
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
  draw_cursor(HMode.panel, "menu", cxoff, cyoff)
  
end

function draw_mode(label, x, y, active)
  local clr = colors.apply.enabled.text
  local img = imgs["fcheck_off"]
  if active then
    clr = colors.apply.active.text
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
                       "dcheck_on", "dcheck_off", "dcheck_dis",
                       "dradio_on", "dradio_off", "dradio_dis",
                       "fcheck_on", "fcheck_off" }) do
    imgs[nm] = Images.new{path = "resources/" .. nm .. ".png"}
  end
  img_static = Images.new{path = "resources/static.png"}

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
HKeys.dummyfield = 0
HKeys.names = {"Trigger", "2nd Trigger", "Microphone", "Previous Weapon", "Next Weapon", "Action", "Auto Map"}
HKeys.shortnames = {"Trigger", "2nd", "Mic", "Previous", "Next", "Action", "Map"}
function HKeys.update()
  HKeys.bitfield = Player.texture_palette.slots[39].texture_index
  HKeys.dummyfield = Player.texture_palette.slots[42].texture_index
end
function HKeys.down(k)
  return hasbit(HKeys.bitfield, k)
end
function HKeys.dummy(k)
  return hasbit(HKeys.dummyfield, k)
end
function HKeys.button_state(keyname, mic_modifier)
  local k = HKeys[keyname]
  local state = "enabled"
  if HKeys.down(k) then state = "active" end
  
  if k == HKeys.mic then
    if HKeys.dummy(HKeys.mic) then state = "disabled" end
  elseif mic_modifier then
    if not HKeys.down(HKeys.mic) then state = "disabled" end
  elseif HKeys.down(HKeys.mic) then
    state = "disabled"
  end
  
  return state
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

  local lbls = HMenu.menus["key_" .. HMode.apply]
  
  if HApply.down(HApply.use_texture) then
    if HApply.down(HApply.use_light) then
      lbls[3][7] = "Apply Light + Texture"
    else
      lbls[3][7] = "Apply Texture"
    end
  elseif HApply.down(HApply.use_light) then
    lbls[3][7] = "Apply Light"
  else
    lbls[3][7] = "Move Texture"
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
HStatus.current_menu_item = 0
function HStatus.update()
  HStatus.bitfield = Player.texture_palette.slots[41].texture_index
  HStatus.current_menu_item = Player.texture_palette.slots[47].texture_index
  
  local lbls = HMenu.menus["key_" .. HMode.apply]
  local lbls2 = HMenu.menus["key_" .. HMode.teleport]
  
  if HStatus.down(HStatus.frozen) then
    lbls[6][7] = "Unfreeze"
  else
    lbls[6][7] = "Freeze"
  end
  
  if HStatus.down(HStatus.undo_active) then
    lbls[1][7] = "Undo"
    lbls[9][7] = "Undo"
  else
    lbls[1][7] = "(Can't Undo)"
    lbls[9][7] = "(Can't Undo)"
  end
  if HStatus.down(HStatus.redo_active) then
    lbls[2][7] = "Redo"
    lbls[9][7] = "Redo"
  else
    lbls[2][7] = "(Can't Redo)"
  end
  if HStatus.down(HStatus.action_active) then
    lbls[10][7] = "Activate"
    lbls2[7][7] = "Activate"
  else
    lbls[10][7] = "Choose Texture"
    lbls2[7][7] = "Choose Texture"
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
HMode.panel = 4
HMode.changed = false
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
  { "label", nil, 20+18, 65, 155-18, 20, "Attributes" },
  { "checkbox", "apply_light", 20, 85, 155, 20, "Apply light" },
  { "checkbox", "apply_tex", 20, 105, 155, 20, "Apply texture" },
  { "checkbox", "apply_align", 20, 125, 155, 20, "Align adjacent" },
  { "checkbox", "apply_edit", 20, 145, 155, 20, "Edit switches and panels" },
  { "checkbox", "apply_xparent", 20, 165, 155, 20, "Edit transparent sides" },
  { "label", "nil", 20+18, 250, 155-18, 20, "Snap to grid" },
  { "radio", "snap_0", 20, 270, 155, 20, "Off" },
  { "radio", "snap_1", 20, 290, 155, 20, "1/4 WU" },
  { "radio", "snap_2", 20, 310, 155, 20, "1/5 WU" },
  { "radio", "snap_3", 20, 330, 155, 20, "1/8 WU" },
  { "label", nil, 200+18, 65, 240-18, 20, "Light" },
  { "label", nil, 200+18, 250, 240-18, 20, "Texture mode" },
  { "radio", "transfer_0", 200, 270, 120, 20, "Normal" },
  { "radio", "transfer_1", 200, 290, 120, 20, "Pulsate" },
  { "radio", "transfer_2", 200, 310, 120, 20, "Wobble" },
  { "radio", "transfer_6", 200, 330, 120, 20, "Horizontal slide" },
  { "radio", "transfer_8", 200, 350, 120, 20, "Vertical slide" },
  { "radio", "transfer_10", 200, 370, 120, 20, "Wander" },
  { "radio", "transfer_5", 320, 270, 120, 20, "Landscape" },
  { "radio", "transfer_4", 320, 290, 120, 20, "Static" },
  { "radio", "transfer_3", 320, 310, 120, 20, "Fast wobble" },
  { "radio", "transfer_7", 320, 330, 120, 20, "Fast horizontal slide" },
  { "radio", "transfer_9", 320, 350, 120, 20, "Fast vertical slide" },
  { "radio", "transfer_11", 320, 370, 120, 20, "Fast wander" },
  { "label", nil, 460, 250, 160, 20, "Preview" } }
HMenu.menus["panel_off"] = {
  { "radio", "ptype_5", 20, 85, 125, 20, "Light switch" },
  { "radio", "ptype_6", 20, 105, 125, 20, "Platform switch" },
  { "radio", "ptype_7", 20, 125, 125, 20, "Tag switch" },
  { "radio", "ptype_10", 20, 145, 125, 20, "Chip insertion" },
  { "radio", "ptype_11", 20, 165, 125, 20, "Wires" },
  { "radio", "ptype_1", 20, 195, 125, 20, "Oxygen" },
  { "radio", "ptype_2", 20, 215, 125, 20, "1X health" },
  { "radio", "ptype_3", 20, 235, 125, 20, "2X health" },
  { "radio", "ptype_4", 20, 255, 125, 20, "3X health" },
  { "radio", "ptype_8", 20, 285, 125, 20, "Pattern buffer" },
  { "radio", "ptype_9", 20, 305, 125, 20, "Terminal" },
  { "radio", "ptype_0", 20, 335, 125, 20, "Inactive" } }
HMenu.menus["panel_plain"] = {
  { "radio", "ptype_5", 20, 85, 125, 20, "Light switch" },
  { "radio", "ptype_6", 20, 105, 125, 20, "Platform switch" },
  { "radio", "ptype_7", 20, 125, 125, 20, "Tag switch" },
  { "radio", "ptype_10", 20, 145, 125, 20, "Chip insertion" },
  { "radio", "ptype_11", 20, 165, 125, 20, "Wires" },
  { "radio", "ptype_1", 20, 195, 125, 20, "Oxygen" },
  { "radio", "ptype_2", 20, 215, 125, 20, "1X health" },
  { "radio", "ptype_3", 20, 235, 125, 20, "2X health" },
  { "radio", "ptype_4", 20, 255, 125, 20, "3X health" },
  { "radio", "ptype_8", 20, 285, 125, 20, "Pattern buffer" },
  { "radio", "ptype_9", 20, 305, 125, 20, "Terminal" },
  { "radio", "ptype_0", 20, 335, 125, 20, "Inactive" },
  { "checkbox", "panel_light", 200, 85, 125, 20, "Light dependent" } }
HMenu.menus["panel_terminal"] = {
  { "radio", "ptype_5", 20, 85, 125, 20, "Light switch" },
  { "radio", "ptype_6", 20, 105, 125, 20, "Platform switch" },
  { "radio", "ptype_7", 20, 125, 125, 20, "Tag switch" },
  { "radio", "ptype_10", 20, 145, 125, 20, "Chip insertion" },
  { "radio", "ptype_11", 20, 165, 125, 20, "Wires" },
  { "radio", "ptype_1", 20, 195, 125, 20, "Oxygen" },
  { "radio", "ptype_2", 20, 215, 125, 20, "1X health" },
  { "radio", "ptype_3", 20, 235, 125, 20, "2X health" },
  { "radio", "ptype_4", 20, 255, 125, 20, "3X health" },
  { "radio", "ptype_8", 20, 285, 125, 20, "Pattern buffer" },
  { "radio", "ptype_9", 20, 305, 125, 20, "Terminal" },
  { "radio", "ptype_0", 20, 335, 125, 20, "Inactive" },
  { "checkbox", "panel_light", 200, 85, 155, 20, "Light dependent" },
  { "label", nil, 200, 125, 155, 20, "Terminal script" } }
 HMenu.menus["panel_light"] = {
  { "radio", "ptype_5", 20, 85, 125, 20, "Light switch" },
  { "radio", "ptype_6", 20, 105, 125, 20, "Platform switch" },
  { "radio", "ptype_7", 20, 125, 125, 20, "Tag switch" },
  { "radio", "ptype_10", 20, 145, 125, 20, "Chip insertion" },
  { "radio", "ptype_11", 20, 165, 125, 20, "Wires" },
  { "radio", "ptype_1", 20, 195, 125, 20, "Oxygen" },
  { "radio", "ptype_2", 20, 215, 125, 20, "1X health" },
  { "radio", "ptype_3", 20, 235, 125, 20, "2X health" },
  { "radio", "ptype_4", 20, 255, 125, 20, "3X health" },
  { "radio", "ptype_8", 20, 285, 125, 20, "Pattern buffer" },
  { "radio", "ptype_9", 20, 305, 125, 20, "Terminal" },
  { "radio", "ptype_0", 20, 335, 125, 20, "Inactive" },
  { "checkbox", "panel_light", 200, 85, 155, 20, "Light dependent" },
  { "checkbox", "panel_weapon", 200, 105, 155, 20, "Only toggled by weapons" },
  { "checkbox", "panel_repair", 360, 85, 155, 20, "Repair switch" },
  { "label", nil, 200, 125, 155, 20, "Light" } }
 HMenu.menus["panel_platform"] = {
  { "radio", "ptype_5", 20, 85, 125, 20, "Light switch" },
  { "radio", "ptype_6", 20, 105, 125, 20, "Platform switch" },
  { "radio", "ptype_7", 20, 125, 125, 20, "Tag switch" },
  { "radio", "ptype_10", 20, 145, 125, 20, "Chip insertion" },
  { "radio", "ptype_11", 20, 165, 125, 20, "Wires" },
  { "radio", "ptype_1", 20, 195, 125, 20, "Oxygen" },
  { "radio", "ptype_2", 20, 215, 125, 20, "1X health" },
  { "radio", "ptype_3", 20, 235, 125, 20, "2X health" },
  { "radio", "ptype_4", 20, 255, 125, 20, "3X health" },
  { "radio", "ptype_8", 20, 285, 125, 20, "Pattern buffer" },
  { "radio", "ptype_9", 20, 305, 125, 20, "Terminal" },
  { "radio", "ptype_0", 20, 335, 125, 20, "Inactive" },
  { "checkbox", "panel_light", 200, 85, 155, 20, "Light dependent" },
  { "checkbox", "panel_weapon", 200, 105, 155, 20, "Only toggled by weapons" },
  { "checkbox", "panel_repair", 360, 85, 155, 20, "Repair switch" },
  { "label", nil, 200, 125, 155, 20, "Platform" } }
 HMenu.menus["panel_tag"] = {
  { "radio", "ptype_5", 20, 85, 125, 20, "Light switch" },
  { "radio", "ptype_6", 20, 105, 125, 20, "Platform switch" },
  { "radio", "ptype_7", 20, 125, 125, 20, "Tag switch" },
  { "radio", "ptype_10", 20, 145, 125, 20, "Chip insertion" },
  { "radio", "ptype_11", 20, 165, 125, 20, "Wires" },
  { "radio", "ptype_1", 20, 195, 125, 20, "Oxygen" },
  { "radio", "ptype_2", 20, 215, 125, 20, "1X health" },
  { "radio", "ptype_3", 20, 235, 125, 20, "2X health" },
  { "radio", "ptype_4", 20, 255, 125, 20, "3X health" },
  { "radio", "ptype_8", 20, 285, 125, 20, "Pattern buffer" },
  { "radio", "ptype_9", 20, 305, 125, 20, "Terminal" },
  { "radio", "ptype_0", 20, 335, 125, 20, "Inactive" },
  { "checkbox", "panel_light", 200, 85, 155, 20, "Light dependent" },
  { "checkbox", "panel_weapon", 200, 105, 155, 20, "Only toggled by weapons" },
  { "checkbox", "panel_repair", 360, 85, 155, 20, "Repair switch" },
  { "checkbox", "panel_active", 360, 105, 155, 20, "Tag is active" },
  { "label", nil, 200, 125, 155, 20, "Tag" } }
HMenu.menus["key_" .. HMode.apply] = {
  { "kaction", "key_mic_primary", 105, 0, 120, 12, "Undo" },
  { "kaction", "key_mic_secondary", 105, 12, 120, 12, "Redo" },
  { "kaction", "key_primary", 105, 24, 120, 12, "Apply Texture" },
  { "kaction", "key_secondary", 105, 36, 120, 12, "Sample Light + Texture" },
  { "kaction", "key_mic_prev_weapon", 320, 0, 120, 12, "Jump" },
  { "kaction", "key_mic_next_weapon", 320, 12, 120, 12, "Freeze" },
  { "kaction", "key_prev_weapon", 320, 24, 120, 12, "Previous Light" },
  { "kaction", "key_next_weapon", 320, 36, 120, 12, "Next Light" },
  { "kaction", "key_mic_action", 535, 0, 120, 12, "Undo" },
  { "kaction", "key_action", 535, 12, 120, 12, "Choose Texture" },
  { "kaction", "key_mic", 535, 24, 120, 12, "Options" },
  { "kaction", "key_map", 535, 36, 120, 12, "Teleport" },
  { "klabel", "key_mic_primary", 10, 0, 90, 12, "Mic + Trigger:" },
  { "klabel", "key_mic_secondary", 10, 12, 90, 12, "Mic + 2nd:" },
  { "klabel", "key_primary", 10, 24, 90, 12, "Trigger:" },
  { "klabel", "key_secondary", 10, 36, 90, 12, "2nd Trigger:" },
  { "klabel", "key_mic_prev_weapon", 225, 0, 90, 12, "Mic + Previous:" },
  { "klabel", "key_mic_next_weapon", 225, 12, 90, 12, "Mic + Next:" },
  { "klabel", "key_prev_weapon", 225, 24, 90, 12, "Previous Weapon:" },
  { "klabel", "key_next_weapon", 225, 36, 90, 12, "Next Weapon:" },
  { "klabel", "key_mic_action", 440, 0, 90, 12, "Mic + Action:" },
  { "klabel", "key_action", 440, 12, 90, 12, "Action:" },
  { "klabel", "key_mic", 440, 24, 90, 12, "Microphone:" },
  { "klabel", "key_map", 440, 36, 90, 12, "Auto Map:" } }
HMenu.menus["key_" .. HMode.teleport] = {
  { "kaction", "key_mic_primary", 105, 0, 120, 12, "Rewind Polygon" },
  { "kaction", "key_mic_secondary", 105, 12, 120, 12, "Fast Forward Polygon" },
  { "kaction", "key_primary", 105, 24, 120, 12, "Teleport" },
  { "kaction", "key_secondary", 105, 36, 120, 12, "Return" },
  { "kaction", "key_prev_weapon", 320, 24, 120, 12, "Previous Polygon" },
  { "kaction", "key_next_weapon", 320, 36, 120, 12, "Next Polygon" },
  { "kaction", "key_action", 535, 12, 120, 12, "Activate" },
  { "kaction", "key_mic", 535, 24, 120, 12, "Options" },
  { "kaction", "key_map", 535, 36, 120, 12, "Return" },
  { "klabel", "key_mic_primary", 10, 0, 90, 12, "Mic + Trigger:" },
  { "klabel", "key_mic_secondary", 10, 12, 90, 12, "Mic + 2nd:" },
  { "klabel", "key_primary", 10, 24, 90, 12, "Trigger:" },
  { "klabel", "key_secondary", 10, 36, 90, 12, "2nd Trigger:" },
  { "klabel", "key_prev_weapon", 225, 24, 90, 12, "Previous Weapon:" },
  { "klabel", "key_next_weapon", 225, 36, 90, 12, "Next Weapon:" },
  { "klabel", "key_action", 440, 12, 90, 12, "Action:" },
  { "klabel", "key_mic", 440, 24, 90, 12, "Microphone:" },
  { "klabel", "key_map", 440, 36, 90, 12, "Auto Map:" } }
HMenu.menus["key_" .. HMode.choose] = {
  { "kaction", "key_mic_primary", 105, 0, 120, 12, "Cycle Textures" },
  { "kaction", "key_mic_secondary", 105, 12, 120, 12, "Cycle Collections" },
  { "kaction", "key_primary", 105, 24, 120, 12, "Select Texture" },
  { "kaction", "key_secondary", 105, 36, 120, 12, "Return" },
  { "kaction", "key_mic_prev_weapon", 320, 0, 120, 12, "Previous Texture" },
  { "kaction", "key_mic_next_weapon", 320, 12, 120, 12, "Next Texture" },
  { "kaction", "key_prev_weapon", 320, 24, 120, 12, "Previous Collection" },
  { "kaction", "key_next_weapon", 320, 36, 120, 12, "Next Collection" },
  { "kaction", "key_action", 535, 12, 120, 12, "Return" },
  { "kaction", "key_mic", 535, 24, 120, 12, "Options" },
  { "kaction", "key_map", 535, 36, 120, 12, "Teleport" },
  { "klabel", "key_mic_primary", 10, 0, 90, 12, "Mic + Trigger:" },
  { "klabel", "key_mic_secondary", 10, 12, 90, 12, "Mic + 2nd:" },
  { "klabel", "key_primary", 10, 24, 90, 12, "Trigger:" },
  { "klabel", "key_secondary", 10, 36, 90, 12, "2nd Trigger:" },
  { "klabel", "key_mic_prev_weapon", 225, 0, 90, 12, "Mic + Previous:" },
  { "klabel", "key_mic_next_weapon", 225, 12, 90, 12, "Mic + Next:" },
  { "klabel", "key_prev_weapon", 225, 24, 90, 12, "Previous Weapon:" },
  { "klabel", "key_next_weapon", 225, 36, 90, 12, "Next Weapon:" },
  { "klabel", "key_action", 440, 12, 90, 12, "Action:" },
  { "klabel", "key_mic", 440, 24, 90, 12, "Microphone:" },
  { "klabel", "key_map", 440, 36, 90, 12, "Auto Map:" } }
HMenu.menus["key_" .. HMode.attribute] = {
  { "kaction", "key_primary", 105, 24, 120, 12, "Select Option" },
  { "kaction", "key_secondary", 105, 36, 120, 12, "Return" },
  { "kaction", "key_prev_weapon", 320, 24, 120, 12, "Previous Option" },
  { "kaction", "key_next_weapon", 320, 36, 120, 12, "Next Option" },
  { "kaction", "key_action", 535, 12, 120, 12, "Choose Texture" },
  { "kaction", "key_mic", 535, 24, 120, 12, "Return" },
  { "kaction", "key_map", 535, 36, 120, 12, "Teleport" },
  { "klabel", "key_primary", 10, 24, 90, 12, "Trigger:" },
  { "klabel", "key_secondary", 10, 36, 90, 12, "2nd Trigger:" },
  { "klabel", "key_prev_weapon", 225, 24, 90, 12, "Previous Weapon:" },
  { "klabel", "key_next_weapon", 225, 36, 90, 12, "Next Weapon:" },
  { "klabel", "key_action", 440, 12, 90, 12, "Action:" },
  { "klabel", "key_mic", 440, 24, 90, 12, "Microphone:" },
  { "klabel", "key_map", 440, 36, 90, 12, "Auto Map:" } }
HMenu.menus["key_" .. HMode.panel] = HMenu.menus["key_" .. HMode.attribute]
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
                               math.floor(x), math.floor(y + h/2 - HGlobals.fheight/2),
                               colors.menu_label)
    elseif item[1] == "klabel" then
      local fw, fh = HGlobals.fontn:measure_text(item[7])
      local state = HMenu.button_state(item[2])
      HGlobals.fontn:draw_text(item[7],
                               math.floor(x + w - fw), math.floor(y + h/2 - HGlobals.fheight/2),
                               colors.commands[state].label)
    elseif item[1] == "kaction" then
      local state = HMenu.button_state(item[2])
      HGlobals.fontn:draw_text(item[7],
                               math.floor(x), math.floor(y + h/2 - HGlobals.fheight/2),
                               colors.commands[state].key)
    elseif item[1] == "texture" or item[1] == "dtexture" then
      local cc, ct = string.match(item[2], "(%d+)_(%d+)")
      local state = "enabled"
      if item[1] == "texture" then state = HMenu.button_state(item[2]) end
      if state == "active" then
        Screen.frame_rect(x - menu_prefs.button_indent*u,
                          y - menu_prefs.button_indent*u,
                          w + 2*menu_prefs.button_indent*u,
                          h + 2*menu_prefs.button_indent*u,
                          colors.current_texture,
                          2*menu_prefs.button_indent*u)
      end
      local xt = x
      local yt = y
      local wt = w
      if item[1] == "texture" then
        xt = xt + menu_prefs.texture_choose_indent*u
        yt = yt + menu_prefs.texture_choose_indent*u
        wt = wt - 2*menu_prefs.texture_choose_indent*u
      else
        xt = xt + menu_prefs.texture_preview_indent*u
        yt = yt + menu_prefs.texture_preview_indent*u
        wt = wt - 2*menu_prefs.texture_preview_indent*u
      end
      HCollections.draw(cc + 0, ct + 0, xt, yt, wt)
    elseif item[1] == "light" then
      local state = HMenu.button_state(item[2])
    
      local xt = x + menu_prefs.button_indent*u
      local yt = y + menu_prefs.button_indent*u
      local wt = w - 2*menu_prefs.button_indent*u
      local ht = h - 2*menu_prefs.button_indent*u
      
      local clr = colors.noncurrent_light
      if state == "active" then clr = colors.current_light end
      Screen.frame_rect(xt + wt - ht, yt, ht, ht, clr, menu_prefs.light_thickness*u)
      
      local val = HLights.val(tonumber(string.sub(item[2], 7)))
      local sz = ht - 2*menu_prefs.light_thickness*u
      Screen.fill_rect(xt + wt - ht + menu_prefs.light_thickness*u,
                       yt + menu_prefs.light_thickness*u,
                       sz, sz, { val, val, val, 1 })

      local fw, fh = HGlobals.fontn:measure_text(item[7])
      local yh = yt + ht/2 - fh/2
      local xh = xt + wt - ht - 5*u - fw
      HGlobals.fontn:draw_text(item[7], xh, yh, clr)
    
    elseif HMenu.clickable(item[1]) then
--       if HStatus.current_menu_item == idx then
--         Screen.frame_rect(x - menu_prefs.button_indent*u,
--                           y - menu_prefs.button_indent*u,
--                           w + 2*menu_prefs.button_indent*u,
--                           h + 2*menu_prefs.button_indent*u,
--                           colors.current_button,
--                           2*menu_prefs.button_indent*u)
--       end
      
      local state = HMenu.button_state(item[2])
      HMenu.draw_button_background(item, state)
      
      local xo = 7
      if item[1] == "checkbox" or item[1] == "radio" then
        xo = 17
      elseif item[1] == "light" then
        local fw, fh = HGlobals.fontn:measure_text(item[7])
        xo = item[5] - 7 - fw/u
      elseif item[1] == "dbutton" then
        local fw, fh = HGlobals.fontn:measure_text(item[7])
        xo = (w/u - fw/u)/2         
      end
      HMenu.draw_button_text(item, state, xo)
        
      if item[1] == "checkbox" or item[1] == "radio" then
        local nm = "dcheck"
        if item[1] == "radio" then
          nm = "dradio"
        end
        if state == "enabled" then
          nm = nm .. "_off"
        elseif state == "disabled" then
          nm = nm .. "_dis"
        elseif state == "active" then
          nm = nm .. "_on"
        end
        
        local img = imgs[nm]
        if img then
          local x = HGlobals.xoff + item[3]*u + menu_prefs.button_indent*u
          local y = HGlobals.yoff + item[4]*u + menu_prefs.button_indent*u
          local h = item[6]*u - 2*menu_prefs.button_indent*u
          img:draw(x + 4*u, y + h/2 - img.height/2)
        end
      elseif item[1] == "light" then
        local val = HLights.val(tonumber(string.sub(item[2], 7)))
        Screen.fill_rect(x + 2*u, y + 2*u, h - 4*u, h - 4*u, { val, val, val, 1 })
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
    if HCollections.current_collection == 0 and mode ~= 5 then state = "disabled" end
    if not HApply.down(HApply.use_texture) then state = "disabled" end
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
  elseif string.sub(name, 1, 6) == "pperm_" then
    local mode = tonumber(string.sub(name, 7))
    if HPanel.permutation == mode then state = "active" end
  elseif string.sub(name, 1, 6) == "ptype_" then
    local mode = tonumber(string.sub(name, 7))
    if not HPanel.valid_class(mode) then state = "disabled" end
    if mode == 0 then state = "enabled" end
    if mode == HPanel.current_class then state = "active" end
  elseif name == "panel_light" then
    if HPanel.option_set(1) then state = "active" end
    if not HPanel.valid_option(1) then state = "disabled" end
  elseif name == "panel_weapon" then
    if HPanel.option_set(2) then state = "active" end
    if not HPanel.valid_option(2) then state = "disabled" end
  elseif name == "panel_repair" then
    if HPanel.option_set(3) then state = "active" end
    if not HPanel.valid_option(3) then state = "disabled" end
  elseif name == "panel_active" then
    if HPanel.option_set(4) then state = "active" end
    if not HPanel.valid_option(4) then state = "disabled" end
  elseif string.sub(name, 1, 8) == "key_mic_" then
    state = HKeys.button_state(string.sub(name, 9), true)
  elseif string.sub(name, 1, 4) == "key_" then
    state = HKeys.button_state(string.sub(name, 5), false)
  end
  
  return state
end
function HMenu.draw_button_background(item, state)
  local u = HGlobals.scale
  local x = HGlobals.xoff + item[3]*u + menu_prefs.button_indent*u
  local y = HGlobals.yoff + item[4]*u + menu_prefs.button_indent*u
  local w = item[5]*u - 2*menu_prefs.button_indent*u
  local h = item[6]*u - 2*menu_prefs.button_indent*u
  local th = menu_prefs.button_highlight_thickness*u
  local ts = menu_prefs.button_shadow_thickness*u
  local c = colors.button[state]

  Screen.fill_rect(x, y, w, h, c.background)
  Screen.fill_rect(x, y, w, th, c.highlight)
  Screen.fill_rect(x, y + th, th, h - th, c.highlight)
  Screen.fill_rect(x + th, y + h - ts, w - th, ts, c.shadow)
  Screen.fill_rect(x + w - ts, y + th, ts, h - th - ts, c.shadow)
end
function HMenu.draw_button_text(item, state, xoff)
  local u = HGlobals.scale
  local x = HGlobals.xoff + item[3]*u + menu_prefs.button_indent*u
  local y = HGlobals.yoff + item[4]*u + menu_prefs.button_indent*u
  local h = item[6]*u - 2*menu_prefs.button_indent*u
  
  HGlobals.fontn:draw_text(item[7],
                           math.floor(x + xoff*u),
                           math.floor(y + h/2 - HGlobals.fheight/2),
                           colors.button[state].text)
end

function HMenu.init_menu(mode)
  local menu = HMenu.menus[mode]
  if mode == HMode.attribute then
    if HCounts.num_lights > 0 then
      for i = 1,math.min(HCounts.num_lights, 56) do
        local l = i - 1
        local yoff = (l % 7) * 20
        local xoff = math.floor(l / 7) * 50
        table.insert(menu, 13 + l,
          { "light", "light_" .. l, 200 + xoff, 85 + yoff, 50, 20, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  elseif mode == "panel_light" then
    if HCounts.num_lights > 0 then
      for i = 1,math.min(HCounts.num_lights, 56) do
        local l = i - 1
        local yoff = (l % 7) * 20
        local xoff = math.floor(l / 7) * 50
        table.insert(menu,
          { "light", "pperm_" .. l, 200 + xoff, 145 + yoff, 50, 20, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  elseif mode == "panel_terminal" then
    if HCounts.num_scripts > 0 then
      for i = 1,math.min(HCounts.num_scripts, 80) do
        local l = i - 1
        local yoff = (l % 10) * 20
        local xoff = math.floor(l / 10) * 50
        table.insert(menu,
          { "radio", "pperm_" .. l, 200 + xoff, 145 + yoff, 50, 20, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  elseif mode == "panel_tag" then
    if HCounts.num_tags > 0 then
      for i = 1,math.min(HCounts.num_tags, 80) do
        local l = i - 1
        local yoff = (l % 10) * 20
        local xoff = math.floor(l / 10) * 50
        table.insert(menu,
          { "radio", "pperm_" .. l, 200 + xoff, 145 + yoff, 50, 20, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  elseif mode == "panel_platform" then
    if HCounts.num_platforms > 0 then
      for i = 1,math.min(HCounts.num_platforms, 80) do
        local l = i - 1
        local yoff = (l % 10) * 20
        local xoff = math.floor(l / 10) * 50
        l = HPlatforms.indexes[l]
        table.insert(menu,
          { "radio", "pperm_" .. l, 200 + xoff, 145 + yoff, 50, 20, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  else
    HMenu.inited[mode] = true
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
    if preview_collection_when_applying then
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
          { "texture", "choose_" .. cc .. "_" .. ct, 
            xt, yt, tsize, tsize, cc .. ", " .. ct })
      end
    end
    HMenu.menus["preview_" .. cnum] = preview
  end  

  -- set up collection buttons
  local cbuttons = {}
  if #menu_colls > 0 then
    local n = #menu_colls
    local w = math.floor(600 / n)
    
    local x = 20
    local y = 370
    for i = 1,n do
      local cinfo = menu_colls[i]
      local cnum = cinfo.cnum
      local cname = HCollections.names[cnum + 1]
      table.insert(cbuttons,
        { "dbutton", "coll_" .. cnum, x, y, w, 20, cname })
        
      -- collection preview
      if preview_all_collections then
        local xx = x + menu_prefs.button_indent
        local yy = y + 20 + menu_prefs.button_indent
        local ww = w - 2*menu_prefs.button_indent
        local hh = 75 - 2*menu_prefs.button_indent
        
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
          x, y, tsize, tsize, cc .. ", " .. ct })
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
function HCollections.preview_current(x, y, size)
  local oldx = Screen.clip_rect.x
  local oldy = Screen.clip_rect.y
  local oldw = Screen.clip_rect.width
  local oldh = Screen.clip_rect.height
  Screen.clip_rect.x = x
  Screen.clip_rect.y = y
  Screen.clip_rect.width = size
  Screen.clip_rect.height = size

  local coll = HCollections.current_coll()
  local tex = Player.texture_palette.slots[coll].texture_index

  if HApply.down(HApply.use_texture) then
    if HApply.current_transfer == 4 then
      local xoff = math.random() * math.max(0, img_static.width - size)
      local yoff = math.random() * math.max(0, img_static.height - size)
      img_static:draw(x - xoff, y - yoff)
    else
      local xoff, yoff, sxmult, symult = HCollections.calc_transfer(HApply.current_transfer)
      xoff = xoff * size
      yoff = yoff * size
      local xp = x + xoff
      local yp = y + yoff
      local sx = size * sxmult
      local sy = size * symult
      
      local shp = HCollections.shape(coll, tex)
      if HCollections.is_landscape(coll) or HApply.current_transfer == 5 then
        sx = sx * 2
        sy = sy * 2
      end
      shp:rescale(sx, sy)
      
      local extrax = { { true, xp }, { xoff > 0, xp - sx }, { (xoff + sx) < size, xp + sx } }
      local extray = { { true, yp }, { yoff > 0, yp - sy }, { (yoff + sy) < size, yp + sy } }
      for _,xv in ipairs(extrax) do
        if xv[1] then
          for _,yv in ipairs(extray) do
            if yv[1] then
              shp:draw(xv[2], yv[2])
            end
          end
        end
      end      
    
      if HApply.down(HApply.use_light) and HApply.current_transfer ~= 5 then
        local val = HLights.adj(HApply.current_light)
        Screen.fill_rect(x, y, size, size, { 0, 0, 0, 1 - val })
      end
    end
  elseif HApply.down(HApply.use_light) then 
    local val = HLights.val(HApply.current_light)
    Screen.fill_rect(x, y, size, size, { val, val, val, 1 })
  end
  
  Screen.clip_rect.x = oldx
  Screen.clip_rect.y = oldy
  Screen.clip_rect.width = oldw
  Screen.clip_rect.height = oldh
end
function HCollections.calc_transfer(ttype)
  local x = 0
  local y = 0
  local sx = 1
  local sy = 1
  if ttype == 1 or ttype == 2 or ttype == 3 then
    local phase = Game.ticks
    if ttype == 3 then phase = phase * 15 end
    phase = bit32.band(phase, 63)
    if phase >= 32 then
      phase = 48 - phase
    else
      phase = phase - 16
    end
    if ttype == 1 then
      sx = 1 - (phase - 8) / 1024
      x = (phase - 8) / 2
      sy = sx
      y = x
    else
      sx = 1 + (phase - 8) / 1024
      sy = 1 - (phase - 8) / 1024
      y = (phase - 8) / 2
    end
  elseif ttype > 5 then
    local phase = Game.ticks
    if ttype == 7 or ttype == 9 or ttype == 11 then phase = phase * 2 end
    if ttype == 6 or ttype == 7 then
      x = bit32.band(phase * 4, 1023)
    elseif ttype == 8 or ttype == 9 then
      y = bit32.band(phase * 4, 1023)
    elseif ttype == 10 or ttype == 11 then
      local alt = phase % 5120
      phase = phase % 3072
      x = (math.cos(HCollections.norm_angle(alt)) +
           math.cos(HCollections.norm_angle(2*alt))/2 +
           math.cos(HCollections.norm_angle(5*alt))/2)*256
      y = (math.sin(HCollections.norm_angle(phase)) +
           math.sin(HCollections.norm_angle(2*phase))/2 +
           math.sin(HCollections.norm_angle(3*phase))/2)*256
      while x > 1024 do x = x - 1024 end
      while x < 0 do x = x + 1024 end
      while y < 0 do y = y + 1024 end
    end
  end
  return x/1024, y/1024, sx, sy
end
function HCollections.norm_angle(angle)
  return bit32.band(angle, 511) * 2*math.pi / 512
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
  for i = 1,math.min(HCounts.num_lights, 56) do
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
end

HPanel = {}
HPanel.bitfield_class = 0
HPanel.oxygen = 1
HPanel.x1 = 2
HPanel.x2 = 3
HPanel.x3 = 4
HPanel.light_switch = 5
HPanel.platform_switch = 6
HPanel.tag_switch = 7
HPanel.save = 8
HPanel.terminal = 9
HPanel.chip = 10
HPanel.wires = 11
HPanel.current_class = 0
HPanel.bitfield_option = 0
HPanel.light_dependent = 1
HPanel.weapons_only = 2
HPanel.repair = 3
HPanel.active = 4
HPanel.permutation = 0
function HPanel.update()
  HPanel.bitfield_class = Player.texture_palette.slots[48].texture_index + 128*Player.texture_palette.slots[49].texture_index
  HPanel.current_class = Player.texture_palette.slots[50].texture_index
  HPanel.bitfield_option = Player.texture_palette.slots[51].texture_index
  HPanel.permutation = Player.texture_palette.slots[52].texture_index + 128*Player.texture_palette.slots[53].texture_index
end
function HPanel.valid_class(k)
  return hasbit(HPanel.bitfield_class, k)
end
function HPanel.option_set(k)
  return hasbit(HPanel.bitfield_option, k)
end
function HPanel.valid_option(k)
  if k == HPanel.light_dependent then
    return true
  elseif k == HPanel.weapons_only or k == HPanel.repair then
    return HPanel.current_class == HPanel.light_switch or HPanel.current_class == HPanel.platform_switch or HPanel.current_class == HPanel.tag_switch or HPanel.current_class == HPanel.chip or HPanel.current_class == HPanel.wires
  elseif k == HPanel.active then
    return HPanel.current_class == HPanel.tag_switch or HPanel.current_class == HPanel.chip or HPanel.current_class == HPanel.wires
  end
  return false
end
function HPanel.menu_name()
  local current_class = HPanel.current_class
  if current_class == HPanel.oxygen or current_class == HPanel.x1 or current_class == HPanel.x2 or current_class == HPanel.x3 or current_class == HPanel.save then
    return "panel_plain"
  elseif current_class == HPanel.terminal then
    return "panel_terminal"
  elseif current_class == HPanel.light_switch then
    return "panel_light"
  elseif current_class == HPanel.platform_switch then
    return "panel_platform"
  elseif current_class == HPanel.tag_switch or current_class == HPanel.chip or current_class == HPanel.wires then
    return "panel_tag"
  end
  return "panel_off"
end

