-- potions.lua

local function RegisterPotion(name, name2, description, description2, ingredients, texture, effect_func, effect_func2, required_level, conversion_time2, effect_duration, effect_duration1)
    potion_manager:register_potion(name, description, ingredients, texture, effect_func, required_level, effect_duration)
    potion_manager:register_potion_2(name2, description2, texture, effect_func2, name, conversion_time2, effect_duration1)
end

-- Global Tables
local damage_protection = {}
local block_metamorphosis = {}
local jump_boost_players = {}
local small_potion_effect = {}
local big_potion_effect = {}
local rat_potion_effect  = {}
local growler_potion_effect  = {}
local DD_potion_effect = {}

-- Cancel Transformation Functions
-- Block to player
local function transform_block_to_normal(player)
    if not player or not player:is_player() then return end

    player:set_properties({
        visual = "mesh",
        mesh = (block_metamorphosis[player:get_player_name()] and block_metamorphosis[player:get_player_name()].mesh) or "character.b3d",
        textures = {(block_metamorphosis[player:get_player_name()] and block_metamorphosis[player:get_player_name()].texture) or "character.png"},
        collisionbox = {-0.45, 0, -0.45, 0.45,  1.7,  0.45},
        eye_height = 1.47,
    })
end

-- Small to player
local function transform_small_to_normal(player)
    if not player or not player:is_player() then return end
    entity_modifier.resize_player(player, 1)
end

-- Big to player
local function transform_big_to_normal(player)
    if not player or not player:is_player() then return end
    entity_modifier.resize_player(player, 1)
end

-- Rat to player
local function transform_rat_to_normal(player)
    if not player or not player:is_player() then return end

    local mesh = nil
    if core.get_modpath("3d_armor") then
        mesh = "3d_armor_character.b3d"
    end

    player:set_properties({
        visual = "mesh",
        visual_size = {x = 1, y = 1},
        mesh = mesh or "character.b3d",
        textures = {"character.png"},
        collisionbox = {-0.45, 0, -0.45, 0.45,  1.7,  0.45},
        eye_height = 1.47,
    })
end

-- Growler to player
local function transform_growler_to_normal(player)
    if not player or not player:is_player() then return end
    local name = player:get_player_name()

    player:set_properties({
        visual = "mesh",
        mesh = "character.b3d",
        textures = {(growler_potion_effect[name] and growler_potion_effect[name].texture) or "character.png"},
        collisionbox = (growler_potion_effect[name] and growler_potion_effect[name].collisionbox) or {-0.45, 0, -0.45, 0.45,  1.7,  0.45},
        eye_height = 1.47,
    })
    -- Enlever la vision nocturne
    player:override_day_night_ratio(nil)

    if growler_potion_effect[name] and growler_potion_effect[name].hud_filter then
        player:hud_remove(growler_potion_effect[name].hud_filter)
    end

    local privs = core.get_player_privs(name)
    privs.fly = false
    core.set_player_privs(name, privs)
end

-- 2D to player
local function transform_DD_to_normal(player)
    if not player or not player:is_player() then return end
    local name = player:get_player_name()

    player:set_properties({
        visual = "mesh",
        mesh = "character.b3d",
        collisionbox = (DD_potion_effect[name] and DD_potion_effect[name].collisionbox) or {-0.45, 0, -0.45, 0.45,  1.7,  0.45},
        eye_height = 1.47,
    })
end

local potions_name_effects = {
    "Elixir de Toph",
    "Elixir de Toph lvl 2",
    "Potion de Lutin",
    "Potion de Lutin lvl 2",
    "Potion de Geant",
    "Potion de Geant lvl 2",
    "Elixir de Rat",
    "Elixir de Rat lvl 2",
    "Elixir a Viaire",
    "Elixir a Viaire lvl 2",
    "Potion 2D",
    "Potion 2D lvl 2"
}

local function RemoveTransformationEffects(player)
    player:set_properties({
        collisionbox = {-0.45, 0, -0.45, 0.45,  1.7,  0.45},
        eye_height = 1.47,
    })
    transform_block_to_normal(player)
    block_metamorphosis[player] = nil
    transform_small_to_normal(player)
    small_potion_effect[player] = nil
    transform_big_to_normal(player)
    big_potion_effect[player] = nil
    transform_rat_to_normal(player)
    rat_potion_effect[player] = nil
    transform_growler_to_normal(player)
    growler_potion_effect[player] = nil
    transform_DD_to_normal(player)
    DD_potion_effect[player] = nil
    local pname = player:get_player_name()
    if active_potions and active_potions[pname] then
        for _, name in ipairs(potions_name_effects) do
            if active_potions[pname][name] then
                active_potions[pname][name] = nil
            end
        end
    end
end

-- Other potions

---------------------
--Protection Potion--
---------------------

-- Update du timer de protection
local timer = 0
core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < 1 then return end
    timer = 0

    for player_name, effect in pairs(damage_protection) do
        effect.time_left = effect.time_left - 1

        if effect.time_left <= 0 then
            damage_protection[player_name] = nil
        end
    end
end)
-- Annulation des dégâts si le joueur est protégé
core.register_on_player_hpchange(function(player, hp_change, reason)
    if not player or not player:is_player() then
        return hp_change
    end

    local player_name = player:get_player_name()

    if damage_protection[player_name] then
        return 0
    end

    return hp_change
end, true)
-- Annulation de la potion si le joueur attaque quelqu'un
core.register_on_punchplayer(function(player, hitter)
    if not hitter or not hitter:is_player() then
        return false
    end

    local hitter_name = hitter:get_player_name()

    if damage_protection[hitter_name] then
        damage_protection[hitter_name] = nil
        core.chat_send_player(hitter_name, "Votre protection disparaît lorsque vous attaquez.")
    end

    return false
end)
-- Nettoyage à la deconnexion
core.register_on_leaveplayer(function(player)
    if not player or not player:is_player() then return end
    damage_protection[player:get_player_name()] = nil
end)

--lvl 1
local function damage_protection_effect(user)
    if not user or not user:is_player() then return end

    local player_name = user:get_player_name()

    -- Application ou rafraichissement de la protection
    damage_protection[player_name] = {
        time_left = 10 -- 10 secondes pour le lvl 1
    }

    core.chat_send_player(player_name, "Vous êtes protégé contre les dégâts pendant 10 secondes.")
end

--lvl 2
local function damage_protection_effect_lv2(user)
    if not user or not user:is_player() then return end

    local player_name = user:get_player_name()

    -- Application ou rafraichissement de la protection
    damage_protection[player_name] = {
        time_left = 30 -- 30 secondes pour le lvl 2
    }

    core.chat_send_player(player_name, "Vous êtes protégé contre les dégâts pendant 30 secondes.")
end

-- Enregistrement des deux potions
RegisterPotion(
    "Potion de Protection",
    "Potion de Protection lvl 2",
    "Protege l'utilisateur des degats",
    "Protege l'utilisateur des degats",
    {"technic:lead_lump", "xocean:brain_skeleton", "mobs:hairball"},
    "francomagicmod_potion_grey.png",
    damage_protection_effect,
    damage_protection_effect_lv2,
    3,
    90,
    10,
    30
)

-----------------------
--Block Metamorphosis--
-----------------------

-- Transformation en bloc
local function transform_player_to_block(player)
    if not player or not player:is_player() then return end
    RemoveTransformationEffects(player)
    local pos = player:get_pos()
    if not pos then return end
    local props = player:get_properties()
    if not props or not props.textures then return nil end
    local name = player:get_player_name()
    block_metamorphosis[name] = block_metamorphosis[name] or {}
    block_metamorphosis[name].mesh = props.mesh or "character.b3d"
    block_metamorphosis[name].texture = props.textures[1] or "character.png"

    player:set_properties({
        visual = "cube",
        visual_size = {x = 1, y = 1},
        textures = {
            "default_grass.png",
            "default_dirt.png",
            "default_dirt.png^default_grass_side.png",
            "default_dirt.png^default_grass_side.png",
            "default_dirt.png^default_grass_side.png",
            "default_dirt.png^default_grass_side.png",
        },
        collisionbox = {-0.5, -0.5, -0.5, 0.4, 0.4, 0.4},
        stepheight = 0.95,
        eye_height = 0.3,
    })
    -- Eviter les glitchs dans le sol
    player:set_pos({x = pos.x, y = pos.y + 1, z = pos.z})
end

-- Update du timer de la potion
local meta_timer = 0
core.register_globalstep(function(dtime)
    meta_timer = meta_timer + dtime
    if meta_timer < 1 then return end
    meta_timer = 0

    for player_name, effect in pairs(block_metamorphosis) do
        effect.time_left = effect.time_left - 1

        if effect.time_left <= 0 then
            local player = core.get_player_by_name(player_name)
            if player then
                transform_block_to_normal(player)
            end
            block_metamorphosis[player_name] = nil
        end
    end
end)
-- Nettoyage à la déconnexion
core.register_on_leaveplayer(function(player)
    if not player or not player:is_player() then return end

    local name = player:get_player_name()
    if block_metamorphosis[name] then
        transform_block_to_normal(player)
        block_metamorphosis[name] = nil
    end
end)

-- lvl 1
local function metamorphosis_effect(user)
    if not user or not user:is_player() then return end
    local name = user:get_player_name()

    if block_metamorphosis[name] then
        return
    end

    block_metamorphosis[name] = {
        time_left = 60
    }

    transform_player_to_block(user)
    core.chat_send_player(name, "Vous êtes transformé en bloc pendant 60 secondes.")
end
-- lvl 2
local function metamorphosis_effect_lv2(user)
    if not user or not user:is_player() then return end
    local name = user:get_player_name()

    block_metamorphosis[name] = {
        time_left = 180
    }

    transform_player_to_block(user)
    core.chat_send_player(name, "Vous êtes transformé en bloc pendant 3 minutes.")
end

RegisterPotion(
    "Elixir de Toph",
    "Elixir de Toph lvl 2",
    "Transforme l'utilisateur en bloc de gazon",
    "Transforme l'utilisateur en bloc de gazon",
    {"default:clay_lump", "default:marram_grass_1", "forgotten_monsters:hungry_sheet"},
    "francomagicmod_potion_green.png",
    metamorphosis_effect,
    metamorphosis_effect_lv2,
    3,
    90,
    60,
    180
)

---------------
--Fast Potion--
---------------

-- Application de l'effet de vitesse
local function speed_boost_apply(player)
    local phys = player:get_physics_override()
    local original_speed = phys.speed or 1
    local original_jump = phys.jump or 1
    local original_gravity = phys.gravity or 1
    player:set_physics_override({
        speed = original_speed * 1.5,
        jump = original_jump,
        gravity = original_gravity
    })
    return {original_speed = original_speed, original_jump = original_jump, original_gravity = original_gravity}
end
-- Annulation de l'effet de vitesse
local function speed_boost_cancel(effect, player)
    if effect.metadata then
        player:set_physics_override({
            speed = effect.metadata.original_speed or 1,
            jump = effect.metadata.original_jump or 1,
            gravity = effect.metadata.original_gravity or 1
        })
    end
end

-- Enregistrer l'effet
playereffects.register_effect_type(
    "speed_boost_lvl1",
    "Vitesse +50%",
    "default_steel_ingot.png",
    {"speed"},
    speed_boost_apply,
    speed_boost_cancel,
    true,
    true
)

-- Meme fonction pour le lvl 2
local function speed_boost_apply(player)
    local phys = player:get_physics_override()
    local original_speed = phys.speed or 1
    local original_jump = phys.jump or 1
    local original_gravity = phys.gravity or 1
    player:set_physics_override({
        speed = original_speed * 2,
        jump = original_jump,
        gravity = original_gravity
    })
    return {original_speed = original_speed, original_jump = original_jump, original_gravity = original_gravity}
end

playereffects.register_effect_type(
    "speed_boost_lvl2",
    "Vitesse +100%",
    "default_steel_ingot.png",
    {"speed"},
    speed_boost_apply,
    speed_boost_cancel,
    true,
    true
)


-- Lvl 1
local function fast_potion_effect(user)
	playereffects.apply_effect_type("speed_boost_lvl1", 30, user)
    local itemstack = user:get_wielded_item()
	return itemstack
end

-- Lvl 2
local function fast_potion_effect_lv2(user)
    playereffects.apply_effect_type("speed_boost_lvl2", 120, user)
    local itemstack = user:get_wielded_item()
    return itemstack
end

RegisterPotion(
    "Potion de Rapidite",
    "Potion de Rapidite lvl 2",
    "Augmente la vitesse de déplacement",
    "Augmente la vitesse de déplacement",
    {"default:mese_crystal", "farming:mint_leaf", "mobs:rabbit_hide"},
    "francomagicmod_potion_magenta.png",
    fast_potion_effect,
    fast_potion_effect_lv2,
    3,
    90,
    30,
    120
)

---------------
--Mana Potion--
---------------

-- Lvl 1
local function mana_potion_effect(user)
    local success = mana.set(user:get_player_name(), mana.get(user:get_player_name()) + 100)
    local itemstack = user:get_wielded_item()
    core.chat_send_player(user:get_player_name(), core.colorize("#00FF00", "+100 mana"))
    return itemstack
end

-- Lvl 2
local function mana_potion_effect_lv2(user)
    local success = mana.set(user:get_player_name(), mana.get(user:get_player_name()) + 200)
    local itemstack = user:get_wielded_item()
    core.chat_send_player(user:get_player_name(), core.colorize("#00FF00", "+200 mana"))
    return itemstack
end

RegisterPotion(
    "Potion de Mana",
    "Potion de Mana lvl 2",
    "Regenere le mana",
    "Regenere le mana",
    {"everness:pyrite_lump", "farming:coffee_beans", "mobs:honey"},
    "francomagicmod_potion_darkpurple.png",
    mana_potion_effect,
    mana_potion_effect_lv2,
    3,
    90,
    0,
    0
)

----------------
--Tasty Potion--
----------------

-- Lvl 1
local function tasty_potion_effect(user)
    user:set_hp(user:get_hp() + 10) -- +10 HP
    local itemstack = user:get_wielded_item()
    core.chat_send_player(user:get_player_name(), core.colorize("#FF0000", "+10 HP"))
    return itemstack
end

-- Lvl 2
local function tasty_potion_effect_lv2(user)
    user:set_hp(user:get_hp() + 20) -- +20 HP
    local itemstack = user:get_wielded_item()
    core.chat_send_player(user:get_player_name(), core.colorize("#FF0000", "+20 HP"))
    return itemstack
end

RegisterPotion(
    "Potion de Vie",
    "Potion de Vie lvl 2",
    "Regenere la vie",
    "Regenere la vie",
    {"default:iron_lump", "farming:carrot", "mobs:egg"},
    "francomagicmod_potion_red.png",
    tasty_potion_effect,
    tasty_potion_effect_lv2,
    2,
    90,
    0,
    0
)

---------------------
--Resistance au feu--
---------------------

-- Fonction nécessaire pour playereffects mais sans actions
local function fire_resist_apply(player)
    return {}
end

local function fire_resist_cancel(effect, player)
    return {}
end

playereffects.register_effect_type(
    "fire_resist_lvl1",
    "Résistance au feu",
    "default_steel_ingot.png",
    {"fire"},
    fire_resist_apply,
    fire_resist_cancel,
    true,
    true
)

playereffects.register_effect_type(
    "fire_resist_lvl2",
    "Résistance au feu ++",
    "default_steel_ingot.png",
    {"fire"},
    fire_resist_apply,
    fire_resist_cancel,
    true,
    true
)

-- lvl 1
local function fire_resist_potion_effect(user)
    playereffects.apply_effect_type("fire_resist_lvl1", 60, user) -- 60 secondes
    local itemstack = user:get_wielded_item()
    return itemstack
end

-- lvl 2
local function fire_resist_potion_effect_lv2(user)
    playereffects.apply_effect_type("fire_resist_lvl2", 180, user) -- 3 minutes
    local itemstack = user:get_wielded_item()
    return itemstack
end

-- Bloquer les dégâts de feu si le joueur a l'effet actif
core.register_on_player_hpchange(function(player, hp_change, reason)
    -- basic flame/permanent flame/lava source/lava flowing
    if reason.type == "node_damage" and (reason.node == "default:lava_source" or reason.node == "fire:basic_flame" or reason.node == "fire:permanent_flame" or reason.node == "default:lava_flowing") and playereffects.has_effect_type(player:get_player_name(), "fire_resist_lvl1") then
        return 0 -- annule les dégâts
    end
    if reason.type == "node_damage" and (reason.node == "default:lava_source" or reason.node == "fire:basic_flame" or reason.node == "fire:permanent_flame" or reason.node == "default:lava_flowing") and playereffects.has_effect_type(player:get_player_name(), "fire_resist_lvl2") then
        return 0 -- annule les dégâts
    end
    return hp_change
end, true)

RegisterPotion(
    "Potion Thermique",
    "Potion Thermique lvl 2",
    "Protege de tous les degats de feu",
    "Protege de tous les degats de feu",
    {"technic:sulfur_lump", "everness:ngrass_2", "mobs:leather"},
    "francomagicmod_potion_yellow.png",
    fire_resist_potion_effect,
    fire_resist_potion_effect_lv2,
    3,
    90,
    60,
    180
)

------------------
--Potion de saut--
------------------


-- Application de l'effet de saut
local function jump_boost_apply(level)
    return function(player)
        local phys = player:get_physics_override()
        local original_speed = phys.speed or 1
        local original_jump = phys.jump or 1
        local original_gravity = phys.gravity or 1

        local jump_value = 2 -- niveau 1 = ~4 blocs
        if level == 2 then
            jump_value = 2.8 -- niveau 2 = ~8 blocs
        end

        player:set_physics_override({
            speed = original_speed,
            jump = jump_value,
            gravity = original_gravity
        })

        jump_boost_players[player:get_player_name()] = true

        return {
            original_speed = original_speed,
            original_jump = original_jump,
            original_gravity = original_gravity
        }
    end
end

-- Annulation de l'effet de saut
local function jump_boost_cancel(effect, player)
    if effect.metadata then
        player:set_physics_override({
            speed = effect.metadata.original_speed or 1,
            jump = effect.metadata.original_jump or 1,
            gravity = effect.metadata.original_gravity or 1
        })
    end
    jump_boost_players[player:get_player_name()] = nil
end

playereffects.register_effect_type(
    "jump_boost_lvl1",
    "Saut +4 blocs",
    "default:diamond.png",
    {"jump"},
    jump_boost_apply(1),
    jump_boost_cancel,
    true,
    true
)

playereffects.register_effect_type(
    "jump_boost_lvl2",
    "Saut +8 blocs",
    "default:diamond.png",
    {"jump"},
    jump_boost_apply(2),
    jump_boost_cancel,
    true,
    true
)

local function jump_potion_effect(user)
    playereffects.apply_effect_type("jump_boost_lvl1", 30, user)
    local itemstack = user:get_wielded_item()
    return itemstack
end

local function jump_potion_effect_lv2(user)
    playereffects.apply_effect_type("jump_boost_lvl2", 120, user)
    local itemstack = user:get_wielded_item()
    return itemstack
end

RegisterPotion(
    "Potion Apesanteur",
    "Potion Apesanteur lvl 2",
    "Reduit l'apesanteur",
    "Reduit l'apesanteur",
    {"moreores:silver_lump", "farming:hemp_leaf", "mobs:chicken_feather"},
    "francomagicmod_potion_silver.png",
    jump_potion_effect,
    jump_potion_effect_lv2,
    3,
    90,
    30,
    120
)

core.register_on_player_hpchange(function(player, hp_change, reason)
    if reason.type == "fall" and jump_boost_players[player:get_player_name()] then
        return 0 -- annule les dégâts
    end
    return hp_change
end, true)

----------------
--Potion Small--
----------------

-- Reduction de la taille
local function transform_player_small(player)
    if not player or not player:is_player() then return end
    RemoveTransformationEffects(player)
    entity_modifier.resize_player(player, 0.5)
end



-- Application de la potion lvl 1
local function small_potion_effect_lv1(user)
    local name = user:get_player_name()
    local itemstack = user:get_wielded_item()
    if small_potion_effect[name] then
        small_potion_effect[name].time_left = 30 -- rafraichit le timer si déjà actif
        return itemstack
    end

    small_potion_effect[name] = {time_left = 30}
    transform_player_small(user)
    return itemstack
end

-- Application de la potion lvl 2
local function small_potion_effect_lv2(user)
    local name = user:get_player_name()
    local itemstack = user:get_wielded_item()
    if small_potion_effect[name] then
        small_potion_effect[name].time_left = 120 -- rafraichit le timer si déjà actif
        return itemstack
    end

    small_potion_effect[name] = {time_left = 120}
    transform_player_small(user)
    return itemstack
end

-- Gestion du timer restant
local small_global_timer = 0
core.register_globalstep(function(dtime)
    small_global_timer = small_global_timer + dtime
    if small_global_timer < 1 then return end
    small_global_timer = 0

    for player_name, effect in pairs(small_potion_effect) do
        effect.time_left = effect.time_left - 1

        if effect.time_left <= 0 then
            local player = core.get_player_by_name(player_name)
            if player then
                transform_small_to_normal(player)
            end
            small_potion_effect[player_name] = nil
        end
    end
end)

-- Nettoyage à la déconnexion
core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if small_potion_effect[name] then
        transform_small_to_normal(player)
        small_potion_effect[name] = nil
    end
end)

RegisterPotion(
    "Potion de Lutin",
    "Potion de Lutin lvl 2",
    "Rapetisse l'utilisateur",
    "Rapetisse l'utilisateur",
    {"technic:tin_dust", "flowers:mushroom_red", "mobs:rat_cooked"},
    "francomagicmod_potion_blue2.png",
    small_potion_effect_lv1,
    small_potion_effect_lv2,
    3,
    90,
    30,
    120
)

--------------
--Potion Big--
--------------

local function jump_big_apply(level)
    return function(player)
        local phys = player:get_physics_override()
        local original_speed = phys.speed or 1
        local original_jump = phys.jump or 1
        local original_gravity = phys.gravity or 1

        local jump_value = 1.7 -- niveau 1 = ~3 blocs
        if level == 2 then
            jump_value = 2.4 -- niveau 2 = ~5 blocs
        end

        player:set_physics_override({
            speed = original_speed,
            jump = jump_value,
            gravity = original_gravity
        })

        jump_boost_players[player:get_player_name()] = true

        return {
            original_speed = original_speed,
            original_jump = original_jump,
            original_gravity = original_gravity
        }
    end
end

-- Annulation de l'effet de saut
local function jump_big_cancel(effect, player)
    if effect.metadata then
        player:set_physics_override({
            speed = effect.metadata.original_speed or 1,
            jump = effect.metadata.original_jump or 1,
            gravity = effect.metadata.original_gravity or 1
        })
    end
    jump_boost_players[player:get_player_name()] = nil
end

playereffects.register_effect_type(
    "jump_big_1",
    "Saut +3 blocs",
    "default:diamond.png",
    {"jump"},
    jump_big_apply(1),
    jump_big_cancel,
    true,
    true
)

playereffects.register_effect_type(
    "jump_big_2",
    "Saut +5 blocs",
    "default:diamond.png",
    {"jump"},
    jump_big_apply(2),
    jump_big_cancel,
    true,
    true
)


-- Augmente la taille (10 blocs)
local function transform_player_big(player, lvl)
    if not player or not player:is_player() then return end
    RemoveTransformationEffects(player)
    if lvl == 1 then
        entity_modifier.resize_player(player, 2.9)
    elseif lvl == 2 then
        entity_modifier.resize_player(player, 5.8)
    end
end

-- Application de la potion lvl 1
local function big_potion_effect_lv1(user)
    local name = user:get_player_name()
    local itemstack = user:get_wielded_item()

    big_potion_effect[name] = {time_left = 30}
    transform_player_big(user, 1)
    playereffects.apply_effect_type("jump_big_1", 30, user)
    return itemstack
end

-- Application de la potion lvl 2
local function big_potion_effect_lv2(user)
    local name = user:get_player_name()
    local itemstack = user:get_wielded_item()

    big_potion_effect[name] = {time_left = 120}
    transform_player_big(user, 2)
    playereffects.apply_effect_type("jump_big_2", 120, user)
    return itemstack
end

-- Gestion du timer restant
local big_global_timer = 0
core.register_globalstep(function(dtime)
    big_global_timer = big_global_timer + dtime
    if big_global_timer < 1 then return end
    big_global_timer = 0

    for player_name, effect in pairs(big_potion_effect) do
        effect.time_left = effect.time_left - 1

        if effect.time_left <= 0 then
            local player = core.get_player_by_name(player_name)
            if player then
                transform_big_to_normal(player)
            end
            big_potion_effect[player_name] = nil
        end
    end
end)

-- Nettoyage à la déconnexion
core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if big_potion_effect[name] then
        transform_big_to_normal(player)
        big_potion_effect[name] = nil
    end
end)

core.register_on_joinplayer(function(player)
    playereffects.cancel_effect_group("jump", player:get_player_name())
end)

RegisterPotion(
    "Potion de Geant",
    "Potion de Geant lvl 2",
    "Aggrandit l'utilisateur",
    "Aggrandit l'utilisateur",
    {"default:tinblock", "farming:cookie", "mobs_add:elephantcorpse"},
    "francomagicmod_potion_brown.png",
    big_potion_effect_lv1,
    big_potion_effect_lv2,
    3,
    90,
    30,
    120
)

----------------------
--Rat Transformation--
----------------------


local function transform_player_rat(player)
    if not player or not player:is_player() then return end
    RemoveTransformationEffects(player)
    local props = player:get_properties()
    if not props or not props.textures then return nil end
    rat_potion_effect[player:get_player_name()].collisionbox = props.collisionbox or {-0.45, 0, -0.45, 0.45,  1.7,  0.45}
    rat_potion_effect[player:get_player_name()].texture = props.textures[1] or "character.png"

    player:set_properties({
        visual = "mesh",
        visual_size = {x = 1, y = 1},
        mesh = "mobs_rat.b3d",
        textures = {"mobs_rat.png", "mobs_rat2.png", "mobs_rat3.png"},
        collisionbox = {-0.2, -1, -0.2, 0.2, -0.8, 0.2},
        eye_height = -0.6,
    })
    local pos = player:get_pos()
    pos.y = pos.y + 1
    player:set_pos(pos)
end

local function rat_potion_effect_lv1(user)
    local name = user:get_player_name()
    local itemstack = user:get_wielded_item()

    if rat_potion_effect[name] then
        rat_potion_effect[name].time_left = 60
        return itemstack
    end

    rat_potion_effect[name] = {time_left = 60}
    transform_player_rat(user)

    core.chat_send_player(name, "Vous êtes transformé en mouton pendant 1 minute.")
    return itemstack
end

local function rat_potion_effect_lv2(user)
    local name = user:get_player_name()
    local itemstack = user:get_wielded_item()

    if rat_potion_effect[name] then
        rat_potion_effect[name].time_left = 180
        return itemstack
    end

    rat_potion_effect[name] = {time_left = 180}
    transform_player_rat(user)

    core.chat_send_player(name, "Vous êtes transformé en mouton pendant 3 minutes.")
    return itemstack
end

local rat_global_timer = 0
core.register_globalstep(function(dtime)
    rat_global_timer = rat_global_timer + dtime
    if rat_global_timer < 1 then return end
    rat_global_timer = 0

    for player_name, effect in pairs(rat_potion_effect) do
        effect.time_left = effect.time_left - 1

        if effect.time_left <= 0 then
            local player = core.get_player_by_name(player_name)
            rat_potion_effect[player_name] = nil
            if player then
                transform_rat_to_normal(player)
                core.after(0.1, function()
                    local p = core.get_player_by_name(player_name)
                    if not p then return end
                    if armor and armor.textures then
                        if not armor.textures[player_name] then
                            armor.textures[player_name] = {}
                        end
                        armor.textures[player_name].skin = armor:get_player_skin(player_name)
                        armor.textures[player_name].armor = "blank.png"
                        armor.textures[player_name].wielditem = "blank.png"
                    end
                    if armor and armor.set_player_armor then
                        armor:set_player_armor(p)
                    end
                end)
            end
        end
    end
end)

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()

    if rat_potion_effect[name] then
        rat_potion_effect[name] = nil
        transform_rat_to_normal(player)
        if armor and armor.update_player_visuals then
            armor:update_player_visuals(player)
        end
    end
end)

if core.get_modpath("mobs_animal") then
    RegisterPotion(
        "Elixir de Rat",
        "Elixir de Rat lvl 2",
        "Transforme l'utilisateur en rat",
        "Transforme l'utilisateur en rat",
        {"skullkingsitems:bone", "wool:white", "mobs:mutton_raw"},
        "francomagicmod_potion_gold.png",
        rat_potion_effect_lv1,
        rat_potion_effect_lv2,
        3,
        90,
        60,
        180
    )
end

local old_set_textures = player_api.set_textures
player_api.set_textures = function(player, textures)
	local name = player:get_player_name()
	if rat_potion_effect and rat_potion_effect[name] then
		return
	end
	return old_set_textures(player, textures)
end

local old_set_texture = player_api.set_texture
player_api.set_texture = function(player, index, texture)
	local name = player:get_player_name()
	if rat_potion_effect and rat_potion_effect[name] then
		return
	end
	return old_set_texture(player, index, texture)
end

--------------------------
--Growler Transformation--
--------------------------


local function transform_player_growler(player)
    if not player or not player:is_player() then return end
    RemoveTransformationEffects(player)
    local name = player:get_player_name()
    growler_potion_effect[name] = growler_potion_effect[name] or {}
    growler_potion_effect[name].collisionbox = player:get_properties().collisionbox
    growler_potion_effect[name].texture = player:get_properties().texture
    growler_potion_effect[name].visual_size = player:get_properties().visual_size

    player:set_properties({
        visual = "mesh",
        mesh = "potion_growler.b3d",
        textures = {"potion_growler.png",},
        collisionbox = {-0.6, 0, -0.6, 0.6, 1.2, 0.6},
        eye_height = 0.3,
    })
    -- Vision nocturne
    player:override_day_night_ratio(1)

    local id = player:hud_add({
        hud_elem_type = "image",
        position = {x=0.5, y=0.5},
        scale = {x=-100, y=-100}, -- plein écran
        text = "bw_filter.png", -- texture noir/blanc
        alignment = {x=0, y=0},
    })
    growler_potion_effect[name].hud_filter = id

    -- Donner la capactié de voler
    local privs = core.get_player_privs(name)
    privs.fly = true
    core.set_player_privs(name, privs)
end

local function growler_potion_effect_lv1(user)
    local name = user:get_player_name()
    local itemstack = user:get_wielded_item()
    if growler_potion_effect[name] then
        growler_potion_effect[name].time_left = 60
        return itemstack
    end

    growler_potion_effect[name] = {time_left = 60}
    transform_player_growler(user)

    core.chat_send_player(name, "Vous êtes transformé en growler pendant 1 minute.")
    return itemstack
end

local function growler_potion_effect_lv2(user)
    local name = user:get_player_name()
    local itemstack = user:get_wielded_item()
    if growler_potion_effect[name] then
        growler_potion_effect[name].time_left = 180
        return itemstack
    end

    growler_potion_effect[name] = {time_left = 180}
    transform_player_growler(user)

    core.chat_send_player(name, "Vous êtes transformé en growler pendant 3 minutes.")
    return itemstack
end

local growler_global_timer = 0
core.register_globalstep(function(dtime)
    growler_global_timer = growler_global_timer + dtime
    if growler_global_timer < 1 then return end
    growler_global_timer = 0
    for player_name, effect in pairs(growler_potion_effect) do
        effect.time_left = effect.time_left - 1

        if effect.time_left <= 0 then
            local player = core.get_player_by_name(player_name)
            if player then
                transform_growler_to_normal(player)
            end
            growler_potion_effect[player_name] = nil
        end
    end
end)

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()

    if growler_potion_effect[name] then
        transform_growler_to_normal(player)
        growler_potion_effect[name] = nil
    end
    -- Sécurité pour retirer le vol
    local privs = core.get_player_privs(name)
    privs.fly = false
    core.set_player_privs(name, privs)
end)

if core.get_modpath("forgotten_monsters") then
    RegisterPotion(
        "Elixir a Viaire",
        "Elixir a Viaire lvl 2",
        "Transforme l'utilisateur en growler",
        "Transforme l'utilisateur en growler",
        {"default:diamond", "butterflies:butterfly_white", "growler:growler_meat_raw"},
        "francomagicmod_potion_cyan.png",
        growler_potion_effect_lv1,
        growler_potion_effect_lv2,
        3,
        90,
        60,
        180
    )
end

---------------------
--2D Transformation--
---------------------

local function transform_player_DD(player)
    if not player or not player:is_player() then return end
    RemoveTransformationEffects(player)
    local name = player:get_player_name()

    DD_potion_effect[name].collisionbox = player:get_properties().collisionbox
    DD_potion_effect[name].visual_size = player:get_properties().visual_size

    player:set_properties({
        visual = "mesh",
        mesh = "2D_player.obj",
        collisionbox = {-0.1, 0, -0.1, 0.1, 1.2, 0.1},
        eye_height = 1.7,
    })
end

local function DD_potion_effect_lv1(user)
    local name = user:get_player_name()
    local itemstack = user:get_wielded_item()

    if DD_potion_effect[name] then
        DD_potion_effect[name].time_left = 60
        return itemstack
    end

    DD_potion_effect[name] = {time_left = 60}
    transform_player_DD(user)

    core.chat_send_player(name, "Vous êtes en 2D pendant 1 minute.")
    return itemstack
end

local function DD_potion_effect_lv2(user)
    local name = user:get_player_name()
    local itemstack = user:get_wielded_item()

    if DD_potion_effect[name] then
        DD_potion_effect[name].time_left = 180
        return itemstack
    end

    DD_potion_effect[name] = {time_left = 180}
    transform_player_DD(user)

    core.chat_send_player(name, "Vous êtes en 2D pendant 3 minutes.")
    return itemstack
end

local DD_global_timer = 0
core.register_globalstep(function(dtime)
    DD_global_timer = DD_global_timer + dtime
    if DD_global_timer < 1 then return end
    DD_global_timer = 0

    for player_name, effect in pairs(DD_potion_effect) do
        effect.time_left = effect.time_left - 1

        if effect.time_left <= 0 then
            local player = core.get_player_by_name(player_name)
            if player then
                transform_DD_to_normal(player)
            end
            DD_potion_effect[player_name] = nil
        end
    end
end)

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if DD_potion_effect[name] then
        transform_growler_to_normal(player)
        DD_potion_effect[name] = nil
    end
end)

RegisterPotion(
    "Potion 2D",
    "Potion 2D lvl 2",
    "Transforme l'utilisateur en 2D",
    "Transforme l'utilisateur en 2D",
    {"default:coal", "butterflies:butterfly_white", "growler:growler_meat_raw"},
    "francomagicmod_potion_white.png",
    DD_potion_effect_lv1,
    DD_potion_effect_lv2,
    3,
    90,
    60,
    180
)