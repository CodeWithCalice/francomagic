-- scifi_nodes.lua

minetest.register_node("magicalities:grassblk", {
	description = "Dirt With Alien Grass",
	tiles = {"magicalities_grass_top.png^[colorize:cyan:80", "magicalities_dirt.png",
		{name = "magicalities_dirt.png^(magicalities_grass_side.png^[colorize:cyan:80)",
			tileable_vertical = false}},
	light_source = 2,
	groups = {crumbly=1, oddly_breakable_by_hand=1, soil=1},
	is_ground_content = false,
	sounds = default.node_sound_dirt_defaults()
})

-- Conversion de l'ancien nom
core.register_alias("scifi_nodes:grassblk", "magicalities:grassblk")
