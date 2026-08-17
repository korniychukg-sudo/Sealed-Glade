import SwiftUI

enum JarSpot: String, Codable, CaseIterable {
    case shade, bright, sun

    var light: Double {
        switch self {
        case .shade: return 0.32
        case .bright: return 0.62
        case .sun: return 0.92
        }
    }
    var label: String {
        switch self {
        case .shade: return "Shaded corner"
        case .bright: return "Bright sill"
        case .sun: return "Direct sun"
        }
    }
    var caution: String {
        switch self {
        case .shade: return "Gentle and slow — the moss's favourite."
        case .bright: return "Bright but soft; most jars are happiest here."
        case .sun: return "Fierce light. Sun-lovers thrive, everything else cooks."
        }
    }
}

enum JarShape: String, Codable, CaseIterable {
    case belly, column, flask

    var label: String {
        switch self {
        case .belly: return "Belly Jar"
        case .column: return "Tall Column"
        case .flask: return "Corked Flask"
        }
    }
}

struct PlantInstance: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var speciesID: String
    var x: Double
    var growth: Double = 0.16
    var health: Double = 0.8
    var seed: UInt64 = UInt64.random(in: 1...99999)
}

struct FaunaInstance: Codable, Equatable {
    var speciesID: String
    var population: Double = 0.3
}

struct JarEvent: Codable, Identifiable {
    var id: UUID = UUID()
    var day: Int
    var text: String
    var kind: String
}

struct JarState: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var shape: JarShape
    var spot: JarSpot
    var createdAt: Date = Date()
    var lastTick: Date = Date()
    var water: Double = 0.6
    var mold: Double = 0.05
    var algae: Double = 0.03
    var air: Double = 0.85
    var deadMatter: Double = 0.05
    var plants: [PlantInstance] = []
    var fauna: [FaunaInstance] = []
    var dayCount: Int = 0
    var sealedDays: Int = 0
    var bestSealedDays: Int = 0
    var timesOpened: Int = 0
    var eventLog: [JarEvent] = []

    static func == (a: JarState, b: JarState) -> Bool { a.id == b.id && a.dayCount == b.dayCount && a.plants == b.plants && a.lastTick == b.lastTick }

    func population(_ speciesID: String) -> Double {
        fauna.first { $0.speciesID == speciesID }?.population ?? 0
    }

    var plantHealthAverage: Double {
        guard !plants.isEmpty else { return 0.5 }
        return plants.map { $0.health }.reduce(0, +) / Double(plants.count)
    }

    var biomass: Double {
        plants.map { $0.growth }.reduce(0, +)
    }

    var balance: Double {
        var score = 0.0
        score += plantHealthAverage * 38
        score += (1 - mold) * 18
        score += (1 - algae) * 12
        score += air * 14
        let waterFit = 1 - (abs(water - 0.6) / 0.4).gladeClamped(0, 1)
        score += waterFit * 18
        return score.gladeClamped(0, 100)
    }

    var weakestLink: String {
        var worst = ("the plants", 1 - plantHealthAverage)
        if mold > worst.1 { worst = ("the mould", mold) }
        if algae > worst.1 { worst = ("algae on the glass", algae) }
        if 1 - air > worst.1 { worst = ("stale air", 1 - air) }
        let waterMiss = (abs(water - 0.6) / 0.4).gladeClamped(0, 1)
        if waterMiss > worst.1 { worst = (water > 0.6 ? "too much water" : "thirsty soil", waterMiss) }
        if worst.1 < 0.25 { return "nothing — the glade is holding its own" }
        return worst.0
    }
}

enum JarSim {
    static func dailyTick(_ jar: inout JarState, rng: inout GladeSeededRandom) {
        jar.dayCount += 1
        jar.sealedDays += 1
        jar.bestSealedDays = max(jar.bestSealedDays, jar.sealedDays)
        let light = jar.spot.light

        var newDead = 0.0
        for i in jar.plants.indices {
            let species = GladeSpecies.plant(jar.plants[i].speciesID)
            let lightMiss = abs(light - species.lightPref)
            let waterMiss = abs(jar.water - species.moisturePref)
            let fit = (1 - lightMiss * 1.7 - waterMiss * 1.5 + species.hardiness * 0.12).gladeClamped(0, 1.05)
            let drift = (fit - 0.52) * 0.22
            jar.plants[i].health = (jar.plants[i].health + drift).gladeClamped(0.02, 1)
            if jar.plants[i].health > 0.35 {
                let crowding = (1 - jar.biomass / 6.5).gladeClamped(0.25, 1)
                jar.plants[i].growth = (jar.plants[i].growth + species.growthRate * 0.028 * fit * crowding).gladeClamped(0.05, 1)
            } else {
                newDead += 0.035
                jar.plants[i].growth = (jar.plants[i].growth - 0.01).gladeClamped(0.05, 1)
            }
        }
        jar.deadMatter = (jar.deadMatter + newDead + 0.006).gladeClamped(0, 1)

        let springtails = jar.population("springtails")
        let isopods = jar.population("dwarfisopods") + jar.population("clownisopods")
        let snails = jar.population("snail")

        let moldFood = jar.deadMatter * 0.055 + max(0, jar.water - 0.72) * 0.05 + max(0, 0.4 - light) * 0.012
        jar.mold = (jar.mold + moldFood - springtails * 0.075 - 0.004).gladeClamped(0, 1)
        jar.algae = (jar.algae + max(0, light * jar.water - 0.42) * 0.05 - snails * 0.06 - 0.002).gladeClamped(0, 1)
        jar.deadMatter = (jar.deadMatter - isopods * 0.055).gladeClamped(0, 1)
        jar.air = (jar.air + jar.biomass * 0.022 * light - jar.mold * 0.05 - 0.012).gladeClamped(0.05, 1)
        jar.water = (jar.water + Double(rng.next()) * 0.01 - 0.005).gladeClamped(0.05, 1)

        updatePopulations(&jar, springFood: jar.mold + jar.deadMatter * 0.5, litterFood: jar.deadMatter, algaeFood: jar.algae, rng: &rng)
        makeEvents(&jar, rng: &rng)
        if jar.eventLog.count > 40 {
            jar.eventLog.removeLast(jar.eventLog.count - 40)
        }
    }

    private static func updatePopulations(_ jar: inout JarState, springFood: Double, litterFood: Double, algaeFood: Double, rng: inout GladeSeededRandom) {
        for i in jar.fauna.indices {
            let id = jar.fauna[i].speciesID
            let food: Double
            switch id {
            case "springtails": food = springFood
            case "snail": food = algaeFood
            default: food = litterFood
            }
            let pop = jar.fauna[i].population
            let growth = (food * 1.6 - 0.06) * 0.3
            let capped = (pop + growth * pop * (1 - pop)).gladeClamped(id == "snail" ? 0.05 : 0.04, 1)
            jar.fauna[i].population = capped
        }
        if jar.population("snail") > 0.5 {
            for i in jar.plants.indices where Double(rng.next()) < 0.2 {
                jar.plants[i].growth = (jar.plants[i].growth - 0.015).gladeClamped(0.05, 1)
            }
        }
    }

    private static func makeEvents(_ jar: inout JarState, rng: inout GladeSeededRandom) {
        var texts: [(String, String)] = []
        if let sprout = jar.plants.first(where: { $0.growth > 0.5 && $0.growth < 0.56 }) {
            let name = GladeSpecies.plant(sprout.speciesID).name.lowercased()
            texts.append(("The \(name) has pushed out new growth — it is halfway to filling its corner.", "growth"))
        }
        if let struggling = jar.plants.first(where: { $0.health < 0.3 }) {
            let name = GladeSpecies.plant(struggling.speciesID).name.lowercased()
            texts.append(("The \(name) is browning at the edges. The light or the water is not to its taste.", "warning"))
        }
        if jar.mold > 0.5 && Double(rng.next()) < 0.6 {
            texts.append(("A grey fuzz of mould is spreading. The springtails are behind on their rounds.", "warning"))
        }
        if jar.mold > 0.15 && jar.mold < 0.25 && jar.population("springtails") > 0.5 {
            texts.append(("The springtail crew has the mould in full retreat.", "good"))
        }
        if jar.algae > 0.5 && Double(rng.next()) < 0.5 {
            texts.append(("Green algae is filming the glass; the view inward is going soft.", "warning"))
        }
        if jar.sealedDays == 7 { texts.append(("Seven days sealed. The little world is holding its own breath and thriving.", "milestone")) }
        if jar.sealedDays == 30 { texts.append(("Thirty days without opening the lid. The jar has forgotten it needs you.", "milestone")) }
        if jar.sealedDays == 100 { texts.append(("One hundred sealed days. This is a world now, not a jar.", "milestone")) }
        if texts.isEmpty && Double(rng.next()) < 0.25 {
            let quiet = [
                "Condensation beads rolled down the glass at dawn — the water cycle, doing its rounds.",
                "A springtail crossed the whole glade today, an epic nobody witnessed.",
                "Nothing happened today, which for a sealed world is the whole point.",
                "The moss looked especially like velvet this morning.",
                "An isopod rearranged a speck of leaf litter with great seriousness.",
            ]
            texts.append((quiet[Int(rng.next() * CGFloat(quiet.count)) % quiet.count], "quiet"))
        }
        for (text, kind) in texts.prefix(2) {
            jar.eventLog.insert(JarEvent(day: jar.dayCount, text: text, kind: kind), at: 0)
        }
    }

    static func catchUp(_ jar: inout JarState, now: Date = Date()) -> Int {
        let elapsed = Calendar.current.dateComponents([.day], from: jar.lastTick, to: now).day ?? 0
        guard elapsed > 0 else { return 0 }
        let days = min(elapsed, 45)
        var rng = GladeSeededRandom(seed: UInt64(abs(jar.id.hashValue % 100000)) &+ UInt64(jar.dayCount))
        for _ in 0..<days {
            dailyTick(&jar, rng: &rng)
        }
        jar.lastTick = now
        return days
    }

    static func vent(_ jar: inout JarState) {
        jar.air = 1
        jar.water = (jar.water - 0.07).gladeClamped(0.05, 1)
        markOpened(&jar)
    }

    static func mist(_ jar: inout JarState) {
        jar.water = (jar.water + 0.12).gladeClamped(0.05, 1)
        markOpened(&jar)
    }

    static func wipeGlass(_ jar: inout JarState) {
        jar.algae = 0.03
        markOpened(&jar)
    }

    static func pruneDead(_ jar: inout JarState) {
        jar.deadMatter = 0.02
        for i in jar.plants.indices where jar.plants[i].health < 0.3 {
            jar.plants[i].health = 0.45
            jar.plants[i].growth = (jar.plants[i].growth * 0.8).gladeClamped(0.1, 1)
        }
        markOpened(&jar)
    }

    static func markOpened(_ jar: inout JarState) {
        jar.timesOpened += 1
        if jar.sealedDays > 0 {
            jar.eventLog.insert(JarEvent(day: jar.dayCount, text: "The lid came off after \(jar.sealedDays) sealed \(jar.sealedDays == 1 ? "day" : "days"). The seal count begins again.", kind: "opened"), at: 0)
        }
        jar.sealedDays = 0
    }

    static func starter(name: String) -> JarState {
        var jar = JarState(name: name, shape: .belly, spot: .bright)
        jar.plants = [
            PlantInstance(speciesID: "cushionmoss", x: 0.3),
            PlantInstance(speciesID: "fernsprout", x: 0.62),
            PlantInstance(speciesID: "nerveplant", x: 0.82),
        ]
        jar.fauna = [FaunaInstance(speciesID: "springtails", population: 0.4)]
        jar.eventLog = [JarEvent(day: 0, text: "The lid closed for the first time. From now on, this world waters itself.", kind: "milestone")]
        return jar
    }
}
