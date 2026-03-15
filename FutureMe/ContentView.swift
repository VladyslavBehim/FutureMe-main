import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        if hasSeenOnboarding {
            MainTabView()
        } else {
            OnboardingView {
                hasSeenOnboarding = true
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        HomeView()
                    }
                case 1:
                    NavigationStack {
                        LibraryView()
                    }
                case 2:
                    NavigationStack {
                        HistoryView()
                    }
                case 3:
                    NavigationStack {
                        SettingsView()
                    }
                default:
                    EmptyView()
                }
            }

            // Custom Tab Bar
            CosmicTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Cosmic Tab Bar

struct CosmicTabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, label: String)] = [
        ("sparkles", "Explore"),
        ("books.vertical", "Library"),
        ("clock.arrow.circlepath", "History"),
        ("gearshape", "Settings")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                TabBarItem(
                    icon: tabs[index].icon,
                    label: tabs[index].label,
                    isSelected: selectedTab == index
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .padding(.bottom, 24)
        .background(
            ZStack {
                // Vibrancy / glass
                Rectangle()
                    .fill(.ultraThinMaterial)

                // Deep cosmic overlay
                Rectangle()
                    .fill(Color(hex: "070B14").opacity(0.82))

                // Top separator — thin gradient line
                VStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "7B5EA7").opacity(0.7),
                            Color(hex: "4A90D9").opacity(0.4),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 0.75)
                    Spacer()
                }
            }
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Selection background pill
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "7B5EA7").opacity(0.35), Color(hex: "4A90D9").opacity(0.2)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "7B5EA7").opacity(0.5), .clear],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.8
                                    )
                            )
                            .transition(.scale(scale: 0.7).combined(with: .opacity))
                    }

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected
                                ? LinearGradient(colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0.35)], startPoint: .top, endPoint: .bottom)
                        )
                        .scaleEffect(pressed ? 0.82 : (isSelected ? 1.08 : 1.0))
                        .shadow(color: isSelected ? Color(hex: "7B5EA7").opacity(0.9) : .clear, radius: 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isSelected)
                }
                .frame(width: 44, height: 30)

                // Dot indicator replaced by label
                Text(label)
                    .font(.system(size: 9.5, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? Color(hex: "C4A6F0") : Color.white.opacity(0.3))
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.08)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { pressed = false } }
        )
    }
}
