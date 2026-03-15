import SwiftUI

struct OnboardingView: View {
    let onCompletion: () -> Void
    @State private var currentPage = 0
    @State private var backgroundPulse = false
    @State private var slideIn = false

    let items: [OnboardingItem] = [
        OnboardingItem(
            title: "Welcome to\nFutureMe",
            description: "Explore the possible futures of your life decisions using AI simulation.",
            icon: "wand.and.stars",
            gradientColors: [Color(hex: "7B5EA7"), Color(hex: "4A90D9")]
        ),
        OnboardingItem(
            title: "Ask Anything",
            description: "Thinking about moving cities? Changing careers? Starting a business? Let's simulate it.",
            icon: "questionmark.bubble.fill",
            gradientColors: [Color(hex: "4A90D9"), Color(hex: "00D4A8")]
        ),
        OnboardingItem(
            title: "Discover Your Paths",
            description: "See optimistic and challenging scenarios unfold across detailed simulated timelines.",
            icon: "arrow.triangle.branch",
            gradientColors: [Color(hex: "FF6B35"), Color(hex: "F7C948")]
        )
    ]

    var body: some View {
        ZStack {
            // Cosmic background
            Color(hex: "070B14").ignoresSafeArea()

            // Nebula glow — shifts per page
            RadialGradient(
                gradient: Gradient(colors: [items[currentPage].gradientColors[0].opacity(backgroundPulse ? 0.45 : 0.25), .clear]),
                center: .init(x: 0.3, y: 0.25),
                startRadius: 10,
                endRadius: 380
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.2), value: currentPage)

            RadialGradient(
                gradient: Gradient(colors: [items[currentPage].gradientColors[1].opacity(backgroundPulse ? 0.3 : 0.15), .clear]),
                center: .init(x: 0.8, y: 0.7),
                startRadius: 10,
                endRadius: 280
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.2), value: currentPage)

            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<items.count, id: \.self) { index in
                        OnboardingPageView(item: items[index], appear: slideIn)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)

                // Bottom area
                VStack(spacing: 28) {
                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<items.count, id: \.self) { i in
                            Capsule()
                                .fill(
                                    i == currentPage
                                        ? LinearGradient(colors: items[currentPage].gradientColors, startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.25)], startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: i == currentPage ? 28 : 8, height: 8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                        }
                    }

                    // CTA Button
                    Button(action: {
                        if currentPage < items.count - 1 {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.35)) {
                                onCompletion()
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text(currentPage == items.count - 1 ? "Start Exploring" : "Continue")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))

                            Image(systemName: currentPage == items.count - 1 ? "sparkles" : "arrow.right")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: items[currentPage].gradientColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            }
                        )
                        .shadow(
                            color: items[currentPage].gradientColors[0].opacity(0.5),
                            radius: 20, y: 8
                        )
                        .animation(.easeInOut(duration: 0.4), value: currentPage)
                    }
                    .padding(.horizontal, 24)

                    // Skip for non-last pages
                    if currentPage < items.count - 1 {
                        Button("Skip") {
                            withAnimation(.easeOut(duration: 0.35)) {
                                onCompletion()
                            }
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                    }
                }
                .padding(.bottom, 52)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.15)) {
                slideIn = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                backgroundPulse = true
            }
        }
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let item: OnboardingItem
    let appear: Bool

    @State private var iconFloat = false
    @State private var orbitRotate = false

    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            // Large icon with orbit
            ZStack {
                // Outer orbit ring
                Circle()
                    .stroke(
                        LinearGradient(colors: [item.gradientColors[0].opacity(0.6), .clear],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(orbitRotate ? 360 : 0))
                    .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: orbitRotate)

                // Inner glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [item.gradientColors[0].opacity(0.35), item.gradientColors[1].opacity(0.1), .clear],
                            center: .center, startRadius: 0, endRadius: 75
                        )
                    )
                    .frame(width: 150, height: 150)

                // Icon
                Image(systemName: item.icon)
                    .font(.system(size: 58, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: item.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: item.gradientColors[0].opacity(0.7), radius: 20)
                    .offset(y: iconFloat ? -8 : 8)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: iconFloat)
            }
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.6)
            .animation(.spring(response: 0.75, dampingFraction: 0.65).delay(0.05), value: appear)

            // Text
            VStack(spacing: 16) {
                Text(item.title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text(item.description)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 32)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)
            .animation(.spring(response: 0.75, dampingFraction: 0.7).delay(0.18), value: appear)

            Spacer()
        }
        .onAppear {
            iconFloat = true
            orbitRotate = true
        }
    }
}

// MARK: - Data Model

struct OnboardingItem {
    let title: String
    let description: String
    let icon: String
    let gradientColors: [Color]
}
