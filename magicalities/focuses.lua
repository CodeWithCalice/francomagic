-- Wand Focuses
local particles = core.settings:get_bool("mgc_particles", true)

-- Focus Blank
core.register_craftitem("magicalities:focus_blank", {
	description = "Blank Wand Focus",
	inventory_image = "magicalities_focus_base.png",
})

-- Fire Focus
core.register_craftitem("magicalities:focus_fire", {
	description = "Wand Focus of Fire",
	groups = {wand_focus = 1},
	inventory_image = "magicalities_focus_fire.png",
	stack_max = 1,
	level_requirement = 3,
	_wand_requirements = {},
	_wand_use = function (itemstack, user, pointed_thing)
		if not user or not user:is_player() then
			return itemstack
		end
		local pname = user:get_player_name()
		if not pname then
			return itemstack
		end
		local inventory = user:get_inventory()
		if not inventory then
			return
		end
		local inventory_size = inventory:get_size("main")
		mana.set(pname, mana.get(pname) - 5)
		for i = 1, inventory_size do
			local stack = inventory:get_stack("main", i)
			if not stack:is_empty() then
				local cooked_item = core.get_craft_result({
					method = "cooking",
					width = 1,
					items = {stack},
				})

				if cooked_item and cooked_item.item and not cooked_item.item:is_empty() then
					-- On prend 10 élements de feu de la baguette par cases cuites
					if magicalities.wands.wand_has_contents(itemstack, {fire = 10}) then
						itemstack = magicalities.wands.wand_take_contents(itemstack, {fire = 10})
					else
						return itemstack
					end
					local cooked_stack = cooked_item.item
					cooked_stack:set_count(stack:get_count())
					inventory:set_stack("main", i, cooked_stack)
				end
			end
		end
		return itemstack
	end
})

if not core.get_modpath("scifi_nodes") then
	local plants = {
		{"flower1", "Glow Flower", 1,0, core.LIGHT_MAX},
		{"flower2", "Pink Flower", 1.5,0, 10},
		{"flower3", "Triffid", 2,5, 0},
		{"flower4", "Weeping flower", 1.5,0, 0},
		{"plant1", "Bulb Plant", 1,0, 0},
		{"plant2", "Trap Plant", 1.5,0, core.LIGHT_MAX},
		{"plant3", "Blue Jelly Plant", 1.2,0, 10},
		{"plant4", "Green Jelly Plant", 1.2,0, 10},
		{"plant5", "Fern Plant", 1.7,0, 0},
		{"plant6", "Curly Plant", 1,0, 10},
		{"plant7", "Egg weed", 1,0, 0},
		{"plant8", "Slug weed", 1,0, 10},
		{"plant9", "Prickly Plant", 1,0, 0},
		{"eyetree", "Eye Tree", 2.5,0, 0},
	}

	for _, row in ipairs(plants) do
		local name = row[1]
		local desc = row[2]
		local size = row[3]
		local dmg = row[4]
		local light = row[5]
		-- Node Definition
		core.register_node("magicalities:"..name, {
			description = desc,
			tiles = {"scifi_nodes_"..name..".png"},
			drawtype = "plantlike",
			inventory_image = "scifi_nodes_"..name..".png",
			groups = {snappy=1, oddly_breakable_by_hand=1, dig_immediate=3, flora=1},
			paramtype = "light",
			visual_scale = size,
			walkable = false,
			damage_per_second = dmg,
			selection_box = {
			type = "fixed",
			fixed = {
				{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3},
			}
			},
			is_ground_content = false,
			light_source = light,
			sounds = default.node_sound_leaves_defaults()
		})
	end
end

-- Earth Focus
local plants = {
	{"magicalities:plant1", 0.10},
	{"magicalities:plant2", 0.10},
	{"magicalities:plant5", 0.10},
	{"magicalities:plant6", 0.10},
	{"magicalities:plant7", 0.10},
	{"magicalities:plant8", 0.10},
	{"magicalities:plant9", 0.10},
	{"magicalities:flower1", 0.25},
	{"magicalities:flower2", 0.25},
	{"magicalities:flower3", 0.25},
	{"magicalities:flower4", 0.25},
	{"magicalities:eyetree", 0.01}
}

local function chose_plant()
	local total = 0
	for _, plant in ipairs(plants) do
		total = total + plant[2]
	end
	local rand = math.random() * total
	local sum = 0
	for _, plant in ipairs(plants) do
		sum = sum + plant[2]
		if rand <= sum then
			return plant[1]
		end
	end
	return plants[#plants][1]
end

core.register_craftitem("magicalities:focus_earth", {
	description = "Wand Focus of Earth",
	groups = {wand_focus = 1},
	inventory_image = "magicalities_focus_earth.png",
	stack_max = 1,
	level_requirement = 4,
	_wand_requirements = {},
	_wand_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		local pos = pointed_thing.under
		local pname = user:get_player_name()
		if core.is_protected(pos, pname) then
			core.record_protection_violation(pos, pname)
			return itemstack
		end
		local node = core.get_node(pos).name
		if node == "default:stone" then
			mana.set(pname, mana.get(pname) - 1)
			core.swap_node(pos, {name = "default:gravel"})
		elseif node == "default:gravel" then
			mana.set(pname, mana.get(pname) - 1)
			core.swap_node(pos, {name = "default:sand"})
		elseif node == "default:sand" then
			mana.set(pname, mana.get(pname) - 1)
			core.swap_node(pos, {name = "default:dirt"})
		elseif node == "default:dirt" then
			if magicalities.wands.wand_has_contents(itemstack, {earth = 10}) then
				itemstack = magicalities.wands.wand_take_contents(itemstack, {earth = 10})
			else
				return itemstack
			end
			mana.set(pname, mana.get(pname) - 1)
			core.swap_node(pos, {name = "scifi_nodes:grassblk"})
		elseif node == "scifi_nodes:grassblk" then
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if core.is_protected(above, pname) then
				core.record_protection_violation(above, pname)
				return itemstack
			end
			local node_above = core.get_node(above).name
			if node_above == "air" then
				if magicalities.wands.wand_has_contents(itemstack, {earth = 20}) then
					itemstack = magicalities.wands.wand_take_contents(itemstack, {earth = 20})
				else
					return itemstack
				end
				mana.set(pname, mana.get(pname) - 10)
				core.set_node(above, {name = chose_plant()})
			end
		end
		if core.get_item_group(node, "tree") > 0 then
			if magicalities.wands.wand_has_contents(itemstack, {earth = 5}) then
				itemstack = magicalities.wands.wand_take_contents(itemstack, {earth = 5})
			else
				return itemstack
			end
			mana.set(pname, mana.get(pname) - 5)
			core.swap_node(pos, {name = "everness:hollow_tree"})
		end
		return itemstack
	end
})

-- Water Focus
core.register_node("magicalities:water_source", {
	description = "Water Source",
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "default_water_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = true,
	diggable = false,
	buildable_to = true,
	drop = "",
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3},
	sounds = default.node_sound_water_defaults(),
})

core.register_node("magicalities:walkable_water_source", {
	description = "Walkable Water Source",
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "default_water_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = true,
	pointable = true,
	diggable = false,
	buildable_to = true,
	drop = "",
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3},
	sounds = default.node_sound_water_defaults(),
})

core.register_node("magicalities:lava_source", {
	description = "Lava Source",
	drawtype = "liquid",
	tiles = {
		{
			name = "default_lava_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
		{
			name = "default_lava_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
	},
	paramtype = "light",
	light_source = default.LIGHT_MAX - 1,
	walkable = false,
	pointable = true,
	diggable = false,
	buildable_to = true,
	drop = "",
	liquid_viscosity = 0,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {liquid = 2},
})

core.register_node("magicalities:walkable_lava_source", {
	description = "Walkable Lava Source",
	drawtype = "liquid",
	tiles = {
		{
			name = "default_lava_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
		{
			name = "default_lava_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
	},
	paramtype = "light",
	light_source = default.LIGHT_MAX - 1,
	walkable = true,
	pointable = true,
	diggable = false,
	buildable_to = true,
	drop = "",
	liquid_viscosity = 0,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {liquid = 2},
})

core.register_craftitem("magicalities:focus_water", {
	description = "Wand Focus of Water",
	groups = {wand_focus = 1},
	inventory_image = "magicalities_focus_water.png",
	stack_max = 1,
	level_requirement = 5,
	_wand_requirements = {
		["water"] = 5
	},
	_wand_use = function(itemstack, user, pointed_thing)
		local pos = pointed_thing.under
		if not pos then
			return itemstack
		end
		local node = core.get_node(pos)
		local node = node.name
		local pname = user:get_player_name()
		if not pname then return itemstack end
		if core.is_protected(pos, pname) then
			core.record_protection_violation(pos, pname)
			return itemstack
		end
		if node == "default:lava_source" then
			mana.set(pname, mana.get(pname) - 5)
			core.swap_node(pos, {name = "magicalities:lava_source"})
		elseif node == "default:water_source" then
			mana.set(pname, mana.get(pname) - 5)
			core.swap_node(pos, {name = "magicalities:water_source"})
		elseif node == "magicalities:lava_source" then
			mana.set(pname, mana.get(pname) - 5)
			core.swap_node(pos, {name = "magicalities:walkable_lava_source"})
		elseif node == "magicalities:water_source" then
			mana.set(pname, mana.get(pname) - 5)
			core.swap_node(pos, {name = "magicalities:walkable_water_source"})
		elseif node == "magicalities:walkable_lava_source" then
			mana.set(pname, mana.get(pname) - 5)
			core.swap_node(pos, {name = "default:lava_source"})
		elseif node == "magicalities:walkable_water_source" then
			mana.set(pname, mana.get(pname) - 5)
			core.swap_node(pos, {name = "default:water_source"})
		end
		return itemstack
	end
})

-- Air Focus
core.register_craftitem("magicalities:focus_air", {
	description = "Wand Focus of Air",
	groups = {wand_focus = 1},
	inventory_image = "magicalities_focus_air.png",
	stack_max = 1,
	level_requirement = 5,
	_wand_requirements = {
		["air"] = 2,
	},
	_wand_use = function(itemstack, user, pointed_thing)
		local pname = user:get_player_name()
		if not pname then return itemstack end
		local start = pointed_thing.under
		local dir = user:get_look_dir()
		if not start or not dir then
			itemstack = magicalities.wands.wand_insert_contents(itemstack, {air = 2})
			return itemstack
		end
		local center = vector.add(start, vector.multiply(dir, 2))
		local cx, cy, cz = math.floor(center.x), math.floor(center.y), math.floor(center.z)
		for dx = -2, 2 do
			for dy = -2, 2 do
				for dz = -2, 2 do
					local npos = {x = cx + dx, y = cy + dy, z = cz + dz}
					local node = core.get_node_or_nil(npos)
					if node and node.name ~= "air" and core.registered_nodes[node.name] then
						local def = core.registered_nodes[node.name]
						if def.walkable then
							if not core.is_protected(npos, pname) then
								core.set_node(npos, {name = "air"})
							else
								core.record_protection_violation(npos, pname)
							end
						end
					end
				end
			end
		end
		core.sound_play("default_dig_metal", {to_player = pname, gain = 15.0})
		return itemstack
	end
})

-- Ice Focus
core.register_entity("magicalities:ice_peak", {
	initial_properties = {
		physical = false,
		collide_with_objects = true,
		pointable = false,
		visual = "mesh",
		mesh = "ice_peak.obj",
		textures = {"ice_peak.png"},
		visual_size = {x = 1, y = 1},
		static_save = false,
	},
	timer = 0,
	lifetime = 3,
	rotation_speed = 5,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > self.lifetime then
			self.object:remove()
			return
		end
		local rot = self.object:get_rotation()
		self.object:set_rotation({x = rot.x, y = rot.y, z = rot.z + self.rotation_speed * dtime})
		local pos = self.object:get_pos()
		local node = core.get_node_or_nil(pos)
		if node and node.name ~= "air" then
			if node.name == "default:water_source" then
				core.set_node(pos, {name = "default:ice"})
			elseif node.name == "default:lava_source" then
				core.set_node(pos, {name = "everness:weeping_obsidian"})
			elseif node.name == "everness:lava_source" then
				core.set_node(pos, {name = "everness:blue_weeping_obsidian"})
			end
			self.object:remove()
			return
		end
		for _,obj in ipairs(core.get_objects_inside_radius(pos, 1)) do
			if obj ~= self.object and obj ~= self.owner then
				local damage = 50
				if math.random(5) == 1 then
					damage = 100
				end
				obj:punch(self.owner, 1.0, {damage_groups = {fleshy = damage}}, nil)
				self.object:remove()
				return
			end
		end
	end,
})

core.register_craftitem("magicalities:focus_ice", {
	description = "Wand Focus of Ice",
	groups = {wand_focus = 1},
	inventory_image = "magicalities_focus_ice.png",
	stack_max = 1,
	level_requirement = 6,
	_wand_requirements = {
		["air"] = 3,
		["water"] = 3
	},
	_wand_use = function(itemstack, user, pointed_thing)
		if not user then return itemstack end
		pname = user:get_player_name()
		if not pname then return itemstack end
		mana.set(pname, mana.get(pname) - 5)
		local pos = vector.add(user:get_pos(), {x=0,y=1.5,z=0})
		local dir = user:get_look_dir()
		local obj = core.add_entity(pos, "magicalities:ice_peak")
		if obj then
			obj:set_velocity(vector.multiply(dir, 25))
			obj:set_acceleration({x=0,y=0,z=0})
			local ent = obj:get_luaentity()
			ent.owner = user
			local yaw = user:get_look_horizontal()
			local pitch = user:get_look_vertical()
			obj:set_rotation({x = -pitch, y = yaw, z = 0})
		end
		core.sound_play("default_place_node", {pos = pos, gain = 2.0, pitch = 0.7})
		return itemstack
	end
})

-- Light Focus
core.register_craftitem("magicalities:focus_light", {
	description = "Wand Focus of Light",
	groups = {wand_focus = 1},
	inventory_image = "magicalities_focus_light.png",
	stack_max = 1,
	level_requirement = 7,
	_wand_requirements = {
		["light"] = 2,
	},
	_wand_use = function(itemstack, user, pointed_thing)
		local pname = user:get_player_name()
		if not pname then return itemstack end
		local player_pos = user:get_pos()
		local start_pos = vector.add(player_pos, {x=0, y=0.2, z=0})
		local eye = vector.add(player_pos, {x=0,y=1.6,z=0})
		local dir = user:get_look_dir()
		local range = 25
		local target = vector.add(eye, vector.multiply(dir, range))
		local ray = core.raycast(eye, target, false, false)
		local hit_pos = target
		for pointed in ray do
			if pointed.type == "node" then
				local pos = pointed.under
				local node = core.get_node(pos)
				hit_pos = pos
				if node.name == "default:stone" then
					if not core.is_protected(pos, pname) then
						core.set_node(pos, {name = "everness:pyrite_lantern"})
					end
				end
				break
			end
		end
		local dir_to_hit = vector.direction(start_pos, hit_pos)
		local dist = vector.distance(start_pos, hit_pos)

		core.add_particlespawner({
			amount = dist * 20,
			time = 0.35,
			minpos = start_pos,
			maxpos = start_pos,
			minvel = vector.multiply(dir_to_hit, dist * 6),
			maxvel = vector.multiply(dir_to_hit, dist * 8),
			minacc = {x=0,y=0,z=0},
			maxacc = {x=0,y=0,z=0},
			minexptime = 0.25,
			maxexptime = 0.35,
			minsize = 1,
			maxsize = 1,
			texture = "light_particle.png",
			glow = 14,
			minpos = vector.subtract(start_pos, {x=0.1,y=0.1,z=0.1}),
			maxpos = vector.add(start_pos, {x=0.1,y=0.1,z=0.1}),
		})

		core.add_particlespawner({
			amount = 10,
			time = 0.1,
			minpos = vector.subtract(hit_pos, {x=0.1,y=0.1,z=0.1}),
			maxpos = vector.add(hit_pos, {x=0.1,y=0.1,z=0.1}),
			minexptime = 0.2,
			maxexptime = 0.4,
			minsize = 1,
			maxsize = 1,
			texture = "light_particle.png",
			glow = 14,
		})
		mana.set(pname, mana.get(pname) - 2)
		core.sound_play("default_meselamp", {pos = eye, gain = 2.0, pitch = 1.2})
		return itemstack
	end
})

-- Dark Focus
core.register_entity("magicalities:dark_lightning", {
	initial_properties = {
		physical = false,
		collide_with_objects = true,
		pointable = false,
		visual = "mesh",
		mesh = "lightning.obj",
		textures = {"lightning_texture.png"},
		visual_size = {x = 1, y = 1},
		static_save = false,
	},
	target = nil,
	owner = nil,
	speed = 20,
	lifetime = 3,
	timer = 0,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > self.lifetime then
			self.object:remove()
			return
		end
		if not self.target or not self.target:get_pos() then
			self.object:remove()
			return
		end
		local pos = self.object:get_pos()
		local target_pos = self.target:get_pos()
		local dir = vector.direction(pos, target_pos)
		self.object:set_velocity(vector.multiply(dir, self.speed))
		local dist = vector.distance(pos, target_pos)
		if dist < 0.5 then
			core.sound_play("tnt_explode", {pos = pos, gain = 2.5, pitch = 0.7})
			local damage = 250
			if math.random(5) == 1 then
				damage = 500
			end
			self.target:punch(self.owner, 1.0, {damage_groups = {fleshy = damage}}, nil)
			self.object:remove()
		end
	end,
})

core.register_entity("magicalities:pentagram_entity", {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		pointable = false,
		visual = "mesh",
		mesh = "pentagram.obj",
		textures = {"pentagram_texture.png"},
		visual_size = {x = 10, y = 10},
		static_save = false,
	},
	lifetime = 2,
	timer = 0,
	rotation_speed = 2,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > self.lifetime then
			self.object:remove()
			return
		end
		local rot = self.object:get_rotation()
		self.object:set_rotation({x = 0, y = rot.y + self.rotation_speed * dtime, z = 0})
	end,
})

core.register_craftitem("magicalities:focus_dark", {
	description = "Wand Focus of Dark",
	groups = {wand_focus = 1},
	inventory_image = "magicalities_focus_dark.png",
	stack_max = 1,
	level_requirement = 7,
	_wand_requirements = {
		["dark"] = 25,
	},
	_wand_use = function(itemstack, user, pointed_thing)
		local pname = user:get_player_name()
		if not pname then return itemstack end
		mana.set(pname, mana.get(pname) - 10)
		local pos = user:get_pos()
		for _,obj in ipairs(core.get_objects_inside_radius(pos, 10)) do
			if obj ~= user then
				local ent = obj:get_luaentity()
				if not (ent and ent.name == "__builtin:item") then
					local target_pos = obj:get_pos()
					local spawn_pos = vector.add(target_pos, {x=0,y=15,z=0})
					local ent = core.add_entity(spawn_pos, "magicalities:dark_lightning")
					if ent then
						ent:set_rotation({
							x = 0,
							y = math.random() * math.pi * 2,
							z = 0
						})
						local lua = ent:get_luaentity()
						lua.target = obj
						lua.owner = user
					end
				end
			end
		end
		local penta = core.add_entity(vector.add(user:get_pos(), {x=0,y=0.1,z=0}), "magicalities:pentagram_entity")
		core.sound_play("thunder", {pos = pos, gain = 2.5, pitch = 0.7})
		if penta then
			local ent = penta:get_luaentity()
			ent.owner = user
		end
		return itemstack
	end
})