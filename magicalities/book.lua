-- magicalities/book.lua

local book = dofile(core.get_modpath("magicalities") .. "/book_content.lua")
local FORMNAME = "magicalities:book"
local POS_KEY = "magicalities_book_pos"

local W, H = 8, 10

local TEXT_X = 0.55
local TEXT_Y = 0.45
local TEXT_W_TABS = 6.1
local TEXT_W_FULL = 6.5
local TEXT_H = 8.0

local TAB_X = 6.95
local TAB_W = 1.0
local TAB_H = 0.9
local TAB_TOP = 0.4
local TAB_BOTTOM = 9.3

local TAB_ICON_RATIO = 0.72
local TITLE_H = 0.8
local HEADER_SIZE = 2.0
local HEADER_GAP = 0.15

local BACK_X, BACK_Y = 5.25, 8.65
local BACK_W, BACK_H = 1.3, 0.95
local MENU_X, MENU_Y = 0.6, 1.7
local MENU_W, MENU_H = 5.6, 1.4
local MENU_STEP = 1.75
local MENU_ICON = 0.9
local TEXT_COLOR = "#2a1c0c"
local INCANT_COLOR = "#4a3313"

local function player_level(player)
	local lvl = 1

	if get_level_witch then
		local ok, res = pcall(get_level_witch, player:get_player_name())
		if ok then
			lvl = tonumber(res) or 1
		end
	end

	return math.max(1, lvl)
end

local function find_chapter(chapter_id)
	for _, chapter in ipairs(book.chapters) do
		if chapter.id == chapter_id then
			return chapter
		end
	end
end

local function visible_pages(chapter, lvl)
	local list = {}

	for index, page in ipairs(chapter.pages) do
		if (page.level or 1) <= lvl then
			table.insert(list, index)
		end
	end

	return list
end

local TAB_HITBOX = "[fill:1x1:#00000000"

local function add_tab(fs, x, y, w, h, page, name, fallback_label)
	if not page.tab_icon then
		table.insert(fs, "image_button[" .. x .. "," .. y .. ";" .. w .. "," .. h .. ";" .. book.tab_bg .. ";" .. name .. ";" .. (page.tab_label or fallback_label) .. ";false;false]")
		return
	end

	local size = math.min(w, h) * TAB_ICON_RATIO

	table.insert(fs, "image[" .. x .. "," .. y .. ";" .. w .. "," .. h .. ";" .. book.tab_bg .. "]")
	table.insert(fs, "image[" .. (x + (w - size) / 2) .. "," .. (y + (h - size) / 2) .. ";" .. size .. "," .. size .. ";" .. page.tab_icon .. "]")
	table.insert(fs, "image_button[" .. x .. "," .. y .. ";" .. w .. "," .. h .. ";" .. core.formspec_escape(TAB_HITBOX) .. ";" .. name .. ";;false;false]")
end

local function save_pos(player, pos)
	player:get_meta():set_string(POS_KEY, pos or "")
end

local function load_pos(player)
	return player:get_meta():get_string(POS_KEY)
end

local function page_hypertext(page, lvl)
	local out = {
		"<global color=" .. TEXT_COLOR .. " background=#00000000>",
	}

	for _, block in ipairs(page.blocks or {}) do
		if (block.level or page.level or 1) <= lvl then
			local line = ""

			if block.icon then
				line = "<img name=" .. block.icon .. " width=40 height=40 float=left>"
			end

			table.insert(out, line .. (block.text or ""))

			if block.incantation then
				table.insert(out, "")
				table.insert(out, "<style color=" .. INCANT_COLOR .. "><i><center>" .. block.incantation .. "</center></i></style>")
			end

			table.insert(out, "")
		end
	end

	return table.concat(out, "\n")
end

local function show_cover(player)
	save_pos(player, "cover")

	core.show_formspec(player:get_player_name(), FORMNAME,
		"formspec_version[6]"
		.. "size[" .. W .. "," .. H .. "]"
		.. "real_coordinates[true]"
		.. "bgcolor[#00000000;false]"
		.. "image_button[0,0;" .. W .. "," .. H .. ";" .. book.cover
		.. ";open;;false;false]"
	)
end

local function show_menu(player)
	save_pos(player, "menu")

	local fs = {
		"formspec_version[6]",
		"size[" .. W .. "," .. H .. "]",
		"real_coordinates[true]",
		"bgcolor[#00000000;false]",
		"image[0,0;" .. W .. "," .. H .. ";" .. book.page_bg .. "]",
		"style_type[label;font=bold;font_size=*1.4;textcolor=" .. TEXT_COLOR .. "]",
		"hypertext[" .. TEXT_X .. ",0.5;" .. TEXT_W_FULL .. ",1;title;"
		.. core.formspec_escape("<global color=" .. TEXT_COLOR
		.. " background=#00000000><center><big><b>"
		.. book.title .. "</b></big></center>") .. "]",
	}

	for i, chapter in ipairs(book.chapters) do
		local y = MENU_Y + (i - 1) * MENU_STEP

		table.insert(fs, "image_button[" .. MENU_X .. "," .. y .. ";" .. MENU_W .. "," .. MENU_H .. ";" .. book.frame_img .. ";chap_" .. chapter.id .. ";;false;false]")
		table.insert(fs, "image[" .. (MENU_X + 0.3) .. "," .. (y + (MENU_H - MENU_ICON) / 2) .. ";" .. MENU_ICON .. "," .. MENU_ICON .. ";" .. chapter.menu_icon .. "]")
		table.insert(fs, "label[" .. (MENU_X + 1.35) .. "," .. (y + MENU_H / 2) .. ";" .. core.formspec_escape(chapter.menu_title) .. "]")
	end

	core.show_formspec(player:get_player_name(), FORMNAME, table.concat(fs))
end

local function show_page(player, chapter_id, page_index)
	local chapter = find_chapter(chapter_id)
	if not chapter then
		return show_menu(player)
	end

	local lvl = player_level(player)
	local shown = visible_pages(chapter, lvl)

	if #shown == 0 then
		return show_menu(player)
	end

	local page = chapter.pages[page_index]
	if not page or (page.level or 1) > lvl then
		page_index = shown[1]
		page = chapter.pages[page_index]
	end

	save_pos(player, chapter_id .. ":" .. page_index)

	local with_tabs = #chapter.pages > 1
	local text_w = with_tabs and TEXT_W_TABS or TEXT_W_FULL

	local fs = {
		"formspec_version[6]",
		"size[" .. W .. "," .. H .. "]",
		"real_coordinates[true]",
		"bgcolor[#00000000;false]",
		"image[0,0;" .. W .. "," .. H .. ";" .. book.page_bg .. "]",
	}

	local y = TEXT_Y

	if page.title then
		table.insert(fs, "hypertext[" .. TEXT_X .. "," .. y .. ";" .. text_w .. "," .. TITLE_H .. ";title;" .. core.formspec_escape("<global color=" .. TEXT_COLOR .. " background=#00000000><center><big><b>" .. page.title .. "</b></big></center>") .. "]")
		y = y + TITLE_H
	end

	if page.header then
		table.insert(fs, "image[" .. (TEXT_X + (text_w - HEADER_SIZE) / 2) .. "," .. y .. ";" .. HEADER_SIZE .. "," .. HEADER_SIZE .. ";" .. page.header .. "]")
		y = y + HEADER_SIZE + HEADER_GAP
	end

	table.insert(fs, "hypertext[" .. TEXT_X .. "," .. y .. ";" .. text_w .. "," .. (TEXT_Y + TEXT_H - y) .. ";content;" .. core.formspec_escape(page_hypertext(page, lvl)) .. "]")

	if with_tabs then
		local count = #shown
		local span = TAB_BOTTOM - TAB_TOP
		local step = TAB_H

		if count > 1 then
			step = math.min(TAB_H, (span - TAB_H) / (count - 1))
		end

		local height = math.min(TAB_H, step)

		for slot, index in ipairs(shown) do
			local tab = chapter.pages[index]
			local y = TAB_TOP + (slot - 1) * step

			local x, w = TAB_X, TAB_W
			if index == page_index then
				x, w = TAB_X - 0.18, TAB_W + 0.18
			end

			add_tab(fs, x, y, w, height, tab, "tab_" .. index, tostring(index))
		end
	end

	table.insert(fs, "image_button[" .. BACK_X .. "," .. BACK_Y .. ";" .. BACK_W .. "," .. BACK_H .. ";" .. book.back_img .. ";back;;false;false]")
	core.show_formspec(player:get_player_name(), FORMNAME, table.concat(fs))
end

local function show_last(player)
	local pos = load_pos(player)

	if pos == "menu" then
		return show_menu(player)
	end

	local chapter_id, page_index = pos:match("^([%w_]+):(%d+)$")
	if chapter_id and find_chapter(chapter_id) then
		return show_page(player, chapter_id, tonumber(page_index))
	end

	return show_cover(player)
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then return end

	if fields.quit then
		return
	end

	if fields.open then
		show_menu(player)
		return true
	end

	if fields.back then
		show_menu(player)
		return true
	end

	for key in pairs(fields) do
		local chapter_id = key:match("^chap_([%w_]+)$")
		if chapter_id then
			local chapter = find_chapter(chapter_id)
			if chapter then
				local shown = visible_pages(chapter, player_level(player))
				show_page(player, chapter_id, shown[1] or 1)
				return true
			end
		end

		local page_index = key:match("^tab_(%d+)$")
		if page_index then
			local current = load_pos(player):match("^([%w_]+):%d+$")
			if current then
				show_page(player, current, tonumber(page_index))
				return true
			end
		end
	end
end)

core.register_craftitem("magicalities:book", {
	description = book.title,
	inventory_image = "magicalities_book.png",
	stack_max = 1,
	on_use = function(itemstack, player)
		if player and player:is_player() then
			show_last(player)
		end
		return itemstack
	end,
})
