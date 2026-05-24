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
                ["3"] = "<b>Les cristaux se régénèrent avec le temps, sauf s'ils ont été totalement vidés.</b> Désormais, ils conserveront toujours au moins une unité d’énergie.",
                ["4"] = "<b>Les sorts et objets avancés exigent davantage d’énergie. Votre baguette de pin ou bâton de Berhjay prélèvent maintenant l’énergie par paquets de 5.</b>",
                ["6"] = "<b>Pour récolter un cristal intact</b> : entourez-le de 17 verres d’obsidienne, recouvrez l’ensemble de 9 demi-blocs de laiton, puis frappez avec votre bâton."
            }
        },
        ["2"] = {
            title = "Chapitre 2 : Forgemagie",
            image = "magicalities_element_ring.png",
            sections = {
                ["1"] = "<b>Selon votre niveau, vous pouvez créer des objets magiques dans la Table des Arcanes. Pour l’obtenir, frappez un pupitre avec votre baguette.</b>",
                ["2"] = "<b>Disposez harmonieusement les ingrédients et placez votre baguette chargée dans l’emplacement prévu. La table indiquera l’énergie requise. \n Chaudron pour confectionner vos potions:</b> \n - 6 blocs de fontes \n - 1 bloc de mithril",
                ["3"] = "<b>L’anneau élémentaire révèle l'énergie contenue dans les cristaux.</b> \n - 1 éclat de cristal d'air, de terre, de feu et d'eau \n - 4 blocs d'or dans les coins",
                ["4"] = "<b>Le bâton de Berhjay stocke jusqu’à 50 unités de chaque énergie.</b> \n - 1 tronc de mese \n - 1 tronc de lave \n - 1 tronc de saule \n - 6 blocs de diamants \n <b>La pelle de cristal conserve l’état naturel des blocs de terre.</b> \n - 2 blocs d'argent \n - 1 bloc de cristal de terre",
                ["5"] = "<b>Le pentacle invoque une créature maléfique aléatoire.</b> \n - 1 potion de vie LVL 1 \n - 4 blocs de pentagramme \n <b>L’épée de lave éclaire et brûle puissamment.</b> \n - 2 orbes de lave \n - 1 tesson d'obsidienne \n <b>Le coquillage magique offre une réserve d'air prolongée en immersion.</b> \n - 1 bloc de cristal d'air \n - 6 bloc de squelette de corail \n - 2 blocs de coraux maudits",
                ["6"] = "<b>L’alambic améliore vos potions.</b> \n - 1 verre de pyrite \n - 1 élement chauffant \n - 5 blocs de bronze \n <b>La tronçonnache abat un arbre en un coup.</b> \n - 2 moteurs \n - 3 haches en mithril \n - 1 bloc de diamant \n - 3 cisailles à vignes \n <b>La pioche luminescente éclaire et mine comme celle en mithril.</b> \n - 2 blocs de pyrite  \n - 1 bloc d'orbes spectrales \n - 1 fruit d'arbre coralien \n - 1 pierre de rêve maudite",
                ["7"] = "<b>Le sceptre d’Edulis vous offrira une plus grande réserve d’énergies.</b> \n - 3 grands plants d'arbre de cristal \n - 1 bloc de chaque cristal \n <b>La corne de dragon transporte et téléporte votre dragon.</b> \n - 4 blocs de cristal des ténèbres \n - 1 bloc d'or \n <b>Le four draconis est le coeur de la forge draconique.</b> \n - 1 four \n - 8 briques de pierre de dragon \n <b>L’anneau de vol se décline en 4 versions : inférieure, ordinaire, supérieure et suprême.</b> \n Version inférieure: \n - 4 cristaux d'air \n - 4 cristaux de lumière \n Version supérieure (ordinaire, supérieure et suprême): \n - 5 anneaux de rang précédent \n - 4 minéraux précieux (or/diamant/mithril)"
            }
        },
        ["3"] = {
            title = "Chapitre 3 : Sorts",
            image = "magicalities_focus_base.png",
            sections = {
                ["1"] = "<b>La table des Arcanes sert aussi pour apprendre des sorts. Une fois dans l’inventaire, activez-les en utilisant votre baguette vers le ciel. Chaque sort consomme l’énergie de son élément.</b>",
                ["2"] = "<b>Les sorts prennent la forme de focus. Pour les apprendre, placez toujours au centre de votre table un focus neutre.</b> \n - 5 éclats de cristaux \n - 4 lingots de mithril",
                ["3"] = "<b>Le focus de feu cuit les items de votre inventaire, à raison de 10 énergies de feu par emplacement.</b> \n - 4 orbes de lave \n - 4 éclats de cristal de feu",
                ["4"] = "<b>Le focus de terre transforme la pierre en gravier, le gravier en sable, le sable en terre et la terre en terre herbeuse sur laquelle il fait apparaître une plante précieuse.</b> \n - 2 pierres \n - 2 graviers \n - 2 sables \n - 2 éclats de critaux de terre \n (deux élements identiques ne peuvent être du même côté)",
                ["5"] = "<b>Le focus d’eau transforme un bloc liquide (source de lave ou eau) en bloc traversable puis en bloc solide. Attention cependant, si vous posez quoi que ce soit au bord de ce trou, le liquide reprendra son écoulement.</b> \n - 4 éclats de cristal d'eau \n - 4 seaux: \n - 1 eau minérale \n - 1 eau saline \n - 1 lave minérale \n - 1 lave ordinaire \n <b>Le focus d’air crée un trou de 5x5x5 dans tout type de blocs solides</b> \n - 2 éclats de cristal d'air \n - 3 pelles \n - 3 pioches en mithril",
                ["6"] = "<b>Le focus de glace projette un pic de glace, gèle l'eau et solidifie la lave en obsidienne.</b> \n - 3 focus d'air \n - 3 focus d'eau \n - 1 éclat de cristal d'air \n - 1 éclat de cristal d'eau",
                ["7"] = "<b>Le focus de lumière envoie un rayon illuminant la pierre.</b> \n - 4 blocs de cristal de lumière \n - 2 lanternes de pyrite \n - 2 forêts coralliennes océaniques \n <b>Le focus foudroyant inflige de lourds dégâts.</b> \n - 2 orbes spectrales \n - 1 focus de chaque sort (les légers en haut et les denses en bas)"
            }
        },
        ["4"] = {
            title = "Chapitre 4 : Potions",
            image = "francomagicmod_potion_gpurple.png",
            sections = {
                ["1"] = "<b>Les potions se préparent dans un chaudron rempli d’eau pure, posé sur un feu.</b> \n <b>Chaque recette comporte 3 ingrédients à ajouter dans un ordre précis.</b>",
                ["2"] = "<b>La Potion de vie soigne vos blessures.</b> \n - 1 minerai de fer \n - 1 carotte \n - 1 œuf.",
                ["3"] = "<b>La potion de rapidité vous fera gagner du temps.</b> \n - 1 cristal de mese \n - 1 feuille de menthe \n - 1 peau de lapin. \n <b>La potion de mana régénère votre mana.</b> \n - 1 minerai de pyrite \n - 1 grain de café \n - 1 miel",
                ["4"] = "<b>La potion thermique protège des brûlures.</b> \n - 1 minerai de souffre \n - 1 fleur lumineuse des cavernes maudites (ngrass_2) \n - 1 morceau de cuir",
                ["5"] = "<b>La potion de protection vous rend insensible aux attaques, tant que vous n’utilisez pas votre main gauche !</b> \n  - 1 minerai de plomb \n - 1 bloc de corail mort (brain) \n - 1 boule de poil \n <b>La potion de lutin vous rendra tout petit.</b> \n - 1 poudre d’étain \n - 1 champignon rouge \n - 1 rat cuit \n <b>La potion de géant fera l’inverse.</b> \n - 1 bloc d’étain \n - 1 cookie \n - 1 peau d’éléphant",
                ["6"] = "<b>L’Elixir de Toph transforme l'utilisateur en bloc de terre herbeuse.</b> \n - 1 aluminosilicate hydraté \n - 1 brin d’ammophila arenaria \n - 1 feuille de Dionaea muscipula. \n <b>L’Elixir de Beeeeh vous transforme en mouton.</b> \n - 1 os \n - 1 laine \n - 1 viande de mouton crue",
                ["7"] = "<b>L’élixir à Viaire vous transforme en growler.</b> \n - 1 diamant \n - 1 papillon blanc \n - 1 viande crue de growler \n (Mais attention à la chute !)"
            }
        }
    }
}

return book