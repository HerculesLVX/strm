import StoreKit
import SwiftUI

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    // Configure these product IDs in App Store Connect
    static let singleReadingProductID = "com.bodyreader.app.reading"

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPurchased = false
    @Published private(set) var isLoading = false

    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await refreshPurchaseStatus() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    var singleReadingProduct: Product? {
        products.first { $0.id == Self.singleReadingProductID }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.singleReadingProductID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase() async throws {
        guard let product = singleReadingProduct else { return }
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            isPurchased = true
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        try? await AppStore.sync()
        await refreshPurchaseStatus()
    }

    private func refreshPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.singleReadingProductID {
                isPurchased = true
                return
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.failedVerification
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await MainActor.run { self.isPurchased = true }
                }
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
