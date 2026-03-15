import Foundation
import StoreKit
import Combine

enum StoreError: Error {
    case failedVerification
}

@MainActor
class StoreManager: ObservableObject {
    @Published private(set) var themes: [Product] = []
    @Published private(set) var purchasedThemeIDs: Set<String> = []
    
    // IDs of products available for purchase
    private let productDict: [String: String] = [
        "theme.dark": "Dark Theme",
        "theme.neon": "Neon Theme"
    ]
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await fetchProducts()
            await updatePurchasedCurrentEntitlements()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func fetchProducts() async {
        do {
            let storeProducts = try await Product.products(for: productDict.keys)
            
            // Sort products based on price or display name
            themes = storeProducts.sorted { $0.displayName < $1.displayName }
            print("Successfully loaded \(themes.count) products")
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check whether the transaction is verified.
            let transaction = try checkVerified(verification)
            
            // The transaction is verified. Deliver content to the user.
            await updatePurchasedCurrentEntitlements()
            
            // Always finish a transaction.
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    func isPurchased(_ productID: String) -> Bool {
        return purchasedThemeIDs.contains(productID)
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedCurrentEntitlements()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    private func updatePurchasedCurrentEntitlements() async {
        var currentPurchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Add the productID to the purchased set
                // Only consider Non-Consumables or active Subscriptions here
                if transaction.revocationDate == nil {
                    currentPurchased.insert(transaction.productID)
                }
            } catch {
                print("Failed to verify transaction in current entitlements: \(error)")
            }
        }
        
        purchasedThemeIDs = currentPurchased
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    await self.updatePurchasedCurrentEntitlements()
                    
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
