import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var historyManager: HistoryManager
    @EnvironmentObject var themeSettings: ThemeSettings
    @State private var showClearConfirmation = false
    @State private var appear = false
    @State private var showAboutView = false

    var body: some View {
        ZStack {
            // Static Cosmic Background
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        Group {
                            Text("Simulation")
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            + Text("\nCenter")
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .shadow(color: Color(hex: "C4A6F0").opacity(0.4), radius: 15, x: 0, y: 0)

                        Text("Fine-tune your reality and manage your manifests.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.6))
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity , alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                    VStack(spacing: 28) {
                        
                        // MARK: App Identity Card
                        AppIdentityCard()
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)
                            .animation(.spring(response: 0.65, dampingFraction: 0.75).delay(0.05), value: appear)

                        // MARK: About Section
                        SettingsSection(title: "About", icon: "info.circle") {
                            Button {
                                showAboutView = true
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(themeSettings.currentTheme.primaryColor.opacity(0.18))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "app.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(
                                                LinearGradient(colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                    }

                                    Text("About FutureMe")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.white.opacity(0.3))
                                        .padding(.trailing, 4)
                                }
                                .padding(.vertical, 4)
                            }
                            Divider().background(Color.white.opacity(0.07)).padding(.vertical, 4)
                            SettingsRow(label: "Version", value: "1.0.0", icon: "tag.fill")
                        }
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(.spring(response: 0.65, dampingFraction: 0.75).delay(0.12), value: appear)
                        
                        // MARK: Premium Section
                        SettingsSection(title: "Premium", icon: "star.fill") {
                            NavigationLink(destination: ThemesView()) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: "F6E05E").opacity(0.18))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "F6E05E"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Get Pro / Themes")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("Unlock premium visual styles")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(Color.white.opacity(0.5))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("NEW")
                                        .font(.system(size: 10, weight: .black, design: .rounded))
                                        .foregroundColor(Color(hex: "070B14"))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(
                                            LinearGradient(colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .cornerRadius(4)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.white.opacity(0.2))
                                        .padding(.leading, 4)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(.spring(response: 0.65, dampingFraction: 0.75).delay(0.15), value: appear)

                        // MARK: Data Section
                        SettingsSection(title: "Data", icon: "cylinder") {
                            Button(role: .destructive) {
                                showClearConfirmation = true
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: "FF6B35").opacity(0.18))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "FF6B35"))
                                    }
                                    Text("Reset Simulations")
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "FF6B35"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(hex: "FF6B35").opacity(0.4))
                                }
                                .padding(.vertical, 4)
                            }
                            .confirmationDialog(
                                "Delete all simulations?",
                                isPresented: $showClearConfirmation,
                                titleVisibility: .visible
                            ) {
                                Button("Delete All", role: .destructive) {
                                    historyManager.clearHistory()
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("This action cannot be undone.")
                            }
                        }
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(.spring(response: 0.65, dampingFraction: 0.75).delay(0.19), value: appear)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
            }
        }
        .fullScreenCover(isPresented: $showAboutView) {
            AboutView()
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation { appear = true }
        }
    }
}

// MARK: - App Identity Card

struct AppIdentityCard: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @State private var iconPulse = false
    @State private var orbitRotate = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Orbit ring
                Circle()
                    .stroke(
                        LinearGradient(colors: [themeSettings.currentTheme.primaryColor.opacity(0.6), .clear], startPoint: .top, endPoint: .bottom),
                        lineWidth: 1.5
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(orbitRotate ? 360 : 0))
                    .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: orbitRotate)

                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [themeSettings.currentTheme.primaryColor.opacity(iconPulse ? 0.4 : 0.2), .clear],
                            center: .center, startRadius: 0, endRadius: 38
                        )
                    )
                    .frame(width: 76, height: 76)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: iconPulse)

                Image(systemName: "wand.and.stars")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.7), radius: 12)
            }

            VStack(spacing: 4) {
                Text("FutureMe")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("AI-powered future simulation")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "2D1B69").opacity(0.4), Color(hex: "1A1035").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [themeSettings.currentTheme.primaryColor.opacity(0.5), Color(hex: "4A90D9").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            }
        )
        .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.2), radius: 20, y: 8)
        .onAppear {
            iconPulse = true
            orbitRotate = true
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeSettings.currentTheme.primaryColor.opacity(0.7))
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.35))
                    .tracking(1.2)
            }
            .padding(.leading, 4)

            // Card
            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.03))
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                }
            )
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(themeSettings.currentTheme.primaryColor.opacity(0.18))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }

            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color.white.opacity(0.35))
        }
        .padding(.vertical, 4)
    }
}
