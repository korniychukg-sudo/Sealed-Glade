import SwiftUI

struct GladeGuide: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let plateArt: String
    let paragraphs: [String]
    let facts: [String]
}

enum GladeGuides {
    static let all: [GladeGuide] = partOne + partTwo

    private static let partOne: [GladeGuide] = [
        GladeGuide(
            id: "g_watercycle",
            title: "The Rain Indoors",
            subtitle: "How a sealed jar waters itself",
            plateArt: "guide_watercycle",
            paragraphs: [
                "Seal a damp world in glass and you have bottled the water cycle itself. By day, warmth lifts moisture out of the soil and the leaves; it drifts up as vapour, meets the cooler glass, and beads into droplets that gather, swell, and slide back down the walls to the soil. It is rain, in miniature, on a loop that never needs you.",
                "This is why a sealed jar is never watered on a schedule. The same water travels the circle indefinitely — the drink the moss takes today fell as glass-rain yesterday and will rise as vapour again tomorrow. A closed terrarium in balance loses essentially nothing; jars exist that have not been opened in decades and are still green.",
                "The keeper's only real job is reading the glass. A soft morning fog that clears by midday is a healthy cycle breathing. Glass that streams all day means too much water aboard; a jar that never mists at all is running dry. The condensation is not a problem to wipe away — it is the weather report.",
            ],
            facts: [
                "A famous sealed bottle garden planted in 1960 was last watered in 1972 and thrives to this day.",
                "Light condensation in the morning that clears by afternoon is the signature of a balanced jar.",
                "The water a sealed jar loses in a year can be measured in drops.",
            ]),
        GladeGuide(
            id: "g_light",
            title: "Light, the Only Import",
            subtitle: "The one thing a sealed world still needs",
            plateArt: "guide_light",
            paragraphs: [
                "A sealed jar trades nothing with the world — no water, no air, no food — except light. Light is the engine that runs everything inside: the plants catch it and spin it into sugar, the sugar feeds growth, the growth feeds the litter crew, and round it goes. Cut off the light and the whole economy closes within weeks.",
                "But glass changes the arithmetic. A jar in direct sun is a greenhouse the size of a fist: heat pours in faster than it can leave, and an afternoon on a sunny sill can cook a rainforest that took months to grow. The classic keeper's compromise is bright, indirect light — near a window, never in the beam.",
                "Different tenants want different rations. Moss and ferns evolved for the dim floor of forests and sulk in brightness; earth stars and string of turtles carry the sun-loving habits of open rock. Reading your plants' light preferences before sealing them together is the difference between a landscape and an argument.",
            ],
            facts: [
                "Direct sun through glass can raise a sealed jar's temperature by tens of degrees in an hour.",
                "Moss photosynthesises happily at light levels that would starve a sun-loving succulent.",
                "North-facing light, gentle and even, has kept more bottle gardens alive than any other window.",
            ]),
        GladeGuide(
            id: "g_layers",
            title: "Reading the Layers",
            subtitle: "Drainage, charcoal, soil: the jar's foundations",
            plateArt: "guide_layers",
            paragraphs: [
                "Every glade stands on three layers, laid like a small geology. At the bottom, pebbles: a basement where surplus water can stand without drowning the roots above. Over them, a dark seam of charcoal: the jar's filter, quietly adsorbing the by-products of decay that would otherwise sour a closed world. And above that, the soil itself, where all the actual living happens.",
                "The pebble layer is the humble hero. In an open pot, extra water drains out the bottom hole; in a sealed jar there is no out. The false bottom of stones gives that water somewhere to wait until the cycle lifts it back into circulation, keeping the soil moist but never waterlogged.",
                "Charcoal earns its keep invisibly. Porous as a sponge at the microscopic scale, a handful holds the surface area of a meadow, and on all that surface it captures the compounds of rot. Old sailors kept water sweet in barrels with charcoal; a bottle gardener keeps a world sweet with the same trick.",
            ],
            facts: [
                "A single gram of activated charcoal can hold the surface area of several tennis courts.",
                "The pebble layer is called a false bottom: a drain for a vessel that cannot drain.",
                "Victorian glasshouse keepers borrowed the charcoal trick from ships' water barrels.",
            ]),
        GladeGuide(
            id: "g_crew",
            title: "The Cleanup Crew",
            subtitle: "Springtails, isopods, and the art of hiring janitors",
            plateArt: "guide_crew",
            paragraphs: [
                "No forest employs a gardener, because it employs decomposers. A sealed glade is no different: leaves fall, roots shed, and something must turn that litter back into soil before mould claims it. Enter the crew: springtails, near-microscopic and tireless, who graze mould the way sheep graze a hillside; and isopods, armoured recyclers who shred dead leaves into the makings of new ones.",
                "The elegance is that the crew is self-regulating. Plenty of litter and mould means plenty of food, and the populations grow to meet the work; when the work runs short, the numbers ease back down. A keeper never counts springtails. They count themselves.",
                "Together the crew closes the last loop of the little world: plants feed the litter, litter feeds the crew, the crew's leavings feed the plants. A jar without decomposers is a museum that slowly moulders. A jar with them is an economy.",
            ],
            facts: [
                "Springtails are among the most numerous land animals on Earth — a handful of forest soil holds thousands.",
                "The spring in springtail is a latch-loaded tail that catapults them away from danger.",
                "Isopods are land crustaceans: distant, air-breathing cousins of crabs.",
            ]),
        GladeGuide(
            id: "g_mold",
            title: "When the Grey Fuzz Comes",
            subtitle: "Mould, and why panic is optional",
            plateArt: "guide_mold",
            paragraphs: [
                "Sooner or later every new jar grows its first patch of grey fuzz, and every new keeper reaches for the lid in alarm. Pause first. Mould spores are everywhere, in every soil and on every leaf; a bloom in a young jar mostly means the decomposition economy has not caught up with the litter supply yet.",
                "Mould loves what the crew loves — dead matter and damp — so the cure is rarely surgery and usually staffing. A healthy springtail population treats a mould bloom as a banquet and will graze a patch back to nothing in days. Persistent mould is a message: too much moisture aboard, too little airflow of light, or a crew too small for the litter it faces.",
                "The keeper's escalation ladder runs: wait and watch; strengthen the crew; shorten the water; and only then open the lid to lift out what offends. Most blooms never survive the first rung. The grey fuzz is not the end of the world — it is the world, working through its backlog.",
            ],
            facts: [
                "Mould spores are present in effectively all soil; a sterile jar is neither possible nor desirable.",
                "A strong springtail colony can clear a fresh mould bloom in under a week.",
                "Persistent mould is usually a water problem wearing a fungus costume.",
            ]),
    ]

    private static let partTwo: [GladeGuide] = [
        GladeGuide(
            id: "g_algae",
            title: "The Green Window",
            subtitle: "Algae, light, and keeping the view",
            plateArt: "guide_algae",
            paragraphs: [
                "Algae is what happens when light and water meet anywhere at all — a film of green pioneers colonising the inside of the glass exactly as their ancestors colonised the early Earth. In a jar it is harmless to the plants but fatal to the view, fogging the window into a green blur.",
                "Its arithmetic is simple: algae grows where light times moisture crosses a threshold. A jar in strong light with streaming walls will green over in weeks; a balanced jar in soft light may never show a trace. The glass is a gauge — reading it tells you about your light and water before it tells you about algae.",
                "Housekeeping has two schools. The patient school hires a glass snail, who rasps the walls clean in wandering ribbons and considers it wages. The direct school opens the lid and wipes. The wise school adjusts the light so the question stops being asked.",
            ],
            facts: [
                "The green film on glass is the same family of organisms that first oxygenated Earth's atmosphere.",
                "A single small snail can keep several square inches of glass clear indefinitely.",
                "Algae on the glass is a light-and-water gauge you can read at a glance.",
            ]),
        GladeGuide(
            id: "g_balance",
            title: "The Art of Balance",
            subtitle: "Reading a whole world in one glance",
            plateArt: "guide_balance",
            paragraphs: [
                "Ask an old keeper how their jar is doing and they will glance, not inspect. The signs read together: leaves the right colour, glass misting and clearing on schedule, litter vanishing as fast as it falls, air that would smell of forest floor if you could smell it. Balance is not any one number; it is the hum of all the loops running.",
                "Every intervention has a price. Opening the lid resets the atmosphere the plants have been quietly composing; a heavy misting can push a dry-side jar straight past ideal into swamp. The keeper's discipline is smallest-move-first: change the light before the water, wait before both, and let the crew try before you reach in.",
                "The deepest habit is trusting the system you built. You chose tenants that agree about light and water; you hired the crew; you shut the lid on a working economy. From then on the glade mostly needs a witness, not a manager — and the jars that thrive longest belong to keepers who learned to sit on their hands.",
            ],
            facts: [
                "Experienced keepers intervene less each year they keep jars, not more.",
                "The healthiest sign a jar can show is needing nothing.",
                "Changing the jar's position is the gentlest intervention there is — no lid required.",
            ]),
        GladeGuide(
            id: "g_ward",
            title: "The Accidental Invention",
            subtitle: "Dr Ward's moth, and the case that changed the world",
            plateArt: "guide_ward",
            paragraphs: [
                "In 1829 a London doctor named Nathaniel Ward sealed a moth chrysalis in a glass bottle with a little soil, and noticed something he was not looking for: a fern sprouting inside, thriving in the sooty city where his garden ferns always died. The sealed glass held clean, moist air. He had invented the terrarium by accident, while watching for a moth.",
                "The Wardian case, as it became known, changed rather more than parlour decoration. For the first time, living plants could survive months at sea, sealed against salt spray and neglect: tea reached India, rubber reached Malaya, orchids and bananas crossed oceans in glass cases lashed to ships' decks. World trade rerouted itself through a doctor's bottle.",
                "The parlours took note as well: Victorian drawing rooms filled with ferns under glass, a full-blown craze with a name — pteridomania, fern madness. Every jar on a modern windowsill is a small descendant of Ward's accident, still doing what it did in 1829: holding a private climate steady while the world outside does otherwise.",
            ],
            facts: [
                "Dr Ward was watching for a moth; the fern was the accident.",
                "Wardian cases carried tea plants out of China and rubber to Southeast Asia.",
                "The Victorian fern craze had its own name: pteridomania.",
            ]),
        GladeGuide(
            id: "g_bottle",
            title: "The Fifty-Year Bottle",
            subtitle: "The garden that was last watered in 1972",
            plateArt: "guide_bottle",
            paragraphs: [
                "In 1960, an Englishman named David Latimer put compost and a spiderwort seedling into a large glass carboy, added a quarter pint of water, and corked it. He watered it exactly once more, in 1972, and then never opened it again. The plant filled the bottle, made its own weather, and simply kept going, decade after decade.",
                "Inside that bottle, the loops run textbook-clean: the plant grows by light, sheds leaves that rot into food, breathes out what it will later breathe in, and drinks the same water in perpetual rotation. The bottle sits by a window and gets turned occasionally so growth stays even. That is the entirety of its care.",
                "The lesson is that a closed system does not need management once its parts agree — it needs light and patience. Every keeper who seals a jar is running the same experiment at a friendlier scale, with better glass and the advantage of knowing, thanks to one corked carboy, that the experiment can run for a lifetime.",
            ],
            facts: [
                "Latimer's bottle garden received water twice in its first sixty years: at planting, and in 1972.",
                "The sealed spiderwort composts its own fallen leaves for nutrients.",
                "Its only maintenance is an occasional quarter-turn toward the light.",
            ]),
        GladeGuide(
            id: "g_build",
            title: "Building One for Real",
            subtitle: "From clean jar to closed world, in an afternoon",
            plateArt: "guide_build",
            paragraphs: [
                "The real thing takes an afternoon and rewards a lifetime. Begin with any clear glass vessel that closes — the classic sweet jar, a flip-top pantry jar, a carboy if you are feeling historic. Wash it well: you are hiring the microbes you want, not sterilising, but starting clean.",
                "Lay the geology first: a couple of fingers of pebbles for the false bottom, a thin seam of activated charcoal, then several fingers of a light, peat-free potting mix. Plant small and plant few — moss and one or two humidity-lovers — remembering that everything you place intends to grow. Water sparingly until the soil is barely moist, never wet; you can add a spoonful later far more easily than you can take one out.",
                "Seal it, set it in bright indirect light, and spend the first fortnight reading the glass: fog that clears by afternoon is right, walls that stream all day mean crack the lid for a few hours. Add springtails if you can get them; they will beat you to every problem. Then do the hardest thing in the hobby, which is nothing.",
            ],
            facts: [
                "Any clear jar that seals can become a glade — sweet jars are the classic.",
                "Underwatering at planting is the single best gift you can give a new jar.",
                "The first two weeks of glass-reading set up the next ten years of doing nothing.",
            ]),
    ]
}
