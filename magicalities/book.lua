-- magicalities/book.lua

local core = core
local book_data = dofile(core.get_modpath("magicalities").."/book_content.lua")

-- Génération du formspec d'un chapitre
local function generate_book_formspec(player, chapter_id)
    local level = get_level_witch(player)
    local chapter = book_data.chapters[chapter_id]
    if not chapter then return "" end
    local content_lines = {}
    local sec_ids = {}
    for sec_id in pairs(chapter.sections) do
        table.insert(sec_ids, tonumber(sec_id))
    end
    table.sort(sec_ids)

    for _, sec_id in ipairs(sec_ids) do
        if sec_id <= level then
            local content = chapter.sections[tostring(sec_id)]
            if content then
                table.insert(content_lines, "<center>----- LVL "..sec_id.." -----</center>")
                table.insert(content_lines, "<center>" .. content .. "</center>\n")
            end
        end
    end

    local formspec =
        "size[8,8]" ..
        default.gui_bg ..
        default.gui_bg_img ..
        default.gui_slots ..

        "button[0,0;2,1;back;Back]"
        .. "hypertext[0.5,0.4;7,1.1;title;"
        .. core.formspec_escape("<center><big><b>" .. chapter.title .. "</b></big></center>")
        .. "]"

    formspec = formspec .. "hypertext[0.7,1.5;7.2,7;content;" .. core.formspec_escape(table.concat(content_lines, "\n")) .. "]"

    return formspec
end

local function open_book(player, chapter_id)
    local uname = player:get_player_name()
    local inv = player:get_inventory()
	local wi = player:get_wield_index()
	local stack = inv:get_stack("main", wi)
	local meta = stack:get_meta()
    meta:set_string("last_chapter", chapter_id) -- Sauvegarde de l'emplacement du joueur dans le livre
	inv:set_stack("main", wi, stack)
    core.show_formspec(uname, "magicalities:book",
        generate_book_formspec(player, chapter_id))
end

local function show_book_index(player)
    local uname = player:get_player_name()

    local formspec =
        "size[8,9]" ..
        default.gui_bg ..
        default.gui_bg_img ..
        default.gui_slots ..
        "button[3,0;2,1;quit_button;Back]"

    local positions = {
        [1] = {x = 0, y = 1},
        [2] = {x = 4, y = 1},
        [3] = {x = 0, y = 5},
        [4] = {x = 4, y = 5},
    }
    local chapter_ids = {}
    for ch_id in pairs(book_data.chapters) do
        table.insert(chapter_ids, tonumber(ch_id))
    end
    table.sort(chapter_ids)

    for i, ch_id in ipairs(chapter_ids) do
        local chapter = book_data.chapters[tostring(ch_id)]
        local pos = positions[i]

        if chapter and pos then
            formspec = formspec .. "image_button[" .. pos.x .. "," .. pos.y .. ";4,4;" .. chapter.image .. ";btn" .. ch_id .. ";]"
        end
    end

    local inv = player:get_inventory()
    local wi = player:get_wield_index()
    local stack = inv:get_stack("main", wi)
    local meta = stack:get_meta()
    meta:set_string("last_chapter", "")
    inv:set_stack("main", wi, stack)
    core.show_formspec(uname, "magicalities:book", formspec)
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "magicalities:book" then return end
    local inv = player:get_inventory()
    local stack = inv:get_stack("main", player:get_wield_index())
    local meta = stack:get_meta()

    if fields.back then
        show_book_index(player)
        return
    end

	if fields.quit_button then
		core.close_formspec(player:get_player_name(), "magicalities:book")
		return
	end

    for key,_ in pairs(fields) do
        local ch_id = key:match("^btn(%d+)$")
        if ch_id and book_data.chapters[ch_id] then
            open_book(player, ch_id)
            return
        end
    end
end)

core.register_craftitem("magicalities:book", {
    description = book_data.title,
    inventory_image = "magicalities_book.png",
    on_use = function(itemstack, player, pointed_thing)
        -- Réouvre le dernier chapitre
        local meta = itemstack:get_meta()
        local last = meta:get_string("last_chapter")
        if last and book_data.chapters[last] then
            open_book(player, last)
        else
            show_book_index(player)
        end
    end,
    stack_max = 1
})