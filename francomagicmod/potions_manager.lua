-- potions_manager.lua

-- Création d'une classe qui stockera les potions ainsi que leur logique
local Potions = {}

Potions.__index = Potions
function Potions:new()
    local self = setmetatable({}, Potions)
    self.potions = {}
    self.upgrades = {}
    return self
end
core.log("action", "[francomagicmod] Loaded potion manager.")
potion_manager = Potions:new()
player_magic_level = {}
active_potions = {}
local potion_huds = {}

-- recup du niveau
function get_level_witch(player_name)
    if type(player_name) ~= "string" and player_name:is_player() then
        player_name = player_name:get_player_name()
    end
    local has_levelcraft_mod = minetest.get_modpath("levelcraft")
	if has_levelcraft_mod ~= nil or has_levelcraft_mod ~= "" then
		return tonumber(levelcraft.get_level(player_name, "witch"))
	else
		return 0
	end
end

local substitutions_table = {
    a = {"a", "@", "4", "à", "á", "â"},
    b = {"b", "8", "ß"},
    c = {"c", "(", "{", "<"},
    d = {"d", "Ð"},
    e = {"e", "€", "3", "è", "é", "ê"},
    f = {"f", "ƒ"},
    g = {"g", "6", "9"},
    h = {"h"},
    i = {"i", "1", "!", "í", "ì"},
    j = {"j", "_|"},
    k = {"k"},
    l = {"l", "1", "|", "£"},
    m = {"m"},
    n = {"n", "ñ"},
    o = {"o", "0", "ø", "ô", "ó"},
    p = {"p"},
    q = {"q"},
    r = {"r"},
    s = {"s", "$", "5", "§"},
    t = {"t", "7"},
    u = {"u", "µ", "ü", "ù"},
    v = {"v"},
    w = {"w", "vv"},
    x = {"x"},
    y = {"y", "¥"},
    z = {"z", "2"},
}

-- Liste des combustibles pour le chaudron et leur temps de combustion en secondes
local cauldron_fuels = {
    ["default:coal_lump"] = 60,
    ["default:charcoal_lump"] = 80,
    ["default:stick"] = 15,
}

local function meta_get_spawners(meta)
    local raw = meta:get_string("spawners")
    return core.deserialize(raw) or {}
end

local function meta_set_spawners(meta, list)
    meta:set_string("spawners", core.serialize(list or {}))
end

local function meta_clear_spawners(meta)
    local spawners = meta_get_spawners(meta)

    for _, id in ipairs(spawners) do
        core.delete_particlespawner(id)
    end

    meta:set_string("spawners", "[]")
end

local function sync_fuel_state(pos)
    local meta = core.get_meta(pos)
    if meta:get_string("lit") ~= "true" then
        return
    end
    local now = os.time()
    local end_time = meta:get_int("fuel_end_time")
    if end_time <= 0 then
        meta:set_string("lit", "false")
        meta:set_string("fuel", "")
        meta:set_int("fuel_time", 0)
        meta:set_int("fuel_end_time", 0)
        meta_clear_spawners(meta)
        return
    end
    local remaining = end_time - now
    if remaining <= 0 then
        meta:set_string("lit", "false")
        meta:set_string("fuel", "")
        meta:set_int("fuel_time", 0)
        meta:set_int("fuel_end_time", 0)

        meta_clear_spawners(meta)
        return
    end
    meta:set_int("fuel_time", remaining)
    core.after(5, function()
        sync_fuel_state(pos)
    end)
end

math.randomseed(os.time())
local function randomize_string(str, chance)
    chance = chance or 0.2
    local result = {}
    for c in str:gmatch(".") do
        local lower = c:lower()
        local subs = substitutions_table[lower]

        if subs and math.random() < chance then
            local repl = subs[math.random(#subs)]
            if c ~= lower then
                repl = repl:upper()
            end
            table.insert(result, repl)
        else
            table.insert(result, c)
        end
    end
    return table.concat(result)
end

local function update_potion_hud(player)
    local name = player:get_player_name()
    local potions = active_potions[name]

    if not potions or next(potions) == nil then
        if potion_huds[name] then
            player:hud_remove(potion_huds[name])
            potion_huds[name] = nil
        end
        return
    end

    local lines = {}
    for potion, time_left in pairs(potions) do
        table.insert(lines, potion .. " : " .. time_left .. "s")
    end

    local text = table.concat(lines, "\n")

    if potion_huds[name] then
        player:hud_change(potion_huds[name], "text", text)
    else
        potion_huds[name] = player:hud_add({
            hud_elem_type = "text",
            position = {x = 1, y = 0.5},
            offset = {x = -20, y = 0},
            alignment = {x = -1, y = 0},
            scale = {x = 100, y = 100},
            text = text,
            number = 0x3BCC31,
        })
    end
end

local function start_potion_timer(player, potion_name, duration)
    local pname = player:get_player_name()

    active_potions[pname] = active_potions[pname] or {}
    active_potions[pname][potion_name] = duration

    update_potion_hud(player)

    local function tick()
        local player = core.get_player_by_name(pname)
        if not player then return end

        if not active_potions[pname] or not active_potions[pname][potion_name] then
            return
        end

        active_potions[pname][potion_name] =
            active_potions[pname][potion_name] - 1

        if active_potions[pname][potion_name] <= 0 then
            active_potions[pname][potion_name] = nil
        end

        update_potion_hud(player)

        if active_potions[pname] and active_potions[pname][potion_name] then
            core.after(1, tick)
        end
    end

    core.after(1, tick)
end

local failed_potion_effects = {}
core.register_craftitem("francomagicmod:failed_potion", {
    description = "Failed Potion",
    inventory_image = "failed_potion.png",
    groups = {not_in_creative_inventory = 1},
    stack_max = 1,
    on_use = function(itemstack, user)
        if not user or not user:is_player() then
            return itemstack
        end
        local name = user:get_player_name()
        itemstack:take_item()
        if failed_potion_effects[name] then
            return itemstack
        end
        local inv = user:get_inventory()
        if inv then
            inv:add_item("main", "vessels:glass_bottle")
        end
        failed_potion_effects[name] = {
            ticks_left = 3
        }
        local function apply_failed_damage()
            local effect = failed_potion_effects[name]
            if not effect then return end
            local player = core.get_player_by_name(name)
            if not player then
                -- Si le joueur n'est plus présent
                failed_potion_effects[name] = nil
                return
            end
            player:set_hp(player:get_hp() - 3)
            effect.ticks_left = effect.ticks_left - 1
            if effect.ticks_left <= 0 then
                failed_potion_effects[name] = nil
                return
            end
            core.after(1, apply_failed_damage)
        end
        core.after(1, apply_failed_damage)
        return itemstack
    end
})


core.register_chatcommand("mlvl", {
    description = "Get your current magic level",
    params = "<player_name>",
    func = function(name, param)
        local player_name = param or name
        local level = get_level_witch(player_name)
        if level then
            player_magic_level[name] = level
            core.chat_send_player(name, "You are level " .. level .. " in the magic progression.")
        else
            core.log("error", "Error: Magic level not defined for player " .. name " .")
            core.chat_send_player(name, "Error: Magic level not defined.")
        end
    end,
})

-- Reinitialiser les meta du bloc lorsque le chaudron est détruit
local function reset_cauldron_meta(meta)
    meta:set_string("water", "false")
    meta:set_string("ingredients", "[]")
    meta:set_string("potion", "")
    meta:set_string("potion_texture", "")
    meta:set_string("potion_effect", "")
    meta:set_string("lit", "false")
    meta:set_string("fuel", "")
    meta:set_int("fuel_time", 0)
    meta:set_int("fuel_end_time", 0)
    meta_clear_spawners(meta)
end

-- Clic gauche sur le chaudron (recuperer les ingrediens ou bien la potion crée)
local function cauldron_on_leftclick(pos, node, clicker, itemstack)
    local meta = core.get_meta(pos)

    if meta:get_string("lit") ~= "true" then
        if clicker and clicker:is_player() then
            core.chat_send_player(clicker:get_player_name(), "Le chaudron doit être allumé avec un briquet.")
        end
        return itemstack
    end

    local player_name = clicker:get_player_name()
    local ingredients = core.deserialize(meta:get_string("ingredients")) or {}

    if #ingredients > 0 then
        local last_ingredient = table.remove(ingredients)
        meta:set_string("ingredients", core.serialize(ingredients))

        local inv = clicker:get_inventory()
        local leftover = inv:add_item("main", last_ingredient)

        if leftover:get_count() ~= 0 then
            local obj = core.add_item(pos, last_ingredient)
            if obj then
                obj:set_velocity({x = math.random() - 0.5, y = 2, z = math.random() - 0.5})
            end
        end

        core.log("action", player_name .. " took " .. last_ingredient)
    else
        core.chat_send_player(player_name, "Il n'y a plus d'ingrédients.")
    end

    return itemstack
end

local function cauldron_on_rightclick(pos, node, clicker, itemstack)

    local meta = core.get_meta(pos)
    local player_name = clicker:get_player_name()
    local item_name = itemstack:get_name()
    local lit = meta:get_string("lit") == "true"
    local fuel = meta:get_string("fuel")
    local water = meta:get_string("water") == "true"
    local ingredients = core.deserialize(meta:get_string("ingredients")) or {}
    local potion_name = meta:get_string("potion")

    -- Cas ou le joueur ajoute de l'eau dans le chaudron
    if core.get_modpath("francomagicmod") and item_name == "francomagicmod:bucket_pure_water" then
        if not water then
            -- Est ce que le chaudron est déjà rempli d'eau
            meta:set_string("water", "true")
            core.log("action", player_name .. " filled cauldron with water at " .. core.pos_to_string(pos))
            core.swap_node(pos, {name = "francomagicmod:cauldron_water"})
            itemstack:take_item()
        else
            core.chat_send_player(player_name, "Le chaudron contient déjà de l'eau.")
        end
        return itemstack
    elseif item_name == "bucket:bucket_water" or item_name == "bucket:bucket_river_water" then
        if not water then
            -- Est ce que le chaudron est déjà rempli d'eau
            meta:set_string("water", "true")
            core.log("action", player_name .. " filled cauldron with water at " .. core.pos_to_string(pos))
            core.swap_node(pos, {name = "francomagicmod:cauldron_water"})
            itemstack = ItemStack("bucket:bucket_empty")
        else
            core.chat_send_player(player_name, "Le chaudron contient déjà de l'eau.")
        end
        return itemstack
    end

    -- Carburant nécessaire sous le chaudron pour utilisation 
    if not lit then
        local burn_time = cauldron_fuels[item_name]
        if burn_time then
            if fuel ~= "" then
                core.chat_send_player(player_name, "Le chaudron contient déjà du carburant.")
                return itemstack
            end
            meta:set_string("fuel", item_name)
            meta:set_int("fuel_time", burn_time)
            itemstack:take_item(1)
            return itemstack
        end
    end

    if item_name == "fire:flint_and_steel" then
        if meta:get_string("fuel") == "" then
            core.chat_send_player(player_name, "Ajoutez d'abord du carburant.")
            return itemstack
        end

        local burn = meta:get_int("fuel_time")

        meta:set_string("lit", "true")
        meta:set_int("fuel_end_time", os.time() + burn)

        local y = pos.y - 0.45
        local spawner_ids = {}

        local function spawn_side(minx, maxx, minz, maxz, vx, vz)
            local id = core.add_particlespawner({
                amount = 40,
                time = 0,

                minpos = {x = minx, y = y, z = minz},
                maxpos = {x = maxx, y = y, z = maxz},

                minvel = {x = vx, y = 0.6, z = vz},
                maxvel = {x = vx, y = 1.1, z = vz},

                minacc = {x = 0, y = 0.2, z = 0},
                maxacc = {x = 0, y = 0.4, z = 0},

                minexptime = 0.2,
                maxexptime = 1.2,

                minsize = 0.5,
                maxsize = 1.2,

                texture = "yellow_fire_particle.png",
                glow = 8
            })
            table.insert(spawner_ids, id)
        end

        spawn_side(
            pos.x - 0.5, pos.x + 0.5,
            pos.z - 0.5, pos.z - 0.5,
            0, -0.02)
        spawn_side(
            pos.x - 0.5, pos.x + 0.5,
            pos.z + 0.5, pos.z + 0.5,
            0, 0.02)
        spawn_side(
            pos.x - 0.5, pos.x - 0.5,
            pos.z - 0.5, pos.z + 0.5,
            -0.02, 0)
        spawn_side(
            pos.x + 0.5, pos.x + 0.5,
            pos.z - 0.5, pos.z + 0.5,
            0.02, 0)

        local id = core.add_particlespawner({
            amount = 50,
            time = 0,

            minpos = {x = pos.x - 0.5, y = y, z = pos.z - 0.5},
            maxpos = {x = pos.x + 0.5, y = y, z = pos.z + 0.5},

            minvel = {x = -0.1, y = 0, z = -0.1},
            maxvel = {x = 0.1, y = 0.2, z = 0.1},

            minacc = {x = -0.1, y = 0.0, z = -0.1},
            maxacc = {x = 0.1, y = 0.2, z = 0.1},

            minexptime = 1.5,
            maxexptime = 2,

            minsize = 2,
            maxsize = 2.5,

            texture = "white_fire_particle.png",
            glow = 15
        })
        table.insert(spawner_ids, id)
        meta_set_spawners(meta, spawner_ids)

        sync_fuel_state(pos)

        return itemstack
    end

    if not lit then
        core.chat_send_player(player_name, "Le chaudron doit être allumé.")
        return itemstack
    end

    -- Cas ou le joueur clique avec une main vide pour voir les ingrédients dans le chaudron
    if itemstack:get_count() == 0 then
        if #ingredients > 0 then
            -- Est ce que le chaudron contient des ingrédients
            core.chat_send_player(player_name, "Ingrédients dans le chaudron:")
            local display_ingredients = {}
            local max_display = 8
            for i = 1, math.min(max_display, #ingredients) do
                table.insert(display_ingredients, ingredients[i])
            end
            for _, ingredient in ipairs(display_ingredients) do
                core.chat_send_player(player_name, "- " .. ingredient)
            end
            if #ingredients > max_display then
                local remaining = #ingredients - max_display
                core.chat_send_player(player_name, "... et " .. remaining .. " autres.")
            end
        else
            -- Sinon il n'y a rien à afficher
            core.chat_send_player(player_name, "Il n'y a pas d'ingrédients dans le chaudron.")
        end
        return itemstack
    end

    -- Construction du nom de la potion pour vérification de son existence
    local potion_item_name = "francomagicmod:" .. potion_name:gsub("%s+", "_"):lower()

    -- Cas ou le joueur récupère la potion
    if item_name == "vessels:glass_bottle" and potion_name ~= "" then
        if core.registered_items[potion_item_name] then
            -- Récuperation de la potion
            itemstack:take_item()
            clicker:get_inventory():add_item("main", potion_item_name)
            core.log("action", player_name .. " took potion " .. potion_name .. " from cauldron at " .. core.pos_to_string(pos))
        else
            core.chat_send_player(player_name, "Erreur: Potion inexistante.")
        end

        -- Chaudron vidé et reinitialisé
        reset_cauldron_meta(meta)
        core.swap_node(pos, {name = "francomagicmod:cauldron"})
        return itemstack
    end

    -- Besoin d'eau dans le chaudron pour ajouter des ingrédients
    if not water then
        core.chat_send_player(player_name, "Ajoutez d'abord de l'eau dans le chaudron avant d'y mettre des ingrédients.")
        return itemstack
    end

    -- Cas ou la potion est incorrect ou incomplete donne une potion corrompue
    if item_name == "vessels:glass_bottle" and potion_name == "" then
        local failed_name = "Potion Ratée"
        local failed_texture = "failed_potion.png"
        local failed_description = "Une potion qui inflige des degats"

        for _, potion in ipairs(potion_manager.potions) do
            local matches = 0
            for _, ing in ipairs(ingredients) do
                for _, ping in ipairs(potion.ingredients) do
                    if ing == ping then
                        matches = matches + 1
                    end
                end
            end

            if matches > 0 then
                failed_name = randomize_string(potion.name, 0.5)
                failed_texture = potion.texture
                failed_description = potion.description
                break
            end
        end

        itemstack:take_item()

        local failed_potion = ItemStack("francomagicmod:failed_potion")
        local meta = failed_potion:get_meta()
        meta:set_string("description", failed_name .. " - " .. failed_description)
        meta:set_string("inventory_image", failed_texture)
        -- Modification du nom et de la description de l'item
        clicker:get_inventory():add_item("main", failed_potion)
        core.log("action", player_name .. " failed to create a potion at " .. core.pos_to_string(pos) .. " (result: " .. failed_name .. ")")
        core.swap_node(pos, {name = "francomagicmod:cauldron"})
        meta = core.get_meta(pos)
        reset_cauldron_meta(meta)
        return itemstack
    end

    -- Outils non autorisés dans le chaudron
    if core.registered_tools[item_name] then
        core.chat_send_player(player_name, "Vous ne pouvez pas mettre d'outil dans le chaudron.")
        core.log("action", player_name .. " tried to add tool " .. item_name .. " to cauldron at " .. core.pos_to_string(pos))
        return itemstack
    end

    -- 3 ingredients max dans le chaudron
    if #ingredients >= 3 then
        core.chat_send_player(player_name, "Le chaudron est plein d'ingrédients.")
        core.log("action", player_name .. " tried to add more ingredients to full cauldron at " .. core.pos_to_string(pos))
        return itemstack
    end

    -- Si le marram_grass n'est pas de la bonne taille, on normalise pour éviter les problèmes de comparaison d'ingrédients
    if item_name == "default:marram_grass_2" or item_name == "default:marram_grass_3" then
        item_name = "default:marram_grass_1"
    end
    -- Ajout de l'ingrédient dans le chaudron
    table.insert(ingredients, item_name)
    meta:set_string("ingredients", core.serialize(ingredients))
    core.chat_send_player(player_name, "Vous avez ajouté " .. item_name .. " au chaudron.")
    core.log("action", player_name .. " added " .. item_name .. " to cauldron at " .. core.pos_to_string(pos))

    itemstack:take_item()

    -- Vérification des potions possibles pour le joueur en fonction de son niveau de magie
    local updated_level = get_level_witch(player_name)
    if updated_level then
        player_magic_level[player_name] = updated_level
    else
        core.chat_send_player(player_name, "Erreur : niveau de magie non défini.")
        return
    end
    local player_level = player_magic_level[player_name]
    for _, potion in ipairs(potion_manager.potions) do
        if potion.ingredients and #potion.ingredients > 0 then
            if player_level >= potion.required_level then
                local potion_ingredients = table.concat(potion.ingredients, ",")
                local ingredient_str = table.concat(ingredients, ",")
                if potion_ingredients == ingredient_str then
                    meta:set_string("potion", potion.name)
                    meta:set_string("potion_texture", potion.texture)
                    core.log("action", player_name .. " created potion " .. potion.name .. " at " .. core.pos_to_string(pos))
                    core.swap_node(pos, {name = "francomagicmod:cauldron_" .. potion.name:gsub("%s+", "_"):lower()})
                    return itemstack
                end
            end
        end
    end

    return itemstack
end

core.register_node("francomagicmod:cauldron", {
    description = "Cauldron",
    tiles = {
        "francomagicmod_cauldron_top.png",
		"francomagicmod_cauldron_bottom.png",
		"francomagicmod_cauldron_side.png",
		"francomagicmod_cauldron_side.png",
		"francomagicmod_cauldron_side.png",
		"francomagicmod_cauldron_side.png"
	},
    drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, -0.4375, 0.4375},
			{-0.375, -0.4375, -0.375, 0.375, -0.375, 0.375},
			{-0.3125, -0.375, -0.3125, 0.3125, -0.3125, 0.3125},
			{-0.375, -0.3125, -0.375, 0.375, -0.25, 0.375},
			{-0.4375, -0.25, -0.4375, 0.4375, -0.1875, 0.4375},
			{-0.5, -0.1875, -0.5, 0.5, -0.125, 0.5},
			{-0.5, -0.125, -0.5, 0.5, 0.3125, -0.3125},
			{-0.5, -0.125, 0.3125, 0.5, 0.3125, 0.5},
			{0.3125, -0.1875, -0.5, 0.5, 0.3125, 0.5},
			{-0.5, -0.125, -0.5, -0.3125, 0.3125, 0.5},
			{-0.4375, 0.375, 0.3125, 0.4375, 0.5, 0.4375},
			{-0.4375, 0.375, -0.4375, 0.4375, 0.5, -0.3125},
			{-0.4375, 0.375, -0.4375, 0.4375, 0.5, -0.3125},
			{0.3125, 0.375, -0.4375, 0.4375, 0.5, 0.4375},
			{-0.4375, 0.375, -0.4375, -0.3125, 0.5, 0.4375},
			{-0.375, 0.3125, -0.375, 0.375, 0.375, -0.3125},
			{-0.375, 0.3125, 0.3125, 0.375, 0.375, 0.375},
			{0.3125, 0.3125, -0.375, 0.375, 0.375, 0.375},
			{-0.375, 0.3125, -0.375, -0.3125, 0.375, 0.375},
		}
	},
    groups = {cracky = 2, interactive = 1},
    drop = "francomagicmod:cauldron",
    after_dig_node = function(pos)
        reset_cauldron_meta(core.get_meta(pos))
    end,
    on_load = function(pos)
        sync_fuel_state(pos)
    end,
    on_destruct = function(pos)
        meta_clear_spawners(core.get_meta(pos))
    end,
    on_punch = cauldron_on_leftclick,
    on_rightclick = cauldron_on_rightclick,
})

core.register_node("francomagicmod:cauldron_water", {
    description = "Cauldron filled with water",
    tiles = {
        {name="francomagicmod_cauldron_water.png", animation = {type="vertical_frames", length=3.0}},
		"francomagicmod_cauldron_bottom.png",
		"francomagicmod_cauldron_side.png",
		"francomagicmod_cauldron_side.png",
		"francomagicmod_cauldron_side.png",
		"francomagicmod_cauldron_side.png"
	},
    drawtype = "nodebox",
	paramtype = "light",
	node_box = {
        type = "fixed",
        fixed = {
            {-0.4375, -0.5, -0.4375, 0.4375, -0.4375, 0.4375},
            {-0.375, -0.4375, -0.375, 0.375, -0.375, 0.375},
            {-0.3125, -0.375, -0.3125, 0.3125, -0.3125, 0.3125},
            {-0.375, -0.3125, -0.375, 0.375, 0.5, 0.375},
            {-0.4375, -0.25, -0.4375, 0.4375, 0.3125, 0.4375},
            {-0.5, -0.1875, -0.5, 0.5, 0.3125, 0.5},
            {-0.4375, 0.375, -0.4375, 0.4375, 0.5, 0.4375},
        }
    },
    groups = {cracky = 2, not_in_creative_inventory = 1},
    drop = "francomagicmod:cauldron",
    after_dig_node = function(pos)
        reset_cauldron_meta(core.get_meta(pos))
    end,
    on_load = function(pos)
        sync_fuel_state(pos)
    end,
    on_destruct = function(pos)
        meta_clear_spawners(core.get_meta(pos))
    end,
    on_punch = cauldron_on_leftclick,
    on_rightclick = cauldron_on_rightclick,
})

function Potions:register_potion(name, description, ingredients, texture, on_consume, required_level, effect_duration)
    if not name or name == "" then
        core.log("error", "Potion name is invalid!")
        return
    end

    if #ingredients ~= 3 then
        core.log("error", "The potion " .. name .. " has an invalid number of ingredients. Must be 3.")
        return
    end

    local potion_item_name = "francomagicmod:" .. name:gsub("%s+", "_"):lower()
    table.insert(self.potions, {
        name = name,
        description = description,
        ingredients = ingredients,
        texture = texture,
        on_consume = on_consume,
        required_level = required_level
    })

    core.register_node(potion_item_name, {
        description = name .. " - " .. description,
        drawtype = "plantlike",
        tiles = {texture},
        inventory_image = texture,
        wield_image = texture,
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        buildable_to = false,
        floodable = false,
        selection_box = {
            type = "fixed",
            fixed = {-0.2, -0.5, -0.2, 0.2, 0.2, 0.2}
        },
        groups = {
            vessel = 1,
            snappy = 3,
            oddly_breakable_by_hand = 1
        },
        drop = potion_item_name,
        sounds = default.node_sound_glass_defaults(),
        stack_max = 1,
        on_use = function(itemstack, user)
            if not user or not user:is_player() then
                return itemstack
            end

            local player_name = user:get_player_name()

            if type(on_consume) ~= "function" then
                core.log("warning", "Potion : " .. potion_item_name .. " mal configurée.")
                return itemstack
            end

            if on_consume then
                on_consume(user)
            end
            if effect_duration and effect_duration > 0 then
                start_potion_timer(user, name, effect_duration)
            end
            itemstack:take_item()
            local inv = user:get_inventory()
            if inv then
                inv:add_item("main", "vessels:glass_bottle")
            end
            return itemstack
        end
    })

    -- Fumée sur le chaudron
    core.register_abm({
        nodenames = {"francomagicmod:cauldron_" .. name:gsub("%s+", "_"):lower()},
        interval = 0.5,
        chance = 1,
        action = function(pos, node)
            core.add_particlespawner({
                amount = 2,
                time = 2,
                minpos = {x=pos.x-0.1, y=pos.y, z=pos.z-0.1},
                maxpos = {x=pos.x+0.1, y=pos.y, z=pos.z+0.1},
                minvel = {x=0, y=0.5, z=0},
                maxvel = {x=0, y=0.6, z=0},
                minacc = {x=0, y=0.2, z=0},
                maxacc = {x=0, y=0.3, z=0},
                minexptime = 2,
                maxexptime = 3,
                minsize = 5,
                maxsize = 8,
                collisiondetection = false,
                texture = "francomagicmod_smoke.png"
            })
        end
    })

    core.register_node("francomagicmod:cauldron_" .. name:gsub("%s+", "_"):lower(), {
        description = "Cauldron with " .. name,
        tiles = {
            {name="francomagicmod_pot_"..name:gsub("%s+", "_"):lower()..".png", animation = {type="vertical_frames", length=3.0}},
            "francomagicmod_cauldron_bottom.png",
            "francomagicmod_cauldron_side.png",
            "francomagicmod_cauldron_side.png",
            "francomagicmod_cauldron_side.png",
            "francomagicmod_cauldron_side.png"
        },
        drawtype = "nodebox",
        paramtype = "light",
        node_box = {
            type = "fixed",
            fixed = {
                {-0.4375, -0.5, -0.4375, 0.4375, -0.4375, 0.4375},
                {-0.375, -0.4375, -0.375, 0.375, -0.375, 0.375},
                {-0.3125, -0.375, -0.3125, 0.3125, -0.3125, 0.3125},
                {-0.375, -0.3125, -0.375, 0.375, 0.5, 0.375},
                {-0.4375, -0.25, -0.4375, 0.4375, 0.3125, 0.4375},
                {-0.5, -0.1875, -0.5, 0.5, 0.3125, 0.5},
                {-0.4375, 0.375, -0.4375, 0.4375, 0.5, 0.4375},
            }
        },
        groups = {cracky = 2, not_in_creative_inventory = 1},
        drop = "francomagicmod:cauldron",
        on_load = function(pos)
            sync_fuel_state(pos)
        end,
        on_destruct = function(pos)
            meta_clear_spawners(core.get_meta(pos))
        end,
        after_dig_node = function(pos)
            reset_cauldron_meta(core.get_meta(pos))
        end,
        on_rightclick = cauldron_on_rightclick,
    })
end

function Potions:register_potion_2(name, description, texture, on_consume, base_name, conversion_time, effect_duration)
    if not name or name == "" then
        core.log("error", "Potion name is invalid !")
        return
    end

    local potion_item_name = "francomagicmod:" .. name:gsub("%s+", "_"):lower()

    if base_name and base_name ~= "" then
        local lvl1_item = "francomagicmod:" .. base_name:gsub("%s+", "_"):lower()
        self.upgrades[lvl1_item] = { target = potion_item_name, time = tonumber(conversion_time) or 120 }
    end

    core.register_node(potion_item_name, {
        description = name .. " - " .. description,
        drawtype = "plantlike",
        tiles = {texture .. "^[colorize:black:50"},
        wield_image = texture .. "^[colorize:black:50",
        inventory_image = texture .. "^[colorize:black:50",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        buildable_to = false,
        floodable = false,
        selection_box = {
            type = "fixed",
            fixed = {-0.2, -0.5, -0.2, 0.2, 0.2, 0.2}
        },
        groups = {
            vessel = 1,
            snappy = 3,
            oddly_breakable_by_hand = 1
        },
        drop = potion_item_name,
        sounds = default.node_sound_glass_defaults(),
        stack_max = 1,
        on_use = function(itemstack, user)
            if not user or not user:is_player() then
                return itemstack
            end

            local player_name = user:get_player_name()

            if type(on_consume) ~= "function" then
                core.chat_send_player(player_name,
                    "Erreur interne : potion mal configurée.")
                return itemstack
            end

            if on_consume then
                on_consume(user)
            end
            if effect_duration and effect_duration > 0 then
                start_potion_timer(user, name, effect_duration)
            end
            itemstack:take_item()
            local inv = user:get_inventory()
            if inv then
                inv:add_item("main", "vessels:glass_bottle")
            end
            return itemstack
        end
    })
end

local alambic_time_default = tonumber(core.settings:get("francomagic_alambic_time")) or 120

core.register_node("francomagicmod:alambic", {
    description = "Alambic",
    drawtype = "nodebox",
	use_texture_alpha = "blend",
	paramtype = "light",
    light_source = 5,
    paramtype2 = "facedir",
    node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, -0.4375, 0.25},
			{-0.0625, -0.5, -0.0625, 0.0625, 0, 0.0625},
			{-0.5, 0, -0.125, 0.5, 0.0625, 0.125},
			{-0.4375, -0.1875, -0.0625, -0.3125, 0.375, 0.0625},
			{0.3125, -0.1875, -0.0625, 0.4375, 0.375, 0.0625},
			{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125},
			{-0.1875, 0.125, -0.125, 0.1875, 0.375, 0.125},
			{-0.125, 0.125, -0.1875, 0.125, 0.375, 0.1875},
			{-0.0625, 0.375, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
    tiles = {
		"francomagicmod_brewing_stand_top.png",
		"francomagicmod_brewing_stand_top.png",
		"francomagicmod_brewing_stand_side.png",
		"francomagicmod_brewing_stand_side.png",
		"francomagicmod_brewing_stand_side.png",
		"francomagicmod_brewing_stand_side.png"
	},
    drop = {
		items = {
			{items = {"francomagicmod:alambic"}, rarity = 1},
		}
	},
    groups = {cracky = 2, oddly_breakable_by_hand = 1},
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("infotext", "Alambic")
        meta:set_string("processing", "false")
        meta:set_string("ready", "false")
        meta:set_int("time_left", 0)
        meta:set_string("result", "")
    end,

    can_dig = function(pos, player)
        local meta = core.get_meta(pos)
        return meta:get_string("processing") ~= "true" and meta:get_string("ready") ~= "true"
    end,

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then return itemstack end
        local pname = clicker:get_player_name()
        local meta = core.get_meta(pos)

        if itemstack:get_count() == 0 then
            if meta:get_string("processing") == "true" then
                core.chat_send_player(pname, "Temps restant: " .. meta:get_int("time_left") .. "s")
            elseif meta:get_string("ready") == "true" then
                core.chat_send_player(pname, "Utilisez clic gauche main vide pour récupérer")
            end
            return itemstack
        end

        local name = itemstack:get_name()
        local mapping = potion_manager.upgrades[name]
        if not mapping then
            core.chat_send_player(pname, "Cet item ne peut pas être transformé dans l'alambic")
            return itemstack
        end

        if meta:get_string("processing") == "true" then
            core.chat_send_player(pname, "Alambic déjà en utilisation")
            return itemstack
        end

        if get_level_witch(pname) < 6 then
            core.chat_send_player(pname, "Votre niveau de magie est insuffisant pour utiliser l'alambic")
            return itemstack
        end

        itemstack:take_item(1)
        meta:set_string("infotext", "Alambic (en cours)")
        meta:set_string("processing", "true")
        meta:set_string("ready", "false")
        meta:set_int("time_left", mapping.time or alambic_time_default)
        meta:set_string("result", mapping.target)
        core.get_node_timer(pos):start(1)
        return itemstack
    end,

    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then return end
        local pname = puncher:get_player_name()
        local meta = core.get_meta(pos)
        local wield = puncher:get_wielded_item()
        if wield:get_count() ~= 0 then
            return
        end
        if meta:get_string("ready") ~= "true" then
            if meta:get_string("processing") == "true" then
                core.chat_send_player(pname, "Temps restant: " .. meta:get_int("time_left") .. "s")
            end
            return
        end

        local result = meta:get_string("result")
        if result == "" then return end
        local inv = puncher:get_inventory()
        local leftover = nil
        if inv then
            leftover = inv:add_item("main", result)
        end
        if leftover and not leftover:is_empty() then
            local obj = core.add_item(pos, leftover)
            if obj then obj:set_velocity({x=0, y=2, z=0}) end
        end

        meta:set_string("processing", "false")
        meta:set_string("ready", "false")
        meta:set_int("time_left", 0)
        meta:set_string("result", "")
    end,
    on_timer = function(pos, elapsed)
        local meta = core.get_meta(pos)
        if meta:get_string("processing") ~= "true" then
            return false
        end
        core.add_particlespawner({
            amount = 6,
            time = 1,
            minpos = {
                x = pos.x - 0.1,
                y = pos.y + 0.35,
                z = pos.z - 0.1
            },
            maxpos = {
                x = pos.x + 0.1,
                y = pos.y + 0.45,
                z = pos.z + 0.1
            },
            minvel = {
                x = -0.05,
                y = 0.2,
                z = -0.05
            },
            maxvel = {
                x = 0.05,
                y = 0.5,
                z = 0.05
            },
            minacc = {
                x = 0,
                y = 0.05,
                z = 0
            },
            maxacc = {
                x = 0,
                y = 0.1,
                z = 0
            },
            minexptime = 1,
            maxexptime = 2,
            minsize = 2,
            maxsize = 4,
            texture = "magicalities_spark.png",
            glow = 4,
        })

        local t = meta:get_int("time_left")
        t = t - math.floor(elapsed)
        if t > 0 then
            meta:set_int("time_left", t)
            return true
        end
        meta:set_string("processing", "false")
        meta:set_string("ready", "true")
        meta:set_int("time_left", 0)
        core.get_node_timer(pos):stop()
        meta:set_string("infotext", "Alambic (prêt)")

        return false
    end,
})