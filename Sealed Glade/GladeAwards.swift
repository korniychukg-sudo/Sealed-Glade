import SwiftUI

struct GladeAward: Identifiable {
    let id: String
    let name: String
    let blurb: String
    let emblem: Int
    let check: (GladeStore) -> Bool
    let progress: (GladeStore) -> (Double, String)
}

enum GladeAwards {
    static let all: [GladeAward] = a + b

    private static func countAward(id: String, name: String, blurb: String, emblem: Int, value: @escaping (GladeStore) -> Double, target: Double, unit: String) -> GladeAward {
        GladeAward(id: id, name: name, blurb: blurb, emblem: emblem,
                   check: { value($0) >= target },
                   progress: { store in
                       let v = value(store)
                       return (min(1, v / target), "\(Int(min(v, target))) of \(Int(target)) \(unit)")
                   })
    }

    private static let a: [GladeAward] = [
        countAward(id: "g_first", name: "Lid Down", blurb: "Seal your first jar of your own making.", emblem: 0,
                   value: { Double($0.stats.jarsBuilt) }, target: 1, unit: "jars"),
        countAward(id: "g_shelf", name: "A Shelf of Weather", blurb: "Keep three living jars at once.", emblem: 1,
                   value: { Double($0.jars.count) }, target: 3, unit: "jars"),
        countAward(id: "g_week", name: "One Held Breath", blurb: "Seven sealed days on a single jar.", emblem: 2,
                   value: { Double($0.stats.bestSealedDays) }, target: 7, unit: "days"),
        countAward(id: "g_month", name: "The Quiet Month", blurb: "Thirty sealed days on a single jar.", emblem: 3,
                   value: { Double($0.stats.bestSealedDays) }, target: 30, unit: "days"),
        countAward(id: "g_hundred", name: "World Status", blurb: "One hundred sealed days on a single jar.", emblem: 4,
                   value: { Double($0.stats.bestSealedDays) }, target: 100, unit: "days"),
        countAward(id: "g_green", name: "Underplanted No More", blurb: "Plant fifteen plants across your jars.", emblem: 5,
                   value: { Double($0.stats.plantsPlanted) }, target: 15, unit: "plants"),
        GladeAward(id: "g_variety", name: "The Living Catalogue", blurb: "Grow eight different plant species.", emblem: 6,
                   check: { $0.stats.speciesUsed.count >= 8 },
                   progress: { (min(1, Double($0.stats.speciesUsed.count) / 8), "\($0.stats.speciesUsed.count) of 8 species") }),
        GladeAward(id: "g_allplants", name: "Every Green Thing", blurb: "Grow all twelve plant species the guide knows.", emblem: 7,
                   check: { $0.stats.speciesUsed.count >= GladeSpecies.plants.count },
                   progress: { (min(1, Double($0.stats.speciesUsed.count) / Double(GladeSpecies.plants.count)), "\($0.stats.speciesUsed.count) of \(GladeSpecies.plants.count) species") }),
        GladeAward(id: "g_crew", name: "Fully Staffed", blurb: "Employ every kind of creature the guide describes.", emblem: 8,
                   check: { $0.stats.faunaUsed.count >= GladeSpecies.faunas.count },
                   progress: { (min(1, Double($0.stats.faunaUsed.count) / Double(GladeSpecies.faunas.count)), "\($0.stats.faunaUsed.count) of \(GladeSpecies.faunas.count) crews") }),
        countAward(id: "g_tend", name: "Gentle Hands", blurb: "Tend your jars twenty-five times.", emblem: 9,
                   value: { Double($0.stats.tendActions) }, target: 25, unit: "tendings"),
    ]

    private static let b: [GladeAward] = [
        GladeAward(id: "g_balance", name: "The Even Keel", blurb: "Hold a jar at balance 90 or better.", emblem: 10,
                   check: { ($0.jars.map { $0.balance }.max() ?? 0) >= 90 },
                   progress: { (min(1, ($0.jars.map { $0.balance }.max() ?? 0) / 90), "Best balance \(Int($0.jars.map { $0.balance }.max() ?? 0)) of 90") }),
        countAward(id: "g_days100", name: "A Season Witnessed", blurb: "Watch one hundred days pass across the shelf.", emblem: 11,
                   value: { Double($0.stats.daysWitnessed) }, target: 100, unit: "days"),
        countAward(id: "g_days365", name: "A Year in Glass", blurb: "Watch three hundred and sixty-five days pass across the shelf.", emblem: 12,
                   value: { Double($0.stats.daysWitnessed) }, target: 365, unit: "days"),
        GladeAward(id: "g_scholar", name: "Field Guide Scholar", blurb: "Read every chapter of the field guide.", emblem: 13,
                   check: { $0.stats.guidesRead.count >= GladeGuides.all.count },
                   progress: { (min(1, Double($0.stats.guidesRead.count) / Double(GladeGuides.all.count)), "\($0.stats.guidesRead.count) of \(GladeGuides.all.count) chapters") }),
        GladeAward(id: "g_exam", name: "The Naturalist's Seal", blurb: "Score a perfect ten on the quiz.", emblem: 14,
                   check: { $0.stats.quizBest >= 10 },
                   progress: { (Double($0.stats.quizBest) / 10, "Best score \($0.stats.quizBest) of 10") }),
        GladeAward(id: "g_notes8", name: "Half the Notebook", blurb: "Ink in eight notes from the naturalist's notebook.", emblem: 15,
                   check: { $0.stats.notesDone.count >= 8 },
                   progress: { (min(1, Double($0.stats.notesDone.count) / 8), "\($0.stats.notesDone.count) of 8 notes") }),
        GladeAward(id: "g_notesall", name: "The Notebook, Closed", blurb: "Ink in every note in the notebook.", emblem: 16,
                   check: { $0.stats.notesDone.count >= GladeNotebook.all.count },
                   progress: { (min(1, Double($0.stats.notesDone.count) / Double(GladeNotebook.all.count)), "\($0.stats.notesDone.count) of \(GladeNotebook.all.count) notes") }),
        countAward(id: "g_streak", name: "Three Misty Mornings", blurb: "Visit the glade three days in a row.", emblem: 17,
                   value: { Double($0.stats.bestDayStreak) }, target: 3, unit: "days"),
        countAward(id: "g_streak7", name: "The Daily Walk", blurb: "Visit the glade seven days in a row.", emblem: 18,
                   value: { Double($0.stats.bestDayStreak) }, target: 7, unit: "days"),
        GladeAward(id: "g_master", name: "Keeper of the Glade", blurb: "Reach the highest rank the glade bestows.", emblem: 19,
                   check: { $0.rankIndex >= GladeStore.ranks.count - 1 },
                   progress: { (Double($0.rankIndex) / Double(GladeStore.ranks.count - 1), $0.rank.name) }),
    ]
}
