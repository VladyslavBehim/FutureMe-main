import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var historyManager: HistoryManager
    @State private var appearCards = false
    @State private var backgroundPulse = false
    @State private var selectedBranch: Branch?

    var body: some View {
        ZStack {
            // Cosmic background
            Color(hex: "070B14").ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [Color(hex: "7B5EA7").opacity(backgroundPulse ? 0.18 : 0.08), .clear]),
                center: .init(x: 0.2, y: 0.15),
                startRadius: 10,
                endRadius: 300
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: backgroundPulse)

            VStack(alignment: .leading, spacing: 0) {
                // MARK: Custom Premium Header
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        Text("Simulation")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        + Text("\nHistory")
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

                    Text("Relive your past decisions and explore the paths you manifested.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.6))
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)

                if historyManager.history.isEmpty {
                    Spacer()
                    HistoryEmptyStateView()
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            ForEach(Array(historyManager.history.enumerated()), id: \.element.id) { index, branch in
                                HistoryCardView(branch: branch, index: index, appear: appearCards) {
                                    selectedBranch = branch
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 120)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            backgroundPulse = true
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appearCards = true
            }
        }
        .fullScreenCover(item: $selectedBranch) { branch in
            HistoryDetailWrapper(branch: branch)
        }
    }
}

// MARK: - History Card

struct HistoryCardView: View {
    let branch: Branch
    let index: Int
    let appear: Bool
    let action: () -> Void
    @State private var pressed = false
    @State private var hover = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                
                // Hologram Icon Core
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "4A90D9").opacity(0.2), .clear],
                                center: .center, startRadius: 5, endRadius: 35
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    // Rotating subtle energy ring
                    Circle()
                        .trim(from: 0, to: 0.8)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "7B5EA7").opacity(0.8), .clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(hover ? 360 : 0))
                        .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: hover)
                    
                    Image(systemName: branch.scenarios.first?.iconName ?? "sparkles")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: "7EC8E3").opacity(0.5), radius: 4)
                }
                .padding(.top, 8)

                // Text content
                VStack(spacing: 6) {
                    Text(branch.parentDecision.text)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(height: 38, alignment: .top)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(branch.parentDecision.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(Color.white.opacity(0.4))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                    
                    // Dark cosmic gradient
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "070B14").opacity(0.7), Color(hex: "1F0D05").opacity(0.3)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                    
                    // Highlight edge
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.1), .clear, Color(hex: "7B5EA7").opacity(0.3)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color(hex: "7B5EA7").opacity(0.05), radius: 8, y: 5)
        }
        .buttonStyle(HistoryCardButtonStyle())
        // Staggered Entrance
        .opacity(appear ? 1 : 0)
        .scaleEffect(appear ? 1 : 0.8)
        .rotation3DEffect(
            .degrees(appear ? 0 : 15),
            axis: (x: 1, y: -1, z: 0)
        )
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7)
            .delay(Double(index) * 0.08),
            value: appear
        )
        .onAppear {
            hover = true
        }
    }
}

// MARK: - History Card Button Style
struct HistoryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Empty State

struct HistoryEmptyStateView: View {
    @State private var iconFloat = false
    @State private var appear = false
    @State private var pulseRing = false

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                // Outer Pulse Ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "4A90D9").opacity(pulseRing ? 0.3 : 0.0), .clear],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulseRing ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulseRing)
                
                // Inner Core
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "7B5EA7").opacity(0.15), .clear],
                            center: .center, startRadius: 10, endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "cube.transparent")
                    .font(.system(size: 54, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "7EC8E3").opacity(0.6), radius: 10)
                    .offset(y: iconFloat ? -8 : 8)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: iconFloat)
            }

            VStack(spacing: 12) {
                Text("No Memories Yet")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.1), radius: 5)

                Text("Go to Explore and run your first\nfuture simulation to manifest a reality.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .opacity(appear ? 1 : 0)
        .scaleEffect(appear ? 1 : 0.85)
        .animation(.spring(response: 0.65, dampingFraction: 0.7).delay(0.1), value: appear)
        .onAppear {
            iconFloat = true
            pulseRing = true
            withAnimation { appear = true }
        }
        .frame(maxWidth: .infinity , alignment: .center)
    }
}

// MARK: - History Detail Wrapper

struct HistoryDetailWrapper: View {
    let branch: Branch
    @StateObject private var viewModel: SimulationViewModel
    @Environment(\.presentationMode) var presentationMode

    init(branch: Branch) {
        self.branch = branch
        _viewModel = StateObject(wrappedValue: SimulationViewModel(decision: branch.parentDecision, questions: [], scenarios: branch.scenarios))
    }

    var body: some View {
        FutureMapView(decision: branch.parentDecision, viewModel: viewModel)
    }
}
