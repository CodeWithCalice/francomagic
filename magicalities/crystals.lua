-- Magicalities crystals

magicalities.crystals = {}

-- Instance pour créer un nombre aléatoire
local randbuff = PcgRandom(os.clock())

-- Génération du contenu d'un cristal avec de l'aléatoire
function magicalities.crystals.generate_crystal_buffer(pos)
	local final    = {}
	local node     = core.get_node(pos)
	local nodedef  = core.registered_nodes[node.name]
	local self_cnt = randbuff:next(10, 60) -- ID aleatoire du cristal
	local added    = 0

	for name, data in pairs(magicalities.elements) do
		if added > 5 then break end
		if not data.inheritance then
			if name == nodedef["_element"] then
				final[name] = {self_cnt, self_cnt}
				added = added + 1
			else
				if randbuff:next(0, 5) == 0 then
					local cnt = randbuff:next(0, math.floor(self_cnt / 4))
					if cnt > 0 then
						final[name] = {cnt, cnt}
						added = added + 1
					end
				end
			end
		else
			if randbuff:next(0, 15) == 0 then
				local cnt = randbuff:next(0, math.floor(self_cnt / 8))
				if cnt > 0 then
					final[name] = {cnt, cnt}
					added = added + 1
				end
			end
		end
	end
	return final
end

-- On supprime l'élement du cristal si il est à 0 (par exemple: si earth = 0, earth est supprimé du cristal)
local function update_contents(pos, contents)
	local meta = core.get_meta(pos)
	local keep = {}

	for name,data in pairs(contents) do
		if data[1] > 0 then
			keep[name] = data
		end
	end
	meta:set_string("contents", core.serialize(keep))
end

-- Lorsque l'on clque droit sur un cristal, on vérifie si le joueur a une baguette, et si oui, on lui prend des éléments du cristal pour les mettre dans la baguette
local function crystal_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player = clicker:get_player_name()
	local meta = core.get_meta(pos)

	-- Si le cristal est en zone protégée
	if core.is_protected(pos, player) then
		return itemstack
	end

	-- Si le cristal est vide (génération), on ajoute un buffer qui contient les éléments
	local contents = core.deserialize(meta:get_string("contents"))
	if not contents then
		contents = magicalities.crystals.generate_crystal_buffer(pos)
		meta:set_string("contents", core.serialize(contents))
	end

	-- On vérifie que le joueur porte une baguette
	if core.get_item_group(itemstack:get_name(), "wand") == 0 then
		return itemstack
	end

	-- On vérifie si le joueur doit laisser au moins un élement (pour la régénation du cristal)
	local def = core.registered_items[itemstack:get_name()]
	local preserve = false
	if def and def.empty_crystal == false then
		preserve = true
	end
	local mincheck = 0
	if preserve then mincheck = 1 end

	-- On vérifie combien d'éléments on prend du crystal à la fois en fonction du niveau de baguette
	local maxtake = 1
	if def and def.max_take and def.max_take ~= 0 then
		maxtake = def.max_take
	end

	-- On crée une table one_of_each qui contient touts les élements à récupérer du cristal
	local one_of_each = {}
	for name, count in pairs(contents) do
		if count[1] > mincheck then
			local take = maxtake
			if count[1] <= maxtake then
				take = count[1] - mincheck
			end

			if take > 0 then
				one_of_each[name] = take
			end
		end
	end


	local done_did = 0 -- Nombre d'éléments que l'on a réussi à mettre dans la baguette
	local can_put = magicalities.wands.wand_insertable_contents(itemstack, one_of_each) -- On vérifie si tout les élements à récupérer peuvent être mis dans la baguette, et on récupère une table can_put qui contient les éléments que l'on peut mettre dans la baguette
	for name, count in pairs(can_put) do
		if count > 0 then
			done_did = done_did + count
			contents[name][1] = contents[name][1] - count -- On retire les éléments du cristal
		end
	end

	if done_did == 0 then return itemstack end -- Si on n'a rien pu mettre dans la baguette, on arrête là

	-- Particules pour montrer les éléments qui sont pris du cristal
	local cpls = clicker:get_pos()
	cpls.y = cpls.y + 1
	for name in pairs(can_put) do
		local ecolor = magicalities.elements[name].color
		local dist   = vector.distance(cpls, pos)
		local normal = vector.normalize(vector.subtract(cpls, pos))
		local spawn  = vector.add(normal, pos)
		local vel    = vector.multiply(normal, 4)
		local extime = dist / 4

		core.add_particle({
			pos = spawn,
			velocity = vel,
			acceleration = vel,
			expirationtime = extime,
			size = 4,
			collisiondetection = true,
			collision_removal = true,
			texture = "magicalities_spark.png^[multiply:"..ecolor.."",
			glow = 2
		})
	end

	itemstack = magicalities.wands.wand_insert_contents(itemstack, can_put) -- On met les éléments dans la baguette
	magicalities.wands.update_wand_desc(itemstack) -- On met à jour la description de la baguette
	update_contents(pos, contents) -- On met à jour les éléments du cristal (en supprimant les éléments à 0)

	return itemstack
end

function magicalities.register_crystal(element, description, color, miny, maxy, block_spawn, biomes, rarity)
	-- Fragment de cristal dropés lorsque l'on casse un cluster
	core.register_craftitem("magicalities:crystal_"..element, {
		description = description.." Crystal Shard",
		inventory_image = "magicalities_crystal_shard.png^[multiply:"..color,
		_element = element,
		groups = {crystal = 1, ["elemental_"..element] = 1}
	})

	-- Le cristal en lui même, drop des fragments de cristal lorsqu'on le casse
	core.register_node("magicalities:crystal_cluster_"..element, {
		description = description.." Crystal Cluster",
		use_texture_alpha = "blend",
		mesh = "crystal.obj",
		paramtype = "light",
		paramtype2 = "wallmounted",
		--param2 = 2,
		drawtype = "mesh",
		light_source = 4,
		_element = element,
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.4375, -0.5000, -0.4375, 0.4375, 0.3750, 0.4375}
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.4375, -0.5000, -0.4375, 0.4375, 0.3750, 0.4375}
			}
		},
		tiles = {
			{
				name = "magicalities_crystal.png^[multiply:"..color,
				backface_culling = true
			}
		},
		drop = {
            max_items = 1,
            items = {
                {
                    items = {"magicalities:crystal_"..element.." 4"},
                    rarity = 1,
                },
                {
                    items = {"magicalities:crystal_"..element.." 5"},
                    rarity = 5,
                },
            },
		},
		groups = {cracky = 3, oddly_breakable_by_hand = 3, crystal_cluster = 1, ["elemental_"..element] = 1},
		sunlight_propagates = true,
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),

		on_rightclick = crystal_rightclick,
        after_place_node = function(pos, placer, itemstack, pointed_thing)
        	local meta = core.get_meta(pos)
        	local imeta = itemstack:get_meta()
        	meta:set_string("contents", imeta:get_string("contents"))
    	end
	})

	-- Bloc de cristal, fait parti des groupes de cristal pour les ABM
	core.register_node("magicalities:crystal_block_"..element, {
		description = description.." Crystal Block",
		use_texture_alpha = "blend",
		paramtype = "light",
		drawtype = "glasslike",
		tiles = {
			{
				name = "magicalities_crystal.png^[multiply:"..color
			}
		},
		groups = {cracky = 3, oddly_breakable_by_hand = 3, crystal_block = 1, ["elemental_"..element] = 1},
		sunlight_propagates = true,
		is_ground_content = false,
		_element = element,
		sounds = default.node_sound_glass_defaults(),
	})

	core.register_decoration({
		deco_type = "simple",
		place_on  = block_spawn,
		sidelen   = 16,
		y_max = maxy,
		y_min = miny,
		flags = "all_ceilings",
		fill_ratio = rarity,
		decoration = "magicalities:crystal_cluster_"..element,
		biomes = biomes or nil
	})

	core.register_decoration({
		deco_type = "simple",
		place_on  = block_spawn,
		sidelen   = 16,
		y_max = maxy,
		y_min = miny,
		flags = "all_floors",
		fill_ratio = rarity,
		decoration = "magicalities:crystal_cluster_"..element,
		biomes = biomes or nil
	})

	core.register_craft({
		type = "shapeless",
		output = "magicalities:crystal_block_"..element,
		recipe = {
			"magicalities:crystal_"..element,
			"magicalities:crystal_"..element,
			"magicalities:crystal_"..element,
			"magicalities:crystal_"..element,
			"magicalities:crystal_"..element,
			"magicalities:crystal_"..element,
			"magicalities:crystal_"..element,
			"magicalities:crystal_"..element,
			"magicalities:crystal_"..element
		},
	})

	core.register_craft({
		type = "shapeless",
		output = "magicalities:crystal_"..element.." 9",
		recipe = {
			"magicalities:crystal_block_"..element
		},
	})
end

core.register_abm({
	label     = "Crystal Elements Refill",
	nodenames = {"group:crystal_cluster"},
	interval  = 30.0,
	chance    = 2,
	action    = function (pos, node, active_object_count, active_object_count_wider)
		local meta = core.get_meta(pos)
		local contents = meta:get_string("contents")
		if contents ~= "" then
			-- Régénération des cristaux via ABM
			contents = core.deserialize(contents)
			local count = 0
			for _, v in pairs(contents) do
				count = count + 1
			end

			if count == 0 then return end

			local mcnt    = randbuff:next(1, count)
			local cnt     = 0
			for name, data in pairs(contents) do
				if cnt == mcnt then break end
				if type(data) ~= 'table' then break end

				if data[1] < data[2] then
					data[1] = data[1] + 1
					cnt = cnt + 1
				end
			end

			if cnt == 0 then return end

			meta:set_string("contents", core.serialize(contents))
		end 
	end
})

-- Modifié le 11/04/2026 , a paufiner
core.register_on_generated(function (minp, maxp)
	local clusters = core.find_nodes_in_area(minp, maxp, "group:crystal_cluster")
	for _, pos in pairs(clusters) do
		--local stone = core.find_node_near(pos, 1, "default:stone") -- On cherche un bloc de stone à côté du cristal pour orienter le cristal vers lui
		--local pos_clusters=core.get_pos(clusters)		
			
		local ypos=pos.y-1  --on retire 1 a la position du crystal sur l'axe verticale	
		local coords = core.string_to_pos("("..pos.x..","..ypos..","..pos.z..")") --on crée les coordonnées
		local idnode = core.get_node(coords) -- On cherche un bloc  au dessous du cristal pour orienter le cristal vers lui
		
		local namenode=idnode.name --on prend son nom pour vérifier qu'il a bien quelque chose 
		if idnode then
		
			if namenode~="air" and namenode~="ignore" then
				local param2 = core.dir_to_wallmounted(vector.direction(pos, coords)) -- Ajout des orientations pour les cristaux  , vector.direction(pos1,pos2)
				local node = core.get_node(pos)
				node.param2 = param2
				core.set_node(pos, node)
			end
		end
	

	end
end)
