-- Register enchanted tools.

local S = minetest.get_translator("xdecor")

-- Number of uses for the (normal) steel hoe from Minetest Game (as of 01/12/20224)
-- This is technically redundant because we cannot access that number
-- directly, but it's unlikely to change in future because Minetest Game is
-- unlikely to change.
local STEEL_HOE_USES = 500

-- Modifier of the steel hoe uses for the enchanted steel hoe
local STEEL_HOE_USES_MODIFIER = 2.2

-- Modifier of the bug net uses for the enchanted bug net
local BUG_NET_USES_MODIFIER = 4

-- Register enchantments for default tools from Minetest Game
local materials = {"steel", "bronze", "mese", "diamond", "mithril"}
local tooltypes = {
	{ "axe", { "durable", "fast", "reach" }, "choppy" },
	{ "pick", { "durable", "fast", "reach" }, "cracky" },
	{ "shovel", { "durable", "fast", "reach" }, "crumbly" },
	{ "sword", { "sharp", "reach" }, nil },
}
for t=1, #tooltypes do
for m=1, #materials do
	local tooltype = tooltypes[t][1]
	local enchants = tooltypes[t][2]
	local dig_group = tooltypes[t][3]
	local material = materials[m]
    local mod = "default:"
    if material == "mithril" then
        mod = "moreores:"
    end
	xdecor.register_enchantable_tool(mod..tooltype.."_"..material, {
		enchants = enchants,
		dig_group = dig_group,
	})
end
end

xdecor.register_enchantable_tool("add_stuff:lava_sword", {
	enchants = tooltypes[4][2],
	dig_group = nil,
})

xdecor.register_enchantable_tool("everness:pick_illuminating", {
	enchants = tooltypes[2][2],
	dig_group = tooltypes[2][3],
})

xdecor.register_enchantable_tool("everness:shovel_silk", {
	enchants = tooltypes[3][2],
	dig_group = tooltypes[3][3],
})

xdecor.register_enchantable_tool("forgotten_monsters:hammer", {
	enchants = tooltypes[4][2],
	dig_group = tooltypes[4][3],
})

-- Register enchantment for bug net
xdecor.register_enchantable_tool("fireflies:bug_net", {
	enchants = { "durable" },
	dig_group = "catchable",
	bonuses = {
		uses = BUG_NET_USES_MODIFIER,
	}
})

-- Register enchanted steel hoe (more durability)
if farming.register_hoe then
	local percent = math.round((STEEL_HOE_USES_MODIFIER - 1) * 100)
	local hitem = ItemStack("farming:hoe_steel")
	local hdesc = hitem:get_short_description() or "farming:hoe_steel"
	local ehdesc, ehsdesc = xdecor.enchant_description(hdesc, "durable", percent)
	farming.register_hoe(":farming:enchanted_hoe_steel_durable", {
		description = ehdesc,
		short_description = ehsdesc,
		inventory_image = xdecor.enchant_texture("farming_tool_steelhoe.png"),
		max_uses = STEEL_HOE_USES * STEEL_HOE_USES_MODIFIER,
		groups = {hoe = 1, not_in_creative_inventory = 1}
	})

	xdecor.register_custom_enchantable_tool("farming:hoe_steel", {
		durable = "farming:enchanted_hoe_steel_durable",
	})
end