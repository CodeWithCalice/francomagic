francomagicmod = {}
francomagicmod.modname = core.get_current_modname()
francomagicmod.modpath = core.get_modpath(francomagicmod.modname)

francomagicmod.has_magicalities = core.get_modpath("magicalities") ~= nil
francomagicmod.has_entity_modifier = core.get_modpath("entity_modifier") ~= nil

dofile(francomagicmod.modpath .. "/potions_manager.lua")
dofile(francomagicmod.modpath .. "/potions.lua")

core.log("action", "[francomagicmod] Loaded.")