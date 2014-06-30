-- Vasara 1.0 rc3 (Script)
-- by Hopper and Ares Ex Machina
-- from work by Irons and Smith, released under the JUICE LICENSE!

-- PREFERENCES

walls = { 17, 18, 19, 20, 21 } 
landscapes = { 27, 28, 29, 30 }

suppress_items = true
suppress_monsters = true

max_tags = 90     -- max: 90
max_scripts = 90  -- max: 90

-- highlight selected destination in Teleport mode
show_teleport_destination = true

-- cursor speed settings: larger numbers mean a slower mouse
menu_vertical_range = 30      -- default: 30
menu_horizontal_range = 70    -- default: 70
drag_vertical_range = 80      -- default: 80
drag_horizontal_range = 120   -- default: 120

-- how far you can drag a texture before it stops moving (in World Units)
drag_vertical_limit = 1
drag_horizontal_limit = 1

-- how many ticks before you start dragging a texture
drag_initial_delay = 3

-- how many ticks between fast forward/rewind steps
ffw_initial_delay = 5
ffw_repeat_delay = 0
ffw_texture_scrub_speed = 0
ffw_teleport_scrub_speed = 1

-- how many ticks to highlight a latched keypress in HUD
key_highlight_delay = 4


-- END PREFERENCES -- no user serviceable parts below ;)

Game.monsters_replenish = not suppress_monsters
snap_denominators = { 2, 3, 4, 5, 8 }
snap_modes = { "Off" }
for _,d in ipairs(snap_denominators) do
  table.insert(snap_modes, "1/" .. d .. " WU")
end
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
      pal.size = 256
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
  SPanel.init()
  SPlatforms.init()
  SFreeze.init()
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
  SLights.update()
  SPlatforms.update()
  SFreeze.update()
  SMode.update()
  SUndo.update()
  SStatus.update()
  SCollections.update()
  SPanel.update()
  
  for p in Players() do
    p.life = 450
    p.oxygen = 10800
  end
end
function Triggers.postidle()
  SFreeze.postidle()
  for p in Players() do
    p.life = 409  -- signal to HUD that Vasara is active
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
  p.life = 450
  p.oxygen = 10800
end

function PIN(v, min, max)
  if v < min then return min end
  if v > max then return max end
  return v
end

SMode = {}
SMode.apply = 0
SMode.choose = 1
SMode.attribute = 2
SMode.teleport = 3
SMode.panel = 4

function SMode.init()
  for p in Players() do
    p._mode = SMode.apply
    p._prev_mode = SMode.apply
    p._mic_dummy = false
    p._target_poly = 0
    p._quantize = 0
    p._menu_button = nil
    p._menu_item = 0
    p._cursor_x = 320
    p._cursor_y = 240
    p._advanced_mode = false
    
    p._apply = {}
    p._apply.texture = true
    p._apply.light = true
    p._apply.transfer = true
    p._apply.align = true
    p._apply.transparent = false
    p._apply.edit_panels = true
        
    p._teleport = {}
    p._teleport.last_target = nil
    p._teleport.last_target_mode = nil
    
    p._panel = {}
    p._panel.editing = false
    p._panel.classnum = 0
    p._panel.permutation = 0
    p._panel.light_dependent = false
    p._panel.only_toggled_by_weapons = false
    p._panel.repair = false
    p._panel.status = false
    p._panel.surface = nil
    p._panel.sides = {}
    p._panel.dinfo = nil
    
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
    p._saved_surface.dragstart = 0
    p._saved_surface.align_table = nil
    p._saved_surface.offset_table = nil
    p._saved_surface.opposite_surface = nil
    p._saved_surface.opposite_offsets = nil
    p._saved_surface.opposite_rem = 0
    
--     p._annotation = Annotations.new(Polygons[0], "")
    
    if p.local_ then
      p.texture_palette.slots[40].texture_index = p._mode
    end
  end
end
function SMode.current_menu_name(p)
  if p._mode == SMode.attribute then
    return SMode.attribute
  elseif p._mode == SMode.choose then
    return "choose_" .. p._collections.current_collection
  elseif p._mode == SMode.panel then
    return SPanel.menu_name(p)
  end
  return nil
end
function SMode.update()
  for p in Players() do
    
    p._prev_mode = p._mode

    -- process mode actions
    if p._mode == SMode.apply then
      SMode.handle_apply(p)
    elseif p._mode == SMode.teleport then
      SMode.handle_teleport(p)
    elseif p._mode == SMode.choose then
      SMode.handle_choose(p)
    elseif p._mode == SMode.attribute then
      SMode.handle_attribute(p)
    elseif p._mode == SMode.panel then
      SMode.handle_panel(p)
    end
    
    -- handle mode switches
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
          SMode.toggle(p, SMode.attribute)
        end
      elseif p._keys.mic.released and (not p._mic_dummy) then
        SMode.toggle(p, SMode.choose)
      elseif p._keys.secondary.released and p._mode ~= SMode.apply then
        SMode.toggle(p, p._mode)
      end
    end
    
    -- track mic-as-modifier, and don't switch if we use that
    if p._keys.mic.down then
      if p._keys.prev_weapon.down or p._keys.next_weapon.down or p._keys.action.down or p._keys.primary.down or p._keys.primary.released or p._keys.secondary.down or p._keys.secondary.released then
        p._mic_dummy = true
      end
    elseif p._keys.mic.released then
      p._mic_dummy = false
    end
    
    local in_menu = SMode.menu_mode(p._mode)
    
    if p._mode ~= p._prev_mode then
      p._menu_button = nil
      p._menu_item = 0
      local was_menu = SMode.menu_mode(p._prev_mode)
      
      -- special cleanup for exiting modes
      if p._prev_mode == SMode.teleport then
        UTeleport.remove_highlight(p)
      elseif p._prev_mode == SMode.panel then
        SPanel.stop_editing(p)
      end
      
      -- special setup for entering modes
      if p._mode == SMode.attribute then
        SMode.start_attribute(p)
      end
      
      if in_menu then
        SFreeze.enter_mode(p, "menu")
      else
        SFreeze.enter_mode(p, nil)
      end
    end

    if p.local_ then
      p.texture_palette.slots[37].texture_index = p._target_poly % 128
      p.texture_palette.slots[38].texture_index = math.floor(p._target_poly/128)
      p.texture_palette.slots[40].texture_index = p._mode
      
      -- set cursor
      if in_menu then
        p._cursor_x, p._cursor_y = SFreeze.coord(p)
      elseif p._mode == SMode.apply then
        p._cursor_x = 320
        p._cursor_y = 72 + 160
        if p._advanced_mode then p._cursor_y = 196 end
        if SFreeze.in_mode(p, "drag") then
          local delta_yaw, delta_pitch
          delta_yaw, delta_pitch = SFreeze.coord(p)
          p._cursor_x = p._cursor_x + math.floor(delta_yaw * 300.0/1024.0)
          p._cursor_y = p._cursor_y + math.floor(delta_pitch * 140.0/1024.0)
        end
      elseif p._mode == SMode.teleport then
        p._cursor_x = 320
        p._cursor_y = math.floor((3*72 + 480)/4)
        if p._advanced_mode then p._cursor_y = 480/4 end
      end
    end
  end
end
function SMode.menu_mode(mode)
  return mode == SMode.choose or mode == SMode.attribute or mode == SMode.panel
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
    if p._keys.next_weapon.held then
      SFreeze.unfreeze(p)
      p:accelerate(0, 0, 0.05)
    elseif p._keys.prev_weapon.pressed then
      SFreeze.toggle_freeze(p)
    end
  else
    if p._keys.primary.down then
      -- apply
      clear_surface = false
      local surface = p._saved_surface.surface
      if p._keys.primary.pressed then
        surface, polygon = SCollections.find_surface(p, false)
        local coll = p._collections.current_collection
        local landscape = false
        if coll == 0 then
          coll = p._collections.current_landscape_collection
          landscape = true
        end
        local tex = p._collections.current_textures[coll]
        
        p._saved_surface.surface = surface
        p._saved_surface.opposite_surface = nil
        p._saved_surface.polygon = polygon
        if (not p._apply.texture) or (surface.collection and (coll == surface.collection.index) and (tex == surface.texture_index)) then
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
        p._saved_surface.dragstart = Game.ticks
        
        SUndo.add_undo(p, surface)
        UApply.apply_texture(p, surface, coll, tex, landscape)
        if is_transparent_side(surface) then
          -- put the same texture on the opposite side of the line
          local dsurface = nil
          local side = Sides[surface.index]
          local line = side.line
          if line.clockwise_side == side then
            if line.counterclockwise_side then
              dsurface = line.counterclockwise_side.transparent
            elseif line.counterclockwise_polygon then
              dsurface = Sides.new(line.counterclockwise_polygon, line).transparent
            end
          else
            if line.clockwise_side then
              dsurface = line.clockwise_side.transparent
            elseif line.clockwise_polygon then
              dsurface = Sides.new(line.clockwise_polygon, line).transparent
            end
          end

          if dsurface then
            SUndo.add_undo(p, dsurface)
            UApply.apply_texture(p, dsurface, coll, tex, landscape)
            local rem = line.length - math.floor(line.length)
            dsurface.texture_x = 0 - dsurface.texture_x - rem
            p._saved_surface.opposite_surface = dsurface
            p._saved_surface.opposite_rem = rem
          end
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
            
            local dsurface = p._saved_surface.opposite_surface
            if dsurface then
              local doffsets = VML.build_side_offsets_table(dsurface)
              p._saved_surface.opposite_offsets = doffsets
              for s in pairs(doffsets) do
                SUndo.add_undo(p, s)
              end
              VML.align_sides(dsurface, doffsets)
            end
          end
        end
      
      elseif surface and (Game.ticks > p._keys.primary.first + drag_initial_delay) then
        SFreeze.enter_mode(p, "drag")
        
        local delta_yaw, delta_pitch
        delta_yaw, delta_pitch = SFreeze.coord(p)
        delta_yaw = delta_yaw / 1024.0
        delta_pitch = delta_pitch / 1024.0
        
        if is_polygon_floor(surface) or is_polygon_ceiling(surface) then
          if is_polygon_ceiling(surface) then delta_pitch = -delta_pitch end

          local orad = math.rad(SFreeze.orig_dir(p))
          local xoff = delta_pitch * math.cos(orad) + delta_yaw * math.sin(orad)
          local yoff = delta_pitch * math.sin(orad) - delta_yaw * math.cos(orad)
                    
          surface.texture_x = VML.quantize(p, p._saved_surface.x + xoff)
          surface.texture_y = VML.quantize(p, p._saved_surface.y + yoff)
          
          if p._apply.align then
            VML.align_polygons(surface, p._saved_surface.align_table)
          end
        else
          surface.texture_x = VML.quantize(p, p._saved_surface.x - delta_yaw)
          surface.texture_y = VML.quantize(p, p._saved_surface.y - delta_pitch)
          
          if p._apply.align then
            VML.align_sides(surface, p._saved_surface.offset_table)
          end
          
          local dsurface = p._saved_surface.opposite_surface
          if dsurface then
            dsurface.texture_x = 0 - surface.texture_x - p._saved_surface.opposite_rem
            dsurface.texture_y = surface.texture_y
            if p._apply.align then
              VML.align_sides(dsurface, p._saved_surface.opposite_offsets)
            end
          end            
        end
      end
    elseif p._keys.primary.released then
      -- release any drag
      SFreeze.enter_mode(p, nil)
      
      -- are we editing control panels
      if p._apply.texture and p._apply.edit_panels and is_primary_side(p._saved_surface.surface) then
        if SPanel.surface_can_hold_panel(p._saved_surface.surface) then
          -- valid for control panels; configure it
          SPanel.start_editing(p, p._saved_surface.surface)
          if p._apply.align then
            for s in pairs(p._saved_surface.offset_table) do
              SPanel.add_for_editing(p, s)
            end
          end
          clear_surface = false
          SMode.toggle(p, SMode.panel)
        else
          -- not a valid texture for control panels; clear it
          Sides[p._saved_surface.surface.index].control_panel = false
          if p._apply.align then
            for s in pairs(p._saved_surface.offset_table) do
              Sides[s.index].control_panel = false
            end
          end
        end
      end
    elseif p._keys.secondary.released then
      -- sample
      local surface = SCollections.find_surface(p, true)
      if surface and (not (is_transparent_side(surface) and surface.empty)) then
        SCollections.set(p, surface.collection.index, surface.texture_index)
        if p._collections.current_collection ~= 0 then
          p._light = surface.light.index
          p._transfer_mode = transfer_mode_lookup[surface.transfer_mode]
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
    local o, x, y, z, poly = VML.find_target(p, false, false)
    if poly then
      p._target_poly = poly.index
      UTeleport.highlight(p, poly)
    end
    
    SMode.annotate(p)
  end
  
  if p._keys.mic.down then
    if p._keys.next_weapon.held then
      SFreeze.unfreeze(p)
      p:accelerate(0, 0, 0.05)
    elseif p._keys.prev_weapon.pressed then
      SFreeze.toggle_freeze(p)
    end
  end

  if (not p._keys.mic.down) and p._keys.primary.released then
    local poly = Polygons[p._target_poly]
    p:position(poly.x, poly.y, poly.z, poly)
    p.monster:play_sound("teleport in")
    UTeleport.remove_highlight(p)
    SFreeze.unfreeze(p)
    return
  end
  
  if ((not p._keys.mic.down) and (p._keys.prev_weapon.held or p._keys.next_weapon.held)) or (p._keys.mic.down and (p._keys.primary.held or p._keys.secondary.held)) then
    local diff = 1
    if p._keys.prev_weapon.held and (not p._keys.mic.down) then
      diff = -1
    elseif p._keys.primary.held and p._keys.mic.down then
      if p._keys.primary.repeated then
        diff = 1 + ffw_teleport_scrub_speed
      else
        diff = 1
      end
    elseif p._keys.secondary.held and p._keys.mic.down then
      if p._keys.secondary.repeated then
        diff = -1 - ffw_teleport_scrub_speed
      else
        diff = -1
      end
    end
    p._target_poly = (p._target_poly + diff) % #Polygons
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
--   p._annotation.polygon = poly
--   p._annotation.text = poly.index
--   p._annotation.x = poly.x
--   p._annotation.y = poly.y
end
function SMode.handle_choose(p)
  -- cycle textures
  if (p._keys.mic.down and (p._keys.primary.held or p._keys.secondary.held)) or ((not p._keys.mic.down) and (p._keys.prev_weapon.held or p._keys.next_weapon.held)) then
    local diff = 1
    if p._keys.prev_weapon.held then
      diff = -1
    elseif p._keys.mic.down and p._keys.primary.repeated then
      diff = 1 + ffw_texture_scrub_speed
    elseif p._keys.mic.down and p._keys.secondary.repeated then
      diff = 0 - (1 + ffw_texture_scrub_speed)
    elseif p._keys.mic.down and p._keys.secondary.held then
      diff = -1
    end
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
      
      tex = (tex + diff) % bct
      for _, collection in pairs(SCollections.landscape_collections) do
        local info = SCollections.collection_map[collection]
        if tex >= info.offset and tex < (info.offset + info.count) then
          local ct = tex - info.offset
          SCollections.set(p, collection, ct)
          break
        end
      end
    else
      local tex = p._collections.current_textures[cur]
      local bct = Collections[cur].bitmap_count
      local ct = (tex + diff) % bct
      SCollections.set(p, cur, ct)
    end
  end
  
  if p._keys.mic.down and (p._keys.next_weapon.held or p._keys.prev_weapon.held) then
    -- cycle collections
    local diff = 1
    if p._keys.prev_weapon.held then diff = -1 end
    
    local cur = p._collections.current_collection
    local ci = 0
    for i, c in ipairs(SCollections.wall_collections) do
      if cur == c then
        ci = i
        break
      end
    end
    ci = (ci + diff) % (#SCollections.wall_collections + 1)
    if ci == 0 then
      p._collections.current_collection = 0
    else
      p._collections.current_collection = SCollections.wall_collections[ci]
    end
  end
    
  -- handle menu
  if (not p._keys.mic.down) and p._keys.primary.released then
    local name = SMenu.selection(p)
    if name == nil then return end
    
    if string.sub(name, 1, 7) == "choose_" then
      local cc, ct = string.match(name, "(%d+)_(%d+)")
      cc = cc + 0
      ct = ct + 0
      p._collections.current_collection = cc
      p._collections.current_textures[cc] = ct
      for _, coll in pairs(SCollections.landscape_collections) do
        if coll == cc then
          p._collections.current_collection = 0
          p._collections.current_landscape_collection = cc
          break
        end
      end
    elseif string.sub(name, 1, 5) == "coll_" then
      local mode = tonumber(string.sub(name, 6))
      p._collections.current_collection = mode
    end
  end

end
function SMode.start_attribute(p)
  p._apply_saved = {}
  p._apply_saved.light = p._apply.light
  p._apply_saved.texture = p._apply.texture
  p._apply_saved.align = p._apply.align
  p._apply_saved.transparent = p._apply.transparent
  p._apply_saved.edit_panels = p._apply.edit_panels
  p._apply_saved.advanced_mode = p._advanced_mode
  p._apply_saved.quantize = p._quantize
  p._apply_saved.transfer_mode = p._transfer_mode
  p._apply_saved.cur_light = p._light
end
function SMode.revert_attribute(p)
  p._apply.light = p._apply_saved.light
  p._apply.texture = p._apply_saved.texture
  p._apply.align = p._apply_saved.align
  p._apply.transparent = p._apply_saved.transparent
  p._apply.edit_panels = p._apply_saved.edit_panels
  p._advanced_mode = p._apply_saved.advanced_mode
  p._quantize = p._apply_saved.quantize
  p._transfer_mode = p._apply_saved.transfer_mode
  p._light = p._apply_saved.cur_light
end
function SMode.default_attribute(p)
  p._apply.light = true
  p._apply.texture = true
  p._apply.align = true
  p._apply.transparent = false
  p._apply.edit_panels = true
  p._advanced_mode = false
  p._quantize = 0
  p._transfer_mode = 0
  p._light = 0
end
function SMode.handle_attribute(p)
  if p._keys.mic.down then
    if p._keys.prev_weapon.pressed then
      p._apply.align = not p._apply.align
    end
    if p._keys.next_weapon.pressed then
      p._apply.transparent = not p._apply.transparent
    end
    if p._keys.primary.released then
      SMode.default_attribute(p)
    end
    if p._keys.secondary.released then
      SMode.revert_attribute(p)
    end
  else
    if p._keys.prev_weapon.pressed then
      p._light = (p._light - 1) % #Lights
    elseif p._keys.next_weapon.pressed then
      p._light = (p._light + 1) % #Lights
    end
  end
  
  -- handle menu
  if (not p._keys.mic.down) and p._keys.primary.released then
    local name = SMenu.selection(p)
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
    elseif name == "advanced" then
      p._advanced_mode = not p._advanced_mode
    elseif string.sub(name, 1, 5) == "snap_" then
      local mode = tonumber(string.sub(name, 6))
      p._quantize = mode
    elseif string.sub(name, 1, 9) == "transfer_" then
      if p._apply.texture then
        local mode = tonumber(string.sub(name, 10))
        p._transfer_mode = mode
      end
    elseif string.sub(name, 1, 6) == "light_" then
      local mode = tonumber(string.sub(name, 7))
      p._light = mode
    end
  end
end
function SMode.handle_panel(p)
  if not p._keys.mic.down then
    if p._keys.prev_weapon.pressed then
      SPanel.cycle_permutation(p, -1)
    end
    if p._keys.next_weapon.pressed then
      SPanel.cycle_permutation(p, 1)
    end
    if p._keys.secondary.released then
      SPanel.revert(p)
    end
  else
    if p._keys.prev_weapon.pressed then
      SPanel.cycle_class(p, -1)
    end
    if p._keys.next_weapon.pressed then
      SPanel.cycle_class(p, 1)
    end
  end
  
  -- handle menu
  if (not p._keys.mic.down) and p._keys.primary.released then
    local name = SMenu.selection(p)
    if name == nil then return end
    
    if name == "panel_light" then
      p._panel.light_dependent = not p._panel.light_dependent
    elseif name == "panel_weapon" then
      p._panel.only_toggled_by_weapons = not p._panel.only_toggled_by_weapons
    elseif name == "panel_repair" then
      p._panel.repair = not p._panel.repair
    elseif name == "panel_active" then
      p._panel.status = not p._panel.status
    elseif string.sub(name, 1, 6) == "ptype_" then
      local mode = tonumber(string.sub(name, 7))
      if mode == 0 or p._panel.dinfo[mode] ~= nil then
        p._panel.classnum = mode
      end
    elseif string.sub(name, 1, 6) == "pperm_" then
      local mode = tonumber(string.sub(name, 7))
      p._panel.permutation = mode
    end
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
  k.repeated = false
  local passed = ticks - k.first
  
  if k.down then
    k.highlight = true
    if passed == 0 then
      k.held = true
    elseif passed >= ffw_initial_delay then
      if ((passed - ffw_initial_delay) % (ffw_repeat_delay + 1)) == 0 then
        k.held = true
        k.repeated = true
      end
    end
  elseif passed < (key_highlight_delay + 1) then
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
        
        local dummy = 0
        if p._mic_dummy then dummy = dummy + 4 end
        
        p.texture_palette.slots[42].texture_index = dummy
      end
    end
  end
end

SFreeze = {}
SFreeze.ranges = {}
SFreeze.ranges["menu"] = {
  xsize = 600, ysize = 320,
  xoff = 20, yoff = 80,
  xrange = menu_horizontal_range, yrange = menu_vertical_range }
SFreeze.ranges["drag"] = {
  xsize = 2048*drag_horizontal_limit, ysize = 2048*drag_vertical_limit,
  xoff = -1024*drag_horizontal_limit, yoff = -1024*drag_vertical_limit,
  xrange = drag_horizontal_range, yrange = drag_vertical_range }
function SFreeze.init()
  for _,rr in pairs(SFreeze.ranges) do
    rr.xscale = rr.xsize / (rr.xrange * 2)
    rr.yscale = rr.ysize / (rr.yrange * 2)
  end
  for p in Players() do
    p._freeze = {}
    p._freeze.frozen = false
    p._freeze.mode = nil
    p._freeze.point = {}
    p._freeze.point.x = 0
    p._freeze.point.y = 0
    p._freeze.point.z = 0
    p._freeze.point.poly = 0
    p._freeze.point.direction = 0
    p._freeze.point.elevation = 0
    p._freeze.restore = {}
    p._freeze.restore.direction = 0
    p._freeze.restore.elevation = 0
  end
end
function SFreeze.postidle()
  for p in Players() do
    if p._freeze.mode then
      p._freeze.restore.direction = p.direction
      p._freeze.restore.elevation = p.elevation
      p.direction = p._freeze.point.direction
      p.elevation = p._freeze.point.elevation
    end
    if p._freeze.frozen or p._freeze.mode then
      SFreeze.reposition(p)
    end
  end
end
function SFreeze.reposition(p)
  local z = p._freeze.point.z
  if p._freeze.mode == "menu" then z = p.polygon.z end
  p:position(p._freeze.point.x, p._freeze.point.y, z, p._freeze.point.poly)
  p.external_velocity.i = 0
  p.external_velocity.j = 0
  p.external_velocity.k = 0
end
function SFreeze.freeze(p)
  if p._freeze.frozen then return end
  p._freeze.frozen = true
  if not p._freeze.mode then
    p._freeze.point.x = p.x
    p._freeze.point.y = p.y
    p._freeze.point.z = math.max(p.z, p.polygon.z + 1/1024.0)
    p._freeze.point.poly = p.polygon
    SFreeze.reposition(p)
  end
end
function SFreeze.unfreeze(p)
  p._freeze.frozen = false
end
function SFreeze.toggle_freeze(p)
  if p._freeze.frozen then
    SFreeze.unfreeze(p)
  else
    SFreeze.freeze(p)
  end
end
function SFreeze.frozen(p)
  return p._freeze.frozen
end
function SFreeze.enter_mode(p, mode)
  local old_mode = p._freeze.mode
  if old_mode == mode then return end
  if old_mode then
    p.direction = p._freeze.point.direction
    p.elevation = p._freeze.point.elevation
  end
  if mode then
    if not p._freeze.frozen then
      p._freeze.point.x = p.x
      p._freeze.point.y = p.y
      p._freeze.point.z = math.max(p.z, p.polygon.z + 1/1024.0)
      p._freeze.point.poly = p.polygon
      SFreeze.reposition(p)
    end
    p._freeze.point.direction = p.direction
    p._freeze.point.elevation = p.elevation
    p._freeze.extra_dir = 0
    p._freeze.extra_elev = 0
    p._freeze.last_forward = p.internal_velocity.forward
    p._freeze.last_perpendicular = p.internal_velocity.perpendicular
    p._freeze.last_motion = {}
    p._freeze.last_motion["forward"] = 0
    p._freeze.last_motion["perpendicular"] = 0
    p.direction = 180
    p.elevation = 0
  end
  p._freeze.mode = mode
end
function SFreeze.in_mode(p, mode)
  return p._freeze.mode == mode
end
function SFreeze.detect_motion(p, which)
  if not p._freeze.mode then return 0 end
  
  local last = p._freeze["last_" .. which]
  if last == nil then last = 0 end
  local cur = p.internal_velocity[which]
  p._freeze["last_" .. which] = cur
  
  local exp = 0
  if last < 0 then
    exp = math.min(0, last + 0.02)
  elseif last > 0 then
    exp = math.max(0, last - 0.02)
  end
  
  local res = tonumber(string.format("%.4f", cur - exp))
  if (cur - exp) < -0.001 then
    return -1
  elseif (cur + exp) > 0.001 then
    return 1
  end
  return 0
end
function SFreeze.update()
  for p in Players() do
    if p._freeze.frozen or p._freeze.mode then
      SFreeze.reposition(p)
    end
    if p._freeze.mode then
      p.direction = p._freeze.restore.direction
      p.elevation = p._freeze.restore.elevation
      local check_direction = true
      
      if p._freeze.mode == "menu" then
        -- check for movement keys
        local last_mov = {}
        local cur_mov = {}
        local any_move = false
        for _,dir in pairs({ "forward", "perpendicular" }) do
          last_mov[dir] = p._freeze.last_motion[dir]
          cur_mov[dir] = SFreeze.detect_motion(p, dir)
          p._freeze.last_motion[dir] = cur_mov[dir]
          if cur_mov[dir] ~= 0 and cur_mov[dir] ~= last_mov[dir] then
            any_move = true
          end
        end
        if any_move then
          -- position cursor to closest menu item
          local item
          if cur_mov["forward"] == 1 then
            item = SMenu.find_next(p, "up")
          elseif cur_mov["forward"] == -1 then
            item = SMenu.find_next(p, "down")
          elseif cur_mov["perpendicular"] == 1 then
            item = SMenu.find_next(p, "right")
          elseif cur_mov["perpendicular"] == -1 then
            item = SMenu.find_next(p, "left")
          end
          if item then
            SFreeze.set_coord(p, item[3] + item[5]/2,
                                 item[4] + item[6]/2)
          end
        end
      end
      
      local nd = p.direction - 180
      local ne = 0 - p.elevation
      
      if (nd < -90) or (nd > 90) then
        p._freeze.extra_dir = p._freeze.extra_dir + nd
        p.direction = 180
        nd = 0
      end
      if (ne < -20) or (ne > 20) then
        p._freeze.extra_elev = p._freeze.extra_elev + ne
        p.elevation = 0
        ne = 0
      end
      
      local rr = SFreeze.ranges[p._freeze.mode]
      if (p._freeze.extra_dir + nd) > rr.xrange then
        p._freeze.extra_dir = rr.xrange - nd
      elseif (p._freeze.extra_dir + nd) < -rr.xrange then
        p._freeze.extra_dir = -rr.xrange - nd
      end
      if (p._freeze.extra_elev + ne) > rr.yrange then
        p._freeze.extra_elev = rr.yrange - ne
      elseif (p._freeze.extra_elev + ne) < -rr.yrange then
        p._freeze.extra_elev = -rr.yrange - ne
      end
    end
  end
end
function SFreeze.coord(p)
  local rr = SFreeze.ranges[p._freeze.mode]
  
  local xa = p.direction - 180 + p._freeze.extra_dir + rr.xrange
  local ya = 0 - p.elevation + p._freeze.extra_elev + rr.yrange
  
  return math.floor(rr.xoff + xa*rr.xscale), math.floor(rr.yoff + ya*rr.yscale)
end
function SFreeze.set_coord(p, x, y)
  local rr = SFreeze.ranges[p._freeze.mode]
  local xa = (x - rr.xoff)/rr.xscale
  local ya = (y - rr.yoff)/rr.yscale
  
  p.direction = 180
  p.elevation = 0
  p._freeze.extra_dir = xa - rr.xrange
  p._freeze.extra_elev = ya - rr.yrange
end
function SFreeze.orig_dir(p)
  if not p._freeze.mode then return p.direction end
  return p._freeze.point.direction
end

SPanel = {}
SPanel.oxygen = 1
SPanel.x1 = 2
SPanel.x2 = 3
SPanel.x3 = 4
SPanel.light_switch = 5
SPanel.platform_switch = 6
SPanel.tag_switch = 7
SPanel.save = 8
SPanel.terminal = 9
SPanel.chip = 10
SPanel.wires = 11
SPanel.classorder = { 5, 6, 7, 10, 11, 1, 2, 3, 4, 8, 9, 0 }
SPanel.device_collections = {}
function SPanel.init()
  -- these must be hard-coded into Forge; the engine can't tell them apart
  ControlPanelTypes[3]._type = SPanel.chip
  ControlPanelTypes[9]._type = SPanel.wires
  ControlPanelTypes[19]._type = SPanel.chip
  ControlPanelTypes[20]._type = SPanel.wires
  ControlPanelTypes[30]._type = SPanel.chip
  ControlPanelTypes[31]._type = SPanel.wires
  ControlPanelTypes[41]._type = SPanel.chip
  ControlPanelTypes[42]._type = SPanel.wires
  ControlPanelTypes[52]._type = SPanel.chip
  ControlPanelTypes[53]._type = SPanel.wires

  for t in ControlPanelTypes() do
    if t.collection then
      if not SPanel.device_collections[t.collection.index] then
        SPanel.device_collections[t.collection.index] = {}
      end
      local cc = SPanel.device_collections[t.collection.index]
      
      local ttype = t.class.index + 1
      if t._type then ttype = t._type end
      
      for _,v in ipairs({ t.active_texture_index, t.inactive_texture_index }) do
        if not cc[v] then cc[v] = {} end
        if not cc[v][ttype] then
          cc[v][ttype] = t
        end
      end
    end
  end
end
function SPanel.update()
  for p in Players() do
    if p.local_ then
      if p._panel.editing then
      
        local classfield = 0
        for i = 0,10 do
          if p._panel.dinfo[i + 1] ~= nil then
            classfield = classfield + 2^i
          end
        end
        p.texture_palette.slots[48].texture_index = classfield % 128
        p.texture_palette.slots[49].texture_index = math.floor(classfield/128)
        
        p.texture_palette.slots[50].texture_index = p._panel.classnum
        
        local option = 0
        if p._panel.light_dependent then option = option + 1 end
        if p._panel.only_toggled_by_weapons then option = option + 2 end
        if p._panel.repair then option = option + 4 end
        if p._panel.status then option = option + 8 end
        p.texture_palette.slots[51].texture_index = option
        
        local perm = p._panel.permutation
        p.texture_palette.slots[52].texture_index = perm % 128
        p.texture_palette.slots[53].texture_index = math.floor(perm/128)
      else
        p.texture_palette.slots[48].texture_index = 0
        p.texture_palette.slots[49].texture_index = 0
        p.texture_palette.slots[50].texture_index = 0
        p.texture_palette.slots[51].texture_index = 0
        p.texture_palette.slots[52].texture_index = 0
        p.texture_palette.slots[53].texture_index = 0
      end
    end
  end
end
function SPanel.cycle_class(p, dir)
  local cur = p._panel.classnum
  local dinfo = p._panel.dinfo
  local total = #SPanel.classorder
  
  local idx = total
  if dir < 0 then idx = 1 end
  for i,v in ipairs(SPanel.classorder) do
    if cur == v then
      idx = i
      break
    end
  end
  
  repeat
    idx = (((idx + dir) - 1) % total) + 1
  until (SPanel.classorder[idx] == 0) or dinfo[SPanel.classorder[idx]]
  
  p._panel.classnum = SPanel.classorder[idx]
end
function SPanel.cycle_permutation(p, dir)
  local cur = p._panel.classnum
  local perm = p._panel.permutation
  
  if cur == SPanel.platform_switch then
    local total = #SPlatforms.sorted_platforms
    if total > 0 then
      local idx = SPlatforms.index_lookup[perm]
      if idx == nil then 
        idx = total
        if dir < 0 then idx = 1 end
      end
      idx = (((idx + dir) - 1) % total) + 1
      p._panel.permutation = SPlatforms.sorted_platforms[idx].polygon.index
    end
  else
    local total = 0
    if cur == SPanel.light_switch then
      total = #Lights
    elseif cur == SPanel.terminal then
      total = #Terminals
      if total < 1 then total = max_scripts end
    elseif cur == SPanel.tag_switch or cur == SPanel.chip or cur == SPanel.wires then
      total = max_tags
    end
    if total > 0 then
      if perm < 0 or perm >= total then
        perm = total - 1
        if dir < 0 then perm = 0 end
      end
      p._panel.permutation = (perm + dir) % total
    end
  end
end
function SPanel.menu_name(p)
  local current_class = 0
  if p._panel and (p._panel.classnum ~= nil) then
    current_class = p._panel.classnum
  end
  
  if current_class == SPanel.oxygen or current_class == SPanel.x1 or current_class == SPanel.x2 or current_class == SPanel.x3 or current_class == SPanel.save then
    return "panel_plain"
  elseif current_class == SPanel.terminal then
    return "panel_terminal"
  elseif current_class == SPanel.light_switch then
    return "panel_light"
  elseif current_class == SPanel.platform_switch then
    return "panel_platform"
  elseif current_class == SPanel.tag_switch or current_class == SPanel.chip or current_class == SPanel.wires then
    return "panel_tag"
  end
  return "panel_off"
end
function SPanel.surface_can_hold_panel(surface)
  if not is_primary_side(surface) then return false end
  local cc = surface.collection.index
  local ct = surface.texture_index
  if SPanel.device_collections[cc] and SPanel.device_collections[cc][ct] then return true end
  return false
end
function SPanel.surface_has_valid_panel(surface)
  if not is_primary_side(surface) then return false end
  local cp = Sides[surface.index].control_panel
  if not cp then return false end
  if surface.collection ~= cp.type.collection then return false end
  if surface.texture_index ~= cp.type.active_texture_index and surface.texture_index ~= cp.type.inactive_texture_index then return false end
  return true
end
function SPanel.classnum_from_type(ctype)
  local idx = ctype.class.index + 1
  if ctype._type then idx = ctype._type end
  return idx
end
function SPanel.add_for_editing(p, surface)
  p._panel.sides[surface.index] = true
end
function SPanel.start_editing(p, surface)
  p._panel.editing = true
  p._panel.classnum = 0
  p._panel.permutation = 0
  p._panel.light_dependent = false
  p._panel.only_toggled_by_weapons = false
  p._panel.repair = false
  p._panel.status = false
  p._panel.surface = surface
  p._panel.sides = {}
  p._panel.sides[surface.index] = true
  p._panel.dinfo = SPanel.device_collections[surface.collection.index][surface.texture_index]
  
  if SPanel.surface_has_valid_panel(surface) then
    -- populate info from existing panel
    local cp = Sides[surface.index].control_panel
    p._panel.classnum = SPanel.classnum_from_type(cp.type)
    p._panel.light_dependent = cp.light_dependent
    p._panel.only_toggled_by_weapons = cp.only_toggled_by_weapons
    p._panel.repair = cp.repair
    p._panel.status = cp.status
    p._panel.permutation = cp.permutation
  else
    -- find first valid type
    local dinfo = p._panel.dinfo
    for classnum = 1,11 do
      if dinfo[classnum] ~= nil then
        p._panel.classnum = classnum
        if ct == dinfo[classnum].active_texture_index then
          p._panel.status = true
        end
        break
      end
    end
  end
  
  p._panel_saved = {}
  p._panel_saved.classnum = p._panel.classnum
  p._panel_saved.permutation = p._panel.permutation
  p._panel_saved.light_dependent = p._panel.light_dependent
  p._panel_saved.only_toggled_by_weapons = p._panel.only_toggled_by_weapons
  p._panel_saved.repair = p._panel.repair
  p._panel_saved.status = p._panel.status
end
function SPanel.revert(p)
  p._panel.classnum = p._panel_saved.classnum
  p._panel.permutation = p._panel_saved.permutation
  p._panel.light_dependent = p._panel_saved.light_dependent
  p._panel.only_toggled_by_weapons = p._panel_saved.only_toggled_by_weapons
  p._panel.repair = p._panel_saved.repair
  p._panel.status = p._panel_saved.status
end
function SPanel.stop_editing(p)
  if p._panel.editing then
    if p._panel.classnum == 0 then
      for sidx,_ in pairs(p._panel.sides) do
        Sides[sidx].control_panel = false
      end
    else
      local class = p._panel.classnum
      local ctype = p._panel.dinfo[p._panel.classnum]
      
      for sidx,_ in pairs(p._panel.sides) do
        Sides[sidx].control_panel = true
        local cp = Sides[sidx].control_panel
        
        cp.type = ctype
        cp.light_dependent = p._panel.light_dependent
        cp.permutation = p._panel.permutation
        cp.can_be_destroyed = (class == SPanel.chip)
        if class == SPanel.light_switch or 
           class == SPanel.platform_switch or
           class == SPanel.tag_switch or
           class == SPanel.chip or
           class == SPanel.wires then
          cp.only_toggled_by_weapons = p._panel.only_toggled_by_weapons
          cp.repair = p._panel.repair
          
          if class == SPanel.light_switch then
            if Lights[p._panel.permutation] then
              cp.status = Lights[p._panel.permutation].active
            else
              cp.status = false
            end
          elseif class == SPanel.platform_switch then
            if Polygons[p._panel.permutation] and Polygons[p._panel.permutation].platform then
              cp.status = Polygons[p._panel.permutation].platform.active
            else
              cp.status = false
            end
          else
            cp.status = p._panel.status
          end
        else
          cp.only_toggled_by_weapons = false
          cp.repair = false
          cp.status = false
        end
      end
    end
    p._panel.editing = false
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
      p.texture_palette.slots[54].texture_index = 0
      p.texture_palette.slots[55].texture_index = 0
      p.texture_palette.slots[56].texture_index = 0
      p.texture_palette.slots[57].texture_index = 0
    end
  end
end
function SStatus.update()
  for p in Players() do
    if p.local_ then
      local status = 0
      if SFreeze.frozen(p) then status = status + 1 end
      if SUndo.undo_active(p) then status = status + 2 end
      if SUndo.redo_active(p) then status = status + 4 end
      if (p._mode == SMode.apply or p._mode == SMode.teleport) and (not SFreeze.in_mode(p, "drag")) and p:find_action_key_target() then status = status + 8 end
      if p._advanced_mode then status = status + 16 end
      p.texture_palette.slots[41].texture_index = status
      
      p.texture_palette.slots[43].texture_index = p._light
      if p._collections.current_collection == 0 then
        p.texture_palette.slots[44].texture_index = 5
      else
        p.texture_palette.slots[44].texture_index = p._transfer_mode
      end
      p.texture_palette.slots[45].texture_index = p._quantize
      
      status = 0
      if p._apply.texture then status = status + 1 end
      if p._apply.light then status = status + 2 end
      if p._apply.align then status = status + 4 end
      if p._apply.transparent then status = status + 8 end
      if p._apply.edit_panels then status = status + 16 end
      p.texture_palette.slots[46].texture_index = status
      
      p.texture_palette.slots[47].texture_index = p._menu_item
      
      p.texture_palette.slots[54].texture_index = p._cursor_x % 128
      p.texture_palette.slots[55].texture_index = math.floor(p._cursor_x / 128)
      p.texture_palette.slots[56].texture_index = p._cursor_y % 128
      p.texture_palette.slots[57].texture_index = math.floor(p._cursor_y / 128)
    end
  end
end

SMenu = {}
SMenu.menus = {}
SMenu.menus[SMode.attribute] = {
  { "bg", nil, 20, 80, 600, 320, nil },
  { "label", nil, 30+5, 85, 155, 20, "Attributes" },
  { "checkbox", "apply_light", 30, 105, 155, 20, "Apply light" },
  { "checkbox", "apply_tex", 30, 125, 155, 20, "Apply texture" },
  { "checkbox", "apply_align", 30, 145, 155, 20, "Align adjacent" },
  { "checkbox", "apply_edit", 30, 165, 155, 20, "Edit switches and panels" },
  { "checkbox", "apply_xparent", 30, 185, 155, 20, "Edit transparent sides" },
  { "checkbox", "advanced", 30, 225, 155, 20, "Hide keyboard shortcuts" },
  { "label", "nil", 30+5, 250, 155, 20, "Snap to grid" },
  { "radio", "snap_0", 30, 270, 155, 20, snap_modes[1] },
  { "radio", "snap_1", 30, 290, 155, 20, snap_modes[2] },
  { "radio", "snap_2", 30, 310, 155, 20, snap_modes[3] },
  { "radio", "snap_3", 30, 330, 155, 20, snap_modes[4] },
  { "radio", "snap_4", 30, 350, 155, 20, snap_modes[5] },
  { "radio", "snap_5", 30, 370, 155, 20, snap_modes[6] },
  { "label", nil, 215+5, 85, 240, 20, "Light" },
  { "label", nil, 215+5, 250, 240, 20, "Texture mode" },
  { "radio", "transfer_0", 215, 270, 120, 20, "Normal" },
  { "radio", "transfer_1", 215, 290, 120, 20, "Pulsate" },
  { "radio", "transfer_2", 215, 310, 120, 20, "Wobble" },
  { "radio", "transfer_6", 215, 330, 120, 20, "Horizontal slide" },
  { "radio", "transfer_8", 215, 350, 120, 20, "Vertical slide" },
  { "radio", "transfer_10", 215, 370, 120, 20, "Wander" },
  { "radio", "transfer_5", 335, 270, 120, 20, "Landscape" },
  { "radio", "transfer_4", 335, 290, 120, 20, "Static" },
  { "radio", "transfer_3", 335, 310, 120, 20, "Fast wobble" },
  { "radio", "transfer_7", 335, 330, 120, 20, "Fast horizontal slide" },
  { "radio", "transfer_9", 335, 350, 120, 20, "Fast vertical slide" },
  { "radio", "transfer_11", 335, 370, 120, 20, "Fast wander" },
  { "label", nil, 485, 250, 120, 20, "Preview" },
  { "applypreview", nil, 485, 270, 120, 120, nil } }
SMenu.menus["panel_off"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 355, 130, 20, "Inactive" } }
SMenu.menus["panel_plain"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
  { "checkbox", "panel_light", 170, 90, 150-3, 20, "Light dependent" } }
SMenu.menus["panel_terminal"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
  { "checkbox", "panel_light", 170, 90, 150-3, 20, "Light dependent" },
  { "label", nil, 170+5, 130, 150, 20, "Terminal script" } }
SMenu.menus["panel_light"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
  { "checkbox", "panel_light", 170, 90, 150-3, 20, "Light dependent" },
  { "checkbox", "panel_weapon", 170, 110, 150-3, 20, "Only toggled by weapons" },
  { "checkbox", "panel_repair", 170, 130, 150-3, 20, "Repair switch" },
  { "label", nil, 170+5, 170, 150, 20, "Light" } }
SMenu.menus["panel_platform"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
  { "checkbox", "panel_light", 170, 90, 150-3, 20, "Light dependent" },
  { "checkbox", "panel_weapon", 170, 110, 150-3, 20, "Only toggled by weapons" },
  { "checkbox", "panel_repair", 170, 130, 150-3, 20, "Repair switch" },
  { "label", nil, 170+5, 170, 150, 20, "Platform" } }
SMenu.menus["panel_tag"] = {
  { "tab_bg", nil, 150, 80, 470, 320, nil },
  { "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
  { "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
  { "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
  { "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
  { "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
  { "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
  { "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
  { "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
  { "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
  { "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
  { "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
  { "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
  { "checkbox", "panel_light", 170, 90, 150-3, 20, "Light dependent" },
  { "checkbox", "panel_weapon", 170, 110, 150-3, 20, "Only toggled by weapons" },
  { "checkbox", "panel_repair", 170, 130, 150-3, 20, "Repair switch" },
  { "checkbox", "panel_active", 220-1, 170, 100-2, 20, "Tag is active" },
  { "label", nil, 170+5, 170, 50-18, 20, "Tag" } }
SMenu.inited = {}
function SMenu.selection(p)
  local mode = SMode.current_menu_name(p)
  if not SMenu.inited[mode] then SMenu.init_menu(mode) end
  local m = SMenu.menus[mode]  
  local x, y = SMenu.coord(p)
  
  for idx, item in ipairs(m) do
    if SMenu.clickable(item[1]) then
      if x >= item[3] and y >= item[4] and x <= (item[3] + item[5]) and y <= (item[4] + item[6]) then
        return item[2]
      end
    end
  end
  return nil
end
function SMenu.find_next(p, direction)
  local mode = SMode.current_menu_name(p)
  if not SMenu.inited[mode] then SMenu.init_menu(mode) end
  local m = SMenu.menus[mode]  
  local x, y = SMenu.coord(p)
  
  local closest = nil
  local distance = 999
  for idx, item in ipairs(m) do
    if SMenu.clickable(item[1]) then
      if (direction == "down" or direction == "up") and
         (x >= item[3] and x <= (item[3] + item[5])) then
        if direction == "down" and y < item[4] then
          if distance > (item[4] - y) then
            distance = item[4] - y
            closest = item
          end
        elseif direction == "up" and y > (item[4] + item[6]) then
          if distance > (y - (item[4] + item[6])) then
            distance = y - (item[4] + item[6])
            closest = item
          end
        end
      elseif (direction == "left" or direction == "right") and
             (y >= item[4] and y <= (item[4] + item[6])) then
        if direction == "right" and x < item[3] then
          if distance > (item[3] - x) then
            distance = item[3] - x
            closest = item
          end
        elseif direction == "left" and x > (item[3] + item[5]) then
          if distance > (x - (item[3] + item[5])) then
            distance = x - (item[3] + item[5])
            closest = item
          end
        end
      end
    end
  end
  return closest
end

function SMenu.coord(p)
  return SFreeze.coord(p)
end
function SMenu.init_menu(mode)
  local menu = SMenu.menus[mode]
  if mode == SMode.attribute then
    for i = 1,math.min(#Lights, 56) do
      local l = i - 1
      local yoff = (l % 7) * 20
      local xoff = math.floor(l / 7) * 50
      local w = 50
      if xoff == 0 then
        w = w - 13
      else
        xoff = xoff - 13
      end
      table.insert(menu, 13 + l,
        { "light", "light_" .. l, 215 + xoff, 105 + yoff, w, 20, tostring(l) })
    end
  elseif mode == "panel_light" then
    for i = 1,math.min(#Lights, 63) do
      local l = i - 1
      local yoff = (l % 7) * 20
      local xoff = math.floor(l / 7) * 49
      local w = 49
      if xoff == 0 then
        w = w - 13
      else
        xoff = xoff - 13
      end
      table.insert(menu,
        { "light", "pperm_" .. l, 170 + xoff, 190 + yoff, w, 20, tostring(l) })
    end
  elseif mode == "panel_terminal" then
    local num_scripts = #Terminals
    if num_scripts < 1 then num_scripts = max_scripts end
    for i = 1,math.min(num_scripts, 90) do
      local l = i - 1
      local yoff = (l % 10) * 20
      local xoff = math.floor(l / 10) * 49
      table.insert(menu,
        { "radio", "pperm_" .. l, 170 + xoff, 150 + yoff, 49, 20, tostring(l) })
    end
  elseif mode == "panel_tag" then
    for i = 1,math.min(max_tags, 90) do
      local l = i - 1
      local yoff = (l % 10) * 20
      local xoff = math.floor(l / 10) * 49
      table.insert(menu,
        { "radio", "pperm_" .. l, 170 + xoff, 190 + yoff, 49, 20, tostring(l) })
    end
  elseif mode == "panel_platform" then
    for i = 1,math.min(#SPlatforms.sorted_platforms, 90) do
      local l = i - 1
      local yoff = (l % 10) * 20
      local xoff = math.floor(l / 10) * 49
      l = SPlatforms.sorted_platforms[i].polygon.index
      table.insert(menu,
        { "radio", "pperm_" .. l, 170 + xoff, 190 + yoff, 49, 20, tostring(l) })
    end
  end
  
  SMenu.inited[mode] = true
end
function SMenu.clickable(item_type)
  return item_type == "button" or item_type == "checkbox" or item_type == "radio" or item_type == "texture" or item_type == "light" or item_type == "dbutton" or item_type == "acheckbox" or item_type == "tab"
end


SChoose = {}
function SChoose.gridsize(bct)
  local rows = 1
  local cols = 4
  while (rows * cols) < bct do
    rows = rows + 1
    cols = 2 + (2*rows)
  end
  return rows, math.ceil(bct / rows)
end
function SChoose.widegridsize(bct)
  local rows = math.floor(math.sqrt(bct))
  return rows, math.ceil(bct / rows)
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
  
  local landscape_textures = {}
  local off = 0
  for _, collection in pairs(landscapes) do
    if not SCollections.collection_map[collection] then
      table.insert(SCollections.landscape_collections, collection)
      SCollections.collection_map[collection] = {type = "landscape", offset = off, count = Collections[collection].bitmap_count}
      off = off + Collections[collection].bitmap_count
      for i = 1,Collections[collection].bitmap_count do
        table.insert(landscape_textures, { collection, i - 1 })
      end
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
  
  if true then
    local menu_colls = {}
    for _,v in ipairs(SCollections.wall_collections) do
      table.insert(menu_colls, v)
    end
    if #landscape_textures > 0 then table.insert(menu_colls, 0) end
    
    -- set up collection buttons
    local cbuttons = {}
    if #menu_colls > 0 then
      local n = #menu_colls
      local w = 600 / n
      
      local x = 20
      local y = 380
      for i = 1,n do
        local cnum = menu_colls[i]
        table.insert(cbuttons,
          { "dbutton", "coll_" .. cnum, x, y, w, 20, "" })
        x = x + w
      end
    end  
    
    -- set up grid
    for _,cnum in ipairs(menu_colls) do
      local bct
      local xscale = 1
      if cnum == 0 then
        bct = #landscape_textures
        xscale = 2
      else
        bct = Collections[cnum].bitmap_count
      end
      
      local buttons = {}
      local rows, cols = SChoose.gridsize(bct)
      if xscale == 2 then rows, cols = SChoose.widegridsize(bct) end
      local tsize = math.min(600 / (cols * xscale), 300 / rows)
      
      for i = 1,bct do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = 20 + (tsize * col * xscale) + (600 - (tsize * cols * xscale))/2
        local y = 80 + (tsize * row) + (300 - (tsize * rows))/2
        
        local cc = cnum
        local ct = i - 1
        if cnum == 0 then
          cc = landscape_textures[i][1]
          ct = landscape_textures[i][2]
        end
        table.insert(buttons,
          { "texture", "choose_" .. cc .. "_" .. ct, 
            x, y, tsize * xscale, tsize, cc .. ", " .. ct })
      end
      for _,v in ipairs(cbuttons) do
        table.insert(buttons, v)
      end
      
      SMenu.menus["choose_" .. cnum] = buttons
    end
  end
    
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
function SCollections.find_surface(p, copy_mode)
  local surface = nil
  local find_first_line = p._apply.transparent
  local find_first_side = false
  if copy_mode then
    find_first_line = false
    find_first_side = p._apply.transparent
  end
  local o, x, y, z, polygon = VML.find_target(p, find_first_line, find_first_side)
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
    val = #Terminals
    if val < 1 then val = max_scripts end
  end
  
  for p in Players() do
    if p.local_ then
      p.texture_palette.slots[33].texture_index = val % 128
      p.texture_palette.slots[34].texture_index = math.floor(val/128)
    end
  end
end


SLights = {}
function SLights.update()
  for p in Players() do
    if p.local_ then
      for i = 1,math.min(#Lights, 56) do
        p.texture_palette.slots[199 + i].texture_index = math.floor(Lights[i - 1].intensity * 128)
      end
    end
  end
end

SPlatforms = {}
SPlatforms.sorted_platforms = {}
SPlatforms.index_lookup = {}
function SPlatforms.init()
  for plat in Platforms() do
    table.insert(SPlatforms.sorted_platforms, plat)
  end
  table.sort(SPlatforms.sorted_platforms, function(a, b) return a.polygon.index < b.polygon.index end)
  for i,v in ipairs(SPlatforms.sorted_platforms) do
    SPlatforms.index_lookup[v.polygon.index] = i
  end
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
    UTeleport.remove_highlight(p)
    p._teleport.last_target = poly
    p._teleport.last_target_mode = poly.floor.transfer_mode
    p._teleport.last_target_type = poly.type
    poly.floor.transfer_mode = "static"
    poly.type = PolygonTypes["major ouch"]
  end
end
function UTeleport.remove_highlight(p)
  if not show_teleport_destination then return end
  if p._teleport.last_target ~= nil then
    -- restore last selected poly
    p._teleport.last_target.floor.transfer_mode = p._teleport.last_target_mode
    p._teleport.last_target.type = p._teleport.last_target_type
    p._teleport.last_target = nil
  end
end

UApply = {}
function UApply.apply_texture(p, surface, coll, tex, landscape)
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
end
function UApply.should_edit_panel(p)
  if not p._apply.edit_panels then return false end
  if not p._apply.texture then return false end
  
  local surface = p._saved_surface.surface
  if surface == nil then return false end
  if is_polygon_floor(surface) or is_polygon_ceiling(surface) then return false end

  
  local cc = p._collections.current_collection
  if cc == 0 then cc = p._collections.current_landscape_collection end
  local ct = p._collections.current_textures[cc]
  
  if not SPanel.device_collections[cc] then return false end
  if not SPanel.device_collections[cc][ct] then return false end
    
  return true
end
function UApply.should_clear_panel(p)
  if not p._apply.edit_panels then return false end
  if not p._apply.texture then return false end
  
  local surface = p._saved_surface.surface
  if surface == nil then return false end
  if is_polygon_floor(surface) or is_polygon_ceiling(surface) then return false end

  
  local cc = p._collections.current_collection
  if cc == 0 then cc = p._collections.current_landscape_collection end
  local ct = p._collections.current_textures[cc]
  
  if not SPanel.device_collections[cc] then return false end
  if not SPanel.device_collections[cc][ct] then return false end
    
  return true
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
