import SwiftUI

struct ReadingSectionView: View {
    let section: ReadingSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: section.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "C9A96E"))
                    .frame(width: 24)

                Text(section.zone.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(Color(hex: "C9A96E"))
            }

            VStack(alignment: .leading, spacing: 6) {
                Label {
                    Text(section.observation)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.75))
                } icon: {
                    Text("OBS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(width: 28, alignment: .leading)
                }

                Label {
                    Text(section.interpretation)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.9))
                } icon: {
                    Text("INT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color(hex: "C9A96E").opacity(0.7))
                        .frame(width: 28, alignment: .leading)
                }
            }
        }
        .padding(14)
        .background(Color(hex: "2C2C2E"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
