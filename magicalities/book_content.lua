-- book_content.lua
-- Contient tout le contenu du livre, structuré par chapitre et section
-- Chaque section correspond à un niveau

local book = {
    title = "Livre des Arcanes",
    chapters = {
        ["1"] = {
            title = "Chapitre 1: Cristaux",
            image = "crystal_image_book.png",
            sections = {
                ["1"] = "<b>Dans les contrées oubliées de notre monde reposent les cristaux élémentaires : ceux de terre, de feu et d'eau préfèrent la quiétude des profondeurs et ceux d'air se nourrissent de souffre. Chacun renferme une quantité variable d’énergie dont parfois d'origines différentes.</b>",
                ["2"] = "<b>Frappez un cristal avec votre baguette en main droite pour la charger en énergie magique.</b>",
                ["3"] = "<b>Les cristaux se régénèrent avec le temps, sauf s'ils ont été totalement vidés par une baguette de pin.</b>",
                ["4"] = "<b>Les sorts et objets avancés exigent davantage d’énergie. Utilisez le bâton de Berhjay pour que les cristaux ne se vident pas entièrement.</b>",
                ["6"] = "<b>Pour récolter un cristal intact</b>, construisez une plateforme centrée juste en-dessous de 3x3 verres d'obsidienne, entourez ensuite le cristal avec 8 verres d'obsidienne, recouvrez l'ensemble de 9 demi-blocs de laiton, puis frappez le cristal avec le bâton ou le sceptre sur le structure.",
                ["7"] = "<b>Le sceptre d'Edulis</b> vous permet de récupérer les énergies par paquets de 5, tout en conservant au moins une énergie dans le cristal."
            }
        },
        ["2"] = {
            title = "Chapitre 2 : Forgemagie",
            image = "magicalities_element_ring.png",
            sections = {
                ["1"] = "<b>Maintenant que vous avez rejoint la guilde des Mages, vous allez pouvoir créer des objets magiques dans votre grille d'inventaire. Les recettes se débloqueront au fur et à mesure de votre formation.</b>",
                ["2"] = "<b>- Le chaudron</b> enchanté sert à réaliser les potions. Son utilisation est détaillée dans le chapitre 'Potions'.",
                ["3"] = "<b>- L’anneau élémentaire</b> révèle les quantités d'énergie contenues dans les cristaux.",
                ["4"] = "<b>- Le bâton de Berhjay</b> peut stocker jusqu’à 50 unités de chaque énergie et empêche les cristaux de se vider totalement. \n <b>- La pelle de cristal</b> est l'outil de prédilection des terraformeurs car elle conserve l'état naturel de la terre.",
                ["5"] = "<b>- Le pentacle</b> invoque créature maléfique aléatoire.\n <b>- L'épée de lave</b> éclaire et brûle puissament. \n <b>- Le coquillage magique</b> offre une réserve d'air prolongée en immersion.",
                ["6"] = "<b>- L’alambic</b> améliore la potion que vous mettez dedans. \n <b>- La Tronçonnache</b> abat un arbre en un coup. \n <b>- La pioche luminescente</b> permet de poser un éclairage temporaire pour miner en toute sécurité.",
                ["7"] = "<b>- Le sceptre d’Edulis</b> peut contenir jusqu'à 100 unités de chaque énergie qu'il récupère par paquets de 5 sur les cristaux. \n <b>- La corne de dragon</b> permet de transporter et téléporter votre dragon. Utilisez-la toujours avec la main droite. Lorsqu'elle est vide, accroupissez-vous pour modifier le paramètre de croissance: votre dragon continuera (ou non) à grandir une fois à l'intérieur. Pour la faire entrer, utilisez la corne sur votre dragon et pour le faire sortir, utilisez-la sur le sol. Si le dragon est en balade, ou que vous vous êtes éloigné, utilisez la corne pour le téléporter à votre position. \n <b>- Le four draconis</b> est le coeur de la forge draconique. Une fois la forge construite, si elle est correctement agencée, vous pourrez placer ce four au centre et y insérer le creuset ainsi que 99 lingots de fer. Utilisez la puissance du souffle de votre dragon pour transformer ces lingots en métal draconique. Une fois la transformation effectuée, vous verrez apparaître une fumée blanche. \n<b>- L'anneau de vol</b> se décline en 4 versions: inférieure, ordinaire, supérieure, et suprême. Chaque version nécessite 5 anneaux du rang précédent et vous permet de rester en l'air plus longtemps. Le retour au sol sera sans danger et vous devrez attendre quelques secondes avant de pouvoir repartir."
            }
        },
        ["3"] = {
            title = "Chapitre 3 : Sorts",
            image = "magicalities_focus_base.png",
            sections = {
                ["1"] = "<b>Pour apprendre des sorts, vous aurez besoin d'une Table des Arcanes. Elle s'obtient en frappant un pupitre avec votre baguette. Ouvrez la grille de la table avec votre main droite, disposez HARMONIEUSEMENT les ingrédients et placez votre baguette chargée d'énergies dans l’emplacement prévu. La table indiquera les quantités d'énergies requises pour créer le sort une fois tous les éléments en place. Les sorts prennent la forme de focus. Pour les fabriquer, placez toujours au centre de votre grille un focus neutre. Une fois créé et placé dans l’inventaire, activez-les en utilisant votre baguette vers le ciel. Chaque sort consomme l’énergie de son élément et parfois du mana. Vous débutez avec une baguette de pin qui peut contenir jusqu'à 25 unités de chaque énergie. Les recettes ne sont malheureusement pas connues, vous devrez faire quelques recherches avant de trouver le bon arrangement !</b>",
                ["2"] = "<b>- Le focus neutre</b> sert de base à la création des autres sorts, il est fait à partir de 5 éclats de cristaux et de 4 lingots de mithril.",
                ["3"] = "<b>- Le focus de feu</b> cuit les items de votre inventaire, à raison de 10 énergies de feu par emplacement. Vous aurez besoin de 4 orbes de lave et 4 éclats de cristal de feu.",
                ["4"] = "<b>- Le focus de terre</b> transforme la pierre en gravier, le gravier en sable, le sable en terre et la terre en terre étrange sur laquelle il fait apparaître une plante magique. Il transforme aussi le bois en arbre creux. Disposez 2 pierres maudites, 2 sables minéral, 2 graviers et 2 éclats de cristaux de terre de façon équilibrée autour du centre.",
                ["5"] = "<b>- Le focus d’eau</b> transforme une source de lave ou d'eau en bloc traversable puis en bloc solide et enfin, lui redonne sa forme d'origine. Utilisez 4 éclats de cristal d'eau, 1 seau d'eau minérale, 1 d'eau saline, 1 de lave minérale et 1 de lave classique. \n <b>- La focus d'air</b> créé un trou de 5x5x5 dans tout type de blocs solides. 3 pelles et 3 pioches en mithril s'entrelacent autour de 2 éclats de cristaux d'air pour créer ce sort.",
                ["6"] = "<b>- Le focus de glace</b> projette un pic de glace, gèle l'eau et solidifie la lave en obsidienne. Pour l'obtenir, sépare trois focus d'eau de trois focus d'air à l'aide d'un éclat de cristal d'air et d'un éclat de cristal d'eau",
                ["7"] = "<b>- Le focus de lumière</b> envoie un rayon illuminant la pierre. Sa confection nécessite 4 blocs de cristal de lumière, deux lanternes de pyrite et deux lanternes de forêt corallienne océanique. \n <b>- Le focus foudroyant</b> inflige de lourds dégâts. Il se réalise à partir des 6 focus précédents, deux orbes spectrales séparent les légers des denses."
            }
        },
        ["4"] = {
            title = "Chapitre 4 : Potions",
            image = "francomagicmod_potion_gpurple.png",
            sections = {
                ["1"] = "<b>Les potions se préparent dans un chaudron rempli d’eau et alimenté par du charbon ou des branches. Chaque recette comporte 3 ingrédients, à ajouter dans un ordre précis. Une fois les ingrédients versés, utilisez une fiole sur le chaudron pour la remplir.</b>",
                ["2"] = "<b>- La Potion de vie</b> soigne vos blessures, utilisez un minerais de fer, une carotte, puis un œuf.",
                ["3"] = "<b>- La potion de rapidité</b> vous fera gagner du temps, utilisez un cristal de mese, une feuille de menthe et une peau de lapin. \n <b>- La potion de mana</b> régénère votre mana, utilisez un minerai de pyrite, des grains de café et du miel.",
                ["4"] = "<b>- La potion thermique</b> protège des brûlures, placez un minerai de souffre, une fleur lumineuse des cavernes maudites (ngrass_2) et un cuir.",
                ["5"] = "<b>- La potion de protection</b> vous rend insensible aux attaques, tant que vous n’utilisez pas votre main gauche ! Versez un minerai de plomb, un bloc de corail mort (brain) et une boule de poil dans votre chaudron. \n <b>- La potion de lutin</b> vous rendra tout petit. Elle s'obtient en mélangeant de la poudre d'étain, un champignon rouge et un rat cuit. \n <b>- La potion de géant</b> fera l'inverse. Placez un bloc d'étain, un cookie et une peau d'éléphant.",
                ["6"] = "<b>- L’Elixir de Toph</b> transforme l'utilisateur en bloc de terre herbeuse. Il est concocté à partir d'une poignée d'aluminosilicate hydraté, d'un brin d'ammophila arenaria et d'une feuille de Dionaea muscipula. \n <b>- L'Elixir de Bèh</b> vous transforme en mouton. Placez un os, une laine et de la viande de mouton crue.",
                ["7"] = "<b>- L’Elixir à Viaire</b> vous transforme en growler. Il s'obtient avec un diamant, un papillon blanc et de la viande crue de growler. Mais attention à la chute !"
            }
        }
    }
}

return book