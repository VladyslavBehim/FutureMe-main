import SwiftUI
import StoreKit

struct ThemesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var themeSettings: ThemeSettings
    
    @State private var appear = false
    @State private var selectedThemeToPurchase: AppTheme? = nil
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    NavBackButton(action: { dismiss() })
                    Spacer()
                    Text("Premium Themes")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    // Empty view for balance
                    Rectangle().fill(Color.clear).frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            ThemeCardView(
                                theme: theme,
                                isSelected: themeSettings.currentTheme == theme,
                                isPurchased: theme.isPremium ? storeManager.isPurchased(theme.rawValue) : true,
                                product: storeManager.themes.first(where: { $0.id == theme.rawValue }),
                                action: {
                                    handleThemeSelection(theme)
                                }
                            )
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(ThemeIndex(for: theme)) * 0.1), value: appear)
                        }
                        
                        // Restore Purchases Button
                        Button(action: {
                            Task {
                                await storeManager.restorePurchases()
                            }
                        }) {
                            Text("Restore Purchases")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(themeSettings.currentTheme.primaryColor)
                                .padding(.vertical, 16)
                        }
                        .padding(.top, 32)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            appear = true
        }
        .sheet(item: $selectedThemeToPurchase) { theme in
            ThemePaywallView(
                theme: theme,
                product: storeManager.themes.first(where: { $0.id == theme.rawValue })
            )
        }
    }
    
    private func handleThemeSelection(_ theme: AppTheme) {
        if theme.isPremium && !storeManager.isPurchased(theme.rawValue) {
            // Show paywall
            selectedThemeToPurchase = theme
        } else {
            // Select theme
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                themeSettings.currentTheme = theme
            }
        }
    }
    
    private func ThemeIndex(for theme: AppTheme) -> Int {
        return AppTheme.allCases.firstIndex(of: theme) ?? 0
    }
}

// MARK: - Theme Card View
struct ThemeCardView: View {
    let theme: AppTheme
    let isSelected: Bool
    let isPurchased: Bool
    let product: Product?
    let action: () -> Void
    
    var isLocked: Bool {
        return theme.isPremium && !isPurchased
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Theme Color Preview Circle
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(theme.primaryColor.opacity(0.3))
                            .frame(width: 52, height: 52)
                    }
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.primaryColor, theme.primaryColor.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: theme.primaryColor.opacity(isSelected ? 0.6 : 0), radius: 10)
                        
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(theme.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        if theme.isPremium && isPurchased {
                            // Pro Badge
                            Text("PRO")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(theme.primaryColor.opacity(0.2))
                                .foregroundColor(theme.primaryColor)
                                .cornerRadius(4)
                        }
                    }
                    
                    if isLocked {
                        Text(product?.displayPrice ?? "Premium")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    } else if isSelected {
                        Text("Active")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.primaryColor)
                    } else {
                        Text("Tap to apply")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Spacer()
                
                // Status Icon / Lock
                if isLocked {
                    ZStack {
                        // Blurred Background for the lock
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 36, height: 36)
                            .blur(radius: 2)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.3))
                        .opacity(isSelected ? 0 : 1)
                }
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(theme.backgroundColors.first?.opacity(0.8) ?? Color.black.opacity(0.6))
                    
                    if isLocked {
                        // Very subtle blur overlay for locked state
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial.opacity(0.3))
                    }
                    
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            isSelected ? theme.primaryColor : Color.white.opacity(0.08),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
            )
            .shadow(color: isSelected ? theme.primaryColor.opacity(0.2) : .clear, radius: 15, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Ensure AppTheme complies with Identifiable for the sheet
extension AppTheme: Identifiable {
    var id: String { self.rawValue }
}
