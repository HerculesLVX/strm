import Foundation

final class UsageManager: ObservableObject {
    static let shared = UsageManager()

    private let freeReadingsKey = "freeReadingsUsed"
    private let freeReadingLimit = 1

    @Published private(set) var freeReadingsUsed: Int

    init() {
        freeReadingsUsed = UserDefaults.standard.integer(forKey: "freeReadingsUsed")
    }

    var hasFreeReading: Bool {
        freeReadingsUsed < freeReadingLimit
    }

    var freeReadingsRemaining: Int {
        max(0, freeReadingLimit - freeReadingsUsed)
    }

    func consumeFreeReading() {
        freeReadingsUsed += 1
        UserDefaults.standard.set(freeReadingsUsed, forKey: freeReadingsKey)
    }
}
