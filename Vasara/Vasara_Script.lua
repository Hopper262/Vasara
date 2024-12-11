-- Vasara 1.1.1 (Script)
-- by Hopper and Ares Ex Machina
-- from work by Irons and Smith, released under the JUICE LICENSE!

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

-- other menu UI prefs
menu_prefs = {}
menu_prefs.button_indent = 1

walls = { 17, 18, 19, 20, 21 }
landscapes = { 27, 28, 29, 30 }

suppress_items = true
suppress_monsters = true

max_tags = 90     -- max: 90
max_scripts = 90  -- max: 90

-- set to false to hide the Visual Mode header on startup
show_visual_mode_header = true

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

-- enable buggy, unfinished height-editing mode
-- (to access, press Map and then Action)
allow_heights = false

-- END PREFERENCES -- no user serviceable parts below ;)

Game.monsters_replenish = not suppress_monsters
snap_denominators = { 2, 3, 4, 5, 8 }
snap_modes = { "Off" }
for _,d in ipairs(snap_denominators) do
  table.insert(snap_modes, "1/" .. d .. " WU")
end

CollectionsUsed = {}
for _, collection in pairs(walls) do
  table.insert(CollectionsUsed, collection)
end
for _, collection in pairs(landscapes) do
  table.insert(CollectionsUsed, collection)
end

Triggers = {}
function Triggers.init()
  for p in Players() do
    p._v = {}
    p._w = {}
  end
end

function init()
  VML.init()

  for p in Players() do
    p.weapons.active = false
  end

  if suppress_items then
    for item in Items() do
      item:delete()
    end

    function Triggers.item_created(item)
      item:delete()
    end
  end

  SExplore.init()
  SKeys.init()
  SCollections.init()
  SLights.init()
  SPanel.init()
  SPlatforms.init()
  SFreeze.init()
  SMode.init()
  SUndo.init()

  inited_script = true
end

function Triggers.idle()
  if not Music.new then
    Players.print("Vasara requires a newer version of Aleph One")
    kill_script()
    return
  end

  if not inited_script then init() end

  SExplore.update()
  SKeys.update()
  SCounts.update()
  SLights.update()
  SPlatforms.update()
  SFreeze.update()
  SMode.update()
  SUndo.update()
  SStatus.update()
  SMenu.update()

  for p in Players() do
    p.life = 450
    p.oxygen = 10800
  end
end

function Triggers.postidle()
  SFreeze.postidle()

  Level.stash["Vasara"] = Game.serialize(Players.local_player._v)
  Level.stash["Vasara_menus"] = Game.serialize(SMenu.menus)
end

function Triggers.terminal_enter(terminal, player)
  if terminal then
    player._v.terminal = true
  end
end
function Triggers.terminal_exit(_, player)
  player._v.terminal = false
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
SMode.heights = 5

function SMode.init()
  for p in Players() do
    p._v.mode = SMode.apply
    p._v.prev_mode = SMode.apply
    p._v.mic_dummy = false
    p._v.target_poly = 0
    p._v.quantize = 0
    p._v.menu_button = nil
    p._v.menu_item = 0
    p._v.cursor_x = 320
    p._v.cursor_y = 240
    p._v.advanced_mode = not show_visual_mode_header

    p._v.apply = {}
    p._v.apply.texture = true
    p._v.apply.light = true
    p._v.apply.transfer = true
    p._v.apply.align = true
    p._v.apply.transparent = false
    p._v.apply.edit_panels = true

    p._v.teleport = {}
    p._v.teleport.last_target = nil
    p._v.teleport.last_target_mode = nil

    p._v.heights = {}
    p._v.heights.target_poly = -1
    p._v.heights.target_floor = true
    p._w.height_surface = {}
    p._w.height_surface.original_surface = nil

    p._v.panel = {}
    p._v.panel.editing = false
    p._v.panel.classnum = 0
    p._v.panel.permutation = 0
    p._v.panel.light_dependent = false
    p._v.panel.only_toggled_by_weapons = false
    p._v.panel.repair = false
    p._v.panel.status = false
    p._v.panel.sides = {}
    p._v.panel.dinfo = nil
    p._w.panel = {}
    p._w.panel.surface = nil

    p._v.saved_facing = {}
    p._v.saved_facing.direction = 0
    p._v.saved_facing.elevation = 0
    p._v.saved_facing.x = 0
    p._v.saved_facing.y = 0
    p._v.saved_facing.z = 0
    p._v.saved_facing.just_set = false

    p._w.saved_surface = {}
    p._w.saved_surface.surface = nil
    p._w.saved_surface.polygon = nil
    p._w.saved_surface.x = 0
    p._w.saved_surface.y = 0
    p._w.saved_surface.align_table = nil
    p._w.saved_surface.offset_table = nil
    p._w.saved_surface.opposite_surface = nil
    p._w.saved_surface.opposite_offsets = nil
    p._w.saved_surface.opposite_rem = 0

    -- p._v.annotation = Annotations.new(Polygons[0], "")
  end
end
function SMode.current_menu_name(p)
  if p._v.mode == SMode.attribute then
    return SMode.attribute
  elseif p._v.mode == SMode.choose then
    return "choose_" .. p._v.collections.current_collection
  elseif p._v.mode == SMode.panel then
    return SPanel.menu_name(p)
  end
  return nil
end
function SMode.update()
  for p in Players() do

    p._v.prev_mode = p._v.mode

    -- process mode actions
    if p._v.mode == SMode.apply then
      SMode.handle_apply(p)
    elseif p._v.mode == SMode.teleport then
      SMode.handle_teleport(p)
    elseif p._v.mode == SMode.choose then
      SMode.handle_choose(p)
    elseif p._v.mode == SMode.attribute then
      SMode.handle_attribute(p)
    elseif p._v.mode == SMode.panel then
      SMode.handle_panel(p)
    elseif p._v.mode == SMode.heights then
      SMode.handle_heights(p)
    end

    -- handle mode switches
    if not p._v.keys.mic.down then
      if p._v.keys.map.pressed then
        if p._v.overhead then
          p._v.mode = SMode.teleport
        else
          p._v.mode = SMode.apply
        end
      elseif p._v.keys.action.pressed then
        -- only allow default action trigger in visual modes
        if SMode.menu_mode(p._v.mode) or (not p:find_action_key_target()) then
          p.action_flags.action_trigger = false
          if p._v.mode == SMode.heights then
            SMode.toggle(p, SMode.apply)
          elseif allow_heights and p._v.mode == SMode.teleport then
            SMode.toggle(p, SMode.heights)
          else
            SMode.toggle(p, SMode.attribute)
          end
        end
      elseif p._v.keys.mic.released and (not p._v.mic_dummy) then
        SMode.toggle(p, SMode.choose)
      elseif p._v.keys.secondary.released and p._v.mode ~= SMode.apply then
        SMode.toggle(p, p._v.mode)
      end
    end

    -- track mic-as-modifier, and don't switch if we use that
    if p._v.keys.mic.down then
      if p._v.keys.prev_weapon.down or p._v.keys.next_weapon.down or p._v.keys.action.down or p._v.keys.primary.down or p._v.keys.primary.released or p._v.keys.secondary.down or p._v.keys.secondary.released then
        p._v.mic_dummy = true
      end
    elseif p._v.keys.mic.released then
      p._v.mic_dummy = false
    end

    local in_menu = SMode.menu_mode(p._v.mode)

    if p._v.mode ~= p._v.prev_mode then
      p._v.menu_button = nil
      p._v.menu_item = 0
      local was_menu = SMode.menu_mode(p._v.prev_mode)

      -- special cleanup for exiting modes
      if p._v.prev_mode == SMode.teleport then
        UTeleport.remove_highlight(p)
      elseif p._v.prev_mode == SMode.panel then
        SPanel.stop_editing(p)
      end

      -- special setup for entering modes
      if p._v.mode == SMode.attribute then
        SMode.start_attribute(p)
      elseif p._v.mode == SMode.teleport then
        SMode.start_teleport(p)
      end

      if in_menu then
        SFreeze.enter_mode(p, "menu")
      else
        SFreeze.enter_mode(p, nil)
      end
    end

    -- ensure current menu is inited
    local mname = SMode.current_menu_name(p)
    if mname then
      if not SMenu.inited[mname] then SMenu.init_menu(mname) end
    end

    if p.local_ then
      -- set cursor
      if in_menu then
        p._v.cursor_x, p._v.cursor_y = SFreeze.coord(p)
      elseif p._v.mode == SMode.apply or p._v.mode == SMode.heights then
        p._v.cursor_x = 320
        p._v.cursor_y = 72 + 160
        if p._v.advanced_mode then p._v.cursor_y = 196 end
        if SFreeze.in_mode(p, "drag") then
          local delta_yaw, delta_pitch
          delta_yaw, delta_pitch = SFreeze.coord(p)
          if p._v.mode ~= SMode.heights then
            p._v.cursor_x = p._v.cursor_x + math.floor(delta_yaw * 300.0/1024.0)
          end
          p._v.cursor_y = p._v.cursor_y + math.floor(delta_pitch * 140.0/1024.0)
        end
      elseif p._v.mode == SMode.teleport then
        p._v.cursor_x = 320
        p._v.cursor_y = math.floor((3*72 + 480)/4)
        if p._v.advanced_mode then p._v.cursor_y = 480/4 end
      end
    end
  end
end
function SMode.menu_mode(mode)
  return mode == SMode.choose or mode == SMode.attribute or mode == SMode.panel
end
function SMode.toggle(p, mode)
  if p._v.mode == mode then
    p._v.mode = SMode.apply
  else
    p._v.mode = mode
  end
  if p._v.overhead then
    p.action_flags.toggle_map = true
    p._v.overhead = false
  end
end
function SMode.handle_heights(p)
  if p._v.keys.mic.down then
    if p._v.keys.next_weapon.held then
      SFreeze.unfreeze(p)
      p:accelerate(0, 0, 0.05)
    elseif p._v.keys.prev_weapon.pressed then
      SFreeze.toggle_freeze(p)
    end
  end

  if p._v.keys.primary.down and p._v.heights.target_poly > -1 then
    if Game.ticks > p._v.keys.primary.first + drag_initial_delay then
      SFreeze.enter_mode(p, "drag")

      local delta_yaw, delta_pitch
      delta_yaw, delta_pitch = SFreeze.coord(p)
      delta_pitch = delta_pitch / 1024.0
      local poly = Polygons[p._v.heights.target_poly]
      local zdiff = -delta_pitch
      local newz = p._v.heights.target_initial + zdiff
      if p._v.heights.target_floor then
        poly:change_height(PIN(newz, -9, poly.ceiling.z), poly.ceiling.z)
      else
        poly:change_height(poly.floor.z, PIN(newz, poly.floor.z, 9))
      end
      for line in poly:lines() do
        if line.cw_side then line.cw_side:recalculate_type() end
        if line.ccw_side then line.ccw_side:recalculate_type() end
      end

    end
  else
    if p._v.keys.primary.released then
      SFreeze.enter_mode(p, nil)
    end

    if (p._v.saved_facing.direction ~= p.direction) or
      (p._v.saved_facing.elevation ~= p.elevation) or
      (p._v.saved_facing.x ~= p.x) or
      (p._v.saved_facing.y ~= p.y) or
      (p._v.saved_facing.z ~= p.z) then
      p._v.saved_facing.direction = p.direction
      p._v.saved_facing.elevation = p.elevation
      p._v.saved_facing.x = p.x
      p._v.saved_facing.y = p.y
      p._v.saved_facing.z = p.z
      local o, x, y, z, poly = VML.find_target(p, false, false)
      if o then
        if is_polygon_floor(o) or is_polygon(o) then
          p._v.heights.target_poly = poly.index
          p._v.heights.target_floor = true
          p._v.heights.target_initial = poly.floor.z
        elseif is_polygon_ceiling(o) then
          p._v.heights.target_poly = poly.index
          p._v.heights.target_floor = false
          p._v.heights.target_initial = poly.ceiling.z
        elseif is_side(o) then
          o:recalculate_type()
          local opposite_polygon
          if o.line.clockwise_side == o then
              opposite_polygon = o.line.counterclockwise_polygon
          else
              opposite_polygon = o.line.clockwise_polygon
          end
          if opposite_polygon then
            p._v.heights.target_poly = opposite_polygon.index
            p._v.heights.target_floor = true
            p._v.heights.target_initial = opposite_polygon.floor.z
            if o.type == "high" or (o.type == "split" and z > o.line.lowest_adjacent_ceiling) then
              p._v.heights.target_floor = false
              p._v.heights.target_initial = opposite_polygon.ceiling.z
            end
          else
            p._v.heights.target_poly = -1
            p._v.heights.target_floor = true
            p._v.heights.target_initial = 0
          end
        end
      end
    end
  end
end
function SMode.handle_apply(p)
  local clear_surface = true

  if p._v.keys.mic.down then
    if p._v.keys.next_weapon.held then
      SFreeze.unfreeze(p)
      p:accelerate(0, 0, 0.05)
    elseif p._v.keys.prev_weapon.pressed then
      SFreeze.toggle_freeze(p)
    end
  else
    if p._v.keys.primary.down then
      -- apply
      clear_surface = false
      local surface = p._w.saved_surface.surface
      if p._v.keys.primary.pressed then
        surface, polygon = SCollections.find_surface(p, false)
        local coll = SCollections.current_coll(p)
        local landscape = SCollections.is_landscape(coll)
        local tex = p._v.collections.current_textures[coll]

        p._w.saved_surface.surface = surface
        p._w.saved_surface.opposite_surface = nil
        p._w.saved_surface.polygon = polygon
        if (not p._v.apply.texture) or (surface.collection and (coll == surface.collection.index) and (tex == surface.texture_index)) then
          p._w.saved_surface.x = surface.texture_x
          p._w.saved_surface.y = surface.texture_y
        else
          p._w.saved_surface.x = 0
          if is_side(o) then
            local bottom, top = VML.surface_heights(surface)
            p._w.saved_surface.y = bottom - top
          else
            p._w.saved_surface.y = 0
          end
        end

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
              dsurface = VML.new_side(line.counterclockwise_polygon, line).transparent
            end
          else
            if line.clockwise_side then
              dsurface = line.clockwise_side.transparent
            elseif line.clockwise_polygon then
              dsurface = VML.new_side(line.clockwise_polygon, line).transparent
            end
          end

          if dsurface then
            SUndo.add_undo(p, dsurface)
            UApply.apply_texture(p, dsurface, coll, tex, landscape)
            local rem = line.length - math.floor(line.length)
            dsurface.texture_x = 0 - dsurface.texture_x - rem
            p._w.saved_surface.opposite_surface = dsurface
            p._w.saved_surface.opposite_rem = rem
          end
        end

        if p._v.apply.align then
          if is_polygon_floor(surface) or is_polygon_ceiling(surface) then
            p._w.saved_surface.align_table = VML.build_polygon_align_table(polygon, surface)
            local is_floor = is_polygon_floor(surface)
            for s in pairs(p._w.saved_surface.align_table) do
              if is_floor then
                SUndo.add_undo(p, s.floor)
              else
                SUndo.add_undo(p, s.ceiling)
              end
            end
            VML.align_polygons(surface, p._w.saved_surface.align_table)
          else
            p._w.saved_surface.offset_table = VML.build_side_offsets_table(surface)
            for s in pairs(p._w.saved_surface.offset_table) do
              SUndo.add_undo(p, s)
            end
            VML.align_sides(surface, p._w.saved_surface.offset_table)

            local dsurface = p._w.saved_surface.opposite_surface
            if dsurface then
              local doffsets = VML.build_side_offsets_table(dsurface)
              p._w.saved_surface.opposite_offsets = doffsets
              for s in pairs(doffsets) do
                SUndo.add_undo(p, s)
              end
              VML.align_sides(dsurface, doffsets)
            end
          end
        end

      elseif surface and (Game.ticks > p._v.keys.primary.first + drag_initial_delay) then
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

          surface.texture_x = VML.quantize(p, p._w.saved_surface.x + xoff)
          surface.texture_y = VML.quantize(p, p._w.saved_surface.y + yoff)

          if p._v.apply.align then
            VML.align_polygons(surface, p._w.saved_surface.align_table)
          end
        else
          surface.texture_x = VML.quantize(p, p._w.saved_surface.x - delta_yaw)
          surface.texture_y = VML.quantize(p, p._w.saved_surface.y - delta_pitch)

          if p._v.apply.align then
            VML.align_sides(surface, p._w.saved_surface.offset_table)
          end

          local dsurface = p._w.saved_surface.opposite_surface
          if dsurface then
            dsurface.texture_x = 0 - surface.texture_x - p._w.saved_surface.opposite_rem
            dsurface.texture_y = surface.texture_y
            if p._v.apply.align then
              VML.align_sides(dsurface, p._w.saved_surface.opposite_offsets)
            end
          end
        end
      end
    elseif p._v.keys.primary.released then
      -- release any drag
      SFreeze.enter_mode(p, nil)

      -- are we editing control panels
      if p._v.apply.texture and p._v.apply.edit_panels and is_primary_side(p._w.saved_surface.surface) then
        if SPanel.surface_can_hold_panel(p._w.saved_surface.surface) then
          -- valid for control panels; configure it
          SPanel.start_editing(p, p._w.saved_surface.surface)
          if p._v.apply.align then
            for s in pairs(p._w.saved_surface.offset_table) do
              SPanel.add_for_editing(p, s)
            end
          end
          clear_surface = false
          SMode.toggle(p, SMode.panel)
        else
          -- not a valid texture for control panels; clear it
          Sides[p._w.saved_surface.surface.index].control_panel = false
          if p._v.apply.align then
            for s in pairs(p._w.saved_surface.offset_table) do
              Sides[s.index].control_panel = false
            end
          end
        end
      end
    elseif p._v.keys.secondary.released then
      -- sample
      local surface = SCollections.find_surface(p, true)
      if surface and (not (is_transparent_side(surface) and surface.empty)) then
        SCollections.set(p, surface.collection.index, surface.texture_index)
        if not SCollections.is_landscape(SCollections.current_coll(p)) then
          p._v.light = surface.light.index
          p._v.transfer_mode = surface.transfer_mode.mnemonic
        end
      end
    elseif p._v.keys.prev_weapon.pressed then
      p._v.light = (p._v.light - 1) % #Lights
    elseif p._v.keys.next_weapon.pressed then
      p._v.light = (p._v.light + 1) % #Lights
    end
  end

  if clear_surface then p._w.saved_surface.surface = nil end

end
function SMode.start_teleport(p)
  p._v.saved_facing.direction = 0
  p._v.saved_facing.elevation = 0
  p._v.saved_facing.x = 0
  p._v.saved_facing.y = 0
  p._v.saved_facing.z = 0
  p._v.saved_facing.just_set = false
end
function SMode.handle_teleport(p)
  if p._v.saved_facing.just_set then
    p._v.saved_facing.direction = p.direction
    p._v.saved_facing.elevation = p.elevation
    p._v.saved_facing.just_set = false
  end
  if (p._v.saved_facing.direction ~= p.direction) or
     (p._v.saved_facing.elevation ~= p.elevation) or
     (p._v.saved_facing.x ~= p.x) or
     (p._v.saved_facing.y ~= p.y) or
     (p._v.saved_facing.z ~= p.z) then
    p._v.saved_facing.direction = p.direction
    p._v.saved_facing.elevation = p.elevation
    p._v.saved_facing.x = p.x
    p._v.saved_facing.y = p.y
    p._v.saved_facing.z = p.z
    local o, x, y, z, poly = VML.find_target(p, false, false)
    if poly then
      p._v.target_poly = poly.index
      UTeleport.highlight(p, poly)
    end

    SMode.annotate(p)
  end

  if p._v.keys.mic.down then
    if p._v.keys.next_weapon.held then
      SFreeze.unfreeze(p)
      p:accelerate(0, 0, 0.05)
    elseif p._v.keys.prev_weapon.pressed then
      SFreeze.toggle_freeze(p)
    end
  end

  if (not p._v.keys.mic.down) and p._v.keys.primary.released then
    local poly = Polygons[p._v.target_poly]
    p:position(poly.x, poly.y, poly.z, poly)
    p.monster:play_sound("teleport in")
    UTeleport.remove_highlight(p)
    SFreeze.unfreeze(p)
    return
  end

  if ((not p._v.keys.mic.down) and (p._v.keys.prev_weapon.held or p._v.keys.next_weapon.held)) or (p._v.keys.mic.down and (p._v.keys.primary.held or p._v.keys.secondary.held)) then
    local diff = 1
    if p._v.keys.prev_weapon.held and (not p._v.keys.mic.down) then
      diff = -1
    elseif p._v.keys.primary.held and p._v.keys.mic.down then
      if p._v.keys.primary.repeated then
        diff = 1 + ffw_teleport_scrub_speed
      else
        diff = 1
      end
    elseif p._v.keys.secondary.held and p._v.keys.mic.down then
      if p._v.keys.secondary.repeated then
        diff = -1 - ffw_teleport_scrub_speed
      else
        diff = -1
      end
    end
    p._v.target_poly = (p._v.target_poly + diff) % #Polygons
    SMode.annotate(p)

    local poly = Polygons[p._v.target_poly]
    UTeleport.highlight(p, poly)
    local xdist = poly.x - p.x
    local ydist = poly.y - p.y
    local zdist = poly.z - (p.z + 614/1024)
    local tdist = math.sqrt(xdist*xdist + ydist*ydist + zdist*zdist)

    local el = math.asin(zdist/tdist)
    local dir = math.atan2(ydist, xdist)
    p.direction = math.deg(dir)
    p.elevation = math.deg(el)
    p._v.saved_facing.just_set = true
  end
end
function SMode.annotate(p)
  local poly = Polygons[p._v.target_poly]
--   p._v.annotation.polygon = poly
--   p._v.annotation.text = poly.index
--   p._v.annotation.x = poly.x
--   p._v.annotation.y = poly.y
end
function SMode.handle_choose(p)
  -- cycle textures
  if (p._v.keys.mic.down and (p._v.keys.primary.held or p._v.keys.secondary.held)) or ((not p._v.keys.mic.down) and (p._v.keys.prev_weapon.held or p._v.keys.next_weapon.held)) then
    local diff = 1
    if p._v.keys.prev_weapon.held then
      diff = -1
    elseif p._v.keys.mic.down and p._v.keys.primary.repeated then
      diff = 1 + ffw_texture_scrub_speed
    elseif p._v.keys.mic.down and p._v.keys.secondary.repeated then
      diff = 0 - (1 + ffw_texture_scrub_speed)
    elseif p._v.keys.mic.down and p._v.keys.secondary.held then
      diff = -1
    end
    local cur = p._v.collections.current_collection
    if cur == 0 then
      local bct = 0
      local tex = 0
      for _, collection in pairs(SCollections.landscape_collections) do
        if collection == p._v.collections.current_landscape_collection then
          local info = SCollections.collection_map[collection]
          tex = info.offset + p._v.collections.current_textures[collection]
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
      local tex = p._v.collections.current_textures[cur]
      local bct = Collections[cur].bitmap_count
      local ct = (tex + diff) % bct
      SCollections.set(p, cur, ct)
    end
  end

  if p._v.keys.mic.down and (p._v.keys.next_weapon.held or p._v.keys.prev_weapon.held) then
    -- cycle collections
    local diff = 1
    if p._v.keys.prev_weapon.held then diff = -1 end

    local cur = p._v.collections.current_collection
    local ci = 0
    for i, c in ipairs(SCollections.wall_collections) do
      if cur == c then
        ci = i
        break
      end
    end
    ci = (ci + diff) % (#SCollections.wall_collections + 1)
    local cnum = 0
    if ci == 0 then
      cnum = p._v.collections.current_landscape_collection
    else
      cnum = SCollections.wall_collections[ci]
    end
    SCollections.set(p, cnum, p._v.collections.current_textures[cnum])
  end

  -- handle menu
  if (not p._v.keys.mic.down) and p._v.keys.primary.released then
    local name = SMenu.selection(p)
    if name == nil then return end

    if string.sub(name, 1, 7) == "choose_" then
      local cc, ct = string.match(name, "(%d+)_(%d+)")
      cc = cc + 0
      ct = ct + 0
      SCollections.set(p, cc, ct)
    elseif string.sub(name, 1, 5) == "coll_" then
      local cnum = tonumber(string.sub(name, 6))
      if cnum == 0 then
        cnum = p._v.collections.current_landscape_collection
      end
      SCollections.set(p, cnum, p._v.collections.current_textures[cnum])
    end
  end

end
function SMode.start_attribute(p)
  p._v.apply_saved = {}
  p._v.apply_saved.light = p._v.apply.light
  p._v.apply_saved.texture = p._v.apply.texture
  p._v.apply_saved.align = p._v.apply.align
  p._v.apply_saved.transparent = p._v.apply.transparent
  p._v.apply_saved.edit_panels = p._v.apply.edit_panels
  p._v.apply_saved.advanced_mode = p._v.advanced_mode
  p._v.apply_saved.quantize = p._v.quantize
  p._v.apply_saved.transfer_mode = p._v.transfer_mode
  p._v.apply_saved.transfer_mode_base = p._v.transfer_mode_base
  p._v.apply_saved.transfer_mode_fast = p._v.transfer_mode_fast
  p._v.apply_saved.transfer_mode_reverse = p._v.transfer_mode_reverse
  p._v.apply_saved.cur_light = p._v.light
end
function SMode.revert_attribute(p)
  p._v.apply.light = p._v.apply_saved.light
  p._v.apply.texture = p._v.apply_saved.texture
  p._v.apply.align = p._v.apply_saved.align
  p._v.apply.transparent = p._v.apply_saved.transparent
  p._v.apply.edit_panels = p._v.apply_saved.edit_panels
  p._v.advanced_mode = p._v.apply_saved.advanced_mode
  p._v.quantize = p._v.apply_saved.quantize
  p._v.transfer_mode = p._v.apply_saved.transfer_mode
  p._v.transfer_mode_base = p._v.apply_saved.transfer_mode_base
  p._v.transfer_mode_fast = p._v.apply_saved.transfer_mode_fast
  p._v.transfer_mode_reverse = p._v.apply_saved.transfer_mode_reverse
  p._v.light = p._v.apply_saved.cur_light
end
function SMode.default_attribute(p)
  p._v.apply.light = true
  p._v.apply.texture = true
  p._v.apply.align = true
  p._v.apply.transparent = false
  p._v.apply.edit_panels = true
  p._v.advanced_mode = false
  p._v.quantize = 0
  p._v.transfer_mode = "normal"
  p._v.transfer_mode_base = "normal"
  p._v.transfer_mode_fast = false
  p._v.transfer_mode_reverse = false
  p._v.light = 0
  if SCollections.is_landscape(SCollections.current_coll(p)) then
    p._v.transfer_mode = "landscape"
    p._v.transfer_mode_base = "landscape"
  end
end
function SMode.can_use_transferm(mod, base)
  if mod == "fast" then
    return base == "wobble" or base == "wander" or base == "horizontal slide" or base == "vertical slide"
  elseif mod == "reverse" then
    return base == "horizontal slide" or base == "vertical slide"
  end
  return false
end
function SMode.set_transfer_mode(p)
  local base = p._v.transfer_mode_base
  local mode = base
  if p._v.transfer_mode_fast and SMode.can_use_transferm("fast", base) then
    mode = "fast " .. mode
  end
  if p._v.transfer_mode_reverse and SMode.can_use_transferm("reverse", base) then
    mode = "reverse " .. mode
  end
  p._v.transfer_mode = mode
end
function SMode.handle_attribute(p)
  if p._v.keys.mic.down then
    if p._v.keys.prev_weapon.pressed then
      p._v.apply.align = not p._v.apply.align
    end
    if p._v.keys.next_weapon.pressed then
      p._v.apply.transparent = not p._v.apply.transparent
    end
    if p._v.keys.primary.released then
      SMode.default_attribute(p)
    end
    if p._v.keys.secondary.released then
      SMode.revert_attribute(p)
    end
  else
    if p._v.keys.prev_weapon.pressed then
      p._v.light = (p._v.light - 1) % #Lights
    elseif p._v.keys.next_weapon.pressed then
      p._v.light = (p._v.light + 1) % #Lights
    end
  end

  -- handle menu
  if (not p._v.keys.mic.down) and p._v.keys.primary.released then
    local name = SMenu.selection(p)
    if name == nil then return end

    if name == "apply_tex" then
      p._v.apply.texture = not p._v.apply.texture
    elseif name == "apply_light" then
      p._v.apply.light = not p._v.apply.light
    elseif name == "apply_align" then
      p._v.apply.align = not p._v.apply.align
    elseif name == "apply_xparent" then
      p._v.apply.transparent = not p._v.apply.transparent
    elseif name == "apply_edit" then
      p._v.apply.edit_panels = not p._v.apply.edit_panels
    elseif name == "advanced" then
      p._v.advanced_mode = not p._v.advanced_mode
    elseif name == "transferm_fast" then
      if p._v.apply.texture and SMode.can_use_transferm("fast", p._v.transfer_mode_base) then
        p._v.transfer_mode_fast = not p._v.transfer_mode_fast
        SMode.set_transfer_mode(p)
      end
    elseif name == "transferm_reverse" then
      if p._v.apply.texture and SMode.can_use_transferm("reverse", p._v.transfer_mode_base) then
        p._v.transfer_mode_reverse = not p._v.transfer_mode_reverse
        SMode.set_transfer_mode(p)
      end
    elseif string.sub(name, 1, 5) == "snap_" then
      local mode = tonumber(string.sub(name, 6))
      p._v.quantize = mode
    elseif string.sub(name, 1, 9) == "transfer_" then
      if p._v.apply.texture then
        p._v.transfer_mode_base = string.sub(name, 10)
        SMode.set_transfer_mode(p)
      end
    elseif string.sub(name, 1, 6) == "light_" then
      local mode = tonumber(string.sub(name, 7))
      p._v.light = mode
    end
  end
end
function SMode.handle_panel(p)
  if not p._v.keys.mic.down then
    if p._v.keys.prev_weapon.pressed then
      SPanel.cycle_permutation(p, -1)
    end
    if p._v.keys.next_weapon.pressed then
      SPanel.cycle_permutation(p, 1)
    end
  else
    if p._v.keys.secondary.released then
      SPanel.revert(p)
    end
    if p._v.keys.prev_weapon.pressed then
      SPanel.cycle_class(p, -1)
    end
    if p._v.keys.next_weapon.pressed then
      SPanel.cycle_class(p, 1)
    end
  end

  -- handle menu
  if (not p._v.keys.mic.down) and p._v.keys.primary.released then
    local name = SMenu.selection(p)
    if name == nil then return end

    if name == "panel_light" then
      p._v.panel.light_dependent = not p._v.panel.light_dependent
    elseif name == "panel_weapon" then
      p._v.panel.only_toggled_by_weapons = not p._v.panel.only_toggled_by_weapons
    elseif name == "panel_repair" then
      p._v.panel.repair = not p._v.panel.repair
    elseif name == "panel_active" then
      p._v.panel.status = not p._v.panel.status
    elseif string.sub(name, 1, 6) == "ptype_" then
      local mode = tonumber(string.sub(name, 7))
      if mode == 0 or p._v.panel.dinfo[mode] ~= nil then
        p._v.panel.classnum = mode
      end
    elseif string.sub(name, 1, 6) == "pperm_" then
      local mode = tonumber(string.sub(name, 7))
      p._v.panel.permutation = mode
    end
  end
end

SExplore = {}
SExplore.must_be_explored = {}
function SExplore.init()
  for p in Polygons() do
    if p.type == "must be explored" then
      SExplore.must_be_explored[p.index] = true
    end
  end
end
function SExplore.update()
  local teleport_poly = nil
  if Players.local_player._v.teleport then
    teleport_poly = Players.local_player._v.teleport.last_target
  end
  for i,v in pairs(SExplore.must_be_explored) do
    if v and i ~= teleport_poly then
      Polygons[i].type = "must be explored"
    end
  end
end

SKeys = {}
function SKeys.init()
  for p in Players() do
    p._v.keys = {}
    p._v.keys.action = {}
    p._v.keys.prev_weapon = {}
    p._v.keys.next_weapon = {}
    p._v.keys.map = {}
    p._v.keys.primary = {}
    p._v.keys.secondary = {}
    p._v.keys.mic = {}

    for _, k in pairs(p._v.keys) do
      k.down = false
      k.pressed = false
      k.released = false
      k.first = -5
      k.lag = -5
      k.highlight = false
      k.held = false
    end

    p._v.overhead = false
    p._v.terminal = false
  end
end

function SKeys.track_key(p, flag, key, disable)
  local k = p._v.keys[key]
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
  for p in Players() do
    if not p._v.terminal then

      -- track keys
      SKeys.track_key(p, 'cycle_weapons_backward', 'prev_weapon', true)
      SKeys.track_key(p, 'cycle_weapons_forward', 'next_weapon', true)
      SKeys.track_key(p, 'left_trigger', 'primary', true)
      SKeys.track_key(p, 'right_trigger', 'secondary', true)
      SKeys.track_key(p, 'microphone_button', 'mic', true)

      SKeys.track_key(p, 'action_trigger', 'action', p._v.keys.mic.down)
      SKeys.track_key(p, 'toggle_map', 'map', p._v.keys.mic.down)

      if p.action_flags.toggle_map then
        p._v.overhead = not p._v.overhead
      end

      -- cancel display highlights if we see a new key
      if p._v.keys.action.pressed or p._v.keys.next_weapon.pressed or p._v.keys.prev_weapon.pressed or p._v.keys.map.pressed then
        SKeys.cancel_highlight(p._v.keys.action)
        SKeys.cancel_highlight(p._v.keys.prev_weapon)
        SKeys.cancel_highlight(p._v.keys.next_weapon)
        SKeys.cancel_highlight(p._v.keys.map)
      end
    end
  end
end
function SKeys.button_state(keyname, mic_modifier, p)
  local state = "enabled"
  local keys = p._v.keys

  if keyname == "any" then
    if mic_modifier then
      if not keys.mic.highlight then
        state = "disabled"
      elseif keys.prev_weapon.highlight or
             keys.next_weapon.highlight or
             keys.primary.highlight or
             keys.secondary.highlight then
        state = "active"
      end
    elseif keys.mic.highlight then
      state = "disabled"
    end
  elseif keyname == "weapon" then
    if keys.prev_weapon.highlight or keys.next_weapon.highlight then state = "active" end

    if keys.mic.highlight ~= mic_modifier then state = "disabled" end
  elseif keyname == "move" then
    -- this isn't true, but it looks a lot nicer visually
    if keys.mic.highlight ~= mic_modifier then state = "disabled" end
  else
    if keys[keyname].highlight then state = "active" end

    if keyname == "mic" then
      if p._v.mic_dummy then state = "disabled" end
    elseif mic_modifier then
      if not keys.mic.highlight then state = "disabled" end
    elseif keys.mic.highlight then
      state = "disabled"
    elseif keyname == "action" and (not SMode.menu_mode(p._v.mode)) and  p:find_action_key_target() then
      state = "disabled"
    end
  end

  return state
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
    p._v.freeze = {}
    p._v.freeze.frozen = false
    p._v.freeze.mode = nil
    p._v.freeze.point = {}
    p._v.freeze.point.x = 0
    p._v.freeze.point.y = 0
    p._v.freeze.point.z = 0
    p._v.freeze.point.poly = 0
    p._v.freeze.point.direction = 0
    p._v.freeze.point.elevation = 0
    p._v.freeze.restore = {}
    p._v.freeze.restore.direction = 0
    p._v.freeze.restore.elevation = 0
  end
end
function SFreeze.postidle()
  for p in Players() do
    if p._v.freeze.mode then
      p._v.freeze.restore.direction = p.direction
      p._v.freeze.restore.elevation = p.elevation
      p.direction = p._v.freeze.point.direction
      p.elevation = p._v.freeze.point.elevation
    end
    if p._v.freeze.frozen or p._v.freeze.mode then
      SFreeze.reposition(p)
    end
  end
end
function SFreeze.reposition(p)
  local z = p._v.freeze.point.z
  if p._v.freeze.mode == "menu" then z = p.polygon.z end
  p:position(p._v.freeze.point.x, p._v.freeze.point.y, z, Polygons[p._v.freeze.point.poly])
  p.external_velocity.i = 0
  p.external_velocity.j = 0
  p.external_velocity.k = 0
end
function SFreeze.freeze(p)
  if p._v.freeze.frozen then return end
  p._v.freeze.frozen = true
  if not p._v.freeze.mode then
    p._v.freeze.point.x = p.x
    p._v.freeze.point.y = p.y
    p._v.freeze.point.z = math.max(p.z, p.polygon.z + 1/1024.0)
    p._v.freeze.point.poly = p.polygon.index
    SFreeze.reposition(p)
  end
end
function SFreeze.unfreeze(p)
  p._v.freeze.frozen = false
end
function SFreeze.toggle_freeze(p)
  if p._v.freeze.frozen then
    SFreeze.unfreeze(p)
  else
    SFreeze.freeze(p)
  end
end
function SFreeze.frozen(p)
  return p._v.freeze.frozen
end
function SFreeze.enter_mode(p, mode)
  local old_mode = p._v.freeze.mode
  if old_mode == mode then return end
  if old_mode then
    p.direction = p._v.freeze.point.direction
    p.elevation = p._v.freeze.point.elevation
    if p._v.freeze.on_teleporter then
      p.polygon.type = "teleporter"
      p._v.freeze.on_teleporter = false
    end
  end
  if mode then
    if not p._v.freeze.frozen then
      p._v.freeze.point.x = p.x
      p._v.freeze.point.y = p.y
      p._v.freeze.point.z = math.max(p.z, p.polygon.z + 1/1024.0)
      p._v.freeze.point.poly = p.polygon.index
      SFreeze.reposition(p)
    end
    -- menus don't work properly when standing on a teleporter
    p._v.freeze.on_teleporter = (p.polygon.type == "teleporter")
    if p._v.freeze.on_teleporter then
      p.polygon.type = "normal"
    end
    p._v.freeze.point.direction = p.direction
    p._v.freeze.point.elevation = p.elevation
    p._v.freeze.extra_dir = 0
    p._v.freeze.extra_elev = 0
    p._v.freeze.last_forward = p.internal_velocity.forward
    p._v.freeze.last_perpendicular = p.internal_velocity.perpendicular
    p._v.freeze.last_motion = {}
    p._v.freeze.last_motion["forward"] = 0
    p._v.freeze.last_motion["perpendicular"] = 0
    p.direction = 180
    p.elevation = 0
  end
  p._v.freeze.mode = mode
end
function SFreeze.in_mode(p, mode)
  return p._v.freeze.mode == mode
end
function SFreeze.detect_motion(p, which)
  if not p._v.freeze.mode then return 0 end

  local last = p._v.freeze["last_" .. which]
  if last == nil then last = 0 end
  local cur = p.internal_velocity[which]
  p._v.freeze["last_" .. which] = cur

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
    if p._v.freeze.frozen or p._v.freeze.mode then
      SFreeze.reposition(p)
    end
    if p._v.freeze.mode then
      p.direction = p._v.freeze.restore.direction
      p.elevation = p._v.freeze.restore.elevation
      local check_direction = true

      if p._v.freeze.mode == "menu" then
        -- check for movement keys
        local last_mov = {}
        local cur_mov = {}
        local any_move = false
        for _,dir in pairs({ "forward", "perpendicular" }) do
          last_mov[dir] = p._v.freeze.last_motion[dir]
          cur_mov[dir] = SFreeze.detect_motion(p, dir)
          p._v.freeze.last_motion[dir] = cur_mov[dir]
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
        p._v.freeze.extra_dir = p._v.freeze.extra_dir + nd
        p.direction = 180
        nd = 0
      end
      if (ne < -20) or (ne > 20) then
        p._v.freeze.extra_elev = p._v.freeze.extra_elev + ne
        p.elevation = 0
        ne = 0
      end

      local rr = SFreeze.ranges[p._v.freeze.mode]
      if (p._v.freeze.extra_dir + nd) > rr.xrange then
        p._v.freeze.extra_dir = rr.xrange - nd
      elseif (p._v.freeze.extra_dir + nd) < -rr.xrange then
        p._v.freeze.extra_dir = -rr.xrange - nd
      end
      if (p._v.freeze.extra_elev + ne) > rr.yrange then
        p._v.freeze.extra_elev = rr.yrange - ne
      elseif (p._v.freeze.extra_elev + ne) < -rr.yrange then
        p._v.freeze.extra_elev = -rr.yrange - ne
      end
    end
  end
end
function SFreeze.coord(p)
  local rr = SFreeze.ranges[p._v.freeze.mode]

  local xa = p.direction - 180 + p._v.freeze.extra_dir + rr.xrange
  local ya = 0 - p.elevation + p._v.freeze.extra_elev + rr.yrange

  return math.floor(rr.xoff + xa*rr.xscale), math.floor(rr.yoff + ya*rr.yscale)
end
function SFreeze.set_coord(p, x, y)
  local rr = SFreeze.ranges[p._v.freeze.mode]
  local xa = (x - rr.xoff)/rr.xscale
  local ya = (y - rr.yoff)/rr.yscale

  p.direction = 180
  p.elevation = 0
  p._v.freeze.extra_dir = xa - rr.xrange
  p._v.freeze.extra_elev = ya - rr.yrange
end
function SFreeze.orig_dir(p)
  if not p._v.freeze.mode then return p.direction end
  return p._v.freeze.point.direction
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

      local ttype = SPanel.classnum_from_type(t)

      for _,v in ipairs({ t.active_texture_index, t.inactive_texture_index }) do
        if not cc[v] then cc[v] = {} end
        if not cc[v][ttype] then
          cc[v][ttype] = t.index
        end
      end
    end
  end
end
function SPanel.cycle_class(p, dir)
  local cur = p._v.panel.classnum
  local dinfo = p._v.panel.dinfo
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

  p._v.panel.classnum = SPanel.classorder[idx]
end
function SPanel.cycle_permutation(p, dir)
  local cur = p._v.panel.classnum
  local perm = p._v.panel.permutation

  if cur == SPanel.platform_switch then
    local total = #SPlatforms.sorted_platforms
    if total > 0 then
      local idx = SPlatforms.index_lookup[perm]
      if idx == nil then
        idx = total
        if dir < 0 then idx = 1 end
      end
      idx = (((idx + dir) - 1) % total) + 1
      p._v.panel.permutation = SPlatforms.sorted_platforms[idx].polygon.index
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
      p._v.panel.permutation = (perm + dir) % total
    end
  end
end
function SPanel.menu_name(p)
  local current_class = 0
  if p._v.panel and (p._v.panel.classnum ~= nil) then
    current_class = p._v.panel.classnum
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
  p._v.panel.sides[surface.index] = true
end
function SPanel.start_editing(p, surface)
  p._v.panel.editing = true
  p._v.panel.classnum = 0
  p._v.panel.permutation = 0
  p._v.panel.light_dependent = false
  p._v.panel.only_toggled_by_weapons = false
  p._v.panel.repair = false
  p._v.panel.status = false
  p._w.panel.surface = surface
  p._v.panel.sides = {}
  p._v.panel.sides[surface.index] = true
  p._v.panel.dinfo = SPanel.device_collections[surface.collection.index][surface.texture_index]

  if SPanel.surface_has_valid_panel(surface) then
    -- populate info from existing panel
    local cp = Sides[surface.index].control_panel
    p._v.panel.classnum = SPanel.classnum_from_type(cp.type)
    p._v.panel.light_dependent = cp.light_dependent
    p._v.panel.only_toggled_by_weapons = cp.only_toggled_by_weapons
    p._v.panel.repair = cp.repair
    p._v.panel.status = cp.status
    p._v.panel.permutation = cp.permutation
  else
    -- find first valid type
    local dinfo = p._v.panel.dinfo
    for classnum = 1,11 do
      if dinfo[classnum] ~= nil then
        p._v.panel.classnum = classnum
        if ct == ControlPanelTypes[dinfo[classnum]].active_texture_index then
          p._v.panel.status = true
        end
        break
      end
    end
  end

  p._v.panel_saved = {}
  p._v.panel_saved.classnum = p._v.panel.classnum
  p._v.panel_saved.permutation = p._v.panel.permutation
  p._v.panel_saved.light_dependent = p._v.panel.light_dependent
  p._v.panel_saved.only_toggled_by_weapons = p._v.panel.only_toggled_by_weapons
  p._v.panel_saved.repair = p._v.panel.repair
  p._v.panel_saved.status = p._v.panel.status
end
function SPanel.revert(p)
  p._v.panel.classnum = p._v.panel_saved.classnum
  p._v.panel.permutation = p._v.panel_saved.permutation
  p._v.panel.light_dependent = p._v.panel_saved.light_dependent
  p._v.panel.only_toggled_by_weapons = p._v.panel_saved.only_toggled_by_weapons
  p._v.panel.repair = p._v.panel_saved.repair
  p._v.panel.status = p._v.panel_saved.status
end
function SPanel.stop_editing(p)
  if p._v.panel.editing then
    if p._v.panel.classnum == 0 then
      for sidx,_ in pairs(p._v.panel.sides) do
        Sides[sidx].control_panel = false
      end
    else
      local class = p._v.panel.classnum
      local ctype = p._v.panel.dinfo[p._v.panel.classnum]
      p._v.panel.device = ctype

      for sidx,_ in pairs(p._v.panel.sides) do
        VML.save_control_panel(Sides[sidx], p._v.panel)
      end
    end
    p._v.panel.editing = false
  end
end
function SPanel.valid_option(k, p)
  local classnum = p._v.panel.classnum
  if k == SPanel.light_dependent then
    return true
  elseif k == SPanel.weapons_only or k == SPanel.repair then
    return classnum == SPanel.light_switch or classnum == SPanel.platform_switch or classnum == SPanel.tag_switch or classnum == SPanel.chip or p._v.panel.classnum == SPanel.wires
  elseif k == SPanel.active then
    return classnum == SPanel.tag_switch or classnum == SPanel.chip or classnum == SPanel.wires
  end
  return false
end
function SPanel.menu_name(p)
  local current_class = p._v.panel.classnum
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

SStatus = {}
function SStatus.init()
end
function SStatus.update()
  local p = Players.local_player

  local lbls = SMenu.menus["key_" .. SMode.apply]
  local lbls2 = SMenu.menus["key_" .. SMode.attribute]
  local lbls3 = SMenu.menus["apply_options"]
  local lbls5 = SMenu.menus["key_" .. SMode.teleport]

  lbls2[9][7] = "Apply Light Only"
  if p._v.apply.texture then
    if p._v.apply.light then
      lbls[2][7] = "Apply Light + Texture"
    else
      lbls[2][7] = "Apply Texture"
    end
  elseif p._v.apply.light then
    lbls[2][7] = "Apply Light"
    lbls2[9][7] = "Apply Texture Only"
  else
    lbls[2][7] = "Move Texture"
  end

  lbls3[1][7] = "Apply light: " .. p._v.light

  local att = "Apply texture"
  local tmode = p._v.transfer_mode
  if SCollections.is_landscape(SCollections.current_coll(p)) then
    if tmode == "landscape" then tmode = nil end
  else
    if tmode == "normal" then tmode = nil end
  end
  if tmode ~= nil then
    att = att .. ": " .. tmode
  end
  lbls3[2][7] = att

  lbls3[6][7] = "Snap to grid: " .. snap_modes[p._v.quantize + 1]

  if SFreeze.frozen(p) then
    lbls[7][7] = "Unfreeze"
    lbls5[7][7] = "Unfreeze"
  else
    lbls[7][7] = "Freeze"
    lbls5[7][7] = "Freeze"
  end

  if SUndo.undo_active(p) then
    lbls[5][7] = "Undo"
  else
    lbls[5][7] = "(Can't Undo)"
  end
  if SUndo.redo_active(p) then
    lbls[6][7] = "Redo"
  else
    lbls[6][7] = "(Can't Redo)"
  end

  if p._v.apply.align then
    lbls2[8][7] = "Ignore Adjacent"
  else
    lbls2[8][7] = "Align Adjacent"
  end
  if p._v.apply.transparent then
    lbls2[9][7] = "Ignore Transparent Sides"
  else
    lbls2[9][7] = "Edit Transparent Sides"
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
  { "label", nil, 30+5, 250, 155, 20, "Snap to grid" },
  { "radio", "snap_0", 30, 270, 155, 20, snap_modes[1] },
  { "radio", "snap_1", 30, 290, 155, 20, snap_modes[2] },
  { "radio", "snap_2", 30, 310, 155, 20, snap_modes[3] },
  { "radio", "snap_3", 30, 330, 155, 20, snap_modes[4] },
  { "radio", "snap_4", 30, 350, 155, 20, snap_modes[5] },
  { "radio", "snap_5", 30, 370, 155, 20, snap_modes[6] },
  { "label", nil, 215+5, 85, 240, 20, "Light" },
  { "label", nil, 215+5, 250, 240, 20, "Texture mode" },
  { "radio", "transfer_normal", 215, 270, 120, 20, "Normal" },
  { "radio", "transfer_2x", 215, 290, 120, 20, "2x" },
  { "radio", "transfer_4x", 215, 310, 120, 20, "4x" },
  { "radio", "transfer_pulsate", 215, 330, 120, 20, "Pulsate" },
  { "radio", "transfer_static", 215, 350, 120, 20, "Static" },
  { "radio", "transfer_landscape", 215, 370, 120, 20, "Landscape" },
  { "radio", "transfer_wobble", 335, 270, 120, 20, "Wobble" },
  { "radio", "transfer_horizontal slide", 335, 290, 120, 20, "Horizontal slide" },
  { "radio", "transfer_vertical slide", 335, 310, 120, 20, "Vertical slide" },
  { "radio", "transfer_wander", 335, 330, 120, 20, "Wander" },
  { "checkbox", "transferm_reverse", 335, 370, 60, 20, "Reverse" },
  { "checkbox", "transferm_fast", 395, 370, 60, 20, "Fast" },
  { "label", nil, 485, 250, 120, 20, "Texture preview" },
  { "applypreview", nil, 485, 270, 120, 1, nil },
  { "applypreview", nil, 485, 270, 40, 2, nil } }
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
SMenu.menus["apply_options"] = {
  { "acheckbox", "apply_light", 110, 394, 155, 14, "Apply light" },
  { "acheckbox", "apply_tex", 110, 408, 155, 14, "Apply texture" },
  { "acheckbox", "apply_align", 110, 422, 155, 14, "Align adjacent" },
  { "acheckbox", "apply_edit", 110, 436, 155, 14, "Edit switches and panels" },
  { "acheckbox", "apply_xparent", 110, 450, 155, 14, "Edit transparent sides" },
  { "acheckbox", "apply_snap", 110, 464, 155, 14, "Snap to grid" },
  { "applypreview", nil, 20, 394, 84, 1, nil },
  { "applypreview", nil, 86, 398, 20, 2, nil } }
SMenu.menus["key_" .. SMode.apply] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Apply Texture" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Sample Light + Texture" },
  { "kaction", "key_weapon", 235, 38, 100, 12, "Change Light" },
--   { "kaction", "key_move", 235, 50, 100, 12, "Select Surface" },
  { "kaction", "key_mic_primary", 475, 10, 100, 12, "Undo" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Redo" },
  { "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Freeze" },
  { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Jump" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
--   { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
  { "kmod", "key_mic_any", 380, 4, 44, 64, nil },
  { "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
  { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
  { "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Prev Weapon" },
  { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
  { "ktab", nil, 20, 4, 130, 16, "Visual Mode" },
  { "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_action", 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
SMenu.menus["key_" .. SMode.teleport] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Teleport" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_weapon", 235, 38, 100, 12, "Change Polygon" },
--   { "kaction", "key_move", 235, 50, 100, 12, "Select Polygon" },
  { "kaction", "key_mic_primary", 475, 10, 100, 12, "Fast Forward Polygon" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Rewind Polygon" },
  { "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Freeze" },
  { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Jump" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
--   { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
  { "kmod", "key_mic_any", 380, 4, 44, 64, nil },
  { "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
  { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
  { "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Prev Weapon" },
  { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
  { "ktab", "key_map", 20, 4, 130, 16, "Visual Mode" },
  { "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_action", 20, 36, 130, 16, (allow_heights and "Heights" or "Options") },
  { "ktab", nil, 20, 52, 130, 16, "Teleport" } }
SMenu.menus["key_" .. SMode.choose] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Select Texture" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_weapon", 235, 38, 100, 12, "Change Texture" },
  { "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
  { "kaction", "key_mic_primary", 475, 10, 100, 12, "Fast Forward Texture" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Rewind Texture" },
  { "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Collection" },
--   { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Collection" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
  { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
  { "kmod", "key_mic_any", 380, 4, 44, 64, nil },
  { "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
  { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
  { "klabel", "key_mic_weapon", 400, 38, 70, 12, "Change Weapon" },
--   { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
  { "ktab", "key_mic", 20, 4, 130, 16, "Visual Mode" },
  { "ktab", nil, 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_action", 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
SMenu.menus["key_" .. SMode.attribute] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_weapon", 235, 38, 100, 12, "Change Light" },
  { "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
  { "kaction", "key_mic_primary", 475, 10, 100, 12, "Default Settings" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
  { "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Ignore Adjacent" },
  { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Edit Transparent Sides" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
  { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
  { "kmod", "key_mic_any", 380, 4, 44, 64, nil },
  { "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
  { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
  { "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Prev Weapon" },
  { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
  { "ktab", "key_action", 20, 4, 130, 16, "Visual Mode" },
  { "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", nil, 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
  SMenu.menus["key_" .. SMode.heights] = {
    { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
    { "kaction", "key_primary", 235, 10, 100, 12, "Adjust Height" },
    { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
    -- { "kaction", "key_weapon", 235, 38, 100, 12, "Change Light" },
  --   { "kaction", "key_move", 235, 50, 100, 12, "Select Surface" },
    { "kaction", "key_mic_primary", 475, 10, 100, 12, "Undo" },
    { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Redo" },
    { "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Freeze" },
    { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Jump" },
    { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
    { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
    -- { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
  --   { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
    { "kmod", "key_mic_any", 380, 4, 44, 64, nil },
    { "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
    { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
    { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
    { "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Prev Weapon" },
    { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
    { "ktab", "key_action", 20, 4, 130, 16, "Visual Mode" },
    { "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
    { "ktab", nil, 20, 36, 130, 16, "Heights" },
    { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
  SMenu.menus["key_panel_off"] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
--   { "kaction", "key_weapon", 235, 38, 100, 12, "Change Script" },
  { "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
--   { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
  { "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Type" },
--   { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Type" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
--   { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
  { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
  { "kmod", "key_mic_any", 380, 4, 44, 64, nil },
  { "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
--   { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
  { "klabel", "key_mic_weapon", 400, 38, 70, 12, "Change Weapon" },
--   { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
  { "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
  { "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_action", 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
SMenu.menus["key_panel_plain"] = SMenu.menus["key_panel_off"]
SMenu.menus["key_panel_terminal"] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_weapon", 235, 38, 100, 12, "Change Script" },
  { "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
--   { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
  { "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Type" },
--   { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Type" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
  { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
  { "kmod", "key_mic_any", 380, 4, 44, 64, nil },
  { "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
--   { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
  { "klabel", "key_mic_weapon", 400, 38, 70, 12, "Change Weapon" },
--   { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
  { "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
  { "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_action", 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
SMenu.menus["key_panel_light"] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_weapon", 235, 38, 100, 12, "Change Light" },
  { "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
--   { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
  { "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Type" },
--   { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Type" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
  { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
  { "kmod", "key_mic_any", 380, 4, 44, 64, nil },
  { "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
--   { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
  { "klabel", "key_mic_weapon", 400, 38, 70, 12, "Change Weapon" },
--   { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
  { "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
  { "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_action", 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
SMenu.menus["key_panel_platform"] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_weapon", 235, 38, 100, 12, "Change Platform" },
  { "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
--   { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
  { "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Type" },
--   { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Type" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
  { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
  { "kmod", "key_mic_any", 380, 4, 44, 64, nil },
  { "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
--   { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
  { "klabel", "key_mic_weapon", 400, 38, 70, 12, "Change Weapon" },
--   { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
  { "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
  { "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_action", 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }
SMenu.menus["key_panel_tag"] = {
  { "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
  { "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
  { "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
  { "kaction", "key_weapon", 235, 38, 100, 12, "Change Tag" },
  { "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
--   { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
  { "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
  { "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Type" },
--   { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Type" },
  { "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
  { "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
  { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
  { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
  { "kmod", "key_mic_any", 380, 4, 44, 64, nil },
  { "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
--   { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
  { "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
  { "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Change Weapon" },
--   { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
  { "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
  { "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
  { "ktab", "key_action", 20, 36, 130, 16, "Options" },
  { "ktab", "key_map", 20, 52, 130, 16, "Teleport" } }

SMenu.inited = {}
function SMenu.selection(p)
  local mode = SMode.current_menu_name(p)
  if not SMenu.inited[mode] then SMenu.init_menu(mode) end
  local m = SMenu.menus[mode]
  local x, y = SMenu.coord(p)

  for idx, item in ipairs(m) do
    if SMenu.clickable(item) then
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
    if SMenu.clickable(item) then
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

  if not closest then
    distance = 999
    for idx, item in ipairs(m) do
      if SMenu.clickable(item) then
        if (direction == "down" and y < item[4]) or
           (direction == "up"   and y > (item[4] + item[6])) then
          local midx = item[3] + item[5]/2
          local dist = math.abs(x - midx)
          if distance > dist then
            distance = dist
            closest = item
          end
        elseif (direction == "right" and x < item[3]) or
               (direction == "left" and x > (item[3] + item[5])) then
          local midy = item[4] + item[6]/2
          local dist = math.abs(y - midy)
          if distance > dist then
            distance = dist
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
function SMenu.clickable(item)
  if item[8] == "disabled" then return false end
  local item_type = item[1]
  return item_type == "button" or item_type == "checkbox" or item_type == "radio" or item_type == "texture" or item_type == "light" or item_type == "dbutton" or item_type == "acheckbox" or item_type == "tab"
end
function SMenu.button_state(name, p)
  local state = "enabled"

  if name == "enabled" then
    state = "enabled"
  elseif name == "active" then
    state = "active"
  elseif name == "disabled" then
    state = "disabled"
  elseif name == "apply_tex" then
    if p._v.apply.texture then state = "active" end
  elseif name == "apply_light" then
    if p._v.apply.light then state = "active" end
  elseif name == "apply_align" then
    if p._v.apply.align then state = "active" end
  elseif name == "apply_xparent" then
    if p._v.apply.transparent then state = "active" end
  elseif name == "apply_edit" then
    if p._v.apply.edit_panels then state = "active" end
  elseif name == "advanced" then
    if p._v.advanced_mode then state = "active" end
  elseif name == "apply_snap" then
    if p._v.quantize > 0 then state = "active" end
  elseif string.sub(name, 1, 5) == "snap_" then
    local mode = tonumber(string.sub(name, 6))
    if p._v.quantize == mode then state = "active" end
  elseif name == "transferm_fast" then
    if p._v.transfer_mode_fast then state = "active" end
    if p._v.transfer_mode_base ~= "wobble" and p._v.transfer_mode_base ~= "wander" and p._v.transfer_mode_base ~= "horizontal slide" and p._v.transfer_mode_base ~= "vertical slide" then state = "disabled" end
    if not p._v.apply.texture then state = "disabled" end
  elseif name == "transferm_reverse" then
    if p._v.transfer_mode_reverse then state = "active" end
    if p._v.transfer_mode_base ~= "horizontal slide" and p._v.transfer_mode_base ~= "vertical slide" then state = "disabled" end
    if not p._v.apply.texture then state = "disabled" end
  elseif string.sub(name, 1, 9) == "transfer_" then
    local mode = string.sub(name, 10)
    if p._v.transfer_mode_base == mode then state = "active" end
    if SCollections.is_landscape(SCollections.current_coll(p)) and mode ~= "landscape" then state = "disabled" end
    if not SCollections.is_landscape(SCollections.current_coll(p)) and mode == "landscape" then state = "disabled" end
    if not p._v.apply.texture then state = "disabled" end
  elseif string.sub(name, 1, 6) == "light_" then
    local mode = tonumber(string.sub(name, 7))
    if p._v.light == mode then state = "active" end
  elseif string.sub(name, 1, 5) == "coll_" then
    local mode = tonumber(string.sub(name, 6))
    if p._v.collections.current_collection == mode then state = "active" end
  elseif string.sub(name, 1, 7) == "choose_" then
    local cc, ct = string.match(name, "(%d+)_(%d+)")
    cc = cc + 0
    ct = ct + 0
    if cc == SCollections.current_coll(p) and ct == p._v.collections.current_textures[cc] then
      state = "active"
    end
  elseif string.sub(name, 1, 6) == "pperm_" then
    local mode = tonumber(string.sub(name, 7))
    if p._v.panel.permutation == mode then state = "active" end
  elseif string.sub(name, 1, 6) == "ptype_" then
    local mode = tonumber(string.sub(name, 7))
    if p._v.panel.dinfo[mode] == nil then state = "disabled" end
    if mode == 0 then state = "enabled" end
    if mode == p._v.panel.classnum then state = "active" end
  elseif name == "panel_light" then
    if p._v.panel.light_dependent then state = "active" end
    if not SPanel.valid_option(SPanel.light_dependent) then state = "disabled" end
  elseif name == "panel_weapon" then
    if p._v.panel.only_toggled_by_weapons then state = "active" end
    if not SPanel.valid_option(SPanel.only_toggled_by_weapons) then state = "disabled" end
  elseif name == "panel_repair" then
    if p._v.panel.repair then state = "active" end
    if not SPanel.valid_option(SPanel.repair) then state = "disabled" end
  elseif name == "panel_active" then
    if p._v.panel.status then state = "active" end
    if not SPanel.valid_option(SPanel.status) then state = "disabled" end
  elseif string.sub(name, 1, 8) == "key_mic_" then
    state = SKeys.button_state(string.sub(name, 9), true, p)
  elseif string.sub(name, 1, 4) == "key_" then
    state = SKeys.button_state(string.sub(name, 5), false, p)
  end

  return state
end
function SMenu.update()
  local p = Players.local_player
  p._v.current_menus = {}
  p._v.fullscreen_menu = false

  if p._v.mode == SMode.choose then
    p._v.current_menus["key_" .. SMode.choose] = true
    p._v.current_menus["choose_" .. p._v.collections.current_collection] = true
    p._v.fullscreen_menu = true
  elseif p._v.mode == SMode.panel then
    p._v.current_menus["key_" .. SPanel.menu_name(p)] = true
    p._v.current_menus[SPanel.menu_name(p)] = true
    p._v.fullscreen_menu = true
  elseif p._v.mode == SMode.attribute then
    p._v.current_menus["key_" .. SMode.attribute] = true
    p._v.current_menus[SMode.attribute] = true
    p._v.fullscreen_menu = true
  elseif p._v.mode == SMode.apply then
    if not p._v.advanced_mode then
      p._v.current_menus["key_" .. SMode.apply] = true
    end
    p._v.current_menus["apply_options"] = true
    p._v.current_menus["preview_" .. p._v.collections.current_collection] = true
  elseif p._v.mode == SMode.teleport then
    if not p._v.advanced_mode then
      p._v.current_menus["key_" .. SMode.teleport] = true
    end
  elseif p._v.mode == SMode.heights then
    if not p._v.advanced_mode then
      p._v.current_menus["key_" .. SMode.heights] = true
    end
  end

  for menu_name,_ in pairs(p._v.current_menus) do
    if not SMenu.inited[menu_name] then SMenu.init_menu(menu_name) end
    local m = SMenu.menus[menu_name]
    for _,item in ipairs(m) do
      local item_name = item[2]
      if item_name ~= nil then
        item[8] = SMenu.button_state(item_name, p)
      else
        item[8] = "enabled"
      end
    end
  end
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
SCollections.names = {"Coll 0", "Coll 1", "Coll 2", "Coll 3", "Coll 4",
                     "Coll 5", "Coll 6", "Coll 7", "Coll 8", "Coll 9",
                     "Coll 10", "Coll 11", "Coll 12", "Coll 13", "Coll 14",
                     "Coll 15", "Coll 16", "Coll 17", "Coll 18", "Coll 19",
                     "Coll 20", "Coll 21", "Coll 22", "Coll 23", "Coll 24",
                     "Coll 25", "Coll 26", "Coll 27", "Coll 28", "Coll 29",
                     "Coll 30", "Coll 31"}
function SCollections.init()
  for k,v in pairs(collection_names) do
    SCollections.names[k + 1] = v
  end

  for _, collection in pairs(walls) do
    if Collections[collection] ~= nil and Collections[collection].bitmap_count and (not SCollections.collection_map[collection]) then
      table.insert(SCollections.wall_collections, collection)
      SCollections.collection_map[collection] = {type = "wall", count = Collections[collection].bitmap_count}
    end
  end
  table.sort(SCollections.wall_collections)

  local landscape_textures = {}
  local off = 0
  for _, collection in pairs(landscapes) do
    if Collections[collection] ~= nil and Collections[collection].bitmap_count and (not SCollections.collection_map[collection]) then
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
    for _,cnum in pairs(SCollections.wall_collections) do
      local bct = Collections[cnum].bitmap_count
      local rows, cols = SChoose.gridsize(bct)
      table.insert(menu_colls, { cnum = cnum, bct = bct, rows = rows, cols = cols, xscale = 1 })
    end
    local num_land = #landscape_textures
    if num_land > 0 then
      local rows, cols = SChoose.widegridsize(num_land)
      table.insert(menu_colls, { cnum = 0, bct = num_land, rows = rows, cols = cols, xscale = 2 })
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
        table.insert(cbuttons,
          { "dbutton", "coll_" .. cinfo.cnum, x, y, w, 20, SCollections.names[cinfo.cnum + 1] })

        -- collection preview
        if preview_all_collections then
          local xx = x + menu_prefs.button_indent
          local yy = y + 20 + menu_prefs.button_indent
          local ww = w - 2*menu_prefs.button_indent
          local hh = 75 - 2*menu_prefs.button_indent

          local bct, rows, cols, xscale = cinfo.bct, cinfo.rows, cinfo.cols, cinfo.xscale
          local tsize = math.min(ww / (cols * xscale), hh / rows)
          xx = xx + (ww - (tsize * cols * xscale))/2

          for j = 1,bct do
            local col = (j - 1) % cols
            local row = math.floor((j - 1) / cols)
            local xt = xx + (tsize * col * xscale)
            local yt = yy + (tsize * row)

            local cc = cinfo.cnum
            local ct = j - 1
            if cc == 0 then
              cc = landscape_textures[j][1]
              ct = landscape_textures[j][2]
            end
            table.insert(cbuttons,
              { "dtexture", "display_" .. cc .. "_" .. ct,
                xt, yt, tsize * xscale, tsize, cc .. ", " .. ct })
          end
        end
        x = x + w
      end
    end

    -- set up grid
    for _,cinfo in ipairs(menu_colls) do
      local bct
      local xscale = 1
      if cinfo.cnum == 0 then
        bct = #landscape_textures
        xscale = 2
      else
        bct = Collections[cinfo.cnum].bitmap_count
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

        local cc = cinfo.cnum
        local ct = i - 1
        if cinfo.cnum == 0 then
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

      SMenu.menus["choose_" .. cinfo.cnum] = buttons
    end

    -- set up apply-mode previews
    for i = 1,#menu_colls do
      local preview = {}
      local cinfo = menu_colls[i]
      local cnum, bct, rows, cols, xscale = cinfo.cnum, cinfo.bct, cinfo.rows, cinfo.cols, cinfo.xscale
      if preview_collection_when_applying then
        local w = 168
        local h = 84
        local tsize = math.min(w / (cols * xscale), h / rows)
        local x = 620 - (tsize * cols * xscale)
        local y = 480 - 88/2 - (tsize * rows)/2
        for j = 1,bct do
          local col = (j - 1) % cols
          local row = math.floor((j - 1) / cols)
          local xt = x + (tsize * col * xscale)
          local yt = y + (tsize * row)

          local cc = cnum
          local ct = j - 1
          if cnum == 0 then
            cc = landscape_textures[j][1]
            ct = landscape_textures[j][2]
          end
          table.insert(preview,
            { "atexture", "choose_" .. cc .. "_" .. ct,
              xt, yt, tsize * xscale, tsize, cc .. ", " .. ct })
        end
      end
      SMenu.menus["preview_" .. cnum] = preview
    end
  end

  for p in Players() do

    p._v.collections = {}
    p._v.collections.current_collection = current_collection
    p._v.collections.current_landscape_collection = current_landscape_collection
    p._v.collections.current_textures = {}
    for idx, info in pairs(SCollections.collection_map) do
      p._v.collections.current_textures[idx] = math.floor(info.count / 2)
    end

    p._v.light = current_light
    p._v.transfer_mode = "normal"
    p._v.transfer_mode_base = "normal"
    p._v.transfer_mode_fast = false
    p._v.transfer_mode_reverse = false

    if p.local_ then
      p._v.collections.collection_map = SCollections.collection_map
    end
  end
end
function SCollections.set(p, coll, tex)
  local ci = SCollections.collection_map[coll]
  if ci == nil then return end
  if ci.type == "landscape" then
    p._v.collections.current_landscape_collection = coll
    p._v.collections.current_collection = 0
    p._v.transfer_mode = "landscape"
    p._v.transfer_mode_base = "landscape"
  else
    p._v.collections.current_collection = coll
    if p._v.transfer_mode == "landscape" then
      p._v.transfer_mode = "normal"
      p._v.transfer_mode_base = "normal"
    end
  end
  p._v.collections.current_textures[coll] = tex
end
function SCollections.find_surface(p, copy_mode)
  local surface = nil
  local find_first_line = p._v.apply.transparent
  local find_first_side = false
  if copy_mode then
    find_first_line = false
    find_first_side = p._v.apply.transparent
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
    surface = VML.side_surface(VML.new_side(polygon, o), z)
  end
  return surface, polygon
end
function SCollections.current_coll(p)
  local coll = p._v.collections.current_collection
  if coll == 0 then
    coll = p._v.collections.current_landscape_collection
  end
  return coll
end
function SCollections.is_landscape(coll)
  if coll == 0 then return true end
  local ci = SCollections.collection_map[coll]
  if ci == nil then return false end
  if ci.type == "landscape" then return true end
  return false
end


SUndo = {}
function SUndo.init()
  for p in Players() do
    p._w.undo = {}
    p._w.undo.undos = {}
    p._w.undo.redos = {}
    p._w.undo.current = {}
  end
end
function SUndo.update()
  for p in Players() do
    local cur_empty = true
    for k, v in pairs(p._w.undo.current) do
      cur_empty = false
      break
    end
    if not cur_empty then
      -- took undoable actions this frame; push onto undo stack
      table.insert(p._w.undo.undos, p._w.undo.current)
      p._w.undo.current = {}

      -- no redo if last action wasn't undo
      p._w.undo.redos = {}

      -- limit size of undo stack
      if #p._w.undo.undos > 64 then
        table.remove(p._w.undo.undos, 1)
      end
    elseif p._v.mode == SMode.apply then
      if p._v.keys.mic.down and p._v.keys.action.pressed then
        if SUndo.redo_active(p) then
          SUndo.redo(p)
        else
          SUndo.undo(p)
        end
      elseif p._v.keys.mic.down and p._v.keys.primary.released then
        if SUndo.undo_active(p) then SUndo.undo(p) end
      elseif p._v.keys.mic.down and p._v.keys.secondary.released then
        if SUndo.redo_active(p) then SUndo.redo(p) end
      end
    end
  end
end
function SUndo.undo_active(p)
  return #p._w.undo.undos > 0
end
function SUndo.redo_active(p)
  return #p._w.undo.redos > 0
end
function SUndo.undo(p)
  if #p._w.undo.undos < 1 then return end
  local un = table.remove(p._w.undo.undos)
  local redo = {}
  for s, f in pairs(un) do
    redo[s] = VML.build_undo(s)
    f()
  end
  table.insert(p._w.undo.redos, redo)
end
function SUndo.redo(p)
  if #p._w.undo.redos < 1 then return end
  local re = table.remove(p._w.undo.redos)
  local undo = {}
  for s, f in pairs(re) do
    undo[s] = VML.build_undo(s)
    f()
  end
  table.insert(p._w.undo.undos, undo)
end
function SUndo.add_undo(p, surface)
  if not p._w.undo.current[surface] then
    p._w.undo.current[surface] = VML.build_undo(surface)
  end
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

SCounts = {}
function SCounts.update()
  for p in Players() do
    if p.local_ then
      p._v.counts = {}
      p._v.counts.lights = #Lights
      p._v.counts.polygons = #Polygons
      p._v.counts.platforms = #Platforms
      p._v.counts.tags = max_tags
      p._v.counts.terminals = #Terminals
      if #Terminals < 1 then p._v.counts.terminals = max_scripts end
    end
  end
end


SLights = {}
function SLights.init()
  SLights.update()
end
function SLights.update()
  for p in Players() do
    if p.local_ then
      p._v.intensities = {}
      for i = 1,#Lights do
        p._v.intensities[i - 1] = Lights[i - 1].intensity
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
  for p in Players() do
    if p.local_ then
      p._v.platform_to_poly = {}
      for plat in Platforms() do
        p._v.platform_to_poly[plat.index] = plat.polygon.index
      end
    end
  end
end

UTeleport = {}
function UTeleport.highlight(p, poly)
  if not show_teleport_destination then return end
  if poly.index ~= p._v.teleport.last_target then
    UTeleport.remove_highlight(p)
    p._v.teleport.last_target = poly.index
    p._v.teleport.last_target_mode = poly.floor.transfer_mode.mnemonic
    p._v.teleport.last_target_type = poly.type.mnemonic
    poly.floor.transfer_mode = "static"
    poly.type = "major ouch"
  end
end
function UTeleport.remove_highlight(p)
  if not show_teleport_destination then return end
  if p._v.teleport.last_target ~= nil then
    -- restore last selected poly
    local poly = Polygons[p._v.teleport.last_target]
    poly.floor.transfer_mode = p._v.teleport.last_target_mode
    poly.type = p._v.teleport.last_target_type
    p._v.teleport.last_target = nil
  end
end

UApply = {}
function UApply.apply_texture(p, surface, coll, tex, landscape)
  if p._v.apply.texture then
    surface.collection = coll
    surface.texture_index = tex
    surface.texture_x = p._w.saved_surface.x
    surface.texture_y = p._w.saved_surface.y
    if landscape then
      surface.transfer_mode = "landscape"
    else
      surface.transfer_mode = p._v.transfer_mode
    end
  end
  if p._v.apply.light then
    surface.light = Lights[p._v.light]
  end
end
function UApply.should_edit_panel(p)
  if not p._v.apply.edit_panels then return false end
  if not p._v.apply.texture then return false end

  local surface = p._w.saved_surface.surface
  if surface == nil then return false end
  if is_polygon_floor(surface) or is_polygon_ceiling(surface) then return false end


  local cc = p._v.collections.current_collection
  if cc == 0 then cc = p._v.collections.current_landscape_collection end
  local ct = p._v.collections.current_textures[cc]

  if not SPanel.device_collections[cc] then return false end
  if not SPanel.device_collections[cc][ct] then return false end

  return true
end
function UApply.should_clear_panel(p)
  if not p._v.apply.edit_panels then return false end
  if not p._v.apply.texture then return false end

  local surface = p._w.saved_surface.surface
  if surface == nil then return false end
  if is_polygon_floor(surface) or is_polygon_ceiling(surface) then return false end


  local cc = p._v.collections.current_collection
  if cc == 0 then cc = p._v.collections.current_landscape_collection end
  local ct = p._v.collections.current_textures[cc]

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
   if player._v.quantize == 0 then
      return value
   end

   local ratio = 1.0 / snap_denominators[player._v.quantize]
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
  if not player._w.undo then return end
  local redo = {}
  for s, f in pairs(player._w.undo) do
    redo[s] = build_undo(s)
    f()
  end
  player._w.undo = redo
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
  local ddevice = ControlPanelTypes[device.device]
  if VML.is_switch(ddevice) then
    side.control_panel.only_toggled_by_weapons = device.only_toggled_by_weapons
    side.control_panel.repair = device.repair
    side.control_panel.can_be_destroyed = (ddevice._type == SPanel.wires)
    side.control_panel.uses_item = (ddevice._type == SPanel.chip)
    if ddevice.class == "light switch" then
      side.control_panel.status = Lights[side.control_panel.permutation].active
    elseif ddevice.class == "platform_switch" then
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
  side.control_panel.type = ddevice
end

function VML.new_side(polygon, line)
   local side = Sides.new(polygon, line)
   table.insert(VML.cw_endpoint_sides[VML.get_clockwise_side_endpoint(side)], side)
   table.insert(VML.ccw_endpoint_sides[VML.get_counterclockwise_side_endpoint(side)], side)
   return side
end
