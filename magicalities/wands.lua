-- Magicalities Wands

magicalities.wands = {}

-- Fonction pour récupérer le cristal intact
-- Faire une structure de 3x3 autour du cristal, les deux niveaux inférieurs en verre d'obsidienne et le niveau supérieur en dalles de bronze
-- Puis frapper n'importe quelle partie du verre avec la baguette. Le cristal tombera au sol.
-- Vue de Coté:
--   DDD
--   VCV
--   VVV
-- D: stairs:slab_wood, V: default:glass, X: group:crystal_cluster
local function pickup_jarred(itemstack, user, glassp)
	local node = core.get_node_or_nil(glassp)
	if not node or node.name ~= "default:obsidian_glass" then return nil end
	local closest = core.find_node_near(glassp, 1, "group:crystal_cluster")
	if not closest then return nil end
	if core.is_protected(closest, user:get_player_name()) then return nil end
	local cap = core.find_nodes_in_area(
		vector.add(closest, {x = -1, y = 1, z = -1}),
		vector.add(closest, {x = 1, y = 1, z = 1}), {"technic:slab_brass_block"})
	if #cap ~= 9 then return nil end
	local glass = core.find_nodes_in_area(
		vector.add(closest, {x = -1, y = 0, z = -1}),
		vector.add(closest, {x = 1, y = -1, z = 1}), {"default:obsidian_glass", "group:crystal_cluster"})
	if #glass ~= 18 then return nil end
	local node = core.get_node(closest)
	local item = ItemStack(node.name)
	local nmeta = core.get_meta(closest)
	local imeta = item:get_meta()

	local contents = nmeta:get_string("contents")
	if contents ~= "" then
		local def = core.registered_items[node.name]
		imeta:set_string("description", def.description .. "\n" ..
			core.colorize("#a070e0", "Contains elements!"))
		imeta:set_string("contents", contents)
	end

	for _,p in pairs(cap) do
		core.set_node(p, { name = "air" })
	end

	for _,p in pairs(glass) do
		core.set_node(p, { name = "air" })
	end

	core.add_item(closest, item)

	return itemstack
end

-- Transformation du pupitre en table d'arcane en le frappant avec une baguette
-- Lorsqu'un verre d'obsidienne est frappé avec une baguette, on vérifie si la structure est correcte, si c'est le cas, on drop un cristal
magicalities.wands.transform_recipes = {
	["group:enchanted_table"] = {result = "magicalities:arcane_table", requirements = nil},
	["default:obsidian_glass"]         = {result = pickup_jarred, requirements = nil},
}

-- Propriétés d'attaque communes à toutes les baguettes
local wandcaps = {
	full_punch_interval = 1.0,
	max_drop_level = 0,
	groupcaps = {},
	damage_groups = {fleshy = 2},
}

-- Fonction pour récuperer le focus actif d'une baguette, et sa definition d'item
function magicalities.wands.get_wand_focus(stack)
	local meta = stack:get_meta()
	if meta:get_string("focus") == "" then
		return nil
	end

	local focus   = meta:get_string("focus")
	local itemdef = core.registered_items[focus]
	if not itemdef then return nil end

	return focus, itemdef
end

-- Récuperer le joueur propriétaire de la baguette
function magicalities.wands.get_wand_owner(stack)
	local meta = stack:get_meta()
	return meta:get_string("player")
end

-- Récupérer les élements nécessaires pour que le focus utilise sa compétence
local function focus_requirements(stack, fdef)
	if fdef["_wand_requirements"] then
		return magicalities.wands.wand_has_contents(stack, fdef["_wand_requirements"])
	end
	return true
end

-- Formspec de selection du focus de la baguette dans la main
local function focuses_formspec(available, focusname)
	local x   = 0
	local fsp = ""
	for focus in pairs(available) do
		if x < 5 then
			fsp = fsp .. "item_image_button["..x..",2.8;1,1;"..focus..";"..focus..";]"
			x = x + 1
		end
	end

	local current = ""
	if not focusname then
		current = "label[2,1;Aucun Focus]"
	else
		current = "item_image_button[2,0.5;1,1;"..focusname..";remove;Supprimer]"..
				  "label[0,1.5;Actuel: "..core.registered_items[focusname].description.."]"
	end

	return "size[5,3.5]"..
		default.gui_bg..
		default.gui_bg_img..
		"label[0,0;Focus de la baguette]"..
		current..
		"label[0,2.4;Disponibles]"..
		fsp
end

-- Mise à jour de la description de la baguette en fonction du focus et des élements contenu
function magicalities.wands.update_wand_desc(stack)
	local meta = stack:get_meta()
	local data_table = core.deserialize(meta:get_string("contents"))
	if not data_table then
		data_table = {}
	end

	local focus, fdef = magicalities.wands.get_wand_focus(stack)

	local wanddata    = core.registered_items[stack:get_name()]
	local description = wanddata.description
	local capcontents = wanddata["_cap_max"] or 15
	local strbld      = description .. "\n\n"

	local elems = {}

	local ordered_elements = {
		"air",
		"earth",
		"water",
		"fire",
		"light",
		"dark",
	}

	for _, elem in ipairs(ordered_elements) do
		local amount = data_table[elem]

		if amount ~= nil then
			local dataelem = magicalities.elements[elem]

			local visual = amount
			if amount < 10 then
				visual = "0" .. amount
			end

			if amount == 0 then
				visual = core.colorize("#ff0505", visual)
			end

			local str = "[" .. visual .. "/" .. capcontents .. "] "
			str = str .. core.colorize(dataelem.color, dataelem.description)

			if focus and fdef and fdef["_wand_requirements"] and fdef["_wand_requirements"][elem] ~= nil then
				elems[#elems + 1] =
					str .. core.colorize("#a070e0", " (" .. fdef["_wand_requirements"][elem] .. ") ")
			elseif amount ~= 0 then
				elems[#elems + 1] = str
			end
		end
	end
	local focusstr = "Aucun Focus"
	if focus then
		focusstr = fdef.description
	end
	strbld = strbld .. core.colorize("#a070e0", focusstr) .. "\n"
	if #elems > 0 then
		strbld = strbld .. "\n" .. table.concat(elems, "\n")
	end
	local owner = meta:get_string("player")
	if owner ~= "" then
		strbld = strbld .. "\n" .. core.colorize("#d33b57", string.format("Baguette de %s", owner))
	end
	meta:set_string("description", strbld)
end

-- Vérifier que la baguette a les élements nécessaires pour une action
function magicalities.wands.wand_has_contents(stack, requirements)
	local meta = stack:get_meta()
	local data_table = core.deserialize(meta:get_string("contents"))
	if not data_table then return false end

	for name, count in pairs(requirements) do
		if not data_table[name] or data_table[name] < count then
			return false
		end
	end

	return true
end

-- Récuperer le contenu nécessaire pour l'action de la baguette
function magicalities.wands.wand_take_contents(stack, to_take)
	local meta = stack:get_meta()
	local data_table = core.deserialize(meta:get_string("contents"))

	for name, count in pairs(to_take) do
		if not data_table[name] or data_table[name] - count < 0 then
			return stack
		end

		data_table[name] = data_table[name] - count
	end

	local data_res = core.serialize(data_table)
	meta:set_string("contents", data_res)
	magicalities.wands.update_wand_desc(stack)

	return stack
end

-- Ajouter des élements dans la baguette
function magicalities.wands.wand_insert_contents(stack, to_put)
	local meta = stack:get_meta()
	local data_table = core.deserialize(meta:get_string("contents"))
	local cap = core.registered_items[stack:get_name()]["_cap_max"]
	local leftover = {}

	for name, count in pairs(to_put) do
		if data_table[name] then
			if data_table[name] + count > cap then
				data_table[name] = cap
				leftover[name] = (data_table[name] + count) - cap
			else
				data_table[name] = data_table[name] + count
			end
		end
	end

	local data_res = core.serialize(data_table)
	meta:set_string("contents", data_res)

	return stack, leftover
end

-- Vérifier que les élements to_put sont insérables dans la baguette
function magicalities.wands.wand_insertable_contents(stack, to_put)
	local meta = stack:get_meta()
	local data_table = core.deserialize(meta:get_string("contents"))
	local cap = core.registered_items[stack:get_name()]["_cap_max"]
	local insertable = {}

	for name, count in pairs(to_put) do
		if data_table[name] then
			if data_table[name] + count <= cap then
				insertable[name] = count
			elseif cap - data_table[name] > 0 then
				insertable[name] = cap - data_table[name]
			end
		end
	end

	return insertable
end

-- Initialiser les métadonnées de la baguette
local function initialize_wand(stack, player)
	local data_table = {}

	for name, data in pairs(magicalities.elements) do
		if not data.inheritance then
			data_table[name] = 0
		end
	end

	local meta = stack:get_meta()
	meta:set_string("player", player)
	meta:set_string("contents", core.serialize(data_table))
end

-- Fonction appelée lorsqu'un joueur clic droit sur un bloc avec la baguette, elle initiale la baguette, vérifie si elle a un focus équipé, si le focus a une action sur le node, elle l'execute, sinon elle effectue normalement le on_rightclick du node
local function wand_action(itemstack, placer, pointed_thing)
	if not pointed_thing.type == "node" then return itemstack end
	local pos = pointed_thing.under
	local node = core.get_node(pointed_thing.under)
	local imeta = itemstack:get_meta()

	-- On initialise les métadonnées de la baguette si elles n'existent pas déjà (sécurité)
	if imeta:get_string("contents") == nil or imeta:get_string("contents") == "" then
		initialize_wand(itemstack, placer:get_player_name())
		magicalities.wands.update_wand_desc(itemstack)
	end

	-- On vérifie que le focus équipé a une action sur le node, et si c'est le cas, on l'execute
	local focus, fdef = magicalities.wands.get_wand_focus(itemstack)
	if focus then
		if fdef["_wand_node"] and focus_requirements(itemstack, fdef) then
			itemstack = fdef["_wand_node"](pos, node, placer, itemstack, pointed_thing)
			return itemstack
		end
	end

	-- On vérifie que le node a une action de définie, et si c'est le cas, on l'execute
	local nodedef = core.registered_nodes[node.name]
	if nodedef.on_rightclick then
		itemstack = nodedef.on_rightclick(pos, node, placer, itemstack, pointed_thing)
	end

	return itemstack
end

-- Fonction appelée lorsqu'un joueur utilise la baguette (clic gauche), elle vérifie si le focus a une action de définie, si c'est le cas, elle l'execute
local function use_wand(itemstack, user, pointed_thing)
	local imeta = itemstack:get_meta()
	local pname = user:get_player_name()

	-- On initialise les métadonnées de la baguette si elles n'existent pas déjà (sécurité)
	if imeta:get_string("contents") == "" then
		initialize_wand(itemstack, pname)
		magicalities.wands.update_wand_desc(itemstack)
	end

	-- On vérifie si le bloc pointé est une bookshelf, si c'est le cas, on la remplace par le drop d'un Livre des Arcanes
	local node
	if pointed_thing.type == "node" then
		node = core.get_node(pointed_thing.under)
	end
	if node and node.name == "default:bookshelf" then
		core.set_node(pointed_thing.under, {name = "air"})
		core.add_item(pointed_thing.under, "magicalities:book")
		return itemstack
	end

	-- On appelle le callback d'utilisation du focus équipé dans la baguette, s'il existe et qu'il a les élements nécessaires pour l'action (élements dans la baguette)
	local focus, fdef = magicalities.wands.get_wand_focus(itemstack)
	if focus and fdef then
		if fdef["_wand_use"] and focus_requirements(itemstack, fdef) then
			-- On vérifie que le joueur à le niveau de magie nécessaire pour lancer le sort
			if get_level_witch(pname) < fdef["level_requirement"] then
				core.chat_send_player(pname, "Vous n'avez pas un niveau suffisant pour lancer ce sort.")
				return itemstack
			end
			if fdef["_wand_requirements"] then
				itemstack = magicalities.wands.wand_take_contents(itemstack, fdef["_wand_requirements"])
				magicalities.wands.update_wand_desc(itemstack)
			end
			itemstack = fdef["_wand_use"](itemstack, user, pointed_thing)
			return itemstack
		end
	end

	-- Maj de la description de la baguette (pour mettre à jour les élements contenus)
	if pointed_thing.type ~= "node" then
		magicalities.wands.update_wand_desc(itemstack)
		return itemstack
	end

	local pos = pointed_thing.under
	local node = core.get_node_or_nil(pos)
	-- On vérifie que le node existe, que ce n'est pas de l'air, et que le joueur a le droit d'interagir avec avant de faire quoi que ce soit (pour éviter les bugs du style "je frappe un node protégé pour faire update ma baguette et ca me met des éléments dedans alors que je suis pas censé pouvoir faire ça")
	if not node or node.name == "air" or core.is_protected(pos, pname) then
		core.record_protection_violation(pos, pname)
		magicalities.wands.update_wand_desc(itemstack)
		return itemstack
	end

	-- On vérifie que le focus équipé a une action de définie sur le node frappé, et si c'est le cas, on l'execute par exemple pour les transformations de node (comme transformer un bloc de terre en bloc d'herbe)
	local to_replace = nil
	for name, result in pairs(magicalities.wands.transform_recipes) do
		if name:match("group:") ~= nil and
			core.get_item_group(node.name, string.gsub(name, "group:", "")) > 0 then
			to_replace = result
			break
		elseif name == node.name then
			to_replace = result
			break
		end
	end

	-- Vérification si on peut miner le node avant de le supprimer
	if to_replace then
		local ndef = core.registered_items[node.name]
		if ndef.can_dig and not ndef.can_dig(pos, user) then
			to_replace = nil
		end
	end

	-- Si une transformation est trouvée pour ce node, on vérifie que la baguette a les élements nécessaires pour effectuer la transformation, et si c'est le cas, on effectue la transformation
	if to_replace then
		local take_req = true

		if type(to_replace.result) == "function" then
			local t = to_replace.result(itemstack, user, pos)
			if not t then
				take_req = false
			else
				itemstack = t
			end
		elseif to_replace.drop then
			local istack = ItemStack(to_replace.result)
			local istackdef = core.registered_items[to_replace.result]
			if istackdef._wand_created then
				istack = istackdef._wand_created(istack, itemstack, user, pos)
			end
			core.add_item(pos, istack)
			core.set_node(pos, {name = "air"})
		else
			core.set_node(pos, {name = to_replace.result, param1 = node.param1, param2 = node.param2})
			local spec = core.registered_nodes[to_replace.result]
			if spec.on_construct then
				spec.on_construct(pos)
			end
		end

		if take_req and to_replace.requirements then
			if not magicalities.wands.wand_has_contents(itemstack, to_replace.requirements) then
				return itemstack
			end
			itemstack = magicalities.wands.wand_take_contents(itemstack, to_replace.requirements)
		end

		magicalities.wands.update_wand_desc(itemstack)
		return itemstack
	end

	-- On appelle le callback _wand_use sur le node, s'il est enregistré
	local ndef = core.registered_nodes[node.name]
	if ndef['_wand_use'] then
		return ndef['_wand_use'](pos, node, itemstack, user, pointed_thing)
	end

	magicalities.wands.update_wand_desc(itemstack)
	return itemstack
end

-- Fonction appelée lorsqu'un joueur clic droit avec la baguette, elle affiche une formspec listant les focus disponibles dans l'inventaire du joueur, et lui permettant d'en équiper un ou de le retirer
local function wand_focuses(itemstack, user, pointed_thing)
	local focuses_found = {}
	local inv  = user:get_inventory()
	local list = inv:get_list("main")

	local focusname, focusdef = magicalities.wands.get_wand_focus(itemstack)
	local meta = itemstack:get_meta()

	for _, stack in pairs(list) do
		if core.get_item_group(stack:get_name(), "wand_focus") > 0 then
			focuses_found[stack:get_name()] = true
		end
	end

	core.show_formspec(user:get_player_name(), "magicalities:wand_focuses", focuses_formspec(focuses_found, focusname))
	core.register_on_player_receive_fields(function (player, formname, fields)
		if formname ~= "magicalities:wand_focuses" then
			return false
		end

		local f = ""
		if not fields["quit"] then
			if fields["remove"] then
				f = nil
			else
				for v in pairs(fields) do
					if core.registered_items[v] then
						mana.set(user:get_player_name(), mana.get(user:get_player_name()) - 10) -- Coût de 10 mana pour changer de focus
						f = v
						break
					end
				end
			end
		else
			return true
		end

		local was

		was = meta:get_string("focus")
		if was == "" and not f then
			return true
		elseif was ~= "" then
			was = ItemStack(was)
			if not inv:room_for_item("main", was) then
				return true
			end
		end

		core.close_formspec(player:get_player_name(), "magicalities:wand_focuses")

		local removed_focus = false
		local set = false

		for i, stack in pairs(list) do
			if set and (removed_focus or not f) then break end
			if not removed_focus and stack:get_name() == f then
				inv:set_stack("main", i, ItemStack(nil))
				removed_focus = true -- On en enlève un seul focus même si le joueur en a plusieurs identiques
			end

			if stack:get_name() == itemstack:get_name() and stack:get_meta() == itemstack:get_meta() and not set then
				if not f then
					meta:set_string("focus", "")
					magicalities.wands.update_wand_desc(itemstack)
				elseif f ~= "" then
					meta:set_string("focus", f)
					magicalities.wands.update_wand_desc(itemstack)
				end

				inv:set_stack("main", i, itemstack)
				set = true
			end
		end

		-- On redonne le focus retiré dans l'inventaire du joueur, s'il y en avait un
		if was then
			inv:add_item("main", was)
		end

		return true
	end)

	return itemstack
end

function magicalities.wands.register_wand(name, data)
	local mod = core.get_current_modname()
	core.register_tool(mod..":"..name.."_wand", { -- <modname>:<name>_wand
		description = data.description,
		inventory_image = data.image,
		tool_capabilities = wandcaps,
		liquids_pointable = true,
		stack_max = 1,
		_cap_max = data.wand_cap,
		max_take = data.max_take,
		empty_crystal = data.empty_crystal,
		on_use = use_wand,
		on_place = wand_action,
		on_secondary_use = wand_focuses,
		groups = {wand = 1}
	})
end