import SwiftUI

struct GladeTerm: Identifiable {
    var id: String { term }
    let term: String
    let definition: String
}

enum GladeGlossary {
    static let terms: [GladeTerm] = [
        GladeTerm(term: "Activated charcoal", definition: "The jar's filter layer: charcoal processed to be riddled with microscopic pores that trap the sour by-products of decay."),
        GladeTerm(term: "Algae", definition: "The green film that pioneers any surface where light and moisture meet — harmless to plants, fatal to the view."),
        GladeTerm(term: "Balance", definition: "The state where all the jar's loops — water, growth, decay, cleanup — run without the keeper's hand."),
        GladeTerm(term: "Biome in a bottle", definition: "The keeper's affectionate name for a sealed jar: a complete habitat with its own weather."),
        GladeTerm(term: "Bioactive", definition: "A setup whose waste is processed by living decomposers rather than removed by cleaning."),
        GladeTerm(term: "Bromeliad", definition: "The pineapple's family of rosette plants; the earth star is the jar-sized member."),
        GladeTerm(term: "Cleanup crew", definition: "The employed decomposers of a sealed world — springtails and isopods, chiefly — who turn litter back into soil."),
        GladeTerm(term: "Closed system", definition: "A world that exchanges nothing with the outside but light: water, air and nutrients all cycle within."),
        GladeTerm(term: "Condensation", definition: "The jar's rainfall: vapour meeting cool glass and beading into droplets that return to the soil."),
        GladeTerm(term: "Decomposer", definition: "Any organism that eats the dead and returns it to circulation; the engine room of every ecosystem."),
        GladeTerm(term: "Detritus", definition: "Fallen leaves and spent growth — the litter that feeds the crew, or the mould if the crew is short-handed."),
        GladeTerm(term: "Drainage layer", definition: "The pebble basement of the jar, where surplus water waits without drowning the roots."),
        GladeTerm(term: "Epiphyte", definition: "A plant that grows perched on others rather than in soil, drinking from the air."),
        GladeTerm(term: "False bottom", definition: "Another name for the drainage layer: a drain for a vessel that cannot drain."),
        GladeTerm(term: "Fern madness", definition: "Pteridomania: the Victorian craze for ferns under glass that followed the Wardian case."),
        GladeTerm(term: "Frond", definition: "A fern's whole leaf, unrolling from a coiled fiddlehead as it grows."),
        GladeTerm(term: "Hardscape", definition: "The unliving architecture of a jar — stones, wood, slopes — that gives the green something to conquer."),
        GladeTerm(term: "Humidity", definition: "The air's cargo of water vapour; near-saturated in a sealed jar, which is why rainforest plants thrive there."),
        GladeTerm(term: "Isopod", definition: "A land crustacean — an air-breathing cousin of crabs — employed in jars as an armoured recycler."),
        GladeTerm(term: "Litter", definition: "The fallen plant matter on the soil surface; a food store in a working jar, a mould farm in a stalled one."),
        GladeTerm(term: "Microclimate", definition: "A pocket of weather different from its surroundings; every sealed jar is a deliberately built one."),
        GladeTerm(term: "Mould bloom", definition: "A flush of fungal fuzz on new litter — a backlog notice to the cleanup crew, not a catastrophe."),
        GladeTerm(term: "Photosynthesis", definition: "The plant's trade of light, water and carbon dioxide for sugar and oxygen — the only import a sealed jar needs."),
        GladeTerm(term: "Rosette", definition: "A growth habit of leaves radiating flat from a centre, like the earth star's."),
        GladeTerm(term: "Springtail", definition: "A near-microscopic soil animal with a latch-loaded leaping tail; the jar's mould-grazing janitor."),
        GladeTerm(term: "Substrate", definition: "Everything below the plants: the layered soil, charcoal and pebbles the world stands on."),
        GladeTerm(term: "Terrarium", definition: "A garden under glass; sealed, it becomes a closed world with its own water cycle."),
        GladeTerm(term: "Transpiration", definition: "The exhale of leaves: water drawn from soil and released as vapour, lifting the jar's rain."),
        GladeTerm(term: "Wardian case", definition: "The sealed glass case of 1829 that carried live plants across oceans and invented the terrarium by accident."),
        GladeTerm(term: "Water cycle", definition: "The loop of evaporation, condensation and return that lets a sealed jar water itself indefinitely."),
    ]
}

struct GladeQuizQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

enum GladeQuiz {
    static func makeRound(seed: UInt64? = nil) -> [GladeQuizQuestion] {
        var rng = GladeSeededRandom(seed: seed ?? UInt64(Date().timeIntervalSince1970 * 1000))
        var questions: [GladeQuizQuestion] = []
        var usedTerms: Set<String> = []
        var usedPlants: Set<String> = []
        for _ in 0..<3 {
            if let q = termQuestion(&rng, used: &usedTerms) { questions.append(q) }
        }
        for _ in 0..<2 {
            if let q = reverseTermQuestion(&rng, used: &usedTerms) { questions.append(q) }
        }
        for _ in 0..<2 {
            if let q = plantQuestion(&rng, used: &usedPlants) { questions.append(q) }
        }
        questions.append(contentsOf: factQuestions(&rng, count: 3))
        while questions.count > 10 { questions.removeLast() }
        var shuffled: [GladeQuizQuestion] = []
        var pool = questions
        while !pool.isEmpty {
            shuffled.append(pool.remove(at: rng.nextInt(pool.count)))
        }
        return shuffled
    }

    private static func pickDistinct(_ rng: inout GladeSeededRandom, count: Int, upper: Int, avoiding: Int?) -> [Int] {
        var picks: Set<Int> = []
        var guardCount = 0
        while picks.count < count && guardCount < 200 {
            guardCount += 1
            let v = rng.nextInt(upper)
            if v != avoiding { picks.insert(v) }
        }
        return Array(picks)
    }

    private static func shuffleOptions(_ rng: inout GladeSeededRandom, _ options: [String]) -> [String] {
        var tmp = options
        var result: [String] = []
        while !tmp.isEmpty { result.append(tmp.remove(at: rng.nextInt(tmp.count))) }
        return result
    }

    private static func termQuestion(_ rng: inout GladeSeededRandom, used: inout Set<String>) -> GladeQuizQuestion? {
        let pool = GladeGlossary.terms.enumerated().filter { !used.contains($0.element.term) }
        guard pool.count >= 4 else { return nil }
        let pick = pool[rng.nextInt(pool.count)]
        used.insert(pick.element.term)
        var options = [pick.element.term]
        for w in pickDistinct(&rng, count: 3, upper: GladeGlossary.terms.count, avoiding: pick.offset) {
            options.append(GladeGlossary.terms[w].term)
        }
        guard options.count == 4 else { return nil }
        let shuffled = shuffleOptions(&rng, options)
        guard let correct = shuffled.firstIndex(of: pick.element.term) else { return nil }
        return GladeQuizQuestion(
            prompt: "Which term does the field guide define as: \u{201C}\(pick.element.definition)\u{201D}",
            options: shuffled, correctIndex: correct,
            explanation: "\(pick.element.term): \(pick.element.definition)")
    }

    private static func reverseTermQuestion(_ rng: inout GladeSeededRandom, used: inout Set<String>) -> GladeQuizQuestion? {
        let pool = GladeGlossary.terms.enumerated().filter { !used.contains($0.element.term) }
        guard pool.count >= 4 else { return nil }
        let pick = pool[rng.nextInt(pool.count)]
        used.insert(pick.element.term)
        var options = [pick.element.definition]
        for w in pickDistinct(&rng, count: 3, upper: GladeGlossary.terms.count, avoiding: pick.offset) {
            options.append(GladeGlossary.terms[w].definition)
        }
        guard options.count == 4 else { return nil }
        let shuffled = shuffleOptions(&rng, options)
        guard let correct = shuffled.firstIndex(of: pick.element.definition) else { return nil }
        return GladeQuizQuestion(
            prompt: "What does \u{201C}\(pick.element.term)\u{201D} mean?",
            options: shuffled, correctIndex: correct,
            explanation: "\(pick.element.term): \(pick.element.definition)")
    }

    private static func plantQuestion(_ rng: inout GladeSeededRandom, used: inout Set<String>) -> GladeQuizQuestion? {
        let pool = GladeSpecies.plants.enumerated().filter { !used.contains($0.element.id) }
        guard pool.count >= 4 else { return nil }
        let pick = pool[rng.nextInt(pool.count)]
        used.insert(pick.element.id)
        let firstSentence = pick.element.note.split(separator: ".").first.map(String.init) ?? pick.element.note
        var options = [pick.element.name]
        for w in pickDistinct(&rng, count: 3, upper: GladeSpecies.plants.count, avoiding: pick.offset) {
            options.append(GladeSpecies.plants[w].name)
        }
        guard options.count == 4 else { return nil }
        let shuffled = shuffleOptions(&rng, options)
        guard let correct = shuffled.firstIndex(of: pick.element.name) else { return nil }
        return GladeQuizQuestion(
            prompt: "Which tenant of the jar is this? \u{201C}\(firstSentence).\u{201D}",
            options: shuffled, correctIndex: correct,
            explanation: "\(pick.element.name) (\(pick.element.latin)).")
    }

    private static let factBank: [(String, String, [String], String)] = [
        ("What is the only thing a sealed jar imports from outside?", "Light", ["Fresh water", "Fresh air", "Fertiliser"], "Everything else cycles inside; light is the engine that runs the loops."),
        ("What does the condensation on the glass actually do?", "Returns to the soil as the jar's rainfall", ["Feeds the algae only", "Escapes through the lid", "Damages the plants"], "Vapour beads on the cool glass and slides back down — a water cycle in miniature."),
        ("What is the pebble layer at the bottom of a jar for?", "Giving surplus water somewhere to stand", ["Anchoring the roots", "Feeding the isopods", "Keeping the jar upright"], "The false bottom keeps soil moist but never waterlogged, in a vessel that cannot drain."),
        ("Why does a jar carry a seam of activated charcoal?", "It traps the sour by-products of decay", ["It feeds the springtails", "It darkens the soil", "It warms the roots"], "Charcoal's microscopic pores adsorb the compounds of rot, keeping the closed world sweet."),
        ("What do springtails mostly eat in a sealed jar?", "Mould", ["Living leaves", "Each other", "Algae on the glass"], "They graze mould like sheep on a hillside — the jar's most important janitors."),
        ("A fresh patch of grey mould in a young jar usually means what?", "The cleanup crew hasn't caught up with the litter yet", ["The jar is ruined", "The plants are diseased", "The glass is failing"], "Most blooms are a backlog notice, and a healthy springtail colony clears them in days."),
        ("Why is direct sunlight dangerous for a sealed jar?", "Glass traps heat and can cook the garden", ["It fades the leaves' colour", "It dries the lid seal", "It breeds too many isopods"], "A jar in the sun is a tiny greenhouse; an afternoon can overheat a world."),
        ("What was Dr Ward actually watching when he invented the terrarium?", "A moth chrysalis", ["A fern spore", "A bottle of rainwater", "A colony of ants"], "The fern that sprouted in his sealed moth jar was the accident that changed plant history."),
        ("How many times has the famous 1960 bottle garden been watered since planting?", "Twice, the last time in 1972", ["Every year", "Never", "Monthly"], "David Latimer's corked carboy has run on its own weather for decades."),
        ("What did Wardian cases make possible in the 1800s?", "Shipping live plants across oceans", ["Growing plants without light", "Breeding sterile soil", "Refrigerating cut flowers"], "Sealed glass cases carried tea, rubber and orchids around the world."),
        ("What is the gentlest first response to a jar with streaming, all-day condensation?", "Crack the lid and let it dry a little", ["Add more water", "Move it into direct sun", "Remove the plants"], "All-day streaming means too much water aboard; a few hours open rebalances it."),
        ("What makes a setup 'bioactive'?", "Living decomposers process the waste", ["It uses electric light", "The soil is sterilised", "It contains only moss"], "Springtails and isopods turn litter back into soil — cleaning that hires itself."),
    ]

    private static func factQuestions(_ rng: inout GladeSeededRandom, count: Int) -> [GladeQuizQuestion] {
        var result: [GladeQuizQuestion] = []
        var usedIdx: Set<Int> = []
        var guardCount = 0
        while result.count < count && guardCount < 60 {
            guardCount += 1
            let idx = rng.nextInt(factBank.count)
            guard !usedIdx.contains(idx) else { continue }
            usedIdx.insert(idx)
            let fact = factBank[idx]
            let shuffled = shuffleOptions(&rng, [fact.1] + fact.2)
            guard let correct = shuffled.firstIndex(of: fact.1) else { continue }
            result.append(GladeQuizQuestion(prompt: fact.0, options: shuffled, correctIndex: correct, explanation: fact.3))
        }
        return result
    }
}
