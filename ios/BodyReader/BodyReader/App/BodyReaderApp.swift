import SwiftUI

@main
struct BodyReaderApp: App {
    @StateObject private var usageManager = UsageManager.shared
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(usageManager)
                .environmentObject(purchaseManager)
                .preferredColorScheme(.dark)
        }
    }
}
