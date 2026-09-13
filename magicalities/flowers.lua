-- flowers.lua

magicalities.flowers = {}

local flowers = magicalities.flowers

local MOONFLOWER_VISION = tonumber(core.settings:get("magicalities_moonflower_vision")) or (60 * 5)

flowers.moonflower_chance = 0.03

flowers.moonflower_closed = "magicalities:moonflower_closed"
flowers.moonflower_open = "magicalities:moonflower_open"

local common_defs = {
	{
		name = "dahlias",
		description = "Dahlias",
		mesh = "magicalities_flower_dahlias.obj",
		tile = "nbt_flower_dahlias.png",
		box = {-0.3, -0.5, -0.3, 0.3, 0.6, 0.3},
	},
	{
		name = "echinacea",
		description = "Échinacée",
		mesh = "magicalities_flower_coneflower.obj",
		tile = "nbt_flower_echinacea.png",
		box = {-0.15, -0.5, -0.15, 0.15, 0.25, 0.15},
	},
	{
		name = "foxglove",
		description = "Digitale",
		mesh = "magicalities_flower_tall.obj",
		tile = "nbt_flower_foxglove.png",
		box = {-0.2, -0.5, -0.2, 0.2, 1.4, 0.2},
		waving = 1,
	},
	{
		name = "globe_thistle",
		description = "Chardon boule",
		mesh = "magicalities_flower_bubble.obj",
		tile = "nbt_flower_globe_thistle.png",
		box = {-0.25, -0.5, -0.2, 0.35, 0.75, 0.2},
	},
	{
		name = "kniphofia",
		description = "Kniphofia",
		mesh = "magicalities_flower_kniphofia.obj",
		tile = "nbt_flower_kniphofia.png",
		box = {-0.3, -0.5, -0.3, 0.3, 0.6, 0.3},
	},
	{
		name = "rafflesia",
		description = "Rafflesia",
		mesh = "magicalities_flower_rafflesia.obj",
		tile = "nbt_flower_rafflesia.png",
		box = {-0.4, -0.5, -0.3, 0.4, 0.4, 0.5},
		walkable = true,
		collision_box = {
			{-0.4, 0, 0.1, 0.4, 0.2, 0.5},
			{-0.4, -0.5, -0.3, 0.4, 0, 0.5},
		},
	},
}

flowers.common = {}

for _, def in ipairs(common_defs) do
	local node_name = "magicalities:" .. def.name

	core.register_node(node_name, {
		description = def.description,
		drawtype = "mesh",
		mesh = def.mesh,
		tiles = {def.tile},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		walkable = def.walkable or false,
		waving = def.waving,
		selection_box = {type = "fixed", fixed = {def.box}},
		collision_box = def.collision_box
			and {type = "fixed", fixed = def.collision_box} or nil,
		groups = {snappy = 3, dig_immediate = 3, flower = 1, flora = 1,
			attached_node = 1, flammable = 2},
		sounds = default.node_sound_leaves_defaults(),
	})

	table.insert(flowers.common, node_name)
end

local moonflower_hint = core.get_color_escape_sequence("#68d2ff")

local function is_night()
	local tod = core.get_timeofday()
	return tod > 0.8 or tod < 0.2
end

core.register_node(flowers.moonflower_closed, {
	description = "Fleur de lune",
	drawtype = "plantlike",
	tiles = {"magicalities_moonflower_closed.png"},
	inventory_image = "magicalities_moonflower_closed.png",
	wield_image = "magicalities_moonflower_closed.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	light_source = 4,
	visual_scale = 0.6,
	selection_box = {type = "fixed", fixed = {-0.15, -0.5, -0.15, 0.15, 0.1, 0.15}},
	groups = {snappy = 3, dig_immediate = 1, flammable = 2, eatable = 2, flora = 1},
	sounds = default.node_sound_leaves_defaults(),
	drop = "",

	after_dig_node = function(pos, oldnode, oldmeta, digger)
	end,

	on_use = function(itemstack, player, pointed_thing)
		if not player or not player:is_player() then
			return itemstack
		end

		local name = player:get_player_name()
		player:override_day_night_ratio(1)

		core.sound_play("default_place_node", {
			pitch = 1.4, pos = player:get_pos(), gain = 1.0,
			max_hear_distance = 5}, true)

		core.after(MOONFLOWER_VISION, function(pname)
			local p = core.get_player_by_name(pname)
			if not p then return end

			p:override_day_night_ratio(nil)

			core.sound_play("default_place_node", {
				pitch = 1.2, pos = p:get_pos(), gain = 1.0,
				max_hear_distance = 5}, true)
		end, name)

		return core.do_item_eat(2, nil, itemstack, player, pointed_thing)
	end,
})

core.register_node(flowers.moonflower_open, {
	description = "Fleur de lune",
	drawtype = "plantlike",
	tiles = {"magicalities_moonflower_open.png"},
	inventory_image = "magicalities_moonflower_open.png",
	wield_image = "magicalities_moonflower_open.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	light_source = 10,
	visual_scale = 0.6,
	selection_box = {type = "fixed", fixed = {-0.15, -0.5, -0.15, 0.15, 0.1, 0.15}},
	groups = {not_in_creative_inventory = 1, snappy = 3, dig_immediate = 1,
		flammable = 2},
	sounds = default.node_sound_leaves_defaults(),
	drop = flowers.moonflower_closed,
	node_dig_prediction = "",

	on_dig = function(pos, node, digger)
		if not is_night() then
			core.swap_node(pos, {name = flowers.moonflower_closed})
			return false
		end

		return core.node_dig(pos, node, digger)
	end,
})

core.register_abm({
	label = "magicalities: ouverture des fleurs de lune",
	nodenames = {flowers.moonflower_closed, flowers.moonflower_open},
	interval = 11,
	chance = 1,
	catch_up = false,

	action = function(pos, node)
		if node.name == flowers.moonflower_open then
			if not is_night() then
				core.swap_node(pos, {name = flowers.moonflower_closed})
			end
		elseif is_night() and core.get_node_light(pos, 0.5) == 15 then
			core.swap_node(pos, {name = flowers.moonflower_open})
		end
	end,
})

function flowers.random_plant()
	if math.random() < flowers.moonflower_chance then
		return flowers.moonflower_closed
	end

	if #flowers.common == 0 then
		return nil
	end

	return flowers.common[math.random(#flowers.common)]
end

function flowers.param2(name)
	local def = core.registered_nodes[name]

	if def and def.paramtype2 == "facedir" then
		return math.random(0, 3)
	end

	return 0
end

core.log("action", "[magicalities] Fleurs magiques enregistrées (".. #flowers.common .. " communes + la fleur de lune).")
