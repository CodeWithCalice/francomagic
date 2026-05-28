-- register.lua

---------------------------------
-- Enregsitrement des cristaux --
---------------------------------

for name, data in pairs(magicalities.elements) do
	if not data.inheritance then
		magicalities.register_crystal(name, data.description, data.color, data.miny, data.maxy, data.block_spawn, data.biomes, data.rarity, data.spawn_by)
	end
end

---------------
-- Baguettes --
---------------

magicalities.wands.register_wand("pin", {
	description   = "Baguette de pin",
	image         = "magicalities_pin_wand.png",
	wand_cap      = 25,
	max_take      = 1,
	empty_crystal = true
})

magicalities.wands.register_wand("berhjay", {
	description   = "Bâton de Berhjay",
	image         = "magicalities_berhjay_wand.png",
	wand_cap      = 50,
	max_take      = 1,
	empty_crystal = false
})

magicalities.wands.register_wand("edulis", {
	description   = "Sceptre d'Edulis",
	image         = "magicalities_sceptre_edulis.png",
	wand_cap      = 100,
	max_take      = 5,
	empty_crystal = false
})

--------------------------------
-- Recettes table des arcanes --
--------------------------------

local recipes = {
	{
		input = {
			{"technic:cast_iron_block", "", "technic:cast_iron_block"},
			{"technic:cast_iron_block", "", "technic:cast_iron_block"},
			{"technic:cast_iron_block", "moreores:mithril_block", "technic:cast_iron_block"},
		},
		output = "francomagicmod:cauldron",
		requirements = {
			["water"] = 10,
			["earth"] = 10,
			["fire"]  = 25,
			["air"]   = 10,
		},
		level_requirement = 2
	},
	{
		input = {
			{"default:goldblock", "magicalities:crystal_air", "default:goldblock"},
			{"magicalities:crystal_water", "", "magicalities:crystal_earth"},
			{"default:goldblock", "magicalities:crystal_fire", "default:goldblock"},
		},
		output = "magicalities:element_ring",
		requirements = {
			["water"] = 15,
			["earth"] = 15,
			["fire"]  = 15,
			["air"]   = 15,
		},
		level_requirement = 3
	},
	{
		input = {
			{"default:diamondblock", "default:diamondblock", "everness:lava_tree_with_lava"},
			{"default:diamondblock", "everness:mese_tree", "default:diamondblock"},
			{"everness:willow_tree", "default:diamondblock", "default:diamondblock"},
		},
		output = "magicalities:berhjay_wand",
		requirements = {
			["water"] = 25,
			["earth"] = 25,
			["fire"]  = 25,
			["air"]   = 25,
		},
		level_requirement = 4
	},
	{
		input = {
			{"", "magicalities:crystal_block_earth", ""},
			{"", "moreores:silver_block", ""},
			{"", "moreores:silver_block", ""},
		},
		output = "everness:shovel_silk",
		requirements = {
			["earth"] = 40,
		},
		level_requirement = 4
	},
	{
		input = {
			{"magicalities:pentablock", "", "magicalities:pentablock"},
			{"", "francomagicmod:potion_de_vie", ""},
			{"magicalities:pentablock", "", "magicalities:pentablock"},
		},
		output = "magicalities:pentagram",
		requirements = {
			["water"] = 5,
			["earth"] = 5,
			["fire"]  = 5,
			["air"]   = 5,
		},
		level_requirement = 5
	},
	{
		input = {
			{"", "", "mobs:lava_orb"},
			{"", "mobs:lava_orb", ""},
			{"default:obsidian_shard", "", ""},
		},
		output = "add_stuff:lava_sword",
		requirements = {
			["fire"]  = 50,
		},
		level_requirement = 5
	},
	{
		input = {
			{"xocean:brain_skeleton", "everness:cursed_lands_deep_ocean_coral_octocurse", "xocean:brain_skeleton"},
			{"xocean:brain_skeleton", "magicalities:crystal_block_air", "xocean:brain_skeleton"},
			{"xocean:brain_skeleton", "everness:cursed_lands_deep_ocean_coral_octocurse", "xocean:brain_skeleton"},
		},
		output = "everness:shell_of_underwater_breathing",
		requirements = {
			["water"] = 40,
			["air"]   = 40,
		},
		level_requirement = 5
	},
	{
		input = {
			{"", "everness:pyrite_glass", ""},
			{"default:bronzeblock", "basic_materials:heating_element", "default:bronzeblock"},
			{"default:bronzeblock", "default:bronzeblock", "default:bronzeblock"},
		},
		output = "francomagicmod:alambic",
		requirements = {
			["water"] = 45,
			["earth"] = 45,
			["fire"]  = 45,
			["air"]   = 45,
		},
		level_requirement = 6
	},
	{
		input = {
			{"everness:vine_shears", "everness:vine_shears", "everness:vine_shears"},
			{"basic_materials:motor", "default:diamondblock", "basic_materials:motor"},
			{"moreores:axe_mithril", "moreores:axe_mithril", "moreores:axe_mithril"},
		},
		output = "magicalities:tronconnache",
		requirements = {
			["earth"] = 25,
			["air"]   = 25,
		},
		level_requirement = 6
	},
	{
		input = {
			{"everness:cursed_dream_stone", "spectrum:spectrum_orb_block", "everness:coral_tree_bioluminescent"},
			{"", "everness:pyriteblock", ""},
			{"", "everness:pyriteblock", ""},
		},
		output = "add_stuff:prismpick",
		requirements = {
			["earth"] = 40,
			["fire"]  = 40,
			["air"]   = 40,
		},
		level_requirement = 6
	},
	{
		input = {
			{"magicalities:crystal_block_light", "magicalities:crystal_block_air", "everness:crystal_tree_large_sapling"},
			{"magicalities:crystal_block_water", "everness:crystal_tree_large_sapling", "magicalities:crystal_block_fire"},
			{"everness:crystal_tree_large_sapling", "magicalities:crystal_block_earth", "magicalities:crystal_block_dark"},
		},
		output = "magicalities:edulis_wand",
		requirements = {
			["water"] = 50,
			["earth"] = 50,
			["fire"]  = 50,
			["air"]   = 50,
			["light"] = 50,
			["dark"]  = 50,
		},
		level_requirement = 7
	},
	{
		input = {
			{"", "", "magicalities:crystal_block_dark"},
			{"", "default:goldblock", "magicalities:crystal_block_dark"},
			{"magicalities:crystal_block_dark", "magicalities:crystal_block_dark", ""},
		},
		output = "draconis:dragonbinder",
		requirements = {
			["earth"] = 60,
			["fire"]  = 80,
			["light"] = 50,
			["dark"]  = 70,
		},
		level_requirement = 7
	},
	{
		input = {
			{"draconis:dragonstone_bricks_fire", "draconis:dragonstone_bricks_fire", "draconis:dragonstone_bricks_fire"},
			{"draconis:dragonstone_bricks_fire", "default:furnace", "draconis:dragonstone_bricks_fire"},
			{"draconis:dragonstone_bricks_fire", "draconis:dragonstone_bricks_fire", "draconis:dragonstone_bricks_fire"},
		},
		output = "draconis:draconic_forge_fire",
		requirements = {
			["fire"]  = 50,
			["dark"]  = 50,
		},
		level_requirement = 7
	},
	{
		input = {
			{"magicalities:crystal_cluster_light", "magicalities:crystal_cluster_air", "magicalities:crystal_cluster_light"},
			{"magicalities:crystal_cluster_air", "", "magicalities:crystal_cluster_air"},
			{"magicalities:crystal_cluster_light", "magicalities:crystal_cluster_air", "magicalities:crystal_cluster_light"},
		},
		output = "magicalities:inferior_ring",
		requirements = {
			["air"]   = 10,
			["light"] = 10,
		},
		level_requirement = 7
	},
	{
		input = {
			{"default:gold_lump", "magicalities:inferior_ring", "default:gold_lump"},
			{"magicalities:inferior_ring", "magicalities:inferior_ring", "magicalities:inferior_ring"},
			{"default:gold_lump", "magicalities:inferior_ring", "default:gold_lump"},
		},
		output = "magicalities:ordinary_ring",
		requirements = {
			["air"]   = 20,
			["light"] = 20,
		},
		level_requirement = 7
	},
	{
		input = {
			{"default:diamond", "magicalities:ordinary_ring", "default:diamond"},
			{"magicalities:ordinary_ring", "magicalities:ordinary_ring", "magicalities:ordinary_ring"},
			{"default:diamond", "magicalities:ordinary_ring", "default:diamond"},
		},
		output = "magicalities:superior_ring",
		requirements = {
			["air"]   = 30,
			["light"] = 30,
		},
		level_requirement = 7
	},
	{
		input = {
			{"moreores:mithril_lump", "magicalities:superior_ring", "moreores:mithril_lump"},
			{"magicalities:superior_ring", "magicalities:superior_ring", "magicalities:superior_ring"},
			{"moreores:mithril_lump", "magicalities:superior_ring", "moreores:mithril_lump"},
		},
		output = "magicalities:supreme_ring",
		requirements = {
			["air"]   = 80,
			["light"] = 80,
		},
		level_requirement = 7
	},
	{
		input = {
			{"group:crystal", "moreores:mithril_ingot", "group:crystal"},
			{"moreores:mithril_ingot", "group:crystal", "moreores:mithril_ingot"},
			{"group:crystal", "moreores:mithril_ingot", "group:crystal"},
		},
		output = "magicalities:focus_blank",
		requirements = {
			["water"] = 5,
			["earth"] = 5,
			["fire"]  = 5,
			["air"]   = 5,
		},
		level_requirement = 2
	},
	{
		input = {
			{"mobs:lava_orb", "magicalities:crystal_fire", "mobs:lava_orb"},
			{"magicalities:crystal_fire", "magicalities:focus_blank", "magicalities:crystal_fire"},
			{"mobs:lava_orb", "magicalities:crystal_fire", "mobs:lava_orb"},
		},
		output = "magicalities:focus_fire",
		requirements = {
			["fire"]  = 25,
		},
		level_requirement = 3
	},
	{
		input = {
			{"everness:cursed_stone", "default:gravel", "everness:mineral_sand"},
			{"magicalities:crystal_earth", "magicalities:focus_blank", "magicalities:crystal_earth"},
			{"everness:mineral_sand", "default:gravel", "everness:cursed_stone"},
		},
		output = "magicalities:focus_earth",
		requirements = {
			["earth"] = 50,
		},
		level_requirement = 4
	},
	{
		input = {
			{"everness:bucket_mineral_water", "magicalities:crystal_water", "bucket:bucket_water"},
			{"magicalities:crystal_water", "magicalities:focus_blank", "magicalities:crystal_water"},
			{"everness:bucket_lava", "magicalities:crystal_water", "bucket:bucket_lava"},
		},
		output = "magicalities:focus_water",
		requirements = {
			["water"] = 50,
		},
		level_requirement = 5
	},
	{
		input = {
			{"moreores:shovel_mithril", "moreores:pick_mithril", "moreores:shovel_mithril"},
			{"magicalities:crystal_air", "magicalities:focus_blank", "magicalities:crystal_air"},
			{"moreores:pick_mithril", "moreores:shovel_mithril", "moreores:pick_mithril"},
		},
		output = "magicalities:focus_air",
		requirements = {
			["air"]   = 50,
		},
		level_requirement = 5
	},
	{
		input = {
			{"magicalities:focus_air", "magicalities:focus_air", "magicalities:focus_air"},
			{"magicalities:crystal_air", "magicalities:focus_blank", "magicalities:crystal_water"},
			{"magicalities:focus_water", "magicalities:focus_water", "magicalities:focus_water"},
		},
		output = "magicalities:focus_ice",
		requirements = {
			["water"] = 50,
			["air"]   = 50,
		},
		level_requirement = 6
	},
	{
		input = {
			{"magicalities:crystal_block_light", "everness:pyrite_lantern", "magicalities:crystal_block_light"},
			{"everness:coral_forest_deep_ocean_lantern", "magicalities:focus_blank", "everness:coral_forest_deep_ocean_lantern"},
			{"magicalities:crystal_block_light", "everness:pyrite_lantern", "magicalities:crystal_block_light"},
		},
		output = "magicalities:focus_light",
		requirements = {
			["light"] = 100,
		},
		level_requirement = 7
	},
	{
		input = {
			{"magicalities:focus_light", "magicalities:focus_air", "magicalities:focus_fire"},
			{"spectrum:spectrum_orb", "magicalities:focus_blank", "spectrum:spectrum_orb"},
			{"magicalities:focus_dark", "magicalities:focus_earth", "magicalities:focus_water"},
		},
		output = "magicalities:focus_dark",
		requirements = {
			["dark"] = 100,
		},
	}
}

for _, recipe in pairs(recipes) do
	magicalities.arcane.register_recipe(recipe)
end

-----------------------
-- Crafting basiques --
-----------------------

core.register_craft({
	recipe = {
		{"group:tree", "group:tree", "group:tree"},
		{"",           "group:tree", ""},
		{"group:tree", "group:tree", "group:tree"}
	},
	output = "magicalities:table",
})

-- Supprimer le craft de la coquille de respiration sous-marine, car elle est maintenant craftable dans la table des arcanes
core.clear_craft({
    output = "everness:shell_of_underwater_breathing"
})