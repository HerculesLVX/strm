import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    let onDismiss: () -> Void

    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                iconArea
                headerText
                valueProps
                priceButton
                restoreButton
                Spacer()
                legalText
            }
            .padding(.horizontal, 28)

            // Close
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(width: 30, height: 30)
                            .background(Color(hex: "2C2C2E"))
                            .clipShape(Circle())
                    }
                    .padding(.top, 52)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
    }

    private var iconArea: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "C9A96E").opacity(0.12))
                .frame(width: 100, height: 100)
            Text("✦")
                .font(.system(size: 44))
                .foregroundStyle(Color(hex: "C9A96E"))
        }
        .padding(.bottom, 24)
    }

    private var headerText: some View {
        VStack(spacing: 8) {
            Text("Unlock Your Reading")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)

            Text("Your free reading has been used.\nContinue exploring with one more.")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.bottom, 32)
    }

    private var valueProps: some View {
        VStack(spacing: 12) {
            valueProp(icon: "sparkles", text: "AI-powered deep reading")
            valueProp(icon: "scope",    text: "Full zone-by-zone analysis")
            valueProp(icon: "doc.text", text: "Detailed interpretation report")
            valueProp(icon: "camera",   text: "Use any body part photo")
        }
        .padding(.bottom, 32)
    }

    private func valueProp(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: "C9A96E"))
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(hex: "C9A96E"))
        }
        .padding(.horizontal, 8)
    }

    private var priceButton: some View {
        Button {
            Task { await purchase() }
        } label: {
            Group {
                if isPurchasing {
                    ProgressView().tint(.black)
                } else {
                    HStack(spacing: 8) {
                        Text(priceLabel)
                            .font(.system(size: 17, weight: .bold))
                        Text("· Unlock Reading")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundStyle(Color(hex: "0A0A0F"))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(hex: "C9A96E"), Color(hex: "8B6914")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isPurchasing)
        .padding(.bottom, 10)
    }

    private var restoreButton: some View {
        Button("Restore purchases") {
            Task {
                await purchaseManager.restorePurchases()
                if purchaseManager.isPurchased {
                    dismiss()
                    onDismiss()
                }
            }
        }
        .font(.system(size: 14))
        .foregroundStyle(.white.opacity(0.35))
        .padding(.bottom, 20)
    }

    private var legalText: some View {
        Text("Payment charged to your Apple ID account. No subscription — one-time purchase per reading.")
            .font(.system(size: 10))
            .foregroundStyle(.white.opacity(0.2))
            .multilineTextAlignment(.center)
            .padding(.bottom, 16)
    }

    private var priceLabel: String {
        if let product = purchaseManager.singleReadingProduct {
            return product.displayPrice
        }
        return "$0.99"
    }

    private func purchase() async {
        isPurchasing = true
        errorMessage = nil
        do {
            try await purchaseManager.purchase()
            if purchaseManager.isPurchased {
                dismiss()
                onDismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }
}
