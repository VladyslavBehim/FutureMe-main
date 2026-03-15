import SwiftUI
import Foundation

extension Notification.Name {
    static let dismissToHome = Notification.Name("dismissToHome")
}

// MARK: - Daily Insight Data
private let dailyInsights: [(quote: String, model: String)] = [
    ("The map is not the territory.", "Mental Models"),
    ("Invert, always invert.", "Charlie Munger"),
    ("First principles, not analogy.", "Elon Musk"),
    ("Most things are two-tailed — consider both outcomes.", "Probabilistic Thinking"),
    ("Explore the adjacent possible.", "Stuart Kauffman"),
    ("Zoom out before zooming in.", "Systems Thinking"),
    ("The best prediction is the one that shrinks the hypothesis space.", "Forecasting"),
    ("What is the best use of this time, right now?", "Opportunity Cost"),
    ("Small hinges swing big doors.", "Leverage Points"),
    ("Every system is perfectly designed to get the results it gets.", "Deming"),
]

// MARK: - HomeView
struct HomeView: View {
    @EnvironmentObject var historyManager: HistoryManager
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var achievementManager: AchievementManager
    @State private var shimmer: CGFloat = 0
    @State private var selectedBranch: Branch?

    // Navigation
    @State private var goToExplore = false
    @State private var goToGoals = false
    @State private var goToButterfly = false
    @State private var goToLibrary = false
    @State private var goToAchievements = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default:      return "Good Night"
        }
    }

    private var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "🌅"
        case 12..<17: return "☀️"
        case 17..<21: return "🌆"
        default:      return "🌙"
        }
    }

    private var todayString: String {
        Date().formatted(.dateTime.weekday(.wide).day().month(.wide).year())
    }

    private var todayInsight: (quote: String, model: String) {
        let day = Calendar.current.component(.day, from: Date())
        return dailyInsights[day % dailyInsights.count]
    }

    private var totalBranches: Int {
        historyManager.history.reduce(0) { $0 + $1.scenarios.count }
    }

    var body: some View {
        ZStack {
            // Cosmic Background
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle top glow
            RadialGradient(
                colors: [themeSettings.currentTheme.primaryColor.opacity(0.12), .clear],
                center: .init(x: 0.8, y: 0),
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // MARK: 1 — Hero Greeting
                     HeroGreetingSection(
                        greeting: greeting,
                        emoji: greetingEmoji,
                        date: todayString,
                        shimmer: shimmer,
                        onAchievementsTapped: { goToAchievements = true }
                    )

                    // MARK: 2 — Manifest CTA Card
                    ManifestCTACard()

                    // MARK: 3 — Quick Actions
                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel(title: "Quick Actions")

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            QuickActionCard(
                                icon: "hurricane",
                                title: "Butterfly Effect",
                                caption: "Ripple every choice",
                                color: Color(hex: "00F0FF"),
                                delay: 0.18
                            ) { goToButterfly = true }

                            QuickActionCard(
                                icon: "target",
                                title: "Set a Goal",
                                caption: "Reverse-engineer success",
                                color: Color(hex: "4A90D9"),
                                delay: 0.22
                            ) { goToGoals = true }

                            
                        }
                    }
                    SimulateFutureWideCard { goToExplore = true }

                    // MARK: 4 — Daily Insight
                    DailyInsightCard(insight: todayInsight)

                    // MARK: 5 — Stats Strip
                    StatsStrip(
                        simulations: historyManager.history.count,
                        branches: totalBranches
                    )

                    // MARK: 6 — Achievements
                    AchievementsStrip(
                        achievements: achievementManager.achievements,
                        onTapAll: { goToAchievements = true }
                    )
                    .padding(.horizontal, -20)

                    // MARK: 7 — Recent Simulation
                    if let recent = historyManager.history.last {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionLabel(title: "Recent Simulation")
                            RecentSimulationCard(branch: recent) {
                                selectedBranch = recent
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
        // Navigation destinations
        .navigationDestination(isPresented: $goToLibrary) { LibraryView() }
        .navigationDestination(isPresented: $goToAchievements) { AchievementsView() }
        .fullScreenCover(isPresented: $goToExplore) { IdeaInputView() }
        .fullScreenCover(isPresented: $goToGoals) { GoalInputView() }
        .fullScreenCover(isPresented: $goToButterfly) { WowFeatureView() }
        .fullScreenCover(item: $selectedBranch) { branch in
            NavigationView {
                HistoryDetailWrapper(branch: branch)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissToHome)) { _ in
            // Collapse all possible modal flows to return to Home
            goToExplore = false
            goToGoals = false
            goToButterfly = false
            selectedBranch = nil
        }
        .onAppear {
            shimmer = 1.0
        }
    }
}

// MARK: - Hero Greeting Section
private struct HeroGreetingSection: View {
    let greeting: String
    let emoji: String
    let date: String
    let shimmer: CGFloat
    let onAchievementsTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting + " " + emoji)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))

                    Group {
                        Text("Future")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        + Text("\nExplorer")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                    }
                    .shadow(color: Color(hex: "C4A6F0").opacity(0.35), radius: 12, x: 0, y: 0)
                }

                Spacer()

                // Achievements and Date badge
                HStack(spacing: 12) {
                    
                    // Achievements Trophy Button
                    
                    
                    // Date badge
                    VStack(spacing: 2) {
                        Text(Date().formatted(.dateTime.day()))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(Date().formatted(.dateTime.month(.wide)))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "7EC8E3"))
                            .tracking(1.5)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                    )
                }
                .padding(.top, 8)
            }
        }
        .padding(.top, 16)
    }
}

// MARK: - Manifest CTA Card
private struct ManifestCTACard: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @State private var goToExplore = false
    @State private var shimmerX: CGFloat = -300

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "2D1B69").opacity(0.85), Color(hex: "1A1035").opacity(0.9)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .opacity(0.3)

            // Glow orb
            Circle()
                .fill(RadialGradient(
                    colors: [themeSettings.currentTheme.primaryColor.opacity(0.4), .clear],
                    center: .center, startRadius: 0, endRadius: 150
                ))
                .frame(width: 200, height: 200)
                .offset(x: 80, y: -60)

            // Shimmer sweep
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.06), location: 0.5),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .offset(x: shimmerX)
                .mask(RoundedRectangle(cornerRadius: 28))
//                .animation(.linear(duration: 3.5).repeatForever(autoreverses: false), value: shimmerX)

            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [themeSettings.currentTheme.primaryColor.opacity(0.5), Color(hex: "4A90D9").opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )

            HStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [themeSettings.currentTheme.primaryColor.opacity(0.4), .clear],
                            center: .center, startRadius: 0, endRadius: 40
                        ))
                        .frame(width: 72, height: 72)

                    Image(systemName: "sparkles")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.8), radius: 12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Simulate a Decision")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Let AI unfold every possible path of your future.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(4)
                        .lineLimit(2)

                    NavigationLink(destination: IdeaInputView()) {
                        HStack(spacing: 6) {
                            Text("Explore")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [themeSettings.currentTheme.primaryColor, Color(hex: "4A90D9")],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                                .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.6), radius: 10, y: 4)
                        )
                    }
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .onAppear { shimmerX = 400 }
    }
}

// MARK: - Quick Action Card
private struct QuickActionCard: View {
    let icon: String
    let title: String
    let caption: String
    let color: Color
    let delay: Double
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                        .shadow(color: color.opacity(0.6), radius: 6)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
//                    Text(caption)
//                        .font(.system(size: 11, weight: .medium, design: .rounded))
//                        .foregroundColor(.white.opacity(0.4))
//                        .lineLimit(2)
//                        .lineSpacing(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "070B14").opacity(0.5))
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(pressed ? 0.5 : 0.2), .clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: color.opacity(pressed ? 0.2 : 0.05), radius: pressed ? 12 : 6, y: 4)
            .scaleEffect(pressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: pressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Daily Insight Card
private struct DailyInsightCard: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let insight: (quote: String, model: String)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel(title: "Daily Insight")

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4A90D9").opacity(0.08), themeSettings.currentTheme.primaryColor.opacity(0.06)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color(hex: "4A90D9").opacity(0.18), lineWidth: 1)

                HStack(spacing: 16) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4A90D9").opacity(0.5), Color(hex: "C4A6F0").opacity(0.3)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .offset(y: -4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(insight.quote)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)

                        Text("— \(insight.model)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "7EC8E3").opacity(0.7))
                    }
                }
                .padding(20)
            }
        }
    }
}

// MARK: - Stats Strip
private struct StatsStrip: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let simulations: Int
    let branches: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel(title: "Your Progress")

            HStack(spacing: 12) {
                StatPill(
                    value: "\(simulations)",
                    label: "Simulations",
                    icon: "wand.and.stars",
                    color: themeSettings.currentTheme.primaryColor
                )
                StatPill(
                    value: "\(branches)",
                    label: "Branches",
                    icon: "arrow.triangle.branch",
                    color: Color(hex: "4A90D9")
                )
                StatPill(
                    value: simulations > 0 ? "Active" : "Begin",
                    label: "Status",
                    icon: "bolt.fill",
                    color: Color(hex: "00F0FF")
                )
            }
        }
    }
}

private struct StatPill: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.6), radius: 4)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 18)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            }
        )
    }
}

// MARK: - Recent Simulation Card
private struct RecentSimulationCard: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let branch: Branch
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(themeSettings.currentTheme.primaryColor.opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: branch.scenarios.first?.iconName ?? "sparkles")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: "7EC8E3").opacity(0.4), radius: 6)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(branch.parentDecision.text)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .lineSpacing(3)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(branch.parentDecision.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.35))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [themeSettings.currentTheme.primaryColor.opacity(pressed ? 0.4 : 0.15), .clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: themeSettings.currentTheme.primaryColor.opacity(pressed ? 0.12 : 0.04), radius: 12, y: 4)
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: pressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation { pressed = true } }
                .onEnded { _ in withAnimation { pressed = false } }
        )
    }
}

// MARK: - Section Label
private struct SectionLabel: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(.white.opacity(0.35))
            .tracking(1.4)
            .textCase(.uppercase)
    }
}

// MARK: - Achievements Strip
private struct AchievementsStrip: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let achievements: [Achievement]
    let onTapAll: () -> Void

    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }

    // Sort achievements to show unlocked first
    var sortedAchievements: [Achievement] {
        achievements.sorted { $0.isUnlocked && !$1.isUnlocked }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionLabel(title: "Achievements (\(unlockedCount)/\(achievements.count))")
                Spacer()
                Button(action: onTapAll) {
                    Text("View All")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(themeSettings.currentTheme.primaryColor)
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(sortedAchievements) { achievement in
                        AchievementMiniCard(achievement: achievement)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

private struct AchievementMiniCard: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? themeSettings.currentTheme.primaryColor.opacity(0.15) : Color.white.opacity(0.05))
                    .frame(width: 48, height: 48)
                
                if achievement.isUnlocked {
                    Circle()
                        .stroke(themeSettings.currentTheme.primaryColor.opacity(0.4), lineWidth: 1)
                        .frame(width: 48, height: 48)
                }
                
                Image(systemName: achievement.isUnlocked ? achievement.iconName : "lock.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(achievement.isUnlocked ? themeSettings.currentTheme.primaryColor : .white.opacity(0.3))
                    .shadow(color: achievement.isUnlocked ? themeSettings.currentTheme.primaryColor.opacity(0.6) : .clear, radius: 6)
            }

            Text(achievement.title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.4))
                .lineLimit(1)
                .frame(width: 76)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                if achievement.isUnlocked {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [themeSettings.currentTheme.primaryColor.opacity(0.05), .clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [themeSettings.currentTheme.primaryColor.opacity(0.3), .clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "070B14").opacity(0.5))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
            }
        )
        .shadow(color: achievement.isUnlocked ? themeSettings.currentTheme.primaryColor.opacity(0.1) : .clear, radius: 10, y: 5)
    }
}

// MARK: - Simulate Future Wide Card
private struct SimulateFutureWideCard: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let action: () -> Void
    @State private var pressed = false
    @State private var glimmer = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Text Area (Moved to the left without the icon)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Simulate Future")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Explore every possible path")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Chevron/Arrow Indicator
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(24)
            .background(
                ZStack {
                    // Base Image
                    GeometryReader { geo in
                        Image("simulate_future_bg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                    
                    // Darkening Overlay & Glow
                    LinearGradient(
                        colors: [Color(hex: "070B14").opacity(0.7), themeSettings.currentTheme.primaryColor.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    // Subtle background gradient that animates
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeSettings.currentTheme.primaryColor.opacity(0.15),
                                    Color(hex: "4A90D9").opacity(0.05),
                                    themeSettings.currentTheme.primaryColor.opacity(0.1)
                                ],
                                startPoint: glimmer ? .topLeading : .bottomTrailing,
                                endPoint: glimmer ? .bottomTrailing : .topLeading
                            )
                        )
                        .blendMode(.overlay)
                    
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [themeSettings.currentTheme.primaryColor.opacity(0.6), Color.white.opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: themeSettings.currentTheme.primaryColor.opacity(pressed ? 0.3 : 0.15), radius: pressed ? 12 : 16, y: pressed ? 4 : 8)
            .scaleEffect(pressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: pressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                glimmer.toggle()
            }
        }
    }
}

