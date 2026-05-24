entity_modifier.resize_player = function(player, size)
	local name = player:get_player_name()
	size = tonumber(size) or 1

	if size <= 0 or size > 80 then
		core.chat_send_player(name, "Invalid size: " .. size)
		return
	end

	local base_cb = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}
	local base_sb = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}

	local cb = {
		base_cb[1] * size,
		0,
		base_cb[3] * size,
		base_cb[4] * size,
		base_cb[5] * size,
		base_cb[6] * size,
	}

	local sb = {
		base_sb[1] * size,
		0,
		base_sb[3] * size,
		base_sb[4] * size,
		base_sb[5] * size,
		base_sb[6] * size,
	}

	local eye_height = 1.47 * size

	player:set_properties({
		visual_size   = {x = size, y = size},
		collisionbox  = cb,
		selectionbox  = sb,
		eye_height    = eye_height,
	})

	player:set_physics_override({
		jump = size >= 4 and 2 or 1,
		stepheight = 0.6 * size,
	})

	player:set_eye_offset(
		{x = 0, y = 0, z = 0},
		{x = 0, y = 0, z = -5 * size}
	)
end

core.register_privilege("resize", {
	description = "Can resize players"
})

core.register_chatcommand("resize", {
	params = "resize <name> [<size>]",
	description = "resize a player size (0.0 to 80)",
	privs = { resize = true },
	func = function(name, params)
		local args = params:split(" ")
		local player_name = args[1]
		if not player_name then
			core.chat_send_player(name, "Invalid usage: " .. params)
			return
		end

		local player = core.get_player_by_name(player_name)
		if player then
			entity_modifier.resize_player(player, tonumber(args[2]))
		else
			core.chat_send_player(name, "Invalid player name: " .. player_name)
		end
	end
})

core.register_privilege("resizeme", {
	description = "Can resize itself"
})

core.register_chatcommand("resizeme", {
	params = "resizeme [<size>]",
	description = "resize your player size (0.0 to 80)",
	privs = { resizeme = true },
	func = function(player_name, size_string)
		entity_modifier.resize_player(
			core.get_player_by_name(player_name),
			tonumber(size_string)
		)
	end
})
