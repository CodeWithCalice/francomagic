-- Magicalities
magicalities = {}

local modpath = core.get_modpath(core.get_current_modname())
magicalities.modpath = modpath

magicalities.elements = {
    -- Base Elements
    ["water"] = {color = "#003cff", description = "Water", inheritance = nil, miny = -20000, maxy = -20, block_spawn = {"default:sand", "default:stone"}, biomes = nil, rarity = 0.0002, spawn_by = "default:water_source"},
    ["earth"] = {color = "#00a213", description = "Earth", inheritance = nil, miny = -500, maxy = 0, block_spawn = "everness:moss_block", biomes = nil, rarity = 0.005, spawn_by = "air"},
    ["light"] = {color = "#ffffff", description = "Light", inheritance = nil, miny = 20000, maxy = 21000, block_spawn = "everness:crystal_leaves", biomes = nil, rarity = 0.01, spawn_by = "air"},
    ["fire"]  = {color = "#ff2424", description = "Fire",  inheritance = nil, miny = -31000, maxy = -2000, block_spawn = "everness:mineral_lava_stone", biomes = nil, rarity = 0.001, spawn_by = "air"},
    ["dark"]  = {color = "#232323", description = "Dark",  inheritance = nil, miny = 20000, maxy = 20500, block_spawn = {"default:stone_with_coal"}, biomes = nil, rarity = 0.001, spawn_by = "air"},
    ["air"]   = {color = "#ffff00", description = "Air",   inheritance = nil, miny = -20000, maxy = 1000, block_spawn = "everness:sulfur_stone", biomes = nil, rarity= 0.01, spawn_by = "air"}
}

-- Storage (complet)
dofile(modpath.."/storage.lua")

-- Crystals (complet)
dofile(modpath.."/crystals.lua")

-- Wands (complet)
dofile(modpath.."/wands.lua")

-- Wand focuses (complet)
dofile(modpath.."/focuses.lua")

-- Tables (complet)
dofile(modpath.."/table.lua")

-- Scanner (complet)
dofile(modpath.."/scanner.lua")

-- Book (complet)
dofile(modpath.."/book.lua")

-- Register (complet)
dofile(modpath.."/register.lua")

-- Items (complet)
dofile(modpath.."/items.lua")