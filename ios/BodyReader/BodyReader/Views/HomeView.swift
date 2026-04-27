import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var usageManager: UsageManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var selectedBodyPart: BodyPartType?
    @State private var showingScan = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0F").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        readingsList
                        freeReadingBadge
                            .padding(.top, 8)
                            .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationDestination(for: BodyPartType.self) { part in
                ScanView(bodyPart: part)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("✦")
                .font(.system(size: 28))
                .foregroundStyle(Color(hex: "C9A96E"))
                .padding(.top, 56)

            Text("BODYREADER")
                .font(.system(size: 32, weight: .black))
                .tracking(6)
                .foregroundStyle(.white)

            Text("Ancient wisdom meets modern vision")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.45))
                .tracking(0.5)
                .padding(.bottom, 36)
        }
    }

    private var readingsList: some View {
        VStack(spacing: 10) {
            ForEach(BodyPartType.allCases) { part in
                NavigationLink(value: part) {
                    BodyPartCard(bodyPart: part)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var freeReadingBadge: some View {
        Group {
            if usageManager.hasFreeReading {
                HStack(spacing: 6) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 12))
                    Text("1 FREE reading included")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(Color(hex: "C9A96E"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "C9A96E").opacity(0.12))
                .clipShape(Capsule())
            } else {
                Text("Additional readings · $0.99 each")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
    }
}
