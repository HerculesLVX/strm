import SwiftUI

struct LoadingView: View {
    let bodyPart: BodyPartType
    @State private var rotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var dotOpacities: [Double] = [1, 0.5, 0.2]
    @State private var phase = 0

    private let phrases = [
        "Reading the signs...",
        "Consulting the patterns...",
        "Mapping the zones...",
        "Interpreting the lines...",
        "Channeling the reading..."
    ]
    @State private var phraseIndex = 0

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: bodyPart.gradientColors + [.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(rotation))

                    // Inner pulse
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [bodyPart.gradientColors[0].opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseScale)

                    Text(bodyPart.emoji)
                        .font(.system(size: 44))
                }
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulseScale = 1.15
                    }
                }

                VStack(spacing: 10) {
                    Text(phrases[phraseIndex])
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .animation(.easeInOut, value: phraseIndex)
                        .onAppear {
                            Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { _ in
                                phraseIndex = (phraseIndex + 1) % phrases.count
                            }
                        }

                    HStack(spacing: 6) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(Color(hex: "C9A96E"))
                                .frame(width: 6, height: 6)
                                .opacity(dotOpacities[i])
                        }
                    }
                    .onAppear {
                        animateDots()
                    }
                }

                Spacer()
            }
        }
    }

    private func animateDots() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                let prev = dotOpacities
                dotOpacities = [prev[2], prev[0], prev[1]]
            }
        }
    }
}
