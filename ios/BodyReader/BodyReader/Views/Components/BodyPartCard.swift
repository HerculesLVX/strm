import SwiftUI

struct BodyPartCard: View {
    let bodyPart: BodyPartType

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                LinearGradient(
                    colors: bodyPart.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Text(bodyPart.emoji)
                    .font(.system(size: 30))
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(bodyPart.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                Text(bodyPart.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.55))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(16)
        .background(Color(hex: "1C1C1E"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
