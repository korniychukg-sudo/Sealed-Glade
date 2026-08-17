import SwiftUI
import Combine

struct GladeRank {
    let name: String
    let xp: Int
}

struct GladeStats: Codable {
    var xp: Int = 0
    var jarsBuilt: Int = 0
    var daysWitnessed: Int = 0
    var bestSealedDays: Int = 0
    var plantsPlanted: Int = 0
    var speciesUsed: Set<String> = []
    var faunaUsed: Set<String> = []
    var guidesRead: Set<String> = []
    var quizBest: Int = 0
    var quizRounds: Int = 0
    var notesDone: Set<String> = []
    var playDays: Set<String> = []
    var bestDayStreak: Int = 0
    var awards: Set<String> = []
    var tendActions: Int = 0
    var eventsSeen: Int = 0
}

struct GladeSave: Codable {
    var jars: [JarState]?
    var currentJar: Int?
    var stats: GladeStats?
    var onboardingDone: Bool?
    var reduceMotion: Bool?
}

final class GladeStore: ObservableObject {
    static let saveKey = "sealed_glade_save_v1"

    @Published var jars: [JarState]
    @Published var currentJar: Int
    @Published var stats: GladeStats
    @Published var onboardingDone: Bool
    @Published var reduceMotion: Bool
    @Published var celebration: String?
    @Published var catchUpReport: String?

    private var saveWork: DispatchWorkItem?

    static let ranks: [GladeRank] = [
        GladeRank(name: "Curious Visitor", xp: 0),
        GladeRank(name: "Jar Builder", xp: 110),
        GladeRank(name: "Moss Tender", xp: 290),
        GladeRank(name: "Crew Keeper", xp: 560),
        GladeRank(name: "Balance Reader", xp: 920),
        GladeRank(name: "Rain Maker", xp: 1400),
        GladeRank(name: "Glade Warden", xp: 2000),
        GladeRank(name: "Keeper of the Glade", xp: 2750),
    ]

    init() {
        var loadedJars: [JarState] = []
        var loadedCurrent = 0
        var loadedStats = GladeStats()
        var loadedOnboarding = false
        var loadedReduce = false
        if let data = UserDefaults.standard.data(forKey: GladeStore.saveKey),
           let save = try? JSONDecoder().decode(GladeSave.self, from: data) {
            loadedJars = save.jars ?? []
            loadedCurrent = save.currentJar ?? 0
            loadedStats = save.stats ?? GladeStats()
            loadedOnboarding = save.onboardingDone ?? false
            loadedReduce = save.reduceMotion ?? false
        }
        if loadedJars.isEmpty {
            loadedJars = [JarSim.starter(name: "The First Glade")]
        }
        jars = loadedJars
        currentJar = min(loadedCurrent, loadedJars.count - 1)
        stats = loadedStats
        onboardingDone = loadedOnboarding
        reduceMotion = loadedReduce
        runCatchUp()
        touchPlayDay()
    }

    var jar: JarState {
        get { jars[currentJar] }
        set {
            jars[currentJar] = newValue
            scheduleSave()
        }
    }

    func runCatchUp() {
        var totalDays = 0
        for i in jars.indices {
            let days = JarSim.catchUp(&jars[i])
            totalDays += days
        }
        if totalDays > 0 {
            stats.daysWitnessed += totalDays
            stats.bestSealedDays = max(stats.bestSealedDays, jars.map { $0.bestSealedDays }.max() ?? 0)
            addXP(min(totalDays * 4, 40))
            if totalDays == 1 {
                catchUpReport = "A day passed on the sill while you were away."
            } else {
                catchUpReport = "\(totalDays) days passed on the sill while you were away."
            }
            checkAwards()
            scheduleSave()
        }
    }

    var rankIndex: Int {
        var idx = 0
        for (i, rank) in GladeStore.ranks.enumerated() where stats.xp >= rank.xp { idx = i }
        return idx
    }

    var rank: GladeRank { GladeStore.ranks[rankIndex] }

    var nextRank: GladeRank? {
        rankIndex + 1 < GladeStore.ranks.count ? GladeStore.ranks[rankIndex + 1] : nil
    }

    var rankProgress: Double {
        guard let next = nextRank else { return 1 }
        let base = GladeStore.ranks[rankIndex].xp
        return Double(stats.xp - base) / Double(next.xp - base)
    }

    func isPlantUnlocked(_ species: PlantSpecies) -> Bool { species.unlockRank <= rankIndex }
    func isFaunaUnlocked(_ species: FaunaSpecies) -> Bool { species.unlockRank <= rankIndex }

    func addXP(_ amount: Int) {
        guard amount > 0 else { return }
        let before = rankIndex
        stats.xp += amount
        if rankIndex > before {
            celebration = "You are now \(rank.name)!"
            GladeHaptics.success()
        }
        scheduleSave()
    }

    func tend(_ action: (inout JarState) -> Void, xp: Int = 6) {
        var j = jar
        action(&j)
        jar = j
        stats.tendActions += 1
        addXP(xp)
        checkAwards()
        GladeHaptics.thump()
    }

    func addJar(_ newJar: JarState) {
        jars.append(newJar)
        currentJar = jars.count - 1
        stats.jarsBuilt += 1
        stats.plantsPlanted += newJar.plants.count
        for p in newJar.plants { stats.speciesUsed.insert(p.speciesID) }
        for f in newJar.fauna { stats.faunaUsed.insert(f.speciesID) }
        addXP(40)
        celebration = "\(newJar.name) is sealed and living."
        checkAwards()
        scheduleSave()
    }

    func removeJar(at index: Int) {
        guard jars.count > 1, jars.indices.contains(index) else { return }
        jars.remove(at: index)
        currentJar = min(currentJar, jars.count - 1)
        scheduleSave()
    }

    func recordReplant(_ jarState: JarState) {
        stats.plantsPlanted += 1
        for p in jarState.plants { stats.speciesUsed.insert(p.speciesID) }
        for f in jarState.fauna { stats.faunaUsed.insert(f.speciesID) }
        checkAwards()
    }

    func touchPlayDay() {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        let today = fmt.string(from: Date())
        if !stats.playDays.contains(today) {
            stats.playDays.insert(today)
            var streak = 1
            var day = Date()
            while true {
                guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
                if stats.playDays.contains(fmt.string(from: prev)) {
                    streak += 1
                    day = prev
                } else {
                    break
                }
            }
            stats.bestDayStreak = max(stats.bestDayStreak, streak)
            addXP(6)
            scheduleSave()
        }
    }

    var currentDayStreak: Int {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        var streak = 0
        var day = Date()
        while stats.playDays.contains(fmt.string(from: day)) {
            streak += 1
            guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    func recordGuideRead(_ id: String) {
        if !stats.guidesRead.contains(id) {
            stats.guidesRead.insert(id)
            addXP(15)
            checkAwards()
        }
    }

    func recordQuiz(score: Int) {
        stats.quizRounds += 1
        if score > stats.quizBest { stats.quizBest = score }
        addXP(score * 6)
        checkAwards()
    }

    func completeNote(_ note: GladeNote) {
        guard !stats.notesDone.contains(note.id) else { return }
        stats.notesDone.insert(note.id)
        addXP(note.rewardXP)
        celebration = "Note inked in: \(note.title)"
        GladeHaptics.success()
        checkAwards()
    }

    func checkAwards() {
        stats.bestSealedDays = max(stats.bestSealedDays, jars.map { $0.bestSealedDays }.max() ?? 0)
        var earned: GladeAward?
        for award in GladeAwards.all where !stats.awards.contains(award.id) {
            if award.check(self) {
                stats.awards.insert(award.id)
                earned = award
            }
        }
        if let award = earned {
            celebration = "Award earned: \(award.name)"
            GladeHaptics.success()
        }
        scheduleSave()
    }

    func resetAll() {
        jars = [JarSim.starter(name: "The First Glade")]
        currentJar = 0
        stats = GladeStats()
        onboardingDone = true
        scheduleSave()
    }

    func scheduleSave() {
        saveWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.saveNow() }
        saveWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
    }

    func saveNow() {
        let save = GladeSave(jars: jars, currentJar: currentJar, stats: stats, onboardingDone: onboardingDone, reduceMotion: reduceMotion)
        if let data = try? JSONEncoder().encode(save) {
            UserDefaults.standard.set(data, forKey: GladeStore.saveKey)
        }
    }

    var daylight: Double {
        let hour = Double(Calendar.current.component(.hour, from: Date()))
        if hour < 6 || hour >= 21 { return 0 }
        if hour < 9 { return (hour - 6) / 3 }
        if hour >= 18 { return 1 - (hour - 18) / 3 }
        return 1
    }
}
