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
colors.menu_label = { 0.7, 0.7, 0.3, 1 }
colors.current_texture = { 0, 1, 0, 1 }

colors.light = {}
colors.light.enabled = {}
colors.light.enabled.frame = { 0.5, 0.5, 0.5, 1 }
colors.light.enabled.text = { 0.5, 0.5, 0.5, 1 }
colors.light.active = {}
colors.light.active.frame = { 0, 1, 0, 1 }
colors.light.active.text = { 0.2, 1.0, 0.2, 1 }

colors.tlight = {}
colors.tlight.enabled = {}
colors.tlight.enabled.frame = { 0.5, 0.5, 0.5, 1 }
colors.tlight.enabled.text = { 1, 1, 1, 1 }
colors.tlight.active = {}
colors.tlight.active.frame = { 0, 1, 0, 1 }
colors.tlight.active.text = { 0.2, 1.0, 0.2, 1 }

colors.commands = {}
colors.commands.enabled = {}
colors.commands.enabled.label = { 0.7, 0.7, 0.3, 1 }
colors.commands.enabled.key = { 1, 1, 1, 1 }
colors.commands.disabled = {}
colors.commands.disabled.label = { 0.4, 0.4, 0.2, 1 }
colors.commands.disabled.key = { 0.5, 0.5, 0.5, 1 }
colors.commands.active = {}
colors.commands.active.label = { 1, 0.15, 0.15, 1 }
colors.commands.active.key = { 1, 0.15, 0.15, 1 }

colors.button = {}
colors.button.enabled = {}
colors.button.enabled.background = { 0.1, 0.1, 0.1, 1 }
colors.button.enabled.highlight = { 0.08, 0.08, 0.08, 1 }
colors.button.enabled.shadow = { 0.12, 0.12, 0.12, 1 }
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
colors.apply.enabled.background = { 0.0, 0.0, 0.0, 1 }
colors.apply.enabled.highlight = { 0.0, 0.0, 0.0, 1 }
colors.apply.enabled.shadow = { 0.0, 0.0, 0.0, 1 }
colors.apply.enabled.text = { 0.5, 0.5, 0.5, 1 }
colors.apply.active = {}
colors.apply.active.background = { 0.0, 0.0, 0.0, 1 }
colors.apply.active.highlight = { 0.0, 0.0, 0.0, 1 }
colors.apply.active.shadow = { 0.0, 0.0, 0.0, 1 }
colors.apply.active.text = { 1, 1, 1, 1 }

colors.ktab = {}
colors.ktab.background = { 0.15, 0.15, 0.15, 1 }
colors.ktab.current = {}
colors.ktab.current.background = { 0.15, 0.15, 0.15, 1 }
colors.ktab.current.text = { 0.2, 1.0, 0.2, 1 }
colors.ktab.current.label = { 0, 0, 0, 0 }
colors.ktab.enabled = {}
colors.ktab.enabled.background = { 0.1, 0.1, 0.1, 1 }
colors.ktab.enabled.text = { 0.8, 0.8, 0.8, 1 }
colors.ktab.enabled.label = { 0.7, 0.7, 0.3, 1 }
colors.ktab.disabled = {}
colors.ktab.disabled.background = { 0.1, 0.1, 0.1, 1 }
colors.ktab.disabled.text = { 0.4, 0.4, 0.4, 1 }
colors.ktab.disabled.label = { 0.4, 0.4, 0.2, 1 }
colors.ktab.active = {}
colors.ktab.active.background = { 0.1, 0.1, 0.1, 1 }
colors.ktab.active.text = { 1, 0.15, 0.15, 1 }
colors.ktab.active.label = { 1, 0.15, 0.15, 1 }

colors.tab = {}
colors.tab.background = { 0.15, 0.15, 0.15, 1 }
colors.tab.enabled = {}
colors.tab.enabled.background = { 0.1, 0.1, 0.1, 1 }
colors.tab.enabled.text = { 0.8, 0.8, 0.8, 1 }
colors.tab.disabled = {}
colors.tab.disabled.background = { 0.1, 0.1, 0.1, 1 }
colors.tab.disabled.text = { 0.4, 0.4, 0.4, 1 }
colors.tab.active = {}
colors.tab.active.background = { 0.15, 0.15, 0.15, 1 }
colors.tab.active.text = { 0.2, 1.0, 0.2, 1 }

colors.tbutton = {}
colors.tbutton.enabled = {}
colors.tbutton.enabled.background = { 0.15, 0.15, 0.15, 1 }
colors.tbutton.enabled.highlight = { 0.13, 0.13, 0.13, 1 }
colors.tbutton.enabled.shadow = { 0.17, 0.17, 0.17, 1 }
colors.tbutton.enabled.text = { 0.8, 0.8, 0.8, 1 }
colors.tbutton.disabled = {}
colors.tbutton.disabled.background = { 0.0, 0.0, 0.0, 0 }
colors.tbutton.disabled.highlight = { 0.0, 0.0, 0.0, 0 }
colors.tbutton.disabled.shadow = { 0.0, 0.0, 0.0, 0 }
colors.tbutton.disabled.text = { 0.5, 0.5, 0.5, 1 }
colors.tbutton.active = {}
colors.tbutton.active.background = { 0.3, 0.3, 0.3, 1 }
colors.tbutton.active.highlight = { 0.35, 0.35, 0.35, 1 }
colors.tbutton.active.shadow = { 0.25, 0.25, 0.25, 1 }
colors.tbutton.active.text = { 0.2, 1.0, 0.2, 1 }


-- other menu UI prefs
menu_prefs = {}
menu_prefs.button_indent = 1
menu_prefs.button_highlight_thickness = 2
menu_prefs.button_shadow_thickness = 2
menu_prefs.texture_choose_indent = 1
menu_prefs.texture_apply_indent = 0.5
menu_prefs.texture_preview_indent = 0
menu_prefs.light_thickness = 2


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
  HPanel.update()
  
  if HMode.changed then layout() end

  -- keys
  HMenu.draw_menu("key_" .. HMode.current, true)
  
  -- teleport notices
  if HMode.is(HMode.teleport) then
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
    end
  end
  
  -- lower area
  if HMode.is(HMode.apply) then
    local xp = HGlobals.xoff + 20*HGlobals.scale
    local yp = HGlobals.yoff + (320+72)*HGlobals.scale
    
    -- lower left: current texture, attributes
    local lbls = HMenu.menus["apply_options"]
    lbls[1][7] = "Apply Light: " .. HApply.current_light    

    local att = "Apply Texture"
    local tmode = HApply.transfer_modes[HApply.current_transfer + 1]
    if HCollections.current_collection == 0 then
      if HApply.current_transfer == 5 then tmode = nil end
    else
      if HApply.current_transfer == 0 then tmode = nil end
    end
    if tmode ~= nil then
      att = att .. ": " .. tmode
    end
    lbls[2][7] = att

    lbls[6][7] = "Snap to grid: " .. HApply.snap_modes[HApply.current_snap + 1]

    HMenu.draw_menu("apply_options", true)
    
    -- lower right: full collection
    HMenu.draw_menu("preview_" .. HCollections.current_collection, true)
  end
  
  -- cursor
  draw_cursor()
  
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

function draw_cursor()
  local cname = "menu"
  if HMode.is(HMode.apply) then
    cname = "apply"
  elseif HMode.is(HMode.teleport) then
    cname = "teleport"
  end
  if HKeys.down(HKeys.primary) and (not HKeys.down(HKeys.mic)) then
    cname = cname .. "_down"
  end

  local x = (HStatus.cursor_x*HGlobals.scale) + HGlobals.xoff
  local y = (HStatus.cursor_y*HGlobals.scale) + HGlobals.yoff
  imgs["cursor_" .. cname]:draw(x - HGlobals.coff[1], y - HGlobals.coff[2])
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
  local header = 72
  
  Screen.clip_rect.x = x
  Screen.clip_rect.y = y
  Screen.clip_rect.width = w
  Screen.clip_rect.height = h
  
  y = y + header*HGlobals.scale
  h = math.floor(w / 2)
  
  Screen.term_rect.x = x
  Screen.term_rect.y = y
  Screen.term_rect.width = w
  Screen.term_rect.height = h
  
  local halfh = math.floor((480 - header)*HGlobals.scale/2)
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
  elseif k == HKeys.action and (HMode.is(HMode.apply) or HMode.is(HMode.teleport)) and HStatus.down(HStatus.action_active) then
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
      lbls[2][7] = "Apply Light + Texture"
    else
      lbls[2][7] = "Apply Texture"
    end
  elseif HApply.down(HApply.use_light) then
    lbls[2][7] = "Apply Light"
  else
    lbls[2][7] = "Move Texture"
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
HStatus.cursor_x = 0
HStatus.cursor_y = 0
function HStatus.update()
  HStatus.bitfield = Player.texture_palette.slots[41].texture_index
  HStatus.current_menu_item = Player.texture_palette.slots[47].texture_index
  HStatus.cursor_x = Player.texture_palette.slots[54].texture_index + 128*Player.texture_palette.slots[55].texture_index
  HStatus.cursor_y = Player.texture_palette.slots[56].texture_index + 128*Player.texture_palette.slots[57].texture_index
  
  local lbls = HMenu.menus["key_" .. HMode.apply]
  local lbls2 = HMenu.menus["key_" .. HMode.teleport]
  
  if HStatus.down(HStatus.frozen) then
    lbls[9][7] = "Unfreeze"
    lbls2[9][7] = "Unfreeze"
  else
    lbls[9][7] = "Freeze"
    lbls2[9][7] = "Freeze"
  end
  
  if HStatus.down(HStatus.undo_active) then
    lbls[6][7] = "Undo"
  else
    lbls[6][7] = "(Can't Undo)"
  end
  if HStatus.down(HStatus.redo_active) then
    lbls[7][7] = "Redo"
  else
    lbls[7][7] = "(Can't Redo)"
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
  { "tab_bg", nil, 20, 80, 600, 320, nil },
  { "label", nil, 30+5, 85, 155, 20, "Attributes" },
  { "tcheckbox", "apply_light", 30, 105, 155, 20, "Apply light" },
  { "tcheckbox", "apply_tex", 30, 125, 155, 20, "Apply texture" },
  { "tcheckbox", "apply_align", 30, 145, 155, 20, "Align adjacent" },
  { "tcheckbox", "apply_edit", 30, 165, 155, 20, "Edit switches and panels" },
  { "tcheckbox", "apply_xparent", 30, 185, 155, 20, "Edit transparent sides" },
  { "label", "nil", 30+5, 250, 155, 20, "Snap to grid" },
  { "tradio", "snap_0", 30, 270, 155, 20, "Off" },
  { "tradio", "snap_1", 30, 290, 155, 20, "1/4 WU" },
  { "tradio", "snap_2", 30, 310, 155, 20, "1/5 WU" },
  { "tradio", "snap_3", 30, 330, 155, 20, "1/8 WU" },
  { "label", nil, 215+5, 85, 240, 20, "Light" },
  { "label", nil, 215+5, 250, 240, 20, "Texture mode" },
  { "tradio", "transfer_0", 215, 270, 120, 20, "Normal" },
  { "tradio", "transfer_1", 215, 290, 120, 20, "Pulsate" },
  { "tradio", "transfer_2", 215, 310, 120, 20, "Wobble" },
  { "tradio", "transfer_6", 215, 330, 120, 20, "Horizontal slide" },
  { "tradio", "transfer_8", 215, 350, 120, 20, "Vertical slide" },
  { "tradio", "transfer_10", 215, 370, 120, 20, "Wander" },
  { "tradio", "transfer_5", 335, 270, 120, 20, "Landscape" },
  { "tradio", "transfer_4", 335, 290, 120, 20, "Static" },
  { "tradio", "transfer_3", 335, 310, 120, 20, "Fast wobble" },
  { "tradio", "transfer_7", 335, 330, 120, 20, "Fast horizontal slide" },
  { "tradio", "transfer_9", 335, 350, 120, 20, "Fast vertical slide" },
  { "tradio", "transfer_11", 335, 370, 120, 20, "Fast wander" },
  { "label", nil, 485, 250, 120, 20, "Preview" },
  { "applypreview", nil, 485, 270, 120, 120, nil } }
HMenu.menus["apply_options"] = {
  { "acheckbox", "apply_light", 110, 394, 155, 14, "Apply light" },
  { "acheckbox", "apply_tex", 110, 408, 155, 14, "Apply texture" },
  { "acheckbox", "apply_align", 110, 422, 155, 14, "Align adjacent" },
  { "acheckbox", "apply_edit", 110, 436, 155, 14, "Edit switches and panels" },
  { "acheckbox", "apply_xparent", 110, 450, 155, 14, "Edit transparent sides" },
  { "acheckbox", "apply_snap", 110, 464, 155, 14, "Snap to grid" },
  { "applypreview", nil, 20, 394, 84, 84, nil } }
HMenu.menus["panel_off"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 90, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 110, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 130, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 150, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 170, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 200, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 220, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 240, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 260, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 290, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 310, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 340, 130, 20, "Inactive" } }
HMenu.menus["panel_plain"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 90, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 110, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 130, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 150, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 170, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 200, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 220, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 240, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 260, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 290, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 310, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 340, 130, 20, "Inactive" },
  { "tcheckbox", "panel_light", 160, 90, 150, 20, "Light dependent" } }
HMenu.menus["panel_terminal"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 90, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 110, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 130, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 150, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 170, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 200, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 220, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 240, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 260, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 290, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 310, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 340, 130, 20, "Inactive" },
  { "tcheckbox", "panel_light", 160, 90, 150, 20, "Light dependent" },
  { "label", nil, 160+5, 130, 150, 20, "Terminal script" } }
 HMenu.menus["panel_light"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 90, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 110, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 130, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 150, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 170, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 200, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 220, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 240, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 260, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 290, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 310, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 340, 130, 20, "Inactive" },
  { "tcheckbox", "panel_light", 160, 90, 150, 20, "Light dependent" },
  { "tcheckbox", "panel_weapon", 160, 110, 150, 20, "Only toggled by weapons" },
  { "tcheckbox", "panel_repair", 160, 130, 150, 20, "Repair switch" },
  { "label", nil, 160+5, 170, 150, 20, "Light" } }
 HMenu.menus["panel_platform"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 90, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 110, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 130, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 150, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 170, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 200, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 220, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 240, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 260, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 290, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 310, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 340, 130, 20, "Inactive" },
  { "tcheckbox", "panel_light", 160, 90, 150, 20, "Light dependent" },
  { "tcheckbox", "panel_weapon", 160, 110, 150, 20, "Only toggled by weapons" },
  { "tcheckbox", "panel_repair", 160, 130, 150, 20, "Repair switch" },
  { "label", nil, 160+5, 170, 150, 20, "Platform" } }
 HMenu.menus["panel_tag"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 90, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 110, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 130, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 150, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 170, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 200, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 220, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 240, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 260, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 290, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 310, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 340, 130, 20, "Inactive" },
  { "tcheckbox", "panel_light", 160, 90, 150, 20, "Light dependent" },
  { "tcheckbox", "panel_weapon", 160, 110, 150, 20, "Only toggled by weapons" },
  { "tcheckbox", "panel_repair", 160, 130, 150, 20, "Repair switch" },
  { "tcheckbox", "panel_active", 210, 170, 100, 20, "Tag is active" },
  { "label", nil, 160+5, 170, 50-18, 20, "Tag" } }
HMenu.menus["key_" .. HMode.apply] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Apply Texture" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Sample Light + Texture" },
  { "kaction", "key_prev_weapon", 235, 38, 100, 12, "Previous Light" },
  { "kaction", "key_next_weapon", 235, 50, 100, 12, "Next Light" },
  { "kaction", "key_mic_primary", 475, 10, 100, 12, "Undo" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Redo" },
  { "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Jump" },
  { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Freeze" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_prev_weapon", 180, 38, 50, 12, "Prev Weapon" },
  { "klabel", "key_next_weapon", 180, 50, 50, 12, "Next Weapon" },
  { "klabel", "key_mic_primary", 400, 10, 70, 12, "Mic + Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Mic + Trigger 2" },
  { "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Mic + Prev Weapon" },
  { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Mic + Next Weapon" },
  { "ktab", nil, 20, 4, 130, 16, "Visual Mode" },
  { "ktab", "key_action", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_mic", 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
HMenu.menus["key_" .. HMode.teleport] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Teleport" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_prev_weapon", 235, 38, 100, 12, "Previous Polygon" },
  { "kaction", "key_next_weapon", 235, 50, 100, 12, "Next Polygon" },
  { "kaction", "key_mic_primary", 475, 10, 100, 12, "Rewind Polygon" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Fast Forward Polygon" },
  { "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Jump" },
  { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Freeze" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_prev_weapon", 180, 38, 50, 12, "Prev Weapon" },
  { "klabel", "key_next_weapon", 180, 50, 50, 12, "Next Weapon" },
  { "klabel", "key_mic_primary", 400, 10, 70, 12, "Mic + Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Mic + Trigger 2" },
  { "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Mic + Prev Weapon" },
  { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Mic + Next Weapon" },
  { "ktab", "key_map", 20, 4, 130, 16, "Visual Mode" },
  { "ktab", "key_action", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_mic", 20, 36, 130, 16, "Options" },
  { "ktab", nil, 20, 52, 130, 16, "Teleport" } }
HMenu.menus["key_" .. HMode.choose] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Select Texture" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_prev_weapon", 235, 38, 100, 12, "Previous Collection" },
  { "kaction", "key_next_weapon", 235, 50, 100, 12, "Next Collection" },
  { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Cycle Collections" },
  { "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Previous Texture" },
  { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Texture" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_prev_weapon", 180, 38, 50, 12, "Prev Weapon" },
  { "klabel", "key_next_weapon", 180, 50, 50, 12, "Next Weapon" },
  { "klabel", "key_mic_primary", 400, 10, 70, 12, "Mic + Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Mic + Trigger 2" },
  { "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Mic + Prev Weapon" },
  { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Mic + Next Weapon" },
  { "ktab", "key_action", 20, 4, 130, 16, "Visual Mode" },
  { "ktab", nil, 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_mic", 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
HMenu.menus["key_" .. HMode.attribute] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_prev_weapon", 235, 38, 100, 12, "Previous Option" },
  { "kaction", "key_next_weapon", 235, 50, 100, 12, "Next Option" },
--   { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
--   { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Cycle Collections" },
--   { "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Previous Texture" },
--   { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Texture" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_prev_weapon", 180, 38, 50, 12, "Prev Weapon" },
  { "klabel", "key_next_weapon", 180, 50, 50, 12, "Next Weapon" },
--   { "klabel", "key_mic_primary", 400, 10, 70, 12, "Mic + Trigger 1" },
--   { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Mic + Trigger 2" },
--   { "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Mic + Prev Weapon" },
--   { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Mic + Next Weapon" },
  { "ktab", "key_mic", 20, 4, 130, 16, "Visual Mode" },
  { "ktab", "key_action", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", nil, 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
HMenu.menus["key_" .. HMode.panel] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_prev_weapon", 235, 38, 100, 12, "Previous Option" },
  { "kaction", "key_next_weapon", 235, 50, 100, 12, "Next Option" },
--   { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
--   { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Cycle Collections" },
--   { "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Previous Texture" },
--   { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Texture" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_prev_weapon", 180, 38, 50, 12, "Prev Weapon" },
  { "klabel", "key_next_weapon", 180, 50, 50, 12, "Next Weapon" },
--   { "klabel", "key_mic_primary", 400, 10, 70, 12, "Mic + Trigger 1" },
--   { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Mic + Trigger 2" },
--   { "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Mic + Prev Weapon" },
--   { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Mic + Next Weapon" },
  { "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
  { "ktab", "key_action", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_mic", 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
HMenu.inited = {}
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
    elseif item[1] == "ktab_bg" then
      Screen.fill_rect(x, y, w, h, colors.ktab.background)
    elseif item[1] == "ktab" then
      local state = "current"
      local label = nil
      if item[2] ~= nil then
        state = HMenu.button_state(item[2])
        if item[2] == "key_action" then
          label = "Act"
          if state == "active" then state = "enabled" end
        elseif item[2] == "key_map" then
          label = "Map"
          if state == "active" then state = "enabled" end
        elseif item[2] == "key_mic" then
          label = "Mic"
        end
      end
              
      Screen.fill_rect(x + menu_prefs.button_indent*u,
                       y + menu_prefs.button_indent*u,
                       w - 1*menu_prefs.button_indent*u,
                       h - 2*menu_prefs.button_indent*u,
                          colors.ktab[state].background)
      HGlobals.fontn:draw_text(item[7],
                               math.floor(x + 30*u),
                               math.floor(y + h/2 - HGlobals.fheight/2),
                               colors.ktab[state].text)
      if label then
        local fw, fh = HGlobals.fontn:measure_text(label)
        HGlobals.fontn:draw_text(label,
                                 math.floor(x + 25*u - fw),
                                 math.floor(y + h/2 - fh/2),
                                 colors.ktab[state].label)
      end
    elseif item[1] == "tab_bg" then
      Screen.fill_rect(x, y, w, h, colors.tab.background)
    elseif item[1] == "tab" then
      local state = HMenu.button_state(item[2])
              
      Screen.fill_rect(x + menu_prefs.button_indent*u,
                       y + menu_prefs.button_indent*u,
                       w - 1*menu_prefs.button_indent*u,
                       h - 2*menu_prefs.button_indent*u,
                          colors.tab[state].background)
      HGlobals.fontn:draw_text(item[7],
                               math.floor(x + 7*u),
                               math.floor(y + h/2 - HGlobals.fheight/2),
                               colors.tab[state].text)
    elseif item[1] == "texture" or item[1] == "atexture" or item[1] == "dtexture" then
      local cc, ct = string.match(item[2], "(%d+)_(%d+)")
      local indent = menu_prefs.texture_preview_indent
      local state = "enabled"
      
      if item[1] == "texture" then
        state = HMenu.button_state(item[2])
        indent = menu_prefs.texture_choose_indent
      elseif item[1] == "atexture" then
        state = HMenu.button_state(item[2])
        indent = menu_prefs.texture_apply_indent
      end

      if state == "active" then
        Screen.frame_rect(x - indent*u,
                          y - indent*u,
                          w + 2*indent*u,
                          h + 2*indent*u,
                          colors.current_texture,
                          2*indent*u)
      end
      local xt = x + indent*u
      local yt = y + indent*u
      local wt = w - 2*indent*u
      HCollections.draw(cc + 0, ct + 0, xt, yt, wt)
    elseif item[1] == "applypreview" then
      HCollections.preview_current(x, y, w)
    elseif item[1] == "light" or item[1] == "tlight" then
      local state = HMenu.button_state(item[2])
    
      local xt = x + menu_prefs.button_indent*u
      local yt = y + menu_prefs.button_indent*u
      local wt = w - 2*menu_prefs.button_indent*u
      local ht = h - 2*menu_prefs.button_indent*u
      
      local c = colors.light[state]
      if item[1] == "tlight" then c = colors.tlight[state] end
      Screen.frame_rect(xt + wt - ht, yt, ht, ht, c.frame, menu_prefs.light_thickness*u)
      
      local val = HLights.val(tonumber(string.sub(item[2], 7)))
      local sz = ht - 2*menu_prefs.light_thickness*u
      Screen.fill_rect(xt + wt - ht + menu_prefs.light_thickness*u,
                       yt + menu_prefs.light_thickness*u,
                       sz, sz, { val, val, val, 1 })

      local fw, fh = HGlobals.fontn:measure_text(item[7])
      local yh = yt + ht/2 - fh/2
      local xh = xt + wt - ht - 5*u - fw
      HGlobals.fontn:draw_text(item[7], xh, yh, c.text)
    
    elseif HMenu.clickable(item[1]) then
      local state = HMenu.button_state(item[2])
      HMenu.draw_button_background(item, state)
      
      local xo = 7
      if item[1] == "checkbox" or item[1] == "acheckbox" or item[1] == "tcheckbox" or item[1] == "radio" or item[1] == "tradio" then
        xo = 17
      elseif item[1] == "light" or item[1] == "tlight" then
        local fw, fh = HGlobals.fontn:measure_text(item[7])
        xo = item[5] - 7 - fw/u
      elseif item[1] == "dbutton" then
        local fw, fh = HGlobals.fontn:measure_text(item[7])
        xo = (w/u - fw/u)/2         
      end
      HMenu.draw_button_text(item, state, xo)
        
      if item[1] == "checkbox" or item[1] == "acheckbox" or item[1] == "tcheckbox" or item[1] == "radio" or item[1] == "tradio" then
        local nm = "dcheck"
        if item[1] == "radio" or item[1] == "tradio" then
          nm = "dradio"
        elseif item[1] == "acheckbox" then
          nm = "fcheck"
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
      elseif item[1] == "light" or item[1] == "tlight" then
        local val = HLights.val(tonumber(string.sub(item[2], 7)))
        Screen.fill_rect(x + 2*u, y + 2*u, h - 4*u, h - 4*u, { val, val, val, 1 })
      end
    end
  end
end
function HMenu.button_state(name)
  local state = "enabled"
  
  if name == "enabled" then
    state = "enabled"
  elseif name == "active" then
    state = "active"
  elseif name == "disabled" then
    state = "disabled"
  elseif name == "apply_tex" then
    if HApply.down(HApply.use_texture) then state = "active" end
  elseif name == "apply_light" then
    if HApply.down(HApply.use_light) then state = "active" end
  elseif name == "apply_align" then
    if HApply.down(HApply.align) then state = "active" end
  elseif name == "apply_xparent" then
    if HApply.down(HApply.transparent) then state = "active" end
  elseif name == "apply_edit" then
    if HApply.down(HApply.edit_panels) then state = "active" end
  elseif name == "apply_snap" then
    if HApply.current_snap > 0 then state = "active" end
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
  if item[1] == "acheckbox" then c = colors.apply[state] end
  if item[1] == "tcheckbox" or item[1] == "tradio" then c = colors.tbutton[state] end

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
  local c = colors.button[state]
  if item[1] == "acheckbox" then c = colors.apply[state] end
  if item[1] == "tcheckbox" or item[1] == "tradio" then c = colors.tbutton[state] end

  HGlobals.fontn:draw_text(item[7],
                           math.floor(x + xoff*u),
                           math.floor(y + h/2 - HGlobals.fheight/2),
                           c.text)
end

function HMenu.init_menu(mode)
  local menu = HMenu.menus[mode]
  if mode == HMode.attribute then
    if HCounts.num_lights > 0 then
      for i = 1,math.min(HCounts.num_lights, 56) do
        local l = i - 1
        local yoff = (l % 7) * 20
        local xoff = math.floor(l / 7) * 50
        local w = 50
        if xoff == 0 then
          w = w - 13
        else
          xoff = xoff - 13
        end
        table.insert(menu, 14 + l,
          { "tlight", "light_" .. l, 215 + xoff, 105 + yoff, w, 20, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  elseif mode == "panel_light" then
    if HCounts.num_lights > 0 then
      for i = 1,math.min(HCounts.num_lights, 63) do
        local l = i - 1
        local yoff = (l % 7) * 20
        local xoff = math.floor(l / 7) * 50
        local w = 50
        if xoff == 0 then
          w = w - 13
        else
          xoff = xoff - 13
        end
        table.insert(menu,
          { "tlight", "pperm_" .. l, 160 + xoff, 190 + yoff, w, 20, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  elseif mode == "panel_terminal" then
    if HCounts.num_scripts > 0 then
      for i = 1,math.min(HCounts.num_scripts, 90) do
        local l = i - 1
        local yoff = (l % 10) * 20
        local xoff = math.floor(l / 10) * 50
        table.insert(menu,
          { "tradio", "pperm_" .. l, 160 + xoff, 150 + yoff, 50, 20, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  elseif mode == "panel_tag" then
    if HCounts.num_tags > 0 then
      for i = 1,math.min(HCounts.num_tags, 90) do
        local l = i - 1
        local yoff = (l % 10) * 20
        local xoff = math.floor(l / 10) * 50
        table.insert(menu,
          { "tradio", "pperm_" .. l, 160 + xoff, 190 + yoff, 50, 20, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  elseif mode == "panel_platform" then
    if HCounts.num_platforms > 0 then
      for i = 1,math.min(HCounts.num_platforms, 90) do
        local l = i - 1
        local yoff = (l % 10) * 20
        local xoff = math.floor(l / 10) * 50
        l = HPlatforms.indexes[l]
        table.insert(menu,
          { "tradio", "pperm_" .. l, 160 + xoff, 190 + yoff, 50, 20, tostring(l) })
      end
      HMenu.inited[mode] = true
    end
  else
    HMenu.inited[mode] = true
  end
end
function HMenu.clickable(item_type)
  return item_type == "button" or item_type == "checkbox" or item_type == "radio" or item_type == "texture" or item_type == "atexture" or item_type == "light" or item_type == "dradio" or item_type == "dbutton" or item_type == "acheckbox" or item_type == "tab" or item_type == "tradio" or item_type == "tcheckbox" or item_type == "tlight"
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
      local w = 168
      local h = 84
      local tsize = math.min(w / cols, h / rows)
      local x = 620 - (tsize * cols)
      local y = 480 - 88/2 - (tsize * rows)/2
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
          { "atexture", "choose_" .. cc .. "_" .. ct, 
            xt, yt, tsize, tsize, cc .. ", " .. ct })
      end
    end
    HMenu.menus["preview_" .. cnum] = preview
  end  

  -- set up collection buttons
  local cbuttons = {}
  if #menu_colls > 0 then
    local n = #menu_colls
    local w = 600 / n
    
    local x = 20
    local y = 380
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
      local y = 80 + (tsize * row) + (300 - (tsize * rows))/2
      
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

