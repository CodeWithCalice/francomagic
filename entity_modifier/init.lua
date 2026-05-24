entity_modifier = {}

--original dis
entity_modifier.player_original_disguise_properties = {}

local mp = core.get_modpath(core.get_current_modname())..'/'

dofile(mp.."resize.lua")

dofile(mp.."disguise.lua")

core.register_on_leaveplayer(function(player)
	entity_modifier.player_original_disguise_properties[player:get_player_name()] = nil
end)
