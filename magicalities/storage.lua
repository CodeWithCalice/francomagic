--[[
	JSON storage information:
	"<player name>": {
		"protect": [<list of player protected nodes (positions)>],
	}
]]

-- Modstorage
local storage = core.get_mod_storage()

-- Memory cache
magicalities.data = {}

local data_default = {
	protect = {},
}

-- Storage actions

function magicalities.load_player_data(player_name)
	local stdata = core.deserialize(storage:get_string(player_name))

	if not stdata then
		magicalities.data[player_name] = table.copy(data_default)
		return
	end

	magicalities.data[player_name] = stdata
end

function magicalities.save_player_data(player_name)
	if not magicalities.data[player_name] then return end
	local data = magicalities.data[player_name]

	-- Ne pas enregistrer les données si elles sont vides
	if #data.protect == 0 then return end

	local str = core.serialize(data)

	storage:set_string(player_name, str)
end

function magicalities.save_all_data()
	for pname in pairs(magicalities.data) do
		core.after(0.1, magicalities.save_player_data, pname)
	end
end

-- System Actions

core.register_chatcommand("mgcstoragereset", {
	privs = {server = 1},
	func = function (name, params)
		magicalities.data[name] = table.copy(data_default)
		magicalities.save_player_data(name)
		return true, "Deleted player storage successfully."
	end
})

core.register_chatcommand("mgcstoragesave", {
	privs = {server = 1},
	func = function (name, params)
		magicalities.save_all_data()
		return true, "Saved all magicalities data."
	end
})

core.register_on_shutdown(magicalities.save_all_data)

core.register_on_joinplayer(function (player)
	magicalities.load_player_data(player:get_player_name())
end)

core.register_on_leaveplayer(function (player, timed)
	local name = player:get_player_name()
	magicalities.save_player_data(name)
	if timed then return end
	magicalities.data[name] = nil
end)