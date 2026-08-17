import SwiftUI

struct GladeNote: Identifiable {
    let id: String
    let title: String
    let brief: String
    let rewardXP: Int
    let progress: (GladeStore) -> (Double, String)

    func satisfied(_ store: GladeStore) -> Bool {
        progress(store).0 >= 1.0
    }
}

enum GladeNotebook {
    static let all: [GladeNote] = first + second

    private static func countNote(id: String, title: String, brief: String, xp: Int, value: @escaping (GladeStore) -> Double, target: Double, unit: String) -> GladeNote {
        GladeNote(id: id, title: title, brief: brief, rewardXP: xp) { store in
            let v = value(store)
            return (min(1, v / target), "\(Int(min(v, target))) of \(Int(target)) \(unit)")
        }
    }

    private static let first: [GladeNote] = [
        countNote(id: "n01", title: "A World, Begun", brief: "Seal your first jar of your own design and set it on the shelf.", xp: 40,
                  value: { Double($0.stats.jarsBuilt) }, target: 1, unit: "jars built"),
        countNote(id: "n02", title: "The First Week", brief: "Keep any jar sealed for seven days straight — no lid, no rescue, just trust.", xp: 60,
                  value: { Double($0.stats.bestSealedDays) }, target: 7, unit: "sealed days"),
        countNote(id: "n03", title: "A Quiet Month", brief: "Thirty sealed days. The glade stops being a project and becomes a place.", xp: 110,
                  value: { Double($0.stats.bestSealedDays) }, target: 30, unit: "sealed days"),
        countNote(id: "n04", title: "Green Thumbs, Small Scale", brief: "Plant ten plants across your jars, in any combination.", xp: 55,
                  value: { Double($0.stats.plantsPlanted) }, target: 10, unit: "plants"),
        GladeNote(id: "n05", title: "The Collector", brief: "Grow six different plant species somewhere on your shelf.", rewardXP: 70) { store in
            (min(1, Double(store.stats.speciesUsed.count) / 6), "\(store.stats.speciesUsed.count) of 6 species grown")
        },
        GladeNote(id: "n06", title: "Full Crew", brief: "Employ three kinds of creature across your jars — janitors, recyclers, cleaners.", rewardXP: 70) { store in
            (min(1, Double(store.stats.faunaUsed.count) / 3), "\(store.stats.faunaUsed.count) of 3 crews employed")
        },
        countNote(id: "n07", title: "Shelf of Worlds", brief: "Build and seal three jars of your own.", xp: 90,
                  value: { Double($0.stats.jarsBuilt) }, target: 3, unit: "jars built"),
        countNote(id: "n08", title: "The Attentive Keeper", brief: "Tend your jars twelve times — venting, misting, wiping, pruning.", xp: 60,
                  value: { Double($0.stats.tendActions) }, target: 12, unit: "tendings"),
    ]

    private static let second: [GladeNote] = [
        GladeNote(id: "n09", title: "Balance, Witnessed", brief: "Bring any jar to a balance of 85 or better and let it hold.", rewardXP: 80) { store in
            let best = store.jars.map { $0.balance }.max() ?? 0
            return (min(1, best / 85), "Best balance \(Int(best)) of 85")
        },
        countNote(id: "n10", title: "A Hundred Days of Weather", brief: "Witness one hundred days pass across your shelf, in any jars.", xp: 90,
                  value: { Double($0.stats.daysWitnessed) }, target: 100, unit: "days"),
        countNote(id: "n11", title: "The Reading Chair", brief: "Read five chapters of the field guide with the rain on the glass.", xp: 55,
                  value: { Double($0.stats.guidesRead.count) }, target: 5, unit: "chapters"),
        countNote(id: "n12", title: "The Examiner's Nod", brief: "Score eight or better on the naturalist's quiz.", xp: 70,
                  value: { Double($0.stats.quizBest) }, target: 8, unit: "best score"),
        countNote(id: "n13", title: "Five Green Mornings", brief: "Visit the glade on five different days.", xp: 60,
                  value: { Double($0.stats.playDays.count) }, target: 5, unit: "days"),
        GladeNote(id: "n14", title: "The Botanist's Dozen", brief: "Grow ten of the twelve plant species the guide describes.", rewardXP: 120) { store in
            (min(1, Double(store.stats.speciesUsed.count) / 10), "\(store.stats.speciesUsed.count) of 10 species grown")
        },
        countNote(id: "n15", title: "Weathered Keeper", brief: "Witness three hundred days of jar time, across everything you keep.", xp: 130,
                  value: { Double($0.stats.daysWitnessed) }, target: 300, unit: "days"),
        countNote(id: "n16", title: "The Long Seal", brief: "One hundred sealed days on a single jar. The lid becomes a rumour.", xp: 160,
                  value: { Double($0.stats.bestSealedDays) }, target: 100, unit: "sealed days"),
    ]
}
