import SwiftUI

enum PlantDrawKind: String, Codable {
    case mound, frond, veined, creeping, broad, trailing, spikes, rosette, buttons, fan
}

struct PlantSpecies: Identifiable {
    let id: String
    let name: String
    let latin: String
    let note: String
    let lightPref: Double
    let moisturePref: Double
    let hardiness: Double
    let growthRate: Double
    let drawKind: PlantDrawKind
    let hue: Int
    let unlockRank: Int

    var plateArt: String { "plant_\(id)" }
}

struct FaunaSpecies: Identifiable {
    let id: String
    let name: String
    let latin: String
    let note: String
    let role: String
    let unlockRank: Int

    var plateArt: String { "fauna_\(id)" }
}

enum GladeSpecies {
    static func plant(_ id: String) -> PlantSpecies {
        plants.first { $0.id == id } ?? plants[0]
    }

    static func fauna(_ id: String) -> FaunaSpecies {
        faunas.first { $0.id == id } ?? faunas[0]
    }

    static let plants: [PlantSpecies] = [
        PlantSpecies(
            id: "cushionmoss", name: "Cushion Moss", latin: "Leucobryum glaucum",
            note: "The green velvet every glade begins with. Moss has no roots to speak of and drinks straight through its leaves, which is why it adores a sealed jar: the air itself waters it. Give it shade and it will quietly carpet everything you let it.",
            lightPref: 0.35, moisturePref: 0.75, hardiness: 0.85, growthRate: 0.7, drawKind: .mound, hue: 0, unlockRank: 0),
        PlantSpecies(
            id: "fernsprout", name: "Fern Sprout", latin: "Asplenium bulbiferum",
            note: "A young fern unrolls its fronds like tiny green fiddleheads, one at a time, each a small ceremony. Ferns are older than flowers and remember a world that was all swamp and mist — a sealed jar is the closest thing to home they have met in a hundred million years.",
            lightPref: 0.5, moisturePref: 0.8, hardiness: 0.6, growthRate: 0.9, drawKind: .frond, hue: 1, unlockRank: 0),
        PlantSpecies(
            id: "nerveplant", name: "Nerve Plant", latin: "Fittonia albivenis",
            note: "Every leaf is a little map of silver or pink veins, drawn fine as lace. The nerve plant faints theatrically when thirsty and springs back within the hour when watered — in a sealed jar it never gets the chance to perform, and simply glows.",
            lightPref: 0.55, moisturePref: 0.8, hardiness: 0.55, growthRate: 1.0, drawKind: .veined, hue: 2, unlockRank: 0),
        PlantSpecies(
            id: "babytears", name: "Baby Tears", latin: "Soleirolia soleirolii",
            note: "Thousands of leaves smaller than grains of rice, spilling over every stone they meet. Baby tears grows like a rumour, and in the closed warmth of a jar it will happily attempt to cover the entire world, one millimetre at a time.",
            lightPref: 0.6, moisturePref: 0.8, hardiness: 0.6, growthRate: 1.15, drawKind: .creeping, hue: 3, unlockRank: 1),
        PlantSpecies(
            id: "peperomia", name: "Dwarf Peperomia", latin: "Peperomia prostrata",
            note: "Thick, coin-round leaves that store their own water, painted in quiet greens. Peperomia is the calm tenant of the jar: it asks little, grows tidily, and never quarrels with the neighbours.",
            lightPref: 0.55, moisturePref: 0.55, hardiness: 0.85, growthRate: 0.6, drawKind: .broad, hue: 4, unlockRank: 1),
        PlantSpecies(
            id: "ivysprig", name: "Ivy Sprig", latin: "Hedera helix minima",
            note: "A single cutting of miniature ivy, already plotting its route up the glass. Ivy grips with tiny rootlets and maps the jar wall like a climber studying a cliff face; prune it kindly or accept that the view will one day be all leaves.",
            lightPref: 0.5, moisturePref: 0.55, hardiness: 0.8, growthRate: 0.85, drawKind: .trailing, hue: 5, unlockRank: 2),
        PlantSpecies(
            id: "clubmoss", name: "Club Moss", latin: "Selaginella kraussiana",
            note: "Not a true moss but an ancient cousin of the ferns, dressed in scales of gold-green. Club moss creeps in soft branching sprays and glitters faintly when the light comes low through the glass.",
            lightPref: 0.4, moisturePref: 0.85, hardiness: 0.55, growthRate: 0.9, drawKind: .spikes, hue: 6, unlockRank: 2),
        PlantSpecies(
            id: "earthstar", name: "Earth Star", latin: "Cryptanthus bivittatus",
            note: "A flat starburst of striped leaves that sits on the soil like a fallen decoration. Earth stars are bromeliads, cousins of the pineapple, and bring the only stripes and the only pink most jars will ever legally contain.",
            lightPref: 0.65, moisturePref: 0.55, hardiness: 0.75, growthRate: 0.5, drawKind: .rosette, hue: 7, unlockRank: 3),
        PlantSpecies(
            id: "turtlestring", name: "String of Turtles", latin: "Peperomia prostrata",
            note: "A thread-thin vine hung with leaves patterned exactly like tiny turtle shells. It drapes over stones and ledges a leaf at a time, and visitors will refuse to believe it is real until they have stared from very close.",
            lightPref: 0.7, moisturePref: 0.45, hardiness: 0.6, growthRate: 0.55, drawKind: .buttons, hue: 8, unlockRank: 4),
        PlantSpecies(
            id: "pothos", name: "Pothos Cutting", latin: "Epipremnum aureum",
            note: "The most forgiving plant in cultivation, said to grow in a dark cupboard out of sheer politeness. A single golden-splashed cutting will root in the jar's soil within days and then set about redecorating.",
            lightPref: 0.5, moisturePref: 0.55, hardiness: 0.95, growthRate: 0.8, drawKind: .broad, hue: 9, unlockRank: 4),
        PlantSpecies(
            id: "maidenhair", name: "Maidenhair Fern", latin: "Adiantum raddianum",
            note: "Fronds so fine they tremble at a footstep across the room, on stems dark and glossy as wet ink. Outside a jar the maidenhair is famously dramatic about humidity; inside one, it is finally, blessedly content.",
            lightPref: 0.4, moisturePref: 0.9, hardiness: 0.4, growthRate: 0.85, drawKind: .frond, hue: 10, unlockRank: 5),
        PlantSpecies(
            id: "dwarfpalm", name: "Dwarf Palm Seedling", latin: "Chamaedorea elegans",
            note: "A palm the size of a teaspoon, holding up its first fan of leaves like a flag on a new island. It will spend years pretending the jar is a jungle clearing, growing with the unhurried confidence of a tree that believes it has centuries.",
            lightPref: 0.7, moisturePref: 0.6, hardiness: 0.7, growthRate: 0.45, drawKind: .fan, hue: 11, unlockRank: 6),
    ]

    static let faunas: [FaunaSpecies] = [
        FaunaSpecies(
            id: "springtails", name: "Springtails", latin: "Folsomia candida",
            note: "White specks the size of a full stop, each armed with a spring-loaded tail that flings it many body-lengths when alarmed. They graze on mould the way sheep graze on grass, which makes them the most important janitors a sealed world can hire.",
            role: "Mould patrol", unlockRank: 0),
        FaunaSpecies(
            id: "dwarfisopods", name: "Dwarf White Isopods", latin: "Trichorhina tomentosa",
            note: "Tiny pale woodlice that work the soil like a night shift that never ends: shredding fallen leaves, turning waste back into food for the plants. A jar with isopods is a jar with a working recycling department.",
            role: "Litter crew", unlockRank: 1),
        FaunaSpecies(
            id: "clownisopods", name: "Clown Isopods", latin: "Armadillidium klugii",
            note: "Dressed in polka dots like tiny painted shields, clown isopods do the same honest litter work as their plain cousins while looking spectacular doing it. They roll into perfect spheres when startled, which is often, and adorable, always.",
            role: "Litter crew, formal wear", unlockRank: 3),
        FaunaSpecies(
            id: "snail", name: "Glass Snail", latin: "Oxychilus alliarius",
            note: "A snail small enough to ride a fingertip, with a shell like smoked glass. It patrols the walls rasping away algae in wandering ribbons — the jar's window cleaner, paid entirely in the mess it removes, though it will absolutely also taste your plants.",
            role: "Glass cleaning", unlockRank: 5),
    ]
}
