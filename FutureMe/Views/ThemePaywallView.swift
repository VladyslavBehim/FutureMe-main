import SwiftUI
import StoreKit

struct ThemePaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var themeSettings: ThemeSettings
    
    let theme: AppTheme
    let product: Product?
    
    @State private var isPurchasing = false
    @State private var appear = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: theme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            // Subtle pulse ring based on theme primary color
            Circle()
                .fill(theme.primaryColor.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 50)
                .scaleEffect(appear ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: appear)
            
            VStack(spacing: 32) {
                // Header Icon
                ZStack {
                    Circle()
                        .fill(theme.primaryColor.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 36))
                        .foregroundColor(theme.primaryColor)
                        .shadow(color: theme.primaryColor, radius: 10)
                }
                .padding(.top, 40)
                
                // Typography
                VStack(spacing: 8) {
                    Text("Unlock")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(theme.title)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: theme.primaryColor.opacity(0.5), radius: 10)
                }
                
                // Feature List
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "sparkles", text: "Exclusive visual style across the entire app", color: theme.primaryColor)
                    FeatureRow(icon: "paintbrush.fill", text: "Custom primary accent colors", color: theme.primaryColor)
                    FeatureRow(icon: "infinity", text: "Keep it forever with a one-time purchase", color: theme.primaryColor)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(theme.primaryColor.opacity(0.3), lineWidth: 1))
                
                Spacer()
                
                // Price & Actions
                VStack(spacing: 16) {
                    if let product = product {
                        // Buy Button
                        Button(action: {
                            purchaseCurrentTheme(product)
                        }) {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 8)
                                }
                                Text("Buy for \(product.displayPrice)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: theme.primaryColor.opacity(0.4), radius: 15, y: 5)
                        }
                        .disabled(isPurchasing)
                    } else {
                        // Fallback in case Product didn't load yet
                        Text("Loading price...")
                            .foregroundColor(.white.opacity(0.6))
                            .padding()
                    }
                    
                    // Not Now Action
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Not Now")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            appear = true
        }
    }
    
    private func purchaseCurrentTheme(_ product: Product) {
        isPurchasing = true
        Task {
            do {
                if let transaction = try await storeManager.purchase(product) {
                    // Success
                    await MainActor.run {
                        // Automatically switch to the new theme
                        themeSettings.currentTheme = theme
                        dismiss()
                    }
                } else {
                    // Cancelled or pending
                    isPurchasing = false
                }
            } catch {
                print("Purchase failed: \(error)")
                isPurchasing = false
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}
