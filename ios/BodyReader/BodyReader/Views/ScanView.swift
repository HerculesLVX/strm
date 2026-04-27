import SwiftUI

struct ScanView: View {
    let bodyPart: BodyPartType

    @EnvironmentObject private var usageManager: UsageManager
    @EnvironmentObject private var purchaseManager: PurchaseManager

    @State private var capturedImage: UIImage?
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var showingPaywall = false
    @State private var reading: BodyReading?
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    @State private var showingResult = false

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()

            if isAnalyzing {
                LoadingView(bodyPart: bodyPart)
            } else {
                mainContent
            }
        }
        .navigationTitle(bodyPart.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showingCamera) {
            ImagePicker(image: $capturedImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            ImagePicker(image: $capturedImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView {
                showingPaywall = false
                if purchaseManager.isPurchased {
                    startAnalysis()
                }
            }
        }
        .fullScreenCover(isPresented: $showingResult) {
            if let reading {
                ResultView(reading: reading, image: capturedImage, bodyPart: bodyPart)
            }
        }
        .onChange(of: capturedImage) { _, newImage in
            if newImage != nil { errorMessage = nil }
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                instructionsCard
                imagePreviewCard
                actionButtons

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.red.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
    }

    private var instructionsCard: some View {
        VStack(spacing: 12) {
            Text(bodyPart.emoji)
                .font(.system(size: 48))

            Text("How to photograph your \(bodyPart.displayName.lowercased())")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(bodyPart.photoInstructions)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "1C1C1E"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var imagePreviewCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1C1C1E"))
                .frame(height: 260)

            if let img = capturedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Re-take overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            capturedImage = nil
                        } label: {
                            Label("Retake", systemImage: "arrow.counterclockwise")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        .padding(12)
                    }
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(hex: "C9A96E").opacity(0.5))
                    Text("Photo will appear here")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if capturedImage == nil {
                HStack(spacing: 12) {
                    photoButton(title: "Camera", icon: "camera.fill") {
                        showingCamera = true
                    }
                    photoButton(title: "Library", icon: "photo.fill") {
                        showingPhotoLibrary = true
                    }
                }
            } else {
                analyzeButton
            }
        }
    }

    private func photoButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "2C2C2E"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var analyzeButton: some View {
        Button(action: handleAnalyzeTap) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text("Read My \(bodyPart.displayName)")
                    .fontWeight(.bold)
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color(hex: "0A0A0F"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: bodyPart.gradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func handleAnalyzeTap() {
        if usageManager.hasFreeReading || purchaseManager.isPurchased {
            startAnalysis()
        } else {
            showingPaywall = true
        }
    }

    private func startAnalysis() {
        guard let image = capturedImage else { return }
        isAnalyzing = true
        errorMessage = nil

        Task {
            do {
                let result = try await ClaudeService.shared.analyze(image: image, bodyPart: bodyPart)
                await MainActor.run {
                    if usageManager.hasFreeReading && !purchaseManager.isPurchased {
                        usageManager.consumeFreeReading()
                    }
                    reading = result
                    isAnalyzing = false
                    showingResult = true
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
