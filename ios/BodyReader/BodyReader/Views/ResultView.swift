import SwiftUI

struct ResultView: View {
    let reading: BodyReading
    let image: UIImage?
    let bodyPart: BodyPartType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    overallSection
                    keyFeaturesSection
                    sectionsArea
                    summarySection
                    disclaimerSection
                    Spacer(minLength: 40)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "2C2C2E"))
                            .clipShape(Circle())
                    }
                    .padding(.top, 56)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, Color(hex: "0A0A0F")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: bodyPart.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 280)
            }

            VStack(spacing: 4) {
                Text(bodyPart.emoji)
                    .font(.system(size: 36))
                Text(reading.title.uppercased())
                    .font(.system(size: 22, weight: .black))
                    .tracking(4)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 4)
                Text(reading.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.bottom, 24)
        }
    }

    // MARK: - Overall impression

    private var overallSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Overall Impression", icon: "sparkles")

            Text(reading.overallImpression)
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(5)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "1C1C1E"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    // MARK: - Key Features

    private var keyFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Key Features Seen", icon: "list.bullet.rectangle")

            VStack(spacing: 6) {
                ForEach(reading.keyFeatures, id: \.self) { feature in
                    HStack(spacing: 10) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .foregroundStyle(Color(hex: "C9A96E"))
                        Text(feature)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "1C1C1E"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Reading Sections

    private var sectionsArea: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Zone Analysis", icon: "scope")

            VStack(spacing: 8) {
                ForEach(reading.sections) { section in
                    ReadingSectionView(section: section)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Summary

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Reading Summary", icon: "checkmark.seal.fill")

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(reading.summary.enumerated()), id: \.offset) { _, point in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 7))
                            .foregroundStyle(Color(hex: "C9A96E"))
                            .padding(.top, 5)
                        Text(point)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(3)
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "1C1C1E"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Disclaimer

    private var disclaimerSection: some View {
        Text(reading.disclaimer)
            .font(.system(size: 11))
            .foregroundStyle(.white.opacity(0.25))
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, 30)
            .padding(.top, 24)
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(hex: "C9A96E"))
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(Color(hex: "C9A96E"))
        }
    }
}
