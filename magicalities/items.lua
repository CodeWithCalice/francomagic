-- items.lua

-- Pentagram
core.register_node("magicalities:pentagram", {
	description = "Pentagram",
	drawtype = "signlike",
	visual_scale = 3.0,
	tiles = {"pentagram_item.png"},
	inventory_image = "pentagram_item.png",
	use_texture_alpha = "clip",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = false,
	light_source = 14,
	walkable = false,
	is_ground_content = true,
	selection_box = {
		type = "wallmounted",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
	},
	on_rightclick = function(pos, node, _)
		if core.get_modpath("mobs") and core.get_modpath("mobs_animal") and core.get_modpath("mobs_monster") and core.get_modpath("forgotten_monsters") then
			core.after(0.5, function()
				if core.get_modpath("mobs_animal") and core.get_modpath("mobs_monster") then
					local num = math.random(31)
                    if num <= 12 then
                        core.add_entity(pos, "mobs_monster:oerkki")
					elseif num >= 13 and num <= 24 then
                        core.add_entity(pos, "mobs_animal:kitten")
                    elseif num >= 25 and num <= 29 then
                        core.add_entity(pos, "forgotten_monsters:spectrum")
					elseif num == 30 then
                        core.add_entity(pos, "forgotten_monsters:sking")
					elseif num == 31 then
						core.add_entity(pos, "mobs_balrog:balrog")
                    end
                end
                core.remove_node(pos)
				core.add_particlespawner({
						amount = 25,
						time = 1,
						minpos = {x=pos.x-1, y=pos.y, z=pos.z-1},
						maxpos = {x=pos.x+1, y=pos.y, z=pos.z+1},
						minvel = {x=-0, y=-0, z=-0},
						maxvel = {x=0, y=0, z=0},
						minacc = {x=-0.5,y=1,z=-0.5},
						maxacc = {x=0.5,y=1,z=0.5},
						minexptime = 1,
						maxexptime = 1.5,
						minsize = 1,
						maxsize = 2,
						collisiondetection = false,
						texture = "magicalities_effect.png^[colorize:green:400"
				})
			end)
		end
	end,
	groups = {cracky=3,dig_immediate=3},
})

-- Pentablock
core.register_node("magicalities:pentablock", {
	description = "Pentagram block",
	tiles = {
		"magicalities_pentablock.png",
	},
	groups = {cracky=1, oddly_breakable_by_hand=1}
})

core.register_craft({
    output = "magicalities:pentablock",
    recipe = {
        {"xdecor:hard_clay", "bones:bones", "xdecor:hard_clay"},
    }
})

-- Tronçonnache
local max_uses = 500
local function wear_per_trunk()
	return 65535 / max_uses
end

local function dig(itemstack, user, pos, visited)
	visited = visited or {}
	local hash = core.hash_node_position(pos)
	if visited[hash] then return end
	visited[hash] = true
	if itemstack:get_wear() >= 65534 then
		return
	end
	if core.is_protected(pos, user:get_player_name()) then
		return
	end
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]
	if not def or not def.groups or not def.groups.choppy then
		return
	end
	core.dig_node(pos)
	if itemstack:get_wear() + wear_per_trunk() > 65534 then
		itemstack:add_wear(65534 - itemstack:get_wear())
	else
		itemstack:add_wear(wear_per_trunk())
	end
	if itemstack:get_wear() == 65534 then
		return
	end
	local dirs = {
		{x=1,y=0,z=0},{x=-1,y=0,z=0},
		{x=0,y=1,z=0},{x=0,y=-1,z=0},
		{x=0,y=0,z=1},{x=0,y=0,z=-1},
		{x=1,y=1,z=0},{x=-1,y=1,z=0},
		{x=0,y=1,z=1},{x=0,y=1,z=-1},
	}
	for _, d in ipairs(dirs) do
		local p = vector.add(pos, d)
		dig(itemstack, user, p, visited)
	end
end

core.register_tool("magicalities:tronconnache", {
	description = "Tronçonnache",
	inventory_image = "magicalities_tronconnache.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		local pos = pointed_thing.under
		local node = core.get_node(pos)
		local def = core.registered_nodes[node.name]
		if def and def.groups and def.groups.choppy and def.groups.choppy >= 2 then
			dig(itemstack, user, pos)
		end
		return itemstack
	end,
})

-- Flying Rings
local flying_user = {}

local function check_fly(user)
	local privs = core.get_player_privs(user:get_player_name())
	return privs.fly == true
end

local function grant_fly(user)
	local pname = user:get_player_name()
	local privs = core.get_player_privs(pname)
	privs.fly = true
	core.set_player_privs(pname, privs)
end

local function revoke_fly(user)
	local pname = user:get_player_name()
	local privs = core.get_player_privs(pname)
	privs.fly = nil
	core.set_player_privs(pname, privs)
	flying_user[pname] = {no_fall_damage = true}
end

local function activate_ring(user, mana_per_sec)
	local pname = user:get_player_name()

	flying_user[pname] = {
		mana_per_sec = mana_per_sec,
		timer = 0
	}

	grant_fly(user)
end

local function deactivate_ring(user)
	if check_fly(user) then
		revoke_fly(user)
	end
end

core.register_craftitem("magicalities:inferior_ring", {
	description = "Anneau Inférieur",
	inventory_image = "inferior_ring.png",
	stack_max = 1,
	on_use = function(itemstack, user)
		activate_ring(user, 7.037)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user)
		deactivate_ring(user)
		return itemstack
	end
})

core.register_craftitem("magicalities:ordinary_ring", {
	description = "Anneau Ordinaire",
	inventory_image = "ordinary_ring.png",
	stack_max = 1,
	on_use = function(itemstack, user)
		activate_ring(user, 3.7037)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user)
		deactivate_ring(user)
		return itemstack
	end
})

core.register_craftitem("magicalities:superior_ring", {
	description = "Anneau Supérieur",
	inventory_image = "superior_ring.png",
	stack_max = 1,
	on_use = function(itemstack, user)
		activate_ring(user, 2.037)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user)
		deactivate_ring(user)
		return itemstack
	end
})

core.register_craftitem("magicalities:supreme_ring", {
	description = "Anneau Suprême",
	inventory_image = "supreme_ring.png",
	stack_max = 1,
	on_use = function(itemstack, user)
		activate_ring(user, 0.6667)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user)
		deactivate_ring(user)
		return itemstack
	end
})

core.register_globalstep(function(dtime)
	for pname, data in pairs(flying_user) do
		if not data.mana_per_sec then return end
		if data.mana_per_sec <= 0 then return end
		local player = core.get_player_by_name(pname)
		if not player then
			flying_user[pname] = nil
			return
		end
		data.timer = data.timer + dtime
		local actual_mana = mana.get(player:get_player_name())
		if actual_mana <= 1 then
				revoke_fly(player)
				return
			end
		if data.timer >= 1 then
			mana.set(player:get_player_name(), mana.get(player:get_player_name())-data.mana_per_sec)
			data.timer = 0
		end
	end
end)

core.register_on_player_hpchange(function(player, hp_change, reason)
	if reason.type == "fall" and flying_user[player:get_player_name()] and flying_user[player:get_player_name()].no_fall_damage then
		flying_user[player:get_player_name()] = nil
	    return 0
	else
		return hp_change
	end
end, true)

core.register_on_leaveplayer(function(player)
	if flying_user[player:get_player_name()] then
		revoke_fly(player)
		flying_user[player:get_player_name()] = nil
	end
end)