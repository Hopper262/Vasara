-- Vasara 1.0 ALPHA (Script)
-- by Hopper and Ares Ex Machina
-- from work by Irons and Smith, released under the JUICE LICENSE!

-- user configurable stuff here

walls = { 17, 18, 19, 20, 21 } 
landscapes = { 27, 28, 29, 30 }

suppress_items = true
suppress_monsters = true

max_tags = 32
max_scripts = 40

-- highlight selected destination in Teleport mode
show_teleport_destination = true

-- don't modify below this line!

Game.monsters_replenish = not suppress_monsters
snap_denominators = { 4, 5, 8 }
transfer_modes = { TransferModes["normal"], TransferModes["pulsate"], TransferModes["wobble"], TransferModes["fast wobble"], TransferModes["static"], TransferModes["landscape"], TransferModes["horizontal slide"], TransferModes["fast horizontal slide"], TransferModes["vertical slide"], TransferModes["fast vertical slide"], TransferModes["wander"], TransferModes["fast wander"] }
transfer_mode_lookup = {}
for k, v in pairs(transfer_modes) do transfer_mode_lookup[v] = k - 1 end

CollectionsUsed = {}
for _, collection in pairs(walls) do
  table.insert(CollectionsUsed, collection)
end
for _, collection in pairs(landscapes) do
  table.insert(CollectionsUsed, collection)
end

TRIGGER_DELAY = 4

Triggers = {}
function init()
  VML.init()
  
  for p in Players() do
    p.weapons.active = false

    local pal = p.texture_palette
    pal.highlight = 0
    if p.local_ then
      local colldef = Collections[0]
      local typedef = TextureTypes["interface"]
      pal.size = 64
      for s = 0,31 do
        local slot = pal.slots[s]
        slot.collection = colldef
        slot.texture_index = 0
        slot.type = typedef
      end
    end
  end
  
  if suppress_items then
    for item in Items() do 
      item:delete()
    end

    function Triggers.item_created(item)
      item:delete()
    end
  end
  
  SKeys.init()
  SCollections.init()
  SPlatforms.init()
  SMode.init()
  SUndo.init()
  
  inited_script = true
end

function Triggers.idle()
  if not Sides.new then
    Players.print("Vasara requires a newer version of Aleph One")
    kill_script()
    return
  end
  
  if not inited_script then init() end
  
  SKeys.update()
  SCounts.update()
  SPlatforms.update()
  SMode.update()
  SUndo.update()
  SStatus.update()
  SCollections.update()
  
  for p in Players() do
    p.life = 409
    p.oxygen = 10800
    if p.local_ then p.crosshairs.active = false end
  end
end

function Triggers.terminal_enter(terminal, player)
  if terminal then
    player._terminal = true
  end
end
function Triggers.terminal_exit(_, player)
  player._terminal = false
end
function Triggers.player_damaged(p, ap, am, dt, da, pr)
  p.life = 409
end


SMode = {}
SMode.apply = 0
SMode.choose = 1
SMode.attribute = 2
SMode.teleport = 3
SMode.switch = 4
SMode.recharger = 5
SMode.terminal = 6

function SMode.init()
  for p in Players() do
    p._mode = SMode.apply
    p._prev_mode = SMode.apply
    p._mic_dummy = false
    p._frozen = false
    p._target_poly = 0
    p._quantize = 0
    p._menu_button = nil
    p._menu_item = 0
    
    p._apply = {}
    p._apply.texture = true
    p._apply.light = true
    p._apply.transfer = true
    p._apply.align = true
    p._apply.transparent = false
    p._apply.edit_panels = false
        
    p._teleport = {}
    p._teleport.last_target = nil
    p._teleport.last_target_mode = nil
    
    p._point = {}
    p._point.x = 0
    p._point.y = 0
    p._point.z = 0
    p._point.poly = 0
    p._point.direction = 0
    p._point.elevation = 0
    
    p._saved_facing = {}
    p._saved_facing.direction = 0
    p._saved_facing.elevation = 0
    p._saved_facing.x = 0
    p._saved_facing.y = 0
    p._saved_facing.z = 0
    p._saved_facing.just_set = false
    
    p._saved_surface = {}
    p._saved_surface.surface = nil
    p._saved_surface.polygon = nil
    p._saved_surface.x = 0
    p._saved_surface.y = 0
    p._saved_surface.direction = 0
    p._saved_surface.elevation = 0
    p._saved_surface.dragstart = 0
    p._saved_surface.align_table = nil
    p._saved_surface.offset_table = nil
    
    p._annotation = Annotations.new(Polygons[0], "")
    
    if p.local_ then
      p.texture_palette.slots[40].texture_index = p._mode
    end
  end
end
function SMode.update()
  for p in Players() do
    
    -- mode transitions
    p._prev_mode = p._mode
    
    if not p._keys.mic.down then
      if p._keys.map.pressed then
        if p._overhead then
          p._mode = SMode.teleport
        else
          p._mode = SMode.apply
        end
      elseif p._keys.action.pressed then
        -- only allow default action trigger in apply and teleport
        if (p._mode ~= SMode.teleport and p._mode ~= SMode.apply) or (not p:find_action_key_target()) then
          p.action_flags.action_trigger = false
          SMode.toggle(p, SMode.choose)
        end
      elseif p._keys.mic.released and (not p._mic_dummy) then
        SMode.toggle(p, SMode.attribute)
      elseif p._keys.secondary.released and p._mode ~= SMode.apply then
        SMode.toggle(p, p._mode)
      end
    end
    
    -- track mic-as-modifier, and don't switch if we use that
    if p._keys.mic.down then
      if p._mode == SMode.apply then
        if p._keys.prev_weapon.down or p._keys.next_weapon.down or p._keys.action.down or p._keys.primary.down or p._keys.primary.released or p._keys.secondary.down or p._keys.secondary.released then
          p._mic_dummy = true
        end
      elseif p._mode == SMode.choose then
        if p._keys.prev_weapon.down or p._keys.next_weapon.down or p._keys.secondary.down or p._keys.secondary.released then
          p._mic_dummy = true
        end
      elseif p._mode == SMode.teleport then
        if p._keys.primary.down or p._keys.primary.released or p._keys.secondary.down or p._keys.secondary.released then
          p._mic_dummy = true
        end
      end
    elseif p._keys.mic.released then
      p._mic_dummy = false
    end
    
    local in_menu = SMode.menu_mode(p._mode)
    
    if p._mode ~= p._prev_mode then
      p._menu_button = nil
      p._menu_item = 0
      local was_menu = SMode.menu_mode(p._prev_mode)
      if in_menu and (not was_menu) then
        -- save player position for menu mode
        p._point.x = p.x
        p._point.y = p.y
        p._point.z = p.z + 1/1024.0
        p._point.poly = p.polygon
        p._point.direction = p.direction
        p._saved_facing.direction = p.direction
        p._point.elevation = p.elevation
        p.direction = 180
        p.elevation = 0
      elseif (not in_menu) and was_menu then
        -- restore player position from menu mode
        p:position(p._point.x, p._point.y, p._point.z, p._point.poly)
        p.external_velocity.i = 0
        p.external_velocity.j = 0
        p.external_velocity.k = 0
        p.direction = p._point.direction
        p.elevation = p._point.elevation
      end
      
      if p._prev_mode == SMode.teleport then
        UTeleport.end_highlight(p)
      end
    end
    if in_menu then
      SMenu.recenter(p)
    end

    if p._mode == SMode.apply then
      SMode.handle_apply(p)
    elseif p._mode == SMode.teleport then
      SMode.handle_teleport(p)
    elseif p._mode == SMode.choose then
      SMode.handle_choose(p)
    elseif p._mode == SMode.attribute then
      SMode.handle_attribute(p)
    elseif p._mode == SMode.switch then
      SMode.handle_switch(p)
    elseif p._mode == SMode.recharger then
      SMode.handle_recharger(p)
    elseif p._mode == SMode.terminal then
      SMode.handle_terminal(p)
    end
    
    -- handle freeze
    if p._frozen or SMode.menu_mode(p._mode) then
      p:position(p._point.x, p._point.y, p._point.z, p._point.poly)
      p.external_velocity.i = 0
      p.external_velocity.j = 0
      p.external_velocity.k = 0
    end
    
    if p.local_ then
      p.texture_palette.slots[37].texture_index = p._target_poly % 128
      p.texture_palette.slots[38].texture_index = math.floor(p._target_poly/128)
      p.texture_palette.slots[40].texture_index = p._mode
      p.texture_palette.slots[42].texture_index = math.floor(p._saved_facing.direction / 2)
    end
  end
end
function SMode.menu_mode(mode)
  return mode == SMode.choose or mode == SMode.attribute or mode == SMode.switch or mode == SMode.recharger or mode == SMode.terminal
end
function SMode.toggle(p, mode)
  if p._mode == mode then
    p._mode = SMode.apply
  else
    p._mode = mode
  end
  if p._overhead then
    p.action_flags.toggle_map = true
    p._overhead = false
  end
end
function SMode.handle_apply(p)
  local clear_surface = true
  
  if p._keys.mic.down then
    if p._keys.prev_weapon.held then
      p:accelerate(0, 0, 0.05)
    elseif p._keys.next_weapon.pressed then
      p._frozen = not p._frozen
      if p._frozen then
        p._point.x = p.x
        p._point.y = p.y
        p._point.z = p.z + 1/1024.0
        p._point.poly = p.polygon
      end
    end
  else
    if p._keys.primary.down then
      -- apply
      clear_surface = false
      local surface = p._saved_surface.surface
      if p._keys.primary.pressed then
        surface, polygon = SCollections.find_surface(p)
        local coll = p._collections.current_collection
        local landscape = false
        if coll == 0 then
          coll = p._collections.current_landscape_collection
          landscape = true
        end
        local tex = p._collections.current_textures[coll]
        
        p._saved_surface.surface = surface
        p._saved_surface.polygon = polygon
        if (not p._apply.texture) or ((coll == surface.collection.index) and (tex == surface.texture_index)) then
          p._saved_surface.x = surface.texture_x
          p._saved_surface.y = surface.texture_y
        else
          p._saved_surface.x = 0
          if is_side(o) then
            local bottom, top = VML.surface_heights(surface)
            p._saved_surface.y = bottom - top
          else
            p._saved_surface.y = 0
          end
        end
        p._saved_surface.direction = p.direction
        p._saved_surface.elevation = p.elevation
        p._saved_surface.dragstart = Game.ticks
        
        SUndo.add_undo(p, surface)
        
        if p._apply.texture then
          surface.collection = coll
          surface.texture_index = tex
          surface.texture_x = p._saved_surface.x
          surface.texture_y = p._saved_surface.y
          if landscape then
            surface.transfer_mode = "landscape"
          else
            surface.transfer_mode = transfer_modes[p._transfer_mode + 1]
          end
        end
        if p._apply.light then
          surface.light = Lights[p._light]
        end
        
        if p._apply.align then
          if is_polygon_floor(surface) or is_polygon_ceiling(surface) then
            p._saved_surface.align_table = VML.build_polygon_align_table(polygon, surface)
            local is_floor = is_polygon_floor(surface)
            for s in pairs(p._saved_surface.align_table) do
              if is_floor then
                SUndo.add_undo(p, s.floor)
              else
                SUndo.add_undo(p, s.ceiling)
              end
            end
            VML.align_polygons(surface, p._saved_surface.align_table)
          else
            p._saved_surface.offset_table = VML.build_side_offsets_table(surface)
            for s in pairs(p._saved_surface.offset_table) do
              SUndo.add_undo(p, s)
            end
            VML.align_sides(surface, p._saved_surface.offset_table)
          end
        end
      
      elseif Game.ticks > p._keys.primary.first + TRIGGER_DELAY then
        -- dragging
        local delta_pitch = p._saved_surface.elevation - p.elevation
        local delta_yaw = p._saved_surface.direction - p.direction
        if is_polygon_floor(surface) or is_polygon_ceiling(surface) then
          if is_polygon_ceiling(surface) then delta_pitch = -delta_pitch end
          
          local x = p._saved_surface.x - delta_yaw / 180 * math.sin(math.rad(p._saved_surface.direction))
          local y = p._saved_surface.y + delta_yaw / 180 * math.cos(math.rad(p._saved_surface.direction))
          
          x = VML.quantize(p, x + delta_pitch / 60 * math.cos(math.rad(p.yaw)))
          y = VML.quantize(p, y + delta_pitch / 60 * math.sin(math.rad(p.yaw)))
          surface.texture_x = x
          surface.texture_y = y
          
          if p._apply.align then
            VML.align_polygons(surface, p._saved_surface.align_table)
          end
        else
          surface.texture_x = VML.quantize(p, p._saved_surface.x + delta_yaw / 90)
          surface.texture_y = VML.quantize(p, p._saved_surface.y - delta_pitch / 60)
          
          if p._apply.align then
            VML.align_sides(surface, p._saved_surface.offset_table)
          end
        end
      end
    elseif p._keys.prev_weapon.pressed then
      p._light = (p._light - 1) % #Lights
    elseif p._keys.next_weapon.pressed then
      p._light = (p._light + 1) % #Lights
    end
  end
  
  if clear_surface then p._saved_surface.surface = nil end
end
function SMode.handle_teleport(p)
  if p._saved_facing.just_set then
    p._saved_facing.direction = p.direction
    p._saved_facing.elevation = p.elevation
    p._saved_facing.just_set = false
  end
  if (p._saved_facing.direction ~= p.direction) or
     (p._saved_facing.elevation ~= p.elevation) or
     (p._saved_facing.x ~= p.x) or
     (p._saved_facing.y ~= p.y) or
     (p._saved_facing.z ~= p.z) then
    p._saved_facing.direction = p.direction
    p._saved_facing.elevation = p.elevation
    p._saved_facing.x = p.x
    p._saved_facing.y = p.y
    p._saved_facing.z = p.z
    local t,x,y,z,poly = p:find_target()
    p._target_poly = poly.index
    UTeleport.highlight(p, poly)
    
    SMode.annotate(p)
  end
  
  if (not p._keys.mic.down) and p._keys.primary.released then
    p:teleport(p._target_poly)
    UTeleport.end_highlight(p)
    p._frozen = false
    return
  end
  
  if ((not p._keys.mic.down) and (p._keys.prev_weapon.held or p._keys.next_weapon.held)) or (p._keys.mic.down and (p._keys.primary.held or p._keys.secondary.held)) then
    if p._keys.prev_weapon.held and (not p._keys.mic.down) then
      p._target_poly = (p._target_poly - 1) % #Polygons
    elseif p._keys.next_weapon.held and (not p._keys.mic.down) then
      p._target_poly = (p._target_poly + 1) % #Polygons
    elseif p._keys.primary.held and p._keys.mic.down then
      p._target_poly = (p._target_poly - 10) % #Polygons
    elseif p._keys.secondary.held and p._keys.mic.down then
      p._target_poly = (p._target_poly + 10) % #Polygons
    end
    SMode.annotate(p)
    
    local poly = Polygons[p._target_poly]
    UTeleport.highlight(p, poly)
    local xdist = poly.x - p.x
    local ydist = poly.y - p.y
    local zdist = poly.z - (p.z + 614/1024)
    local tdist = math.sqrt(xdist*xdist + ydist*ydist + zdist*zdist)
    
    local el = math.asin(zdist/tdist)
    local dir = math.atan2(ydist, xdist)
    p.direction = math.deg(dir)
    p.elevation = math.deg(el)
    p._saved_facing.just_set = true
  end
end
function SMode.annotate(p)
  local poly = Polygons[p._target_poly]
  p._annotation.polygon = poly
  p._annotation.text = poly.index
  p._annotation.x = poly.x
  p._annotation.y = poly.y
end
function SMode.handle_choose(p)
  if p._keys.primary.released then
    local tex = SChoose.gridtexture(p)
    if tex > -1 then
      --p._mode = SMode.apply
    end
  end
end
function SMode.handle_attribute(p)
  if p._keys.prev_weapon.pressed then
    SMenu.highlight_item(p, SMode.attribute, -1)
    SMenu.point_at_item(p, SMode.attribute, p._menu_item)
  end
  if p._keys.next_weapon.pressed then
    SMenu.highlight_item(p, SMode.attribute, 1)
    SMenu.point_at_item(p, SMode.attribute, p._menu_item)
  end
  if p._keys.primary.released then
    local name = SMenu.selection(p, SMode.attribute)
    if name == nil then return end
    
    if name == "apply_tex" then
      p._apply.texture = not p._apply.texture
    elseif name == "apply_light" then
      p._apply.light = not p._apply.light
    elseif name == "apply_align" then
      p._apply.align = not p._apply.align
    elseif name == "apply_xparent" then
      p._apply.transparent = not p._apply.transparent
    elseif name == "apply_edit" then
      p._apply.edit_panels = not p._apply.edit_panels
    elseif string.sub(name, 1, 5) == "snap_" then
      local mode = tonumber(string.sub(name, 6))
      p._quantize = mode
    elseif string.sub(name, 1, 9) == "transfer_" then
      local mode = tonumber(string.sub(name, 10))
      p._transfer_mode = mode
    elseif string.sub(name, 1, 6) == "light_" then
      local mode = tonumber(string.sub(name, 7))
      p._light = mode
    end
  end
end
function SMode.handle_switch(p)
  if p._keys.primary.released then
    -- tbd -- handle change
    p._mode = SMode.apply
  end
end
function SMode.handle_recharger(p)
  if p._keys.primary.released then
    -- tbd -- handle change
    p._mode = SMode.apply
  end
end
function SMode.handle_terminal(p)
  if p._keys.primary.released then
    -- tbd -- handle change
    p._mode = SMode.apply
  end
end

SKeys = {}
function SKeys.init()
  for p in Players() do
    p._keys = {}
    p._keys.action = {}
    p._keys.prev_weapon = {}
    p._keys.next_weapon = {}
    p._keys.map = {}
    p._keys.primary = {}
    p._keys.secondary = {}
    p._keys.mic = {}
    
    for _, k in pairs(p._keys) do
      k.down = false
      k.pressed = false
      k.released = false
      k.first = -5
      k.lag = -5
      k.highlight = false
      k.held = false
    end
    
    p._overhead = false
    p._terminal = false
    
    if p.local_ then
      p.texture_palette.slots[39].texture_index = 0
    end
  end
end

function SKeys.track_key(p, flag, key, disable)
  local k = p._keys[key]
  local ticks = Game.ticks
  
  if p.action_flags[flag] then
    if disable then
      p.action_flags[flag] = false
    end
    
    if k.down then
      k.pressed = false
    else
      k.down = true
      k.pressed = true
      k.released = false
      k.first = ticks
      k.lag = ticks
    end
  else
    if k.down then
      k.down = false
      k.pressed = false
      k.released = true
    else
      k.released = false
    end
  end
  
  k.highlight = false
  k.held = false
  local passed = ticks - k.first
  
  if k.down then
    k.highlight = true
    if (passed % (TRIGGER_DELAY + 1)) == 0 then
      k.held = true
    end
  elseif passed < (TRIGGER_DELAY + 1) then
    k.highlight = true
  end
end
function SKeys.cancel_highlight(k)
  if not k.down then
    k.lag = -5
    k.highlight = false
  end
end
function SKeys.update()
  local ticks = Game.ticks
  for p in Players() do
    if not p._terminal then
      
      -- track keys
      SKeys.track_key(p, 'cycle_weapons_backward', 'prev_weapon', true)
      SKeys.track_key(p, 'cycle_weapons_forward', 'next_weapon', true)
      SKeys.track_key(p, 'left_trigger', 'primary', true)
      SKeys.track_key(p, 'right_trigger', 'secondary', true)
      SKeys.track_key(p, 'microphone_button', 'mic', true)
      
      SKeys.track_key(p, 'action_trigger', 'action', p._keys.mic.down)
      SKeys.track_key(p, 'toggle_map', 'map', p._keys.mic.down)
      
      if p.action_flags.toggle_map then
        p._overhead = not p._overhead
      end
      
      -- cancel display highlights if we see a new key
      if p._keys.action.pressed or p._keys.next_weapon.pressed or p._keys.prev_weapon.pressed or p._keys.map.pressed then
        SKeys.cancel_highlight(p._keys.action)
        SKeys.cancel_highlight(p._keys.prev_weapon)
        SKeys.cancel_highlight(p._keys.next_weapon)
        SKeys.cancel_highlight(p._keys.map)
      end
            
      if p.local_ then
        local down = 0
        if p._keys.primary.highlight then down = down + 1 end
        if p._keys.secondary.highlight then down = down + 2 end
        if p._keys.mic.highlight then down = down + 4 end
        
        if p._keys.prev_weapon.highlight then down = down + 8 end
        if p._keys.next_weapon.highlight then down = down + 16 end
        if p._keys.action.highlight then down = down + 32 end
        if p._keys.map.highlight then down = down + 64 end
        
        p.texture_palette.slots[39].texture_index = down
      end
    end
  end
end


SStatus = {}
function SStatus.init()
  for p in Players() do
    if p.local_ then
      p.texture_palette.slots[41].texture_index = 0
      p.texture_palette.slots[43].texture_index = 0
      p.texture_palette.slots[44].texture_index = 0
      p.texture_palette.slots[45].texture_index = 0
      p.texture_palette.slots[46].texture_index = 0
      p.texture_palette.slots[47].texture_index = 0
    end
  end
end
function SStatus.update()
  for p in Players() do
    if p.local_ then
      local status = 0
      if p._frozen then status = status + 1 end
      if SUndo.undo_active(p) then status = status + 2 end
      if SUndo.redo_active(p) then status = status + 4 end
      if (p._mode == SMode.apply or p._mode == SMode.teleport) and p:find_action_key_target() then status = status + 8 end
      p.texture_palette.slots[41].texture_index = status
      
      p.texture_palette.slots[43].texture_index = p._light
      p.texture_palette.slots[44].texture_index = p._transfer_mode
      p.texture_palette.slots[45].texture_index = p._quantize
      
      status = 0
      if p._apply.texture then status = status + 1 end
      if p._apply.light then status = status + 2 end
      if p._apply.align then status = status + 4 end
      if p._apply.transparent then status = status + 8 end
      if p._apply.edit_panels then status = status + 16 end
      p.texture_palette.slots[46].texture_index = status
      
      p.texture_palette.slots[47].texture_index = p._menu_item
      
    end
  end
end

SMenu = {}
SMenu.menus = {}
SMenu.menus[SMode.attribute] = {
  { nil, nil, 60, 30, 500, 240 },
  { "label", nil, 0, 0, 150, 20, "Apply options" },
  { "button", "apply_light", 0, 20, 150, 18, "Apply light" },
  { "button", "apply_tex", 0, 40, 150, 18, "Apply texture" },
  { "button", "apply_align", 0, 60, 150, 18, "Align adjacent" },
  { "button", "apply_edit", 0, 80, 150, 18, "Edit switches and panels" },
  { "button", "apply_xparent", 0, 100, 150, 18, "Edit transparent sides" },
  { "label", "nil", 0, 140, 150, 20, "Snap to grid" },
  { "button", "snap_0", 0, 160, 150, 18, "Off" },
  { "button", "snap_1", 0, 180, 150, 18, "1/4 WU" },
  { "button", "snap_2", 0, 200, 150, 18, "1/5 WU" },
  { "button", "snap_3", 0, 220, 150, 18, "1/8 WU" },
  { "label", nil, 160, 0, 150, 20, "Texture mode" },
  { "button", "transfer_0", 160, 20, 150, 18, "Normal" },
  { "button", "transfer_1", 160, 40, 150, 18, "Pulsate" },
  { "button", "transfer_2", 160, 60, 150, 18, "Wobble" },
  { "button", "transfer_3", 160, 80, 150, 18, "Fast wobble" },
  { "button", "transfer_6", 160, 100, 150, 18, "Horizontal slide" },
  { "button", "transfer_7", 160, 120, 150, 18, "Fast horizontal slide" },
  { "button", "transfer_8", 160, 140, 150, 18, "Vertical slide" },
  { "button", "transfer_9", 160, 160, 150, 18, "Fast vertical slide" },
  { "button", "transfer_10", 160, 180, 150, 18, "Wander" },
  { "button", "transfer_11", 160, 200, 150, 18, "Fast wander" },
  { "button", "transfer_4", 160, 220, 150, 18, "Static" } }
SMenu.inited = {}
SMenu.inited[SMode.attribute] = false
SMenu.buttons = {}
SMenu.buttons[SMode.attribute] = {}
function SMenu.selection(p, mode)
  if not SMenu.inited[mode] then SMenu.init_menu(mode) end
  local m = SMenu.menus[mode]
  local xa, ya = SMenu.gridpos(p, m[1][6], m[1][5])
  local y = math.floor(-ya + (m[1][6] * 0.5))
  local x = math.floor(-xa + (m[1][5] * 0.5))
  
  for idx, item in ipairs(m) do
    if item[1] == "button" then
      if x >= item[3] and y >= item[4] and x <= (item[3] + item[5]) and y <= (item[4] + item[6]) then
        return item[2]
      end
    end
  end
  return nil
end
function SMenu.gridpos(p, rows, cols)
  return SChoose.gridpos(p, rows, cols)
end
function SMenu.recenter(p)
  SChoose.recenter(p)
end
function SMenu.init_menu(mode)
  local menu = SMenu.menus[mode]
  if mode == SMode.attribute then
    table.insert(menu,
        { "label", nil, 320, 0, 150, 20, "Light" })
    for i = 1,#Lights do
      local l = i - 1
      local yoff = (l % 10) * 20
      local xoff = math.floor(l / 10) * 32
      table.insert(menu,
        { "button", "light_" .. l, 320 + xoff, 20 + yoff, 30, 18, tostring(l) })
    end
    SMenu.inited[mode] = true
  end
  
  local blist = SMenu.buttons[mode]
  for idx, item in ipairs(menu) do
    if item[1] == "button" then
      table.insert(blist, idx)
    end
  end
end
function SMenu.highlight_item(p, mode, inc)
  if not SMenu.inited[mode] then SMenu.init_menu(mode) end
  local bm = SMenu.buttons[mode]
  
  if p._menu_button == nil then
    if inc < 0 then
      p._menu_button = #bm
    else
      p._menu_button = 1
    end
  else
    p._menu_button = ((p._menu_button - 1 + inc) % #bm) + 1
  end
  p._menu_item = bm[p._menu_button]
end
function SMenu.point_at_item(p, mode, idx)
  if not SMenu.inited[mode] then SMenu.init_menu(mode) end
  local m = SMenu.menus[mode]
  local item = m[idx]
  local col = item[3] + math.floor(item[5]/2)
  local row = item[4] + math.floor(item[6]/2)
  
  SChoose.setcursor(p, m[1][6], m[1][5], row, col)
end  


SChoose = {}
function SChoose.gridsize(bct)
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
function SChoose.recenter(p)
  local fov = 60
  if p.direction < (180 - fov) then
    p.direction = 180 - fov
  elseif p.direction > (180 + fov) then
    p.direction = 180 + fov
  end
end

function SChoose.gridpos(p, rows, cols)
  local ya = (rows - 0.5) * p.pitch / 60

  local xa = 0
  local fov = 60
  local dir = p.direction - 180
  if dir > fov then
    xa = -(cols-0.5) / 2
  elseif dir < -fov then
    xa = (cols-0.5) / 2
  else
    xa = (-(cols-0.5) / 2) * (dir / fov)
  end
  return xa, ya
end
function SChoose.setcursor(p, rows, cols, sel_row, sel_col)
  p.pitch = -60 * (sel_row + 0.5 - rows/2) / (rows - 0.5)
  p.direction = 180 - (120 * (sel_col + 0.5 - (cols * 0.5)) / (0.5 - cols))
end
function SChoose.point_to_texture(p)
  local coll = p._collections.current_collection
  local bct = 0
  local tex = 0
  if coll == 0 then
    for _, collection in pairs(SCollections.landscape_collections) do
      bct = bct + Collections[collection].bitmap_count
      if collection == p._collections.current_landscape_collection then
        local ci = SCollections.collection_map[collection]        
        tex = p._collections.current_textures[collection] + ci.offset
      end
    end
  else
    bct = Collections[coll].bitmap_count
    tex = p._collections.current_textures[coll]
  end
  local rows, cols = SChoose.gridsize(bct)
  local sel_row = math.floor(tex / cols)
  local sel_col = tex % cols

  SChoose.setcursor(p, rows, cols, sel_row, sel_col)
end
function SChoose.gridtexture(p)
  local coll = p._collections.current_collection
  local bct = 0
  if coll == 0 then
    for _, collection in pairs(SCollections.landscape_collections) do
      bct = bct + Collections[collection].bitmap_count
    end
  else
    bct = Collections[coll].bitmap_count
  end
  local rows, cols = SChoose.gridsize(bct)
  local xa, ya = SChoose.gridpos(p, rows, cols)
  local row = math.floor(-ya + (rows * 0.5))
  local col = math.floor(-xa + (cols * 0.5))
  local tex = col + (row * cols)
  
  if tex < bct then
    p._collections.current_textures[coll] = tex
    if coll == 0 then
      for _, collection in pairs(SCollections.landscape_collections) do
        local ci = SCollections.collection_map[collection]
        if tex < (ci.offset + ci.count) then
          p._collections.current_landscape_collection = collection
          p._collections.current_textures[collection] = tex - ci.offset
          break
        end
      end
    end
  else
    tex = -1
  end
  return tex
end

SCollections = {}
SCollections.wall_collections = {}
SCollections.landscape_collections = {}
SCollections.collection_map = {}
function SCollections.init()

  for _, collection in pairs(walls) do
    if not SCollections.collection_map[collection] then
      table.insert(SCollections.wall_collections, collection)
      SCollections.collection_map[collection] = {type = "wall", count = Collections[collection].bitmap_count}
    end
  end
  table.sort(SCollections.wall_collections)
  
  local off = 0
  for _, collection in pairs(landscapes) do
    if not SCollections.collection_map[collection] then
      table.insert(SCollections.landscape_collections, collection)
      SCollections.collection_map[collection] = {type = "landscape", offset = off, count = Collections[collection].bitmap_count}
      off = off + Collections[collection].bitmap_count
    end
  end
  table.sort(SCollections.landscape_collections)
  
  local current_collection = SCollections.wall_collections[1]
  local current_light = 0
  if Sides[0] and Sides[0].primary and Sides[0].primary.collection then
    local c = Sides[0].primary.collection.index
    if SCollections.collection_map[c] and SCollections.collection_map[c].type == "wall" then
      current_collection = c
      current_light = Sides[0].primary.light.index
    end
  end
  local current_landscape_collection = SCollections.landscape_collections[1]
    
  for p in Players() do
  
    p._collections = {}
    p._collections.current_collection = current_collection
    p._collections.current_landscape_collection = current_landscape_collection
    p._collections.current_textures = {}
    for idx, info in pairs(SCollections.collection_map) do
      p._collections.current_textures[idx] = math.floor(info.count / 2)
    end
    
    p._light = current_light
    p._transfer_mode = 0
    
    if p.local_ then
      local pal = p.texture_palette.slots
      for c = 0,31 do
        pal[c].collection = Collections[0]
        local used = SCollections.collection_map[c]
        if used then
          pal[c].texture_index = p._collections.current_textures[c]
          pal[c].type = TextureTypes[used.type]
        else
          pal[c].texture_index = 0
          pal[c].type = TextureTypes["interface"]
        end
      end
      pal[0].texture_index = p._collections.current_landscape_collection
      pal[32].collection = Collections[p._collections.current_collection]
      pal[32].texture_index = p._collections.current_textures[p._collections.current_collection]
      
      local cur = 0
      for _, collection in pairs(SCollections.wall_collections) do
        pal[cur].collection = Collections[collection]
        cur = cur + 1
      end
      pal[cur].collection = Collections[0]
      cur = cur + 1
      for _, collection in pairs(SCollections.landscape_collections) do
        pal[cur].collection = Collections[collection]
        cur = cur + 1
      end
      pal[cur].collection = Collections[0]
    end
  end
end
function SCollections.update()
  for p in Players() do

    if p._mode == SMode.choose then
      if p._keys.mic.down then
        -- cycle textures
        if p._keys.prev_weapon.held then
          local cur = p._collections.current_collection
          if cur == 0 then
            local bct = 0
            local tex = 0
            for _, collection in pairs(SCollections.landscape_collections) do
              if collection == p._collections.current_landscape_collection then
                local info = SCollections.collection_map[collection]
                tex = info.offset + p._collections.current_textures[collection]
              end
              bct = bct + Collections[collection].bitmap_count
            end
            
            tex = (tex - 1) % bct
            for _, collection in pairs(SCollections.landscape_collections) do
              local info = SCollections.collection_map[collection]
              if tex >= info.offset and tex < (info.offset + info.count) then
                SCollections.set(p, collection, tex - info.offset)
                SChoose.point_to_texture(p)
                break
              end
            end
          else
            local tex = p._collections.current_textures[cur]
            local bct = Collections[cur].bitmap_count
            SCollections.set(p, cur, (tex - 1) % bct)
            SChoose.point_to_texture(p)
          end
        end
        if p._keys.next_weapon.held or p._keys.primary.held then
          local cur = p._collections.current_collection
          if cur == 0 then
            local bct = 0
            local tex = 0
            for _, collection in pairs(SCollections.landscape_collections) do
              if collection == p._collections.current_landscape_collection then
                local info = SCollections.collection_map[collection]
                tex = info.offset + p._collections.current_textures[collection]
              end
              bct = bct + Collections[collection].bitmap_count
            end
            
            tex = (tex + 1) % bct
            for _, collection in pairs(SCollections.landscape_collections) do
              local info = SCollections.collection_map[collection]
              if tex >= info.offset and tex < (info.offset + info.count) then
                SCollections.set(p, collection, tex - info.offset)
                SChoose.point_to_texture(p)
                break
              end
            end
          else
            local tex = p._collections.current_textures[cur]
            local bct = Collections[cur].bitmap_count
            SCollections.set(p, cur, (tex + 1) % bct)
            SChoose.point_to_texture(p)
          end
        end
        if p._keys.secondary.held then
          -- ffwd collections
          local cur = p._collections.current_collection
          if cur == 0 then
            p._collections.current_collection = SCollections.wall_collections[1]
          else
            local nxt = 0
            local found = false
            for _, c in pairs(SCollections.wall_collections) do
              if found then
                nxt = c
                break
              end
              if c == cur then found = true end
            end
            p._collections.current_collection = nxt
          end
        end
      else
        -- cycle collections
        if p._keys.prev_weapon.held then
          local cur = p._collections.current_collection
          if cur == 0 then
            p._collections.current_collection = SCollections.wall_collections[#SCollections.wall_collections]
          else
            local prev = 0
            for _, c in pairs(SCollections.wall_collections) do
              if c == cur then break end
              prev = c
            end
            p._collections.current_collection = prev
          end
        end
        if p._keys.next_weapon.held then
          local cur = p._collections.current_collection
          if cur == 0 then
            p._collections.current_collection = SCollections.wall_collections[1]
          else
            local nxt = 0
            local found = false
            for _, c in pairs(SCollections.wall_collections) do
              if found then
                nxt = c
                break
              end
              if c == cur then found = true end
            end
            p._collections.current_collection = nxt
          end
        end
      end
    end
    if p._mode == SMode.apply then
      if (not p._keys.mic.down) and p._keys.secondary.released then
        local surface = SCollections.find_surface(p)
        if surface and (not (is_transparent_side(surface) and surface.empty)) then
          SCollections.set(p, surface.collection.index, surface.texture_index)
          if p._collections.current_collection ~= 0 then
            p._light = surface.light.index
            p._transfer_mode = transfer_mode_lookup[surface.transfer_mode]
          end
        end
      end
    end
    
    if p.local_ then
      local pal = p.texture_palette.slots
      pal[0].texture_index = p._collections.current_landscape_collection
      if p._collections.current_collection == 0 then
        pal[32].collection = 0
        pal[32].texture_index = p._collections.current_textures[p._collections.current_landscape_collection] + SCollections.collection_map[p._collections.current_landscape_collection].offset
      else
        pal[32].collection = p._collections.current_collection
        pal[32].texture_index = p._collections.current_textures[p._collections.current_collection]
      end
      for idx, info in pairs(SCollections.collection_map) do
        pal[idx].texture_index = p._collections.current_textures[idx]
      end
    end
  end
end
function SCollections.set(p, coll, tex)
  local ci = SCollections.collection_map[coll]
  if ci == nil then return end
  if ci.type == "landscape" then
    p._collections.current_landscape_collection = coll
    p._collections.current_collection = 0
  else
    p._collections.current_collection = coll
  end
  p._collections.current_textures[coll] = tex
end
function SCollections.find_surface(p)
  local surface = nil
  local o, x, y, z, polygon = VML.find_target(p, false, false)
  if is_side(o) then
    o:recalculate_type()
    surface = VML.side_surface(o, z)
  elseif is_polygon_floor(o) or is_polygon_ceiling(o) then
    surface = o
  elseif is_polygon(o) then
    surface = o.floor
  elseif is_line(o) then
    -- we need to make a new side
    surface = VML.side_surface(Sides.new(polygon, o), z)
  end
  return surface, polygon
end


SUndo = {}
function SUndo.init()
  for p in Players() do
    p._undo = {}
    p._undo.undos = {}
    p._undo.redos = {}
    p._undo.current = {}
  end
end
function SUndo.update()
  for p in Players() do
    local cur_empty = true
    for k, v in pairs(p._undo.current) do
      cur_empty = false
      break
    end
    if not cur_empty then
      -- took undoable actions this frame; push onto undo stack
      table.insert(p._undo.undos, p._undo.current)
      p._undo.current = {}
      
      -- no redo if last action wasn't undo
      p._undo.redos = {}
      
      -- limit size of undo stack
      if #p._undo.undos > 64 then
        table.remove(p._undo.undos, 1)
      end
    elseif p._mode == SMode.apply then
      if p._keys.mic.down and p._keys.action.pressed then
        if SUndo.redo_active(p) then
          SUndo.redo(p)
        else
          SUndo.undo(p)
        end
      elseif p._keys.mic.down and p._keys.primary.released then
        if SUndo.undo_active(p) then SUndo.undo(p) end
      elseif p._keys.mic.down and p._keys.secondary.released then
        if SUndo.redo_active(p) then SUndo.redo(p) end
      end
    end
  end
end
function SUndo.undo_active(p)
  return #p._undo.undos > 0
end
function SUndo.redo_active(p)
  return #p._undo.redos > 0
end
function SUndo.undo(p)
  if #p._undo.undos < 1 then return end
  local un = table.remove(p._undo.undos)
  local redo = {}
  for s, f in pairs(un) do
    redo[s] = VML.build_undo(s)
    f()
  end
  table.insert(p._undo.redos, redo)
end
function SUndo.redo(p)
  if #p._undo.redos < 1 then return end
  local re = table.remove(p._undo.redos)
  local undo = {}
  for s, f in pairs(re) do
    undo[s] = VML.build_undo(s)
    f()
  end
  table.insert(p._undo.undos, undo)
end
function SUndo.add_undo(p, surface)
  if not p._undo.current[surface] then
    p._undo.current[surface] = VML.build_undo(surface)
  end
end
  
      
SCounts = {}
function SCounts.update()
  local turn = Game.ticks % 5
  local val = 0
  
  if turn == 0 then
    val = #Lights
  elseif turn == 1 then
    val = #Polygons
  elseif turn == 2 then
    val = #Platforms
  elseif turn == 3 then
    val = max_tags
  elseif turn == 4 then
    val = max_scripts
  end
  
  for p in Players() do
    if p.local_ then
      p.texture_palette.slots[33].texture_index = val % 128
      p.texture_palette.slots[34].texture_index = math.floor(val/128)
    end
  end
end


SPlatforms = {}
SPlatforms.sorted_platforms = {}
function SPlatforms.init()
  for plat in Platforms() do
    table.insert(SPlatforms.sorted_platforms, plat)
  end
  table.sort(SPlatforms.sorted_platforms, function(a, b) return a.polygon.index < b.polygon.index end)
end
function SPlatforms.update()
  local turn = Game.ticks % #Platforms
  local val = SPlatforms.sorted_platforms[turn+1].polygon.index
  
  for p in Players() do
    if p.local_ then
      p.texture_palette.slots[35].texture_index = val % 128
      p.texture_palette.slots[36].texture_index = math.floor(val/128)
    end
  end
end

UTeleport = {}
function UTeleport.highlight(p, poly)
  if not show_teleport_destination then return end
  if poly ~= p._teleport.last_target then
    UTeleport.end_highlight(p)
    p._teleport.last_target = poly
    p._teleport.last_target_mode = poly.floor.transfer_mode
    poly.floor.transfer_mode = "static"
  end
end
function UTeleport.end_highlight(p)
  if not show_teleport_destination then return end
  if p._teleport.last_target ~= nil then
    -- restore last selected poly
    p._teleport.last_target.floor.transfer_mode = p._teleport.last_target_mode
    p._teleport.last_target = nil
  end
end

VML = {}
VML.cw_endpoint_sides = {}
VML.ccw_endpoint_sides = {}
function VML.init()
  local endpoint, side
  for endpoint in Endpoints() do 
    VML.cw_endpoint_sides[endpoint] = {}
    VML.ccw_endpoint_sides[endpoint] = {}
  end
  for side in Sides() do
    table.insert(VML.cw_endpoint_sides[VML.get_clockwise_side_endpoint(side)], side)
    table.insert(VML.ccw_endpoint_sides[VML.get_counterclockwise_side_endpoint(side)], side)
  end
end
function VML.quantize(player, value)
   if player._quantize == 0 then
      return value
   end

   local ratio = 1.0 / snap_denominators[player._quantize]
   return math.floor(value / ratio + 0.5) * ratio
end
function VML.find_line_intersection(line, x0, y0, z0, x1, y1, z1)
   local dx = x1 - x0
   local dy = y1 - y0
   local dz = z1 - z0

   local ldx = line.endpoints[1].x - line.endpoints[0].x
   local ldy = line.endpoints[1].y - line.endpoints[0].y
   local t
   if ldx * dy - ldy * dx == 0 then
      t = 0
   else 
      t = (ldx * (line.endpoints[0].y - y0) + ldy * (x0 - line.endpoints[0].x)) / (ldx * dy - ldy * dx)
   end

   return x0 + t * dx, y0 + t * dy, z0 + t * dz
end
function VML.find_floor_or_ceiling_intersection(height, x0, y0, z0, x1, y1, z1)
   local dx = x1 - x0
   local dy = y1 - y0
   local dz = z1 - z0

   local t
   if dz == 0 then
      t = 0
   else
      t = (height - z0) / dz
   end

   return x0 + t * dx, y0 + t * dy, z
end
function VML.find_target(player, find_first_line, find_first_side)
   local polygon = player.monster.polygon
   local x0, y0, z0 = player.x, player.y, player.z + 0.6
   local x1, y1, z1 = x0, y0, z0
   local dx = math.cos(math.rad(player.pitch)) * math.cos(math.rad(player.yaw))
   local dy = math.cos(math.rad(player.pitch)) * math.sin(math.rad(player.yaw))
   local dz = math.sin(math.rad(player.pitch))

   local line

   x1 = x1 + dx
   y1 = y1 + dy
   z1 = z1 + dz
   repeat
      line = polygon:find_line_crossed_leaving(x0, y0, x1, y1)

      if line then
         local x, y, z = VML.find_line_intersection(line, x0, y0, z0, x1, y1, z1)
         if z > polygon.ceiling.height then
            x, y, z = VML.find_floor_or_ceiling_intersection(polygon.ceiling.height, x0, y0, z0, x1, y1, z1)
            return polygon.ceiling, x, y, z, polygon
         elseif z < polygon.floor.height then
            x, y, z = VML.find_floor_or_ceiling_intersection(polygon.ceiling.height, x0, y0, z0, x1, y1, z1)
            return polygon.floor, x, y, z, polygon
         else
            local opposite_polygon
            if line.clockwise_polygon == polygon then
               opposite_polygon = line.counterclockwise_polygon
            elseif line.counterclockwise_polygon == polygon then
               opposite_polygon = line.clockwise_polygon
            end

            if not opposite_polygon or find_first_line then
               -- always stop
               -- locate the side
               if line.clockwise_polygon == polygon then
                  if line.clockwise_side then
                     return line.clockwise_side, x, y, z, polygon
                  else
                     return line, x, y, z, polygon
                  end
               else
                  if line.counterclockwise_side then
                     return line.counterclockwise_side, x, y, z, polygon
                  else
                     return line, x, y, z, polygon
                  end
               end
            elseif find_first_side and line.has_transparent_side then
               if line.clockwise_polygon == polygon then
                  return line.clockwise_side, x, y, z, polygon
               else
                  return line.counterclockwise_side, x, y, z, polygon
               end
            else
               -- can we pass
               if z < opposite_polygon.floor.height or z > opposite_polygon.ceiling.height then
                  if line.clockwise_polygon == polygon then
                     if line.clockwise_side then
                        return line.clockwise_side, x, y, z, polygon
                     else
                        return line, x, y, z, polygon
                     end
                  else
                     if line.counterclockwise_side then
                        return line.counterclockwise_side, x, y, z, polygon
                     else
                        return line, x, y, z, polygon
                     end
                  end
               else
                  -- pass
                  polygon = opposite_polygon
               end
            end
         end
      else
         -- check if we hit the floor, or ceiling
         if z1 > polygon.ceiling.height then
            local x, y, z = VML.find_floor_or_ceiling_intersection(polygon.ceiling.height, x0, y0, z0, x1, y1, z1)
            return polygon.ceiling, x, y, z, polygon
         elseif z1 < polygon.floor.height then
            local x, y, z = VML.find_floor_or_ceiling_intersection(polygon.floor.height, x0, y0, z0, x1, y1, z1)
            return polygon.floor, x, y, z, polygon
         else
            x1 = x1 + dx
            y1 = y1 + dy
            z1 = z1 + dz
         end
      end
   until x1 > 32 or x1 < -32 or y1 > 32 or y1 < -32 or z1 > 32 or z1 < -32
   -- uh oh
   print("POOP!")
   return nil
end
function VML.get_clockwise_side_endpoint(side)
  local line_is_clockwise = true
  if side.line.clockwise_polygon ~= side.polygon then
    -- counterclockwise line
    return side.line.endpoints[0]
  else
    return side.line.endpoints[1]
  end
end
function VML.get_counterclockwise_side_endpoint(side)
  local line_is_clockwise = true
  if side.line.clockwise_polygon ~= side.polygon then
    -- counterclockwise line
    return side.line.endpoints[1]
  else
    return side.line.endpoints[0]
  end
end
function VML.side_surface(side, z)
   if side.type == "full" then
      local opposite_polygon
      if side.line.clockwise_side == side then
         opposite_polygon = side.line.counterclockwise_polygon
      else
         opposite_polygon = side.line.clockwise_polygon
      end
      if opposite_polygon then
         return side.transparent
      else
         return side.primary
      end
   elseif side.type == "high" then
      if z > side.line.lowest_adjacent_ceiling then
         return side.primary
      else
         return side.transparent
      end
   elseif side.type == "low" then
      if z < side.line.highest_adjacent_floor then
         return side.primary
      else
         return side.transparent
      end
   else
      if z > side.line.lowest_adjacent_ceiling then
         return side.primary
      elseif z < side.line.highest_adjacent_floor then
         return side.secondary
      else
         return side.transparent
      end
   end
end
function VML.surface_heights(surface)
   local side = Sides[surface.index]
   if is_primary_side(surface) then
      if side.type == "full" then
         return side.polygon.floor.height, side.polygon.ceiling.height
      elseif side.type == "low" then
         return side.polygon.floor.height, side.line.highest_adjacent_floor
      else
         return side.line.lowest_adjacent_ceiling, side.polygon.ceiling.height
      end
   elseif is_secondary_side(surface) then
      if side.type == "split" then
         return side.polygon.floor.height, side.line.highest_adjacent_floor
      else
         return nil
      end
   else -- transparent
      if side.type == "full" then
         return side.polygon.floor.height, side.polygon.ceiling.height
      elseif side.type == "low" then
         return side.line.highest_adjacent_floor, side.polygon.ceiling.height
      elseif side.type == "high" then
         return side.polygon.floor.height, side.line.lowest_adjacent_ceiling
      else -- split
         return side.line.highest_adjacent_floor, side.line.lowest_adjacent_ceiling
      end
   end
end
function VML.build_undo(surface)
  local collection = surface.collection
  local texture_index = surface.texture_index
  local transfer_mode = surface.transfer_mode
  local light = surface.light
  local texture_x = surface.texture_x
  local texture_y = surface.texture_y
  local empty = is_transparent_side(surface) and surface.empty
  local device
  if is_primary_side(surface) then
    local side = Sides[surface.index]
    if side.control_panel then
      device = {}
      device.device = side.control_panel.type
      device.light_dependent = side.control_panel.light_dependent
      device.permutation = side.control_panel.permutation
      device.only_toggled_by_weapons = side.control_panel.only_toggled_by_weapons
      device.repair = side.control_panel.repair
      device.status = side.control_panel.status
    end
  end
  local function undo()
    if empty then
      surface.empty = true
    else
      if collection then
        surface.collection = collection
      end
      surface.texture_index = texture_index
      surface.transfer_mode = transfer_mode
      surface.light = light
      if device then
        VML.save_control_panel(Sides[surface.index], device)
      elseif is_primary_side(surface) then
        Sides[surface.index].control_panel = false
      end
    end
    surface.texture_x = texture_x
    surface.texture_y = texture_y
  end
  return undo
end
function VML.undo(player)
  if not player._undo then return end
  local redo = {}
  for s, f in pairs(player._undo) do
    redo[s] = build_undo(s)
    f()
  end
  player._undo = redo
end
function VML.valid_surfaces(side) 
  local surfaces = {}
  if side.type == "split" then
    table.insert(surfaces, side.primary)
    table.insert(surfaces, side.secondary)
    table.insert(surfaces, side.transparent)
  elseif side.type == "full" then
    table.insert(surfaces, side.primary)
  else
    table.insert(surfaces, side.primary)
    table.insert(surfaces, side.transparent)
  end
  return surfaces
end
function VML.build_side_offsets_table(first_surface)
  local surfaces = {}
  local offsets = {} -- surface -> offset

  table.insert(surfaces, first_surface)
  offsets[first_surface] = 0

  while # surfaces > 0 do
    -- remove the first surface
    local surface = table.remove(surfaces, 1)
    local low, high = VML.surface_heights(surface)
    
    local side = Sides[surface.index]

    -- consider neighboring surfaces on this side
    local neighbors = {}
    
    if side.type == "split" then
      if is_transparent_side(surface) then
        table.insert(neighbors, side.primary)
        table.insert(neighbors, side.secondary)
      else
        -- check for "joined" split
        local bottom, top = VML.surface_heights(side.transparent)
        if bottom == top then
          if is_primary_side(surface) then
            table.insert(neighbors, side.secondary)
          else
            table.insert(neighbors, side.primary)
          end
        else
          table.insert(neighbors, side.transparent)
        end
      end
    elseif side.type ~= "full" then
      if is_primary_side(surface) then
        table.insert(neighbors, side.transparent)
      elseif is_transparent_side(surface) then
        table.insert(neighbors, side.primary)
      end
    end

    for _, neighbor in pairs(neighbors) do
      if offsets[neighbor] == nil 
        and surface.texture_index == neighbor.texture_index
        and surface.collection == neighbor.collection
      then
        offsets[neighbor] = offsets[surface]
        table.insert(surfaces, neighbor)
      end
    end

    local line = Sides[surface.index].line
    local length = line.length
    -- consider any clockwise adjacent surfaces within our height range
    for _, side in pairs(VML.ccw_endpoint_sides[VML.get_clockwise_side_endpoint(Sides[surface.index])]) do
      if side.line ~= line then
        for _, neighbor_surface in pairs(VML.valid_surfaces(side)) do
          local bottom, top = VML.surface_heights(neighbor_surface)
          if offsets[neighbor_surface] == nil
            and neighbor_surface.texture_index == surface.texture_index
            and neighbor_surface.collection == surface.collection
            and high > bottom and top > low
          then
            offsets[neighbor_surface] = offsets[surface] + length
            table.insert(surfaces, neighbor_surface)
          end
        end
      end
    end

    -- consider any counterclockwise adjacent surfaces within our height range
    for _, side in pairs(VML.cw_endpoint_sides[VML.get_counterclockwise_side_endpoint(Sides[surface.index])]) do

      if side.line ~= line then
        for _, neighbor_surface in pairs(VML.valid_surfaces(side)) do
          local bottom, top = VML.surface_heights(neighbor_surface)
          if offsets[neighbor_surface] == nil
            and neighbor_surface.texture_index == surface.texture_index
            and neighbor_surface.collection == surface.collection
            and high > bottom and top > low
          then
            offsets[neighbor_surface] = offsets[surface] - side.line.length
            table.insert(surfaces, neighbor_surface)
          end
        end
      end
    end
  end
  
  return offsets
end
function VML.align_sides(surface, offsets)
  local x = surface.texture_x
  local y = surface.texture_y
  local _, top = VML.surface_heights(surface)

  for surface, offset in pairs(offsets) do
    local _, new_top = VML.surface_heights(surface)
    surface.texture_x = x + offset
    surface.texture_y = y + top - new_top
  end
end
function VML.build_polygon_align_table(polygon, surface)
  local polygons = {}
  local accessor
  if is_polygon_floor(surface) then
    accessor = "floor"
  else
    accessor = "ceiling"
  end

  local function recurse(p)
    if not polygons[p] -- already visited
      and p[accessor].texture_index == surface.texture_index 
      and p[accessor].collection == surface.collection 
      and p[accessor].z == surface.z
    then
      -- add this polygon, and search for any adjacent
      polygons[p] = true
      for adjacent in p:adjacent_polygons() do
        recurse(adjacent)
      end
    end
  end

  recurse(polygon)
  return polygons
end
function VML.align_polygons(surface, align_table)
  local x = surface.texture_x
  local y = surface.texture_y
  
  local accessor
  if is_polygon_floor(surface) then
    accessor = "floor"
  else
    accessor = "ceiling"
  end
  for p in pairs(align_table) do
    p[accessor].texture_x = x
    p[accessor].texture_y = y
  end
end
function VML.is_switch(device)
  return device.class == "light switch" or device.class == "tag switch" or device.class == "platform switch"
end
function VML.save_control_panel(side, device)
  side.control_panel = true
  side.control_panel.light_dependent = device.light_dependent
  side.control_panel.permutation = device.permutation
  if VML.is_switch(device.device) then
    side.control_panel.only_toggled_by_weapons = device.only_toggled_by_weapons
    side.control_panel.repair = device.repair
    side.control_panel.can_be_destroyed = (device.device._type == "wires")
    side.control_panel.uses_item = (device.device._type == "chip insertion")
    if device.device.class == "light switch" then
      side.control_panel.status = Lights[side.control_panel.permutation].active
    elseif device.device.class == "platform_switch" then
      side.control_panel.status = Polygons[side.control_panel.permutation].platform.active
    else
      side.control_panel.status = device.status
    end
  else
    side.control_panel.only_toggled_by_weapons = false
    side.control_panel.repair = false
    side.control_panel.can_be_destroyed = false
    side.control_panel.uses_item = false
    side.control_panel.status = false
  end
  side.control_panel.type = device.device
end
