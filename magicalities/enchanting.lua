local enchanting = {}

screwdriver = screwdriver or {}
local S = minetest.get_translator("xdecor")
local NS = function(s) return s end
local FS = function(...) return minetest.formspec_escape(S(...)) end
local ceil, abs, random = math.ceil, math.abs, math.random
local reg_tools = minetest.registered_tools
local reg_enchantable_tools = {}
local available_tool_enchants = {}

-- Cost in Mese crystal(s) for enchanting.
local CRYSTAL_COST = 1

-- Default strenth of the enchantments
local DEFAULT_ENCHANTING_USES = 1.2 -- Durability
local DEFAULT_ENCHANTING_TIMES = 0.1 -- Efficiency
local DEFAULT_ENCHANTING_DAMAGES = 1 -- Sharpness
local DEFAULT_ENCHANTING_REACH = 2 -- Reach

local POWERFUL_ENCHANTMENT_CHANCE = 0.10 -- Chance to get a buffed enchant
local POWERFUL_ENCHANTMENT_MULTIPLIER = 1.5 -- Boost multiplier of the buffed enchant

local function to_percent(orig_value, final_value)
	return abs(ceil(((final_value - orig_value) / orig_value) * 100))
end

function enchanting:get_tooltip_raw(enchant, percent)
	local specs = {
		durable = "#00baff",
		fast    = "#74ff49",
		sharp   = "#ffff00",
        reach   = "ffff7300",
	}
	local enchant_loc = {
		--~ Enchantment
		fast = S("Efficiency"),
		--~ Enchantment
		durable = S("Durability"),
		--~ Enchantment
		sharp = S("Sharpness"),
        --~ Enchantment
        reach = S("Reach"),
	}

	if minetest.colorize then
		--~ Tooltip for enchantment, in format "<enchantment name> (+<bonus>%)", e.g. "Efficiency (+5%)"
		return minetest.colorize(specs[enchant], S("@1 (+@2%)", enchant_loc[enchant], percent))
	else
		return S("@1 (+@2%)", enchant_loc[enchant], percent)
	end

end

function enchanting:get_tooltip(enchant, orig_caps, fleshy, bonus_defs, orig_range)
	local bonus = {
		durable = 0,
		efficiency = 0,
		damages = 0,
		reach = 0
	}

	if orig_caps then
		if orig_caps.uses then
			bonus.durable = to_percent(
				orig_caps.uses,
				orig_caps.uses * bonus_defs.uses
			)
		end

		if orig_caps.times and #orig_caps.times > 0 then
			local sum_caps_times = 0
			for i = 1, #orig_caps.times do
				sum_caps_times = sum_caps_times + orig_caps.times[i]
			end

			local average_caps_time = sum_caps_times / #orig_caps.times
			bonus.efficiency = to_percent(average_caps_time, average_caps_time - bonus_defs.times)
		end
	end

	if fleshy and fleshy > 0 then
		bonus.damages = to_percent(fleshy - bonus_defs.damages, fleshy)
	end

	if orig_range and orig_range > 0 then
		bonus.reach = to_percent(orig_range, orig_range + bonus_defs.reach)
	end

	local specs = {
		durable = bonus.durable,
		fast = bonus.efficiency,
		sharp = bonus.damages,
		reach = bonus.reach
	}

	local percent = specs[enchant] or 0
	return enchanting:get_tooltip_raw(enchant, percent)
end

local enchant_buttons = {
	fast = "image_button[3.6,0.67;4.75,0.85;bg_btn.png;fast;"..FS("Efficiency").."]",
	durable = "image_button[3.6,1.65;4.75,1.05;bg_btn.png;durable;"..FS("Durability").."]",
	sharp = "image_button[3.6,1.65;4.75,0.85;bg_btn.png;sharp;"..FS("Sharpness").."]",
	reach = "image_button[3.6,2.8;4.75,0.85;bg_btn.png;reach;"..FS("Reach").."]",
}

function enchanting.formspec(pos, enchants)
	local meta = minetest.get_meta(pos)
	local formspec = [[
			size[9,8.6;]
			no_prepend[]
			bgcolor[#080808BB;true]
			listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
			background9[0,0;9,9;ench_ui.png;6]
			list[context;tool;0.9,2.9;1,1;]
			list[context;crystal;2,2.9;1,1;]
			list[current_player;main;0.55,4.5;8,4;]
			listring[current_player;main]
			listring[context;tool]
			listring[current_player;main]
			listring[context;crystal]
			image[2,2.9;1,1;crystal_layout.png]
			]]
			--~ Sharpness enchantment
			.."tooltip[sharp;"..FS("Your weapon inflicts more damage").."]"
			--~ Durability enchantment
			.."tooltip[durable;"..FS("Your tool lasts longer").."]"
			--~ Efficiency enchantment
			.."tooltip[fast;"..FS("Your tool digs faster").."]"
			--~ Reach enchantment
			.."tooltip[reach;"..FS("Your tool reachs further").."]"
			..default.gui_slots .. default.get_hotbar_bg(0.55, 4.5)

	if enchants then
		for e=1, #enchants do
			formspec = formspec .. enchant_buttons[enchants[e]]
		end
	end
	meta:set_string("formspec", formspec)
end

function enchanting.on_put(pos, listname, _, stack)
	if listname == "tool" then
		local stackname = stack:get_name()
		local enchants = available_tool_enchants[stackname]
		if enchants then
			enchanting.formspec(pos, enchants)
		end
	end
end

function enchanting.fields(pos, _, fields, sender)
	if not next(fields) or fields.quit then
		return
	end

	local inv = minetest.get_meta(pos):get_inventory()
	local tool = inv:get_stack("tool", 1)
	local crystal = inv:get_stack("crystal", 1)

	if crystal:get_count() < CRYSTAL_COST then
		return
	end

	local orig_wear = tool:get_wear()
	local mod, name = tool:get_name():match("(.*):(.*)")
	local enchant = next(fields)

	local powerful = random(1, 10) == 1

	local suffix = powerful and "_powerful" or ""

	local enchanted_tool =
		(mod or "") ..
		":enchanted_" ..
		(name or "") ..
		"_" ..
		enchant ..
		suffix

	if reg_tools[enchanted_tool] then
		minetest.sound_play("xdecor_enchanting", {
			to_player = sender:get_player_name(),
			gain = 0.8
		})

		tool:replace(enchanted_tool)
		tool:add_wear(orig_wear)

		crystal:take_item(CRYSTAL_COST)

		inv:set_stack("crystal", 1, crystal)
		inv:set_stack("tool", 1, tool)
	end
end

function enchanting.dig(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("tool") and inv:is_empty("crystal")
end

function enchanting.blast(pos)
	local drops = xdecor.get_inventory_drops(pos, {"tool", "crystal"})
	minetest.remove_node(pos)
	return drops
end

local function allowed(tool)
	if not tool then
		return false
	end
	if reg_enchantable_tools[tool] then
		return true
	else
		return false
	end
end

function enchanting.put(_, listname, _, stack)
	local stackname = stack:get_name()
	if listname == "crystal" and stackname == "magicalities:crystal_light" then
		return stack:get_count()
	elseif listname == "tool" and allowed(stackname) then
		return 1
	end

	return 0
end

function enchanting.on_take(pos, listname)
	if listname == "tool" then
		enchanting.formspec(pos)
	end
end

function enchanting.construct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", S("Enchantment Table"))
	enchanting.formspec(pos)

	local inv = meta:get_inventory()
	inv:set_size("tool", 1)
	inv:set_size("crystal", 1)

	minetest.add_entity({x = pos.x, y = pos.y + 0.85, z = pos.z}, "magicalities:book_open")
	local timer = minetest.get_node_timer(pos)
	timer:start(0.5)
end

function enchanting.destruct(pos)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, 0.9)) do
		if obj and obj:get_luaentity() and
				obj:get_luaentity().name == "magicalities:book_open" then
			obj:remove()
			break
		end
	end
end

function enchanting.timer(pos)
	local minp = {x = pos.x - 2, y = pos.y,     z = pos.z - 2}
	local maxp = {x = pos.x + 2, y = pos.y + 1, z = pos.z + 2}

	local bookshelves = minetest.find_nodes_in_area(minp, maxp, "default:bookshelf")
	if #bookshelves == 0 then
		return true
	end

	local bookshelf_pos = bookshelves[random(1, #bookshelves)]
	local x = pos.x - bookshelf_pos.x
	local y = bookshelf_pos.y - pos.y
	local z = pos.z - bookshelf_pos.z

	if tostring(x .. z):find(2) then
		minetest.add_particle({
			pos = bookshelf_pos,
			velocity = {x = x, y = 2 - y, z = z},
			acceleration = {x = 0, y = -2.2, z = 0},
			expirationtime = 1,
			size = 1.5,
			glow = 5,
			texture = "xdecor_glyph" .. random(1,18) .. ".png"
		})
	end

	return true
end

core.register_node("magicalities:enchantment_table", {
	description = S("Enchantment Table"),
	--~ Enchantment table tooltip
	tiles = {
		"xdecor_enchantment_top.png",  "xdecor_enchantment_bottom.png",
		"xdecor_enchantment_side.png", "xdecor_enchantment_side.png",
		"xdecor_enchantment_side.png", "xdecor_enchantment_side.png"
	},
	groups = {cracky = 1, level = 1},
	is_ground_content = false,
	light_source = 6,
	sounds = default.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_simple,
	can_dig = enchanting.dig,
	on_blast = enchanting.blast,
	on_timer = enchanting.timer,
	on_construct = enchanting.construct,
	on_destruct = enchanting.destruct,
	on_receive_fields = enchanting.fields,
	on_metadata_inventory_put = enchanting.on_put,
	on_metadata_inventory_take = enchanting.on_take,
	allow_metadata_inventory_put = enchanting.put,
	allow_metadata_inventory_move = function()
		return 0
	end,
})

minetest.register_entity("magicalities:book_open", {
	initial_properties = {
		visual = "sprite",
		visual_size = {x=0.75, y=0.75},
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
		physical = false,
		textures = {"xdecor_book_open.png"},
		static_save = false,
	},

	on_activate = function(self)
		self.object:set_armor_groups({immortal=1})
	end,

	-- Minetest Game support: Prevent entity being pushed or damaged by TNT explosion
	on_blast = function()
		return false, false, {}
	end,
})

minetest.register_lbm({
	label = "recreate book entity",
	name = "magicalities:create_book_entity",
	nodenames = {"magicalities:enchantment_table"},
	run_at_every_load = true,
	action = function(pos, node)
		local objs = minetest.get_objects_inside_radius(pos, 0.9)

		for _, obj in ipairs(objs) do
			local e = obj:get_luaentity()
			if e and e.name == "magicalities:book_open" then
				return
			end
		end

		minetest.add_entity({x = pos.x, y = pos.y + 0.85, z = pos.z}, "magicalities:book_open")
	end,
})

function enchanting:enchant_texture(img)
    if img == nil or img == "" or type(img) ~= "string" then
        return "no_texture.png"
    else
        return "("..img.. ")^[colorize:violet:50"
    end
end

local function copy_groupcaps(groupcaps)
	local result = {}
	for group, caps in pairs(groupcaps) do
		result[group] = table.copy(caps)
		if caps.times then
			result[group].times = table.copy(caps.times)
		end
	end
	return result
end

local NON_INHERITED_FIELDS = {
	name = true,
	type = true,
	mod_origin = true,
}

local function inherit_tool_def(original_tool, overrides)
	local def = {}

	for key, value in pairs(original_tool) do
		if not NON_INHERITED_FIELDS[key] then
			if type(value) == "table" then
				def[key] = table.copy(value)
			else
				def[key] = value
			end
		end
	end

	for key, value in pairs(overrides) do
		def[key] = value
	end

	return def
end

local function enchanted_toolcaps(original_toolcaps, groupcaps, fleshy)
	local caps = table.copy(original_toolcaps)

	caps.groupcaps = groupcaps
	caps.damage_groups = caps.damage_groups or {}
	caps.damage_groups.fleshy = fleshy

	return caps
end

function enchanting:register_tool(original_tool_name, def)
	local original_tool = reg_tools[original_tool_name]

	if not original_tool then
		minetest.log("error", "[magicalities] Called enchanting:register_tool for non-existing tool: " .. original_tool_name)
		return
	end

	local original_toolcaps = original_tool.tool_capabilities

	if not original_toolcaps then
		minetest.log("error", "[magicalities] Called enchanting:register_tool for tool without tool_capabilities: " .. original_tool_name)
		return
	end

	local original_damage_groups = original_toolcaps.damage_groups or {}
	local original_groupcaps = original_toolcaps.groupcaps or {}
	local original_basename = original_tool_name:match(".*:(.*)")
	local toolitem = ItemStack(original_tool_name)
	local original_desc = toolitem:get_short_description() or original_tool_name
	local original_range = tonumber(original_tool.range) or 4.0
	local base_groups

	if def.groups then
		base_groups = table.copy(def.groups)
	elseif original_tool.groups then
		base_groups = table.copy(original_tool.groups)
	else
		base_groups = {}
	end

	base_groups.not_in_creative_inventory = 1
	base_groups.enchanted_tool = 1

	if not def.bonuses then
		def.bonuses = {}
	end

	local bonus_defs = {
		uses = def.bonuses.uses or DEFAULT_ENCHANTING_USES,
		times = def.bonuses.times or DEFAULT_ENCHANTING_TIMES,
		damages = def.bonuses.damages or DEFAULT_ENCHANTING_DAMAGES,
		reach = def.bonuses.reach or DEFAULT_ENCHANTING_REACH,
	}

	for _, enchant in ipairs(def.enchants) do
		local normal_groupcaps = copy_groupcaps(original_groupcaps)
		local normal_fleshy = original_damage_groups.fleshy
		local normal_range = original_range
		local normal_bonus_defs = table.copy(bonus_defs)
		local normal_groups = table.copy(base_groups)
		local dig_group = def.dig_group

		if enchant == "durable" then
			if not dig_group or not normal_groupcaps[dig_group] then
				minetest.log("error", "[magicalities] Durability enchantment requires a valid dig_group for " .. original_tool_name)
				return
			end

			normal_groupcaps[dig_group].uses = ceil(original_groupcaps[dig_group].uses * normal_bonus_defs.uses)
			normal_groups.enchantment_durable = 1

		elseif enchant == "fast" then
			if not dig_group or not normal_groupcaps[dig_group] then
				minetest.log("error", "[magicalities] Efficiency enchantment requires a valid dig_group for " .. original_tool_name)
				return
			end

			for i, time in pairs(original_groupcaps[dig_group].times) do
				normal_groupcaps[dig_group].times[i] = time - normal_bonus_defs.times
			end

			normal_groups.enchantment_fast = 1

		elseif enchant == "sharp" then
			local original_damage = original_damage_groups.fleshy or 0
			normal_fleshy = original_damage + normal_bonus_defs.damages
			normal_groups.enchantment_sharp = 1

		elseif enchant == "reach" then
			normal_range = original_range + normal_bonus_defs.reach
			normal_groups.enchantment_reach = 1

		else
			minetest.log("error", "[magicalities] Called enchanting:register_tool with unsupported enchant: " .. tostring(enchant))
			return
		end

		local tooltip_caps = dig_group and original_groupcaps[dig_group] or nil
		local normal_arg2 = self:get_tooltip(enchant, tooltip_caps, normal_fleshy, normal_bonus_defs, original_range)
		local normal_invimg = enchanting:enchant_texture(original_tool.inventory_image)
		local normal_wieldimg = original_tool.wield_image

		if normal_wieldimg == nil or normal_wieldimg == "" then
			normal_wieldimg = normal_invimg
		end

		local normal_tool_name = original_tool.mod_origin .. ":enchanted_" .. original_basename .. "_" .. enchant

		minetest.register_tool(":" .. normal_tool_name, inherit_tool_def(original_tool, {
			description = S("Enchanted @1\n@2", original_desc, normal_arg2),
			short_description = S("Enchanted @1", original_desc),
			inventory_image = normal_invimg,
			wield_image = normal_wieldimg,
			range = normal_range,
			groups = normal_groups,
			tool_capabilities = enchanted_toolcaps(
				original_toolcaps, normal_groupcaps, normal_fleshy),
		}))

		if minetest.get_modpath("toolranks") then
			toolranks.add_tool(normal_tool_name)
		end

		local powerful_groupcaps = copy_groupcaps(original_groupcaps)
		local powerful_fleshy = original_damage_groups.fleshy
		local powerful_range = original_range
		local powerful_bonus_defs = table.copy(bonus_defs)
		local powerful_groups = table.copy(base_groups)

		if enchant == "durable" then
			if not dig_group or not powerful_groupcaps[dig_group] then
				minetest.log("error", "[magicalities] Powerful durability enchantment requires a valid dig_group for " .. original_tool_name)
				return
			end

			powerful_bonus_defs.uses = 1 + (bonus_defs.uses - 1) * POWERFUL_ENCHANTMENT_MULTIPLIER
			powerful_groupcaps[dig_group].uses = ceil(original_groupcaps[dig_group].uses * powerful_bonus_defs.uses)
			powerful_groups.enchantment_durable = 1

		elseif enchant == "fast" then
			if not dig_group or not powerful_groupcaps[dig_group] then
				minetest.log("error", "[magicalities] Powerful efficiency enchantment requires a valid dig_group for " .. original_tool_name)
				return
			end

			powerful_bonus_defs.times = bonus_defs.times * POWERFUL_ENCHANTMENT_MULTIPLIER

			for i, time in pairs(original_groupcaps[dig_group].times) do
				powerful_groupcaps[dig_group].times[i] = time - powerful_bonus_defs.times
			end

			powerful_groups.enchantment_fast = 1

		elseif enchant == "sharp" then
			local original_damage = original_damage_groups.fleshy or 0
			powerful_bonus_defs.damages = bonus_defs.damages * POWERFUL_ENCHANTMENT_MULTIPLIER
			powerful_fleshy = original_damage + powerful_bonus_defs.damages
			powerful_groups.enchantment_sharp = 1

		elseif enchant == "reach" then
			powerful_bonus_defs.reach = bonus_defs.reach * POWERFUL_ENCHANTMENT_MULTIPLIER
			powerful_range = original_range + powerful_bonus_defs.reach
			powerful_groups.enchantment_reach = 1
		end

		local powerful_arg2 = self:get_tooltip(enchant, tooltip_caps, powerful_fleshy, powerful_bonus_defs, original_range)
		local powerful_invimg = enchanting:enchant_texture(original_tool.inventory_image)
		local powerful_wieldimg = original_tool.wield_image

		if powerful_wieldimg == nil or powerful_wieldimg == "" then
			powerful_wieldimg = powerful_invimg
		end

		powerful_groups.enchantment_powerful = 1

		local powerful_tool_name = original_tool.mod_origin .. ":enchanted_" .. original_basename .. "_" .. enchant .. "_powerful"

		minetest.register_tool(":" .. powerful_tool_name, inherit_tool_def(original_tool, {
			description = S("Enchanted @1\n@2", original_desc, powerful_arg2),
			short_description = S("Enchanted @1", original_desc),
			inventory_image = powerful_invimg,
			wield_image = powerful_wieldimg,
			range = powerful_range,
			groups = powerful_groups,
			tool_capabilities = enchanted_toolcaps(
				original_toolcaps, powerful_groupcaps, powerful_fleshy),
		}))

		if minetest.get_modpath("toolranks") then
			toolranks.add_tool(powerful_tool_name)
		end
	end

	available_tool_enchants[original_tool_name] = table.copy(def.enchants)
	reg_enchantable_tools[original_tool_name] = true
end

function enchanting:register_custom_tool(original_tool_name, enchanted_tools)
	if not available_tool_enchants[original_tool_name] then
		available_tool_enchants[original_tool_name] = {}
	end
	for enchant, v in pairs(enchanted_tools) do
		table.insert(available_tool_enchants[original_tool_name], enchant)
	end
	reg_enchantable_tools[original_tool_name] = true
end

-- Recipes

minetest.register_craft({
	output = "magicalities:enchantment_table",
	recipe = {
		{"", "forgotten_monsters:summon_golem", ""},
		{"forgotten_monsters:eye_of_the_golem", "everness:blue_crying_obsidian","forgotten_monsters:eye_of_the_golem"},
		{"everness:blue_crying_obsidian", "everness:blue_crying_obsidian", "everness:blue_crying_obsidian"},
	}
})

--[[ API FUNCTIONS ]]

--[[
Register one or more enchantments for an already defined tool.
This will register a new tool for each enchantment. The new tools will
have the following changes over the original:
* New description and short_description
* Apply a purple glow on wield_image and inventory_image using
  "(<original_texture_string>)^[colorize:purple"
* Change tool_capabilities and damage_groups, depending on
  enchantments.
* Have groups set to { not_in_creative_inventory = 1 }

The new tools will follow this naming scheme:

    <original_mod>:enchanted_<original_basename>_<enchantment>

e.g. example:sword_diamond with the enchantment "sharp" will
have "example:enchanted_sword_diamond_sharp" added.

You must make sure this name is available before calling this
function.

Arguments:
* toolname: Itemstring of original tool to enchant
* def: Definition table with the following fields:
    * enchants: a list of strings, one for each enchantment to add.
      there must be at least one enchantment.
      Available enchantments:
      * "durable": Durability (tool lasts longer)
      * "fast": Efficiency (tool digs faster)
      * "sharp": Sharpness (more damage using the damage group "fleshy")
    * dig_group: Must be specified if Durability or Efficiency is used.
      This defines the tool's digging group that enchantment will improve.
    * bonuses: optional table to customize the enchantment "strengths":
      * uses: multiplies number of uses (Durability) (default: 1.2)
      * times: subtracts from digging time; higher = faster (Efficiency) (default: 0.1)
      * damages: adds to damage (Sharpness) (default: 1)
    * groups: optional table specifying all item groups. If specified,
      this should at least contain `not_in_creative_inventory=1`.
      If unspecified (recommended), the enchanted tools will inherit all
      groups from the original tool, plus they receive `not_in_creative_inventory=1`
]]
xdecor.register_enchantable_tool = function(toolname, def)
	enchanting:register_tool(toolname, def)
end

--[[ Registers a custom tool enchantment.
Here, you are fully free to design the tool yourself.

The enchanted tools should follow these guidelines:

1) Use xdecor.enchant_description to generate the description and short_description
2) Use xdecor.enchant_texture to generate the inventory_image and wield_image
3) Set groups to { not_in_creative_inventory = 1 }

Arguments:
* toolname: Itemstring of original tool to enchant
* enchanted_tools: Table of enchanted tools.
    * The keys are enchantment names from "enchants" in xdecor.register_enchantable_tool
    * The values are the itemstrings of the enchanted tools for those
      enchantments
]]
xdecor.register_custom_enchantable_tool = function(toolname, enchanted_tools)
	enchanting:register_custom_tool(toolname, enchanted_tools)
end

-- Takes a texture (string) and applies an "enchanting" modifier on it.
-- Useful when you want to register custom tool enchantments.
xdecor.enchant_texture = function(texture)
	return enchanting:enchant_texture(texture)
end

--[[
Takes a description of a normal tool and modifies it for the enchanted tool variant.
Arguments:
* description: Original description to modify
* enchant: Enchantment type. One of the enchantment names from "enchants" in xdecor.register_enchantable_tool
* percent: Percentage to display

Returns: <description>, <short_description>

-- Useful when you want to register custom tool enchantments.
]]
xdecor.enchant_description = function(description, enchant, percent)
	local append = enchanting:get_tooltip_raw(enchant, percent)
	local desc = S("Enchanted @1\n@2", description, append)
	local short_desc S("Enchanted @1", description)
	return desc, short_desc
end