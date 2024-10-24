-- Vasara 1.1.1 (HUD script)
-- by Hopper and Ares Ex Machina

-- PREFERENCES

-- colors (RGBA, 0 to 1)
colors = {}
colors.menu_label = { 0.7, 0.7, 0.3, 1 }
colors.current_texture = { 0, 1, 0, 1 }
colors.snap_grid = { 0, 1, 0, 0.6 }

colors.light = {}
colors.light.enabled = {}
colors.light.enabled.frame = { 0.5, 0.5, 0.5, 1 }
colors.light.enabled.text = { 0.8, 0.8, 0.8, 1 }
colors.light.active = {}
colors.light.active.frame = { 0, 1, 0, 1 }
colors.light.active.text = { 0.2, 1.0, 0.2, 1 }

colors.commands = {}
colors.commands.enabled = {}
colors.commands.enabled.label = { 0.7, 0.7, 0.3, 1 }
colors.commands.enabled.key = { 1, 1, 1, 1 }
colors.commands.disabled = {}
colors.commands.disabled.label = { 0.4, 0.4, 0.2, 1 }
colors.commands.disabled.key = { 0.5, 0.5, 0.5, 1 }
colors.commands.active = {}
colors.commands.active.label = { 0.2, 1.0, 0.2, 1 }
colors.commands.active.key = { 0.2, 1.0, 0.2, 1 }

colors.button = {}
colors.button.enabled = {}
colors.button.enabled.background = { 0.1, 0.1, 0.1, 1 }
colors.button.enabled.highlight = { 0.08, 0.08, 0.08, 1 }
colors.button.enabled.shadow = { 0.12, 0.12, 0.12, 1 }
colors.button.enabled.text = { 0.8, 0.8, 0.8, 1 }
colors.button.disabled = {}
colors.button.disabled.background = { 0.1, 0.1, 0.1, 1 }
colors.button.disabled.highlight = { 0.08, 0.08, 0.08, 1 }
colors.button.disabled.shadow = { 0.12, 0.12, 0.12, 1 }
colors.button.disabled.text = { 0.4, 0.4, 0.4, 1 }
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

colors.teleport = {}
colors.teleport.poly_background = { 0.0, 0.0, 0.0, 0.6 }
colors.teleport.poly_text = { 1, 1, 1, 1 }
colors.teleport.poly_text_active = { 0.2, 1, 0.2, 1 }

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
colors.ktab.active.text = { 0.2, 1.0, 0.2, 1 }
colors.ktab.active.label = { 0.2, 1.0, 0.2, 1 }

colors.tab = {}
colors.tab.background = { 0.1, 0.1, 0.1, 1 }
colors.tab.enabled = {}
colors.tab.enabled.background = { 0.06, 0.06, 0.06, 1 }
colors.tab.enabled.text = { 0.8, 0.8, 0.8, 1 }
colors.tab.disabled = {}
colors.tab.disabled.background = { 0.06, 0.06, 0.06, 1 }
colors.tab.disabled.text = { 0.4, 0.4, 0.4, 1 }
colors.tab.active = {}
colors.tab.active.background = { 0.1, 0.1, 0.1, 1 }
colors.tab.active.text = { 0.2, 1.0, 0.2, 1 }


-- other menu UI prefs
menu_prefs = {}

menu_prefs.button_indent = 1
menu_prefs.button_highlight_thickness = 2
menu_prefs.button_shadow_thickness = 2

menu_prefs.tab_indent = {}
menu_prefs.tab_indent.top = menu_prefs.button_indent
menu_prefs.tab_indent.bottom = menu_prefs.button_indent
menu_prefs.tab_indent.left = 0
menu_prefs.tab_indent.right = 2*menu_prefs.button_indent
menu_prefs.tab_indent.band_left = 7

menu_prefs.texture_choose_indent = 1
menu_prefs.texture_apply_indent = 0.5
menu_prefs.texture_preview_indent = 0

menu_prefs.light_thickness = 2

menu_prefs.preview = {}
menu_prefs.preview.apply = {}
menu_prefs.preview.apply.light_border = 2
menu_prefs.preview.apply.snap_grid = 0
menu_prefs.preview.attribute = {}
menu_prefs.preview.attribute.light_border = 4
menu_prefs.preview.attribute.snap_grid = 1


-- END PREFERENCES -- no user serviceable parts below ;)

Triggers = {}

g_scriptChecked = false
g_initMode = 0

snap_denominators = { 2, 3, 4, 5, 8 }

HStash = {}

function Triggers.draw()
  -- print "q"

  local rawData = Level.stash["Vasara"]
  -- print "qa"
  if not rawData then
    error "Vasara HUD requires Vasara Script"
    return
  end
  -- print "qb"
  -- print(rawData)
  HStash = Game.deserialize(rawData)
--   print "qc"
-- 
--   print "a"
-- 
  HMenu.menus = Game.deserialize(Level.stash["Vasara_menus"])

  -- print "b"

  if g_initMode < 2 then
    if g_initMode == 1 then
      HCollections.update()
      HMenu.draw_menu("choose_" .. HStash.collections.current_collection)
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

  -- print "c"

  HMode.update()
  HCollections.update()

  -- print "d"

  if HMode.changed then layout() end

  -- print "e"

  -- teleport notices
  if HMode.is(HMode.teleport) then
    local yp = HGlobals.cpos[2]
    local xp = HGlobals.cpos[1]

    local fw, fh = HGlobals.fontn:measure_text(HStash.target_poly)
    local xf = xp - fw/2
    local yf = yp - fh - 15*HGlobals.scale
    Screen.fill_rect(xf - 5*HGlobals.scale, yf, fw + 10*HGlobals.scale, fh, colors.teleport.poly_background)
    local clr = colors.teleport.poly_text
    if (not HStash.keys.mic.highlight) and HStash.keys.primary.highlight then
      clr = colors.teleport.poly_text_active
    end
    HGlobals.fontn:draw_text(HStash.target_poly, xf, yf, clr)

    if not Screen.map_overlay_active then
      HGlobals.fontn:draw_text("Please turn on Overlay Map mode in Graphics preferences",
        Screen.world_rect.x + 10*HGlobals.scale,
        Screen.world_rect.y + Screen.world_rect.height - 2*HGlobals.fheight,
        { 0, 1, 0, 1 })
    end
  end

  -- print "g"

  -- menus
  if HStash.fullscreen_menu then
    Screen.fill_rect(Screen.world_rect.x, Screen.world_rect.y,
                     Screen.world_rect.width, Screen.world_rect.height,
                     { 0, 0, 0, 1 })
  end
  for k,_ in pairs(HStash.current_menus) do
    HMenu.draw_menu(k)
  end

  -- cursor
  draw_cursor()

  -- print "j"
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
  elseif HMode.is(HMode.heights) then
    cname = "heights"
  end
  if HStash.keys.primary.highlight and (not HStash.keys.mic.highlight) then
    cname = cname .. "_down"
  end
  if HStash.keys.secondary.highlight and (not HStash.keys.mic.highlight) and HMode.is(HMode.apply) then
    cname = cname .. "_down2"
  end

  local x = (HStash.cursor_x*HGlobals.scale) + HGlobals.xoff
  local y = (HStash.cursor_y*HGlobals.scale) + HGlobals.yoff
  local im = imgs["cursor_" .. cname]
  if im then im:draw(x - HGlobals.coff[1], y - HGlobals.coff[2]) end
end

imgs = {}
function Triggers.init()
  Screen.crosshairs.lua_hud = true
  g_initMode = 0

  for _, nm in pairs({ "cursor_menu", "cursor_menu_down",
                       "cursor_apply", "cursor_apply_down", "cursor_apply_down2",
                       "cursor_teleport", "cursor_teleport_down",
                       "cursor_heights", "cursor_heights_down",
                       "bracket_on", "bracket_off", "bracket_dis",
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
  HGlobals.fontm = Fonts.new{file = "dejavu/DejaVuLGCSansCondensed-Bold.ttf", size = 7 * HGlobals.scale}

  HGlobals.fwidth, HGlobals.fheight = HGlobals.fontn:measure_text("  ")
  HGlobals.bwidth, HGlobals.bheight = HGlobals.fontb:measure_text("  ")
  HGlobals.mwidth, HGlobals.mheight = HGlobals.fontm:measure_text("  ")
  HGlobals.fnoff = 0 - HGlobals.fheight/2
  HGlobals.fmoff = 0 + HGlobals.fheight/2 - HGlobals.mheight

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
  if HStash.advanced_mode and (HMode.is(HMode.apply) or HMode.is(HMode.teleport)) then
    header = 0
    x = 0
    w = Screen.width
  end

  Screen.clip_rect.x = x
  Screen.clip_rect.y = y
  Screen.clip_rect.width = w
  Screen.clip_rect.height = h

  y = y + header*HGlobals.scale
  h = (392 - header)*HGlobals.scale

  Screen.term_rect.x = x
  Screen.term_rect.y = y
  Screen.term_rect.width = w
  Screen.term_rect.height = h

  local halfh = math.floor((480 - header)*HGlobals.scale/2)
  Screen.map_rect.x = x
  Screen.map_rect.y = y + halfh
  Screen.map_rect.width = w
  Screen.map_rect.height = halfh

  if Screen.map_active then
    local halfw = halfh * 2
    Screen.world_rect.x = x + (w - halfw)/2
    Screen.world_rect.y = y
    Screen.world_rect.width = halfw
    Screen.world_rect.height = halfh
  else
    local fullw = math.min(w, h * 2)
    Screen.world_rect.x = x + (w - fullw)/2
    Screen.world_rect.y = y
    Screen.world_rect.width = fullw
    Screen.world_rect.height = h
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

HMode = {}
HMode.current = -1
HMode.apply = 0
HMode.choose = 1
HMode.attribute = 2
HMode.teleport = 3
HMode.panel = 4
HMode.heights = 5
HMode.changed = false
function HMode.update()
  local newstate = HStash.mode
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
function HMenu.draw_menu(mode)
  local u = HGlobals.scale
  local m = HMenu.menus[mode]
  local xp = HGlobals.xoff
  local yp = HGlobals.yoff

  for idx, item in ipairs(m) do
    local x = xp + item[3]*u
    local y = yp + item[4]*u
    local w = item[5]*u
    local h = item[6]*u
    local state = item[8]
    if state == nil then state = "enabled" end

    if item[1] == "label" then
      HGlobals.fontn:draw_text(item[7],
                               math.floor(x), math.floor(y + h/2 + HGlobals.fnoff),
                               colors.menu_label)
    elseif item[1] == "klabel" then
      local fw, fh = HGlobals.fontm:measure_text(item[7])
      -- local state = HMenu.button_state(item[2])
      HGlobals.fontm:draw_text(item[7],
                               math.floor(x + w - fw), math.floor(y + h/2 + HGlobals.fmoff),
                               colors.commands[state].label)
    elseif item[1] == "kaction" then
      -- local state = HMenu.button_state(item[2])
      HGlobals.fontn:draw_text(item[7],
                               math.floor(x), math.floor(y + h/2 + HGlobals.fnoff),
                               colors.commands[state].key)
    elseif item[1] == "kmod" then
      -- local state = HMenu.button_state(item[2])
      local nm = "bracket"
      if state == "enabled" then
        nm = nm .. "_off"
      elseif state == "disabled" then
        nm = nm .. "_dis"
      elseif state == "active" then
        nm = nm .. "_on"
      end

      local img = imgs[nm]
      if img then
        img:draw(x + w/2 - img.width/2, y + h/2 - img.height/2)
      end
    elseif item[1] == "ktab_bg" then
      Screen.fill_rect(x, y, w, h, colors.ktab.background)
    elseif item[1] == "ktab" then
      local label = nil
      if item[2] ~= nil then
        if item[2] == "key_action" then
          label = "Action"
          if state == "active" then state = "enabled" end
        elseif item[2] == "key_map" then
          label = "Map"
          if state == "active" then state = "enabled" end
        elseif item[2] == "key_mic" then
          label = "Aux"
        end
      else
        state = "current"
      end

      local li = menu_prefs.tab_indent.left
      local ri = menu_prefs.tab_indent.right
      local ti = menu_prefs.tab_indent.top
      local bi = menu_prefs.tab_indent.bottom
      if state == "current" then ri = 0 end
      Screen.fill_rect(x + li*u,
                       y + ti*u,
                       w - li*u - ri*u,
                       h - ti*u - bi*u,
                       colors.ktab[state].background)
      HGlobals.fontn:draw_text(item[7],
                               math.floor(x + 35*u),
                               math.floor(y + h/2 + HGlobals.fnoff),
                               colors.ktab[state].text)
      if label then
        local fw, fh = HGlobals.fontm:measure_text(label)
        HGlobals.fontm:draw_text(label,
                                 math.floor(x + 30*u - fw),
                                 math.floor(y + h/2 + HGlobals.fmoff),
                                 colors.ktab[state].label)
      end
    elseif item[1] == "tab_bg" then
      Screen.fill_rect(x, y, w, h, colors.tab.background)
    elseif item[1] == "bg" then
      Screen.fill_rect(x, y, w, h, colors.tab.background)
    elseif item[1] == "tab" then
      local state = HMenu.button_state(item[2])

      local li = menu_prefs.tab_indent.left
      local ri = menu_prefs.tab_indent.right
      local ti = menu_prefs.tab_indent.top
      local bi = menu_prefs.tab_indent.bottom
      if state == "active" then ri = 0 end
      Screen.fill_rect(x + li*u,
                       y + ti*u,
                       w - li*u - ri*u,
                       h - ti*u - bi*u,
                       colors.tab[state].background)
      HGlobals.fontn:draw_text(item[7],
                               math.floor(x + 7*u),
                               math.floor(y + h/2 + HGlobals.fnoff),
                               colors.tab[state].text)
    elseif item[1] == "texture" or item[1] == "atexture" or item[1] == "dtexture" then
      local cc, ct = string.match(item[2], "(%d+)_(%d+)")
      local indent = menu_prefs.texture_preview_indent

      if item[1] == "texture" then
        indent = menu_prefs.texture_choose_indent
      elseif item[1] == "atexture" then
        indent = menu_prefs.texture_apply_indent
      else
        state = "enabled"
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
      local ht = h - 2*indent*u
      HCollections.draw(cc + 0, ct + 0, xt, yt, wt, ht)
    elseif item[1] == "applypreview" then
      HCollections.preview_current(x, y, w, item[6])
    elseif item[1] == "light" then
      local xt = x + menu_prefs.button_indent*u
      local yt = y + menu_prefs.button_indent*u
      local wt = w - 2*menu_prefs.button_indent*u
      local ht = h - 2*menu_prefs.button_indent*u

      local c = colors.light[state]
      Screen.frame_rect(xt + wt - ht, yt, ht, ht, c.frame, menu_prefs.light_thickness*u)

      local val = HStash.intensities[tonumber(string.sub(item[2], 7))]
      local sz = ht - 2*menu_prefs.light_thickness*u
      Screen.fill_rect(xt + wt - ht + menu_prefs.light_thickness*u,
                       yt + menu_prefs.light_thickness*u,
                       sz, sz, { val, val, val, 1 })

      local fw, fh = HGlobals.fontn:measure_text(item[7])
      local yh = yt + ht/2 - fh/2
      local xh = xt + wt - ht - 5*u - fw
      HGlobals.fontn:draw_text(item[7], xh, yh, c.text)

    elseif HMenu.clickable(item[1]) then
      HMenu.draw_button_background(item, state)

      local xo = 7
      if item[1] == "checkbox" or item[1] == "acheckbox" or item[1] == "radio" then
        xo = 17
      elseif item[1] == "light" then
        local fw, fh = HGlobals.fontn:measure_text(item[7])
        xo = item[5] - 7 - fw/u
      elseif item[1] == "dbutton" then
        local fw, fh = HGlobals.fontn:measure_text(item[7])
        xo = (w/u - fw/u)/2
      end
      HMenu.draw_button_text(item, state, xo)

      if item[1] == "checkbox" or item[1] == "acheckbox" or item[1] == "radio" then
        local nm = "dcheck"
        if item[1] == "radio" then
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
      elseif item[1] == "light" then
        local val = HStash.intensities[tonumber(string.sub(item[2], 7))]
        Screen.fill_rect(x + 2*u, y + 2*u, h - 4*u, h - 4*u, { val, val, val, 1 })
      end
    end
  end
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

  HGlobals.fontn:draw_text(item[7],
                           math.floor(x + xoff*u),
                           math.floor(y + h/2 + HGlobals.fnoff),
                           c.text)
end

function HMenu.clickable(item_type)
  return item_type == "button" or item_type == "checkbox" or item_type == "radio" or item_type == "texture" or item_type == "light" or item_type == "dbutton" or item_type == "acheckbox" or item_type == "tab"
end

HCollections = {}
HCollections.inited = false
HCollections.all_shapes = {}

function HCollections.init()
  for i = 0,31 do
    local cinfo = HStash.collections.collection_map[i]
    if cinfo ~= nil then
      local bct = cinfo.count
      HCollections.all_shapes[i] = {}
      for j = 0,bct-1 do
        HCollections.all_shapes[i][j] = Shapes.new{collection = Collections[i], texture_index = j, type = TextureTypes[cinfo.type]}
      end
    end
  end

  HCollections.inited = true
end
function HCollections.update()
  if not HCollections.inited then HCollections.init() end
end
function HCollections.current_coll()
  local coll = HStash.collections.current_collection
  if coll == 0 then
    coll = HStash.collections.current_landscape_collection
  end
  return coll
end
function HCollections.shape(coll, tex)
  if coll == nil then
    coll = HCollections.current_coll()
  end
  if coll == 0 then
    coll = HStash.collections.current_landscape_collection
  end
  if tex == nil then
    tex = HStash.collections.current_textures[coll]
  end
  return HCollections.all_shapes[coll][tex]
end
function HCollections.is_landscape(coll)
  if coll == nil then
    coll = HCollections.current_coll()
  end
  if coll == 0 then
    coll = HStash.collections.current_landscape_collection
  end
  return HStash.collections.collection_map[coll].type == "landscape"
end
function HCollections.predraw(coll, tex, w, h)
  local xb, yb = 0, 0
  local shp = HCollections.shape(coll, tex)
  if not shp then return nil, 0, 0 end
  if HCollections.is_landscape(coll) then
    local sw = math.max(shp.unscaled_width, shp.unscaled_height)
    local sh = math.min(shp.unscaled_width, shp.unscaled_height)
    local aspect = sw / sh
    local scale = math.max(w / sw, h / sh)

    -- work around deep voodoo in landscape rendering
    local nw = sw
    local nh = sh / (aspect * 540/1024)
    shp:rescale(nw * scale, nh * scale)

    local xoff = (shp.width - w)/2
    local yoff = (shp.height - h)/2
    shp.crop_rect.x = math.max(0, xoff)
    shp.crop_rect.y = math.max(0, yoff)
    shp.crop_rect.width = math.min(w, shp.width)
    shp.crop_rect.height = math.min(h, shp.height)
    xb = math.max(0, -xoff)
    yb = math.max(0, -yoff)
  else
    shp:rescale(w, h)
  end
  return shp, xb, yb
end
function HCollections.draw(coll, tex, x, y, w, h)
  local shp, xoff, yoff = HCollections.predraw(coll, tex, w, h)
  if shp then shp:draw(x + xoff, y + yoff) end
end
function HCollections.preview_current(x, y, size, mode)
  if (mode == 1) and (not HStash.apply.texture) then return end
  if (mode == 2) and      HStash.apply.texture  then return end

  local pref = menu_prefs.preview.apply
  if HMode.is(HMode.attribute) then pref = menu_prefs.preview.attribute end
  local u = HGlobals.scale
  local oldx = Screen.clip_rect.x
  local oldy = Screen.clip_rect.y
  local oldw = Screen.clip_rect.width
  local oldh = Screen.clip_rect.height
  Screen.clip_rect.x = x
  Screen.clip_rect.y = y
  Screen.clip_rect.width = size
  Screen.clip_rect.height = size

  local coll = HCollections.current_coll()
  local tex = HStash.collections.current_textures[coll]
  local xfer = HStash.transfer_mode
  if HStash.collections.current_collection == 0 then
    xfer = "landscape"
  end

  if HStash.apply.texture then

    if xfer == "static" then
      local xoff = math.random() * math.max(0, img_static.width - size)
      local yoff = math.random() * math.max(0, img_static.height - size)
      img_static:draw(x - xoff, y - yoff)
    else
      local xoff, yoff, sxmult, symult = HCollections.calc_transfer(xfer)
      xoff = xoff * size
      yoff = yoff * size
      local sx = size * sxmult
      local sy = size * symult

      local shp, shpx, shpy = HCollections.predraw(coll, tex, sx, sy)
      local xp = x + xoff + shpx
      local yp = y + yoff + shpy

      local extrax = { { true, xp }, { xoff > 0, xp - sx }, { (xoff + sx) < size, xp + sx } }
      local extray = { { true, yp }, { yoff > 0, yp - sy }, { (yoff + sy) < size, yp + sy } }
      for _,xv in ipairs(extrax) do
        if xv[1] then
          for _,yv in ipairs(extray) do
            if yv[1] then
              if shp then shp:draw(xv[2], yv[2]) end
            end
          end
        end
      end

      if HStash.apply.light and xfer ~= "landscape" then
        local val = 0.5 + HStash.intensities[HStash.light]/2
        Screen.fill_rect(x, y, size, size, { 0, 0, 0, 1 - val })
      end

      if pref.snap_grid > 0 and HStash.quantize > 0 then
        local border = u * pref.snap_grid
        Screen.frame_rect(x, y, size, size, colors.snap_grid, border)
        local grids = snap_denominators[HStash.quantize]
        for i = 1,grids-1 do
          local off = size * i / grids
          Screen.fill_rect(x + off - border/2, y + border,
                           border, size - 2*border, colors.snap_grid)
          Screen.fill_rect(x + border, y + off - border/2,
                           size - 2*border, border, colors.snap_grid)
        end
      end


    end
  elseif HStash.apply.light then
    local val = HStash.intensities[HStash.light]
    local border = u * pref.light_border
    Screen.fill_rect(x, y, size, size, colors.light.enabled.frame)
    Screen.fill_rect(x + border, y + border,
                     size - 2*border, size - 2*border,
                     { val, val, val, 1 })
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
  if ttype == "pulsate" then
    local phase = Game.ticks + 32
    phase = bit32.band(phase, 63)
    if phase >= 32 then
      phase = 48 - phase
    else
      phase = phase - 16
    end
    sx = 1 - (phase - 8) / 1024
    x = (phase - 8) / 2
    sy = sx
    y = x
  elseif ttype == "pulsate" or ttype == "wobble" or ttype == "fast wobble" then
    local phase = Game.ticks + 32
    if ttype == "fast wobble" then phase = phase * 15 end
    phase = bit32.band(phase, 63)
    if phase >= 32 then
      phase = 48 - phase
    else
      phase = phase - 16
    end
    sx = 1 + (phase - 8) / 1024
    sy = 1 - (phase - 8) / 1024
    y = (phase - 8) / 2
    if ttype == "pulsate" then
      sx = sy
      x = y
    end
  elseif ttype == "2x" then
    sx = 2
    sy = 2
  elseif ttype == "4x" then
    sx = 4
    sy = 4
  else
    local phase = Game.ticks
    if ttype == "fast horizontal slide" or ttype == "fast vertical slide" or ttype == "fast wander" or ttype == "reverse fast horizontal slide" or ttype == "reverse fast vertical slide" then
      phase = phase * 2
    end
    if ttype == "horizontal slide" or ttype == "fast horizontal slide" then
      x = bit32.band(phase * 4, 1023)
    elseif ttype == "reverse horizontal slide" or ttype == "reverse fast horizontal slide" then
      x = bit32.band(1024 - (phase * 4), 1023)
    elseif ttype == "vertical slide" or ttype == "fast vertical slide" then
      y = bit32.band(phase * 4, 1023)
    elseif ttype == "reverse vertical slide" or ttype == "reverse fast vertical slide" then
      y = bit32.band(1024 - (phase * 4), 1023)
    elseif ttype == "wander" or ttype == "fast wander" then
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
