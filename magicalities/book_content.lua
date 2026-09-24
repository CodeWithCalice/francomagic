-- book_content.lua
--
-- Structure:
-- chapitres  -> pages  -> blocs
--
-- Un chapitre = un bouton du sommaire.
--   id         identifiant interne, ne pas changer (sert à retenir la page)
--   menu_title texte affiché sur le bouton du sommaire
--   menu_icon  image affichée sur le bouton du sommaire
--   pages      liste des pages, dans l'ordre des onglets
--
-- Une page = un onglet sur le bord droit.
--   level      niveau de mage minimum pour que l'onglet apparaisse
--   tab_label  texte inscrit sur l'onglet (sur le parchemin d'onglet)
--   tab_icon   ou image utilisée comme onglet, à la place du parchemin
--   title      titre affiché en haut de la page (optionnel)
--   header     grande image affichée sous le titre (optionnel)
--   blocks     liste des blocs de la page
--
-- Un bloc = un paragraphe.
--   level        niveau minimum pour voir ce bloc (par défaut celui de la page)
--   icon         petite image à gauche du paragraphe (optionnel)
--   text         le paragraphe
--   incantation  l'énigme de recette, affichée en italique (optionnel)
--
-- Pour ajouter une page : ajouter une entrée dans "pages".
-- Pour ajouter un paragraphe : ajouter une entrée dans "blocks".
-- Les onglets, la navigation et le bouton retour s'adaptent tout seuls.

local IMG = "magicalities_book_"

return {
	title = "Livre des Arcanes",

	cover = IMG .. "couverture.png",
	page_bg = IMG .. "page.png",
	tab_bg = IMG .. "onglet.png",
	back_img = IMG .. "retour.png",
	frame_img = IMG .. "cadre.png",

	chapters = {

		-------------
		-- CRISTAUX--
		-------------
		{
			id = "cristaux",
			menu_title = "CRISTAUX",
			menu_icon = IMG .. "crystal_air.png",
			pages = {
				{
					level = 1,
					title = "CRISTAUX",
					blocks = {
						{
							level = 1,
							text = "Dispersés aux six coins de Francophonia, les cristaux renferment une ou plusieurs énergies élémentaires en quantité variable. Ces énergies servent à charger votre baguette afin d'apprendre et lancer des sorts. Au cours du temps, un cristal qui n'aura pas été entièrement vidé de son énergie pourra se regénérer.\nUtilisez l'anneau élémentaire pour connaître ce que contiennent ces cristaux et la pioche en argent pour les briser à tout jamais. Seuls les mages puissants sauront comment les ramasser intact.",
						},
						{
							level = 2,
							icon = IMG .. "crystal_feu.png",
							text = "Les cristaux de feu se trouvent dans les entrailles profondes des régions minérales.",
						},
						{
							level = 2,
							icon = IMG .. "crystal_terre.png",
							text = "Les cristaux de terre poussent sur la mousse à moins de 1000 blocs de la surface.",
						},
						{
							level = 2,
							icon = IMG .. "crystal_eau.png",
							text = "Les cristaux d'eau apprécient le fond des océans et les cavernes inondées.",
						},
						{
							level = 2,
							icon = IMG .. "crystal_air.png",
							text = "Les cristaux d'air apparaissent dans les zones volcaniques.",
						},
						{
							level = 6,
							icon = IMG .. "crystal_light.png",
							text = "Les cristaux de lumière fleurissent dans les arbres de cristal.",
						},
						{
							level = 6,
							icon = IMG .. "crystal_dark.png",
							text = "Les cristaux des ténèbres préfèrent la quiétude des abysses d'Edulis.",
						},
					},
				},
			},
		},

		---------------
		-- FORGEMAGIE--
		---------------
		{
			id = "forgemagie",
			menu_title = "FORGEMAGIE",
			menu_icon = IMG .. "magicalities_element_ring.png",
			pages = {
				{
					level = 1,
					tab_label = "1",
					title = "FORGEMAGIE",
					blocks = {
						{
							text = "La forgemagie est l'art par lequel le mage façonne la matière au moyen des forces arcaniques. De savantes combinaisons donneront naissance à des objets imprégnés de pouvoirs stupéflipants. Les secrets de cet art ne se révèlent qu'aux mages suffisamment aguerris : à mesure que leur maîtrise grandit, de nouvelles recettes apparaissent.",
						},
					},
				},
				{
					level = 2,
					tab_label = "2",
					blocks = {
						{
							icon = IMG .. "chaudron.png",
							text = "Le chaudron enchanté sert à réaliser les potions. Avant d'y insérer les ingrédients, il faut le remplir d'eau, placer un bâton ou un morceau de charbon et allumer avec un briquet. La combustion est rapide alors préparez à l'avance tout ce dont vous aurez besoin. Une fois que la potion est prête, remplissez votre fiole.",
						},
						{
							icon = IMG .. "moreores_tool_silverpick.png",
							text = "La pioche en argent est la seule qui peut briser les cristaux pour en récupérer les éclats. Ces éclats servent d'ingrédients pour la forgemagie, la réalisation de potions ou la création de sorts.",
						},
					},
				},
				{
					level = 3,
					tab_label = "3",
					blocks = {
						{
							icon = IMG .. "magicalities_element_ring.png",
							text = "L'anneau élémentaire révèle les quantités d'énergie contenues dans les cristaux. Ainsi, vous saurez s'ils méritent d'être conservés en l'état ou s'il vaut mieux les vider de leurs énergies et les briser pour servir d'autres destins.",
						},
					},
				},
				{
					level = 4,
					tab_label = "4",
					blocks = {
						{
							icon = IMG .. "francomagicmod_berhjay_wand.png",
							text = "Le bâton de Berhjay est un outil puissant dans les mains d'un mage. Il double la capacité énergétique de la baguette et empêche les cristaux de se vider totalement. Ce bâton permet aussi de récolter les cristaux en frappant une structure de 17 verres d'obsidienne surmontée de 9 demi-blocs de laiton.",
						},
						{
							icon = IMG .. "everness_shovel_silk.png",
							text = "La pelle de cristal est l'outil de prédilection des terraformeurs. Elle conserve l'état naturel des blocs de terre qu'elle creuse.",
						},
					},
				},
				{
					level = 5,
					tab_label = "5",
					blocks = {
						{
							icon = IMG .. "witchcraft_pentagram.png",
							text = "Le pentacle est à usage unique et se dessine sur le sol. Une fois activé, il invoque une créature maléfique aléatoire. Prenez garde, car cette créature peut s'avérer très puissante !",
						},
						{
							icon = IMG .. "lavastuff_sword.png",
							text = "L'épée de lave, en plus d'être particulièrement puissante, peut allumer la flamme du sol pas inconnu.",
						},
						{
							icon = IMG .. "everness_shell_of_underwarer_breathing.png",
							text = "Le coquillage magique a été inventé par Sandy Cheeks lors de ses expéditions sous-marines. Il offre une réserve d'air prolongée en immersion. Vous pouvez le recharger dans un atelier de réparation.",
						},
					},
				},
				{
					level = 6,
					tab_label = "6",
					blocks = {
						{
							icon = IMG .. "alambic.png",
							text = "L'alambic est l'instrument avec lequel le mage purifie et renforce ses élixirs. Par le pouvoir du feu, de la vapeur et de la distillation, il extrait des breuvages leur essence la plus subtile, leur conférant une puissance accrue.",
						},
						{
							icon = IMG .. "magicalities_tellium_axe_rage.png",
							text = "Née de l'alliance de l'ingéniosité mécanique et des forces arcaniques, la tronçonache permet d'abattre les plus robustes des arbres d'un seul coup. Son mécanisme enchanté concentre en un instant une puissance qu'aucun bûcheron ne saurait égaler.",
						},
						{
							icon = IMG .. "add_stuff_prismpick.png",
							text = "La pioche luminescente apporte au mineur une clarté éphémère dans la confusion des ténèbres.",
						},
						{
							icon = IMG .. "xdecor_enchantment_side.png",
							text = "La table d'enchantement renferme des arcanes d'une puissance peu commune. À l'aide d'un éclat de lumière, elle permet d'insuffler aux outils des propriétés nouvelles, accroissant leur puissance, leur portée ou leur résistance bien au-delà de leurs limites naturelles.",
						},
					},
				},
				{
					level = 7,
					tab_label = "7",
					blocks = {
						{
							icon = IMG .. "francomagicmod_sceptre_edulis.png",
							text = "Le sceptre d'Edulis est l'arme ultime du Mage puissant, il peut contenir une quantité considérable d'énergie et se recharge cinq fois plus vite que le bâton de Berhjay tout en conservant ses autres propriétés : préservation et récolte des cristaux.",
						},
						{
							icon = IMG .. "francomagicmod_superior_ring.png",
							text = "L'anneau céleste se décline en 4 versions : inférieur, ordinaire, supérieur et suprême. Chaque version nécessite 5 anneaux du rang précédent et vous permet de rester en l'air plus longtemps. Le retour au sol sera sans danger et vous devrez attendre quelques secondes avant de pouvoir repartir.",
						},
						{
							icon = IMG .. "draconis_dragonbinder.png",
							text = "La corne de dragon a le pouvoir de transporter et téléporter votre dragon. Utilisez-la toujours avec la main droite. Lorsqu'elle est vide, accroupissez-vous pour modifier le paramètre de croissance : votre dragon continuera (ou pas) à grandir une fois à l'intérieur. Pour le faire entrer, utilisez la corne sur votre dragon et pour le faire sortir, utilisez-la sur le sol. Si le dragon est en balade, ou que vous vous êtes éloigné, utilisez la corne pour le faire venir à vous.",
						},
						{
							icon = IMG .. "draconis_draconic_forge_fire.png",
							text = "Le four draconis est le coeur de la forge draconique. Une fois la forge construite, si elle est correctement agencée, vous pourrez placer ce four au centre et y insérer le creuset ainsi que 99 lingots de fer. Utilisez la puissance du souffle de votre dragon pour transformer ces lingots en métal draconique. Une fois la transformation effectuée, vous verrez apparaître une fumée blanche.",
						},
					},
				},
			},
		},

		----------
		-- SORTS--
		----------
		{
			id = "sorts",
			menu_title = "SORTS",
			menu_icon = IMG .. "focus_base.png",
			pages = {
				{
					level = 1,
					tab_icon = IMG .. "focus_base.png",
					title = "SORTS",
					blocks = {
						{
							level = 1,
							text = "Les sorts prennent la forme de focus à créer dans une table des Arcanes. Cette dernière s'obtient en frappant un pupitre de votre baguette.\nL'arrangement des ingrédients dépendra de votre capacité à décrypter l'incantation correspondante, tout en respectant l'harmonie des éléments.\nSi la disposition est correcte, en plaçant votre baguette dans l'emplacement prévu, les quantités d'énergies requises apparaitront.\nLes sorts s'activent en utilisant votre baguette vers le ciel. Chaque sort consomme l'énergie de son élément et parfois du mana.",
						},
						{
							level = 2,
							icon = IMG .. "focus_base.png",
							text = "Le focus neutre sert de réceptacle pour les autres sorts, il se place toujours au centre de l'atelier.",
							incantation = "Croix de cristal et sommets de métal azuré.",
						},
					},
				},
				{
					level = 3,
					tab_icon = IMG .. "focus_fire.png",
					header = IMG .. "focus_fire.png",
					blocks = {
						{
							text = "Le focus de feu cuit les items de votre inventaire, à raison de 10 énergies de feu par emplacement.",
							incantation = "Des coeurs de lave aux éclats de rubis.",
						},
					},
				},
				{
					level = 4,
					tab_icon = IMG .. "focus_earth.png",
					header = IMG .. "focus_earth.png",
					blocks = {
						{
							text = "Le focus de terre transforme la pierre en gravier, le gravier en sable, le sable en terre et la terre en terre étrange sur laquelle il fait apparaître une plante magique aléatoire. Il vide aussi le bois de son âme.",
							incantation = "Les grains de roche séparent les maudites pierres de sable minéral, soutenus pas les fragments d'émeraude.",
						},
					},
				},
				{
					level = 5,
					tab_icon = IMG .. "focus_water.png",
					header = IMG .. "focus_water.png",
					blocks = {
						{
							text = "Le focus d'eau transforme une source de lave ou d'eau en bloc traversable puis en bloc solide et enfin, lui redonne sa forme d'origine.",
							incantation = "Dans chaque direction, les gemmes abyssales s'accompagnent de liquides d'origines différentes et de forces opposées.",
						},
					},
				},
				{
					level = 5,
					tab_icon = IMG .. "focus_air.png",
					header = IMG .. "focus_air.png",
					blocks = {
						{
							text = "Le focus d'air crée un trou de 5x5x5 dans tout type de blocs solides.",
							incantation = "Les ustensiles du mineur de la Moria s'entrelacent autour d'un duel de souffle.",
						},
					},
				},
				{
					level = 6,
					tab_icon = IMG .. "focus_ice.png",
					header = IMG .. "focus_ice.png",
					blocks = {
						{
							text = "Le focus de glace projette un pic de glace, gèle l'eau et solidifie la lave en obsidienne.",
							incantation = "Triplés de sorts en sort, de l'eau sous l'air, séparés d'un éclat de chaque.",
						},
					},
				},
				{
					level = 7,
					tab_icon = IMG .. "focus_light.png",
					header = IMG .. "focus_light.png",
					blocks = {
						{
							text = "Le focus de lumière envoie un rayon illuminant la pierre.",
							incantation = "Que se réunissent les rayons cristallins aux sommets, séparés par les jumelles éclairées des profondeurs. Les unes forgées, les autres bercées par les flots.",
						},
					},
				},
				{
					level = 7,
					tab_icon = IMG .. "focus_storm.png",
					header = IMG .. "focus_storm.png",
					blocks = {
						{
							text = "Le focus foudroyant inflige de très lourds dégâts.",
							incantation = "Ce sort ressort des six sorts, les légers sont séparés des denses par les yeux du spectre.",
						},
					},
				},
			},
		},

		------------
		-- POTIONS--
		------------
		{
			id = "potions",
			menu_title = "POTIONS",
			menu_icon = IMG .. "potion_poison.png",
			pages = {
				{
					level = 1,
					tab_icon = IMG .. "potion_poison.png",
					title = "POTIONS",
					blocks = {
						{
							text = "Les potions se préparent dans un chaudron enchanté.\nChaque recette comporte 3 ingrédients, à ajouter dans un ordre précis.\nEn cas d'erreur, vous pourrez toujours récupérer les ingrédients dans votre chaudron.",
						},
					},
				},
				{
					level = 2,
					tab_icon = IMG .. "potion_ace.png",
					title = "Cocktail ACE",
					header = IMG .. "potion_ace.png",
					blocks = {
						{
							text = "Cette potion écarlate regorge de précieuses vitamines et d'essences bienfaisantes. Elle revigore le corps et referme les blessures, pour peu que le breuvage soit absorbé sans grimace.",
							incantation = "Un concentré de caroténoïdes, un fruit qui ne devrait pas donner d'épices et quelques gouttes de tocophérols.",
						},
					},
				},
				{
					level = 3,
					tab_icon = IMG .. "potion_flash.png",
					title = "Potion flash",
					header = IMG .. "potion_flash.png",
					blocks = {
						{
							text = "Ce breuvage confère à son consommateur une célérité peu commune. Idéal pour les explorateurs pressés qui considèrent que le chemin le plus court est celui qui mène au trésor.",
							incantation = "Prélevez les ingrédients de cette potion sur un gallinacé, un lagomorphe et un félin.",
						},
					},
				},
				{
					level = 3,
					tab_icon = IMG .. "potion_copacamana.png",
					title = "Cocktail copacamana",
					header = IMG .. "potion_copacamana.png",
					blocks = {
						{
							text = "Ce mystérieux cocktail regorge d'énergies arcaniques. Quelques gorgées suffisent à ranimer les forces magiques d'un mage à court d'inspiration.",
							incantation = "Rassemblez deux jolies fleurs des profondeurs, l'une pousse sur du corail, l'autre sur de la glace. Ajoutez-y un peu de miel car leur beauté n'est pas sans amertume.",
						},
					},
				},
				{
					level = 4,
					tab_icon = IMG .. "potion_thermique.png",
					title = "Potion thermique",
					header = IMG .. "potion_thermique.png",
					blocks = {
						{
							text = "D'une chaude teinte dorée, cette potion protège son consommateur des ardeurs du feu et de la lave. Une précaution fort appréciable pour qui fréquente les contrées où les flammes ont tendance à vous accueillir chaleureusement.",
							incantation = "Faites bouillir un fragment de chalcogène et une pépite d'or des fous puis ajoutez un éclat de cristal de feu.",
						},
					},
				},
				{
					level = 5,
					tab_icon = IMG .. "potion_de_pet.png",
					title = "Potion de pet",
					header = IMG .. "potion_de_pet.png",
					blocks = {
						{
							text = "Cette sombre potion doit son nom à un mage dysorthographique dont la réputation n'a jamais survécu à cette regrettable erreur. Elle vous rend insensible aux attaques... à condition de ne surtout pas utiliser votre main gauche !",
							incantation = "Faites mijoter un coussin de belle-mère dans de la poussière de plomb diluée avant d'y tremper la peau d'un bouledogue pas français.",
						},
					},
				},
				{
					level = 5,
					tab_icon = IMG .. "potion_skaven.png",
					title = "Potion Skaven",
					header = IMG .. "potion_skaven.png",
					blocks = {
						{
							text = "Cette potion n'est guère engageante, mais ses effets sont sans équivoque : quelques gorgées suffisent à vous faire adopter l'apparence d'un véritable Skaven. La discrétion vient parfois sous des formes inattendues.",
							incantation = "Mélangez la chair du mangeur de restes, la fleur du mangeur de mouches et le fruit rôti du mangeur de griots.",
						},
					},
				},
				{
					level = 6,
					tab_icon = IMG .. "potion_de_toph.png",
					title = "Elixir de Toph",
					header = IMG .. "potion_de_toph.png",
					blocks = {
						{
							text = "Cet élixir verdoyant vous unit à la terre au point de vous en faire prendre la forme. Vous deviendrez alors aussi discret qu'un bloc de terre herbeuse... et probablement tout aussi difficile à distinguer du paysage.",
							incantation = "Un tison de Satan, un éclat de cristal de terre et une feuille de carnivore.",
						},
					},
				},
				{
					level = 6,
					tab_icon = IMG .. "potion_dede.png",
					title = "Potion de Dédé",
					header = IMG .. "potion_dede.png",
					blocks = {
						{
							text = "Cet élixir aux reflets d'or vous permet de réduire votre encombrement à une taille fort commode. Les passages les plus étroits ne seront bientôt plus un obstacle...",
							incantation = "Trempez une feuille dans de l'huile puis rajoutez un souffle d'air.",
						},
					},
				},
				{
					level = 6,
					tab_icon = IMG .. "potion_uskull.png",
					title = "Popo d'Uskull",
					header = IMG .. "potion_uskull.png",
					blocks = {
						{
							text = "Son aspect brunâtre et son goût douteux auraient dû suffire à décourager les plus téméraires. Pourtant, ceux qui osent l'avaler se voient investis de la noble apparence d'un roi squelette.",
							incantation = "Enveloppez une belle masse métallique dans la peau du géant puis laissez l'éclat des ténèbres en réveiller la force.",
						},
					},
				},
				{
					level = 7,
					tab_icon = IMG .. "potion_grogneur.png",
					title = "Potion du grogneur",
					header = IMG .. "potion_grogneur.png",
					blocks = {
						{
							text = "Ce breuvage vous confère l'apparence et les aptitudes d'un redoutable Growler. Mais prenez garde : sous cette nouvelle forme, le sol peut sembler bien plus éloigné qu'il ne l'était auparavant.",
							incantation = "L'âme du grogneur se réveillera lorsque le rai de lumière atteindra la fleur de lune.",
						},
					},
				},
			},
		},
	},
}
