import SwiftUI

// MARK: - Simulation Loading View

struct SimulationLoadingView: View {
    let decision: Decision
    let questions: [Question]
    @EnvironmentObject var themeSettings: ThemeSettings

    @StateObject private var viewModel: SimulationViewModel
    @State private var phraseIndex = 0
    @State private var phraseVisible = true

    private let loadingPhrases = [
        "Mapping probability branches…",
        "Extrapolating timelines…",
        "Calculating future outcomes…",
        "Simulating possible worlds…",
        "Analyzing your decision…",
        "Almost there…"
    ]

    init(decision: Decision, questions: [Question]) {
        self.decision = decision
        self.questions = questions
        _viewModel = StateObject(wrappedValue: SimulationViewModel(decision: decision, questions: questions))
    }

    var body: some View {
        ZStack {
            // Cosmic background
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle ambient radials
            RadialGradient(
                colors: [themeSettings.currentTheme.primaryColor.opacity(0.18), .clear],
                center: .init(x: 0.5, y: 0.6),
                startRadius: 0, endRadius: 360
            )
            .ignoresSafeArea()

            if let error = viewModel.error {
                ErrorStateView(message: error) {
                    Task { await viewModel.generateSimulations() }
                }
            } else {
                VStack(spacing: 0) {
                    Spacer()

                    // ── Timeline animation ───────────────────────
                    TimelineBranchView(primaryColor: themeSettings.currentTheme.primaryColor)
                        .frame(height: 340)

                    Spacer().frame(height: 48)

                    // ── Text section ─────────────────────────────
                    VStack(spacing: 12) {
                        Text("Simulating Futures")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text(loadingPhrases[phraseIndex])
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .opacity(phraseVisible ? 1 : 0)
                            .animation(.easeInOut(duration: 0.4), value: phraseVisible)
                    }

                    Spacer()
                }
                .padding(.horizontal, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.scenarios != nil },
            set: { _ in }
        )) {
            FutureMapView(decision: decision, viewModel: viewModel)
        }
        .task {
            startPhraseRotation()
            await viewModel.generateSimulations()
        }
    }

    private func startPhraseRotation() {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { timer in
            withAnimation { phraseVisible = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                phraseIndex = (phraseIndex + 1) % loadingPhrases.count
                withAnimation { phraseVisible = true }
            }
            if viewModel.scenarios != nil { timer.invalidate() }
        }
    }
}

// MARK: - Timeline Branch View

private struct TimelineBranchView: View {
    let primaryColor: Color

    // Growth progress for each segment [0…1]
    @State private var rootGrowth: CGFloat = 0
    @State private var leftGrowth:  CGFloat = 0
    @State private var rightGrowth: CGFloat = 0
    @State private var leftSubGrowth: [CGFloat] = [0, 0, 0]
    @State private var rightSubGrowth: [CGFloat] = [0, 0, 0]
    @State private var nodeAppear: [[Bool]] = [[false, false, false], [false, false, false]]
    @State private var rootNodeAppear = false
    @State private var branchNodeAppear = [false, false]
    @State private var loopPhase: CGFloat = 0

    // Continuous subtle pulse for grown nodes
    @State private var nodePulse = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // ── Layout constants ───────────────────────────────
            let rootX: CGFloat  = w / 2
            let rootY: CGFloat  = h - 20
            let rootTopY: CGFloat = h * 0.55

            // Branch forks
            let leftBranchX: CGFloat  = w * 0.22
            let rightBranchX: CGFloat = w * 0.78
            let branchY: CGFloat      = h * 0.30

            // Sub-branch endpoints (left side)
            let leftSubs: [(CGFloat, CGFloat)] = [
                (w * 0.04,  h * 0.02),
                (w * 0.20,  h * 0.05),
                (w * 0.38,  h * 0.10)
            ]
            // Sub-branch endpoints (right side)
            let rightSubs: [(CGFloat, CGFloat)] = [
                (w * 0.62,  h * 0.10),
                (w * 0.80,  h * 0.05),
                (w * 0.96,  h * 0.02)
            ]

            ZStack {
                // ── Root trunk ────────────────────────────────
                GrowingLine(
                    from: CGPoint(x: rootX, y: rootY),
                    to:   CGPoint(x: rootX, y: rootTopY),
                    progress: rootGrowth,
                    color: primaryColor,
                    lineWidth: 3
                )

                // ── Left branch ──────────────────────────────
                GrowingLine(
                    from: CGPoint(x: rootX,       y: rootTopY),
                    to:   CGPoint(x: leftBranchX, y: branchY),
                    progress: leftGrowth,
                    color: primaryColor.opacity(0.85),
                    lineWidth: 2.5
                )

                // ── Right branch ─────────────────────────────
                GrowingLine(
                    from: CGPoint(x: rootX,        y: rootTopY),
                    to:   CGPoint(x: rightBranchX, y: branchY),
                    progress: rightGrowth,
                    color: Color(hex: "4A90D9").opacity(0.85),
                    lineWidth: 2.5
                )

                // ── Left sub-branches ────────────────────────
                ForEach(0..<3) { i in
                    GrowingLine(
                        from: CGPoint(x: leftBranchX, y: branchY),
                        to:   CGPoint(x: leftSubs[i].0, y: leftSubs[i].1),
                        progress: leftSubGrowth[i],
                        color: primaryColor.opacity(0.6),
                        lineWidth: 1.8
                    )

                    // Endpoint node
                    if nodeAppear[0][i] {
                        BranchNode(
                            color: primaryColor,
                            size: 10,
                            pulse: nodePulse
                        )
                        .position(x: leftSubs[i].0, y: leftSubs[i].1)
                        .transition(.scale(scale: 0.1).combined(with: .opacity))
                    }
                }

                // ── Right sub-branches ───────────────────────
                ForEach(0..<3) { i in
                    GrowingLine(
                        from: CGPoint(x: rightBranchX, y: branchY),
                        to:   CGPoint(x: rightSubs[i].0, y: rightSubs[i].1),
                        progress: rightSubGrowth[i],
                        color: Color(hex: "4A90D9").opacity(0.6),
                        lineWidth: 1.8
                    )

                    if nodeAppear[1][i] {
                        BranchNode(
                            color: Color(hex: "4A90D9"),
                            size: 10,
                            pulse: nodePulse
                        )
                        .position(x: rightSubs[i].0, y: rightSubs[i].1)
                        .transition(.scale(scale: 0.1).combined(with: .opacity))
                    }
                }

                // ── Branch fork nodes ────────────────────────
                if branchNodeAppear[0] {
                    BranchNode(color: primaryColor, size: 13, pulse: nodePulse)
                        .position(x: leftBranchX, y: branchY)
                        .transition(.scale(scale: 0.1).combined(with: .opacity))
                }
                if branchNodeAppear[1] {
                    BranchNode(color: Color(hex: "4A90D9"), size: 13, pulse: nodePulse)
                        .position(x: rightBranchX, y: branchY)
                        .transition(.scale(scale: 0.1).combined(with: .opacity))
                }

                // ── Root node ────────────────────────────────
                if rootNodeAppear {
                    RootNode(color: primaryColor, pulse: nodePulse)
                        .position(x: rootX, y: rootY)
                        .transition(.scale(scale: 0.1).combined(with: .opacity))
                }
            }
        }
        .onAppear { startSequence() }
    }

    private func startSequence() {
        // Sequence timings (seconds)
        let rootDur    = 0.7
        let branchDur  = 0.55
        let subDur     = 0.45

        // Root node immediately
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            rootNodeAppear = true
        }

        // Root trunk grows
        withAnimation(.easeInOut(duration: rootDur)) {
            rootGrowth = 1
        }

        // Left + right branches simultaneously after trunk
        DispatchQueue.main.asyncAfter(deadline: .now() + rootDur + 0.05) {
            withAnimation(.easeInOut(duration: branchDur)) { leftGrowth  = 1 }
            withAnimation(.easeInOut(duration: branchDur)) { rightGrowth = 1 }

            // Branch fork nodes appear
            DispatchQueue.main.asyncAfter(deadline: .now() + branchDur) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                    branchNodeAppear[0] = true
                    branchNodeAppear[1] = true
                }

                // Sub-branches staggered
                for i in 0..<3 {
                    let delay = Double(i) * 0.18
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation(.easeInOut(duration: subDur)) { leftSubGrowth[i]  = 1 }
                        withAnimation(.easeInOut(duration: subDur)) { rightSubGrowth[i] = 1 }

                        DispatchQueue.main.asyncAfter(deadline: .now() + subDur) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                                nodeAppear[0][i] = true
                                nodeAppear[1][i] = true
                            }
                        }
                    }
                }

                // After full tree is built, start looping
                let totalBuildTime = branchDur + Double(3) * 0.18 + subDur + 0.3
                DispatchQueue.main.asyncAfter(deadline: .now() + totalBuildTime) {
                    withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                        nodePulse = true
                    }
                    // Loop: fade out and rebuild
                    loopRebuild(delay: 2.0)
                }
            }
        }
    }

    private func loopRebuild(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            // Fade everything out
            withAnimation(.easeInOut(duration: 0.5)) {
                rootGrowth = 0; leftGrowth = 0; rightGrowth = 0
                leftSubGrowth  = [0, 0, 0]
                rightSubGrowth = [0, 0, 0]
                branchNodeAppear = [false, false]
                nodeAppear = [[false, false, false], [false, false, false]]
                rootNodeAppear = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                startSequence()
            }
        }
    }
}

// MARK: - Growing Line Shape

private struct GrowingLine: View {
    let from: CGPoint
    let to: CGPoint
    let progress: CGFloat
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        Canvas { context, _ in
            let current = CGPoint(
                x: from.x + (to.x - from.x) * progress,
                y: from.y + (to.y - from.y) * progress
            )
            var path = Path()
            path.move(to: from)
            path.addLine(to: current)

            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )

            // Glow tip
            if progress > 0.02 {
                let tipRect = CGRect(x: current.x - 4, y: current.y - 4, width: 8, height: 8)
                context.fill(
                    Path(ellipseIn: tipRect),
                    with: .color(color.opacity(0.9))
                )
                // Outer glow
                let glowRect = CGRect(x: current.x - 8, y: current.y - 8, width: 16, height: 16)
                context.fill(
                    Path(ellipseIn: glowRect),
                    with: .color(color.opacity(0.25))
                )
            }
        }
    }
}

// MARK: - Branch Node

private struct BranchNode: View {
    let color: Color
    let size: CGFloat
    let pulse: Bool

    var body: some View {
        ZStack {
            // Outer glow halo
            Circle()
                .fill(color.opacity(0.18))
                .frame(width: size * 3.2, height: size * 3.2)
                .scaleEffect(pulse ? 1.25 : 0.85)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)

            // Ring
            Circle()
                .stroke(color.opacity(0.55), lineWidth: 1.2)
                .frame(width: size * 1.8, height: size * 1.8)

            // Core
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, color.opacity(0.5)],
                        center: .center, startRadius: 0, endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.8), radius: 6)
        }
    }
}

// MARK: - Root Node

private struct RootNode: View {
    let color: Color
    let pulse: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 56, height: 56)
                .scaleEffect(pulse ? 1.2 : 0.9)
                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulse)

            Circle()
                .stroke(color.opacity(0.4), lineWidth: 1.5)
                .frame(width: 38, height: 38)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, Color(hex: "4A90D9")],
                        center: .center, startRadius: 0, endRadius: 12
                    )
                )
                .frame(width: 22, height: 22)
                .shadow(color: color.opacity(0.9), radius: 10)

            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Loading Animation (legacy, kept for reuse)

struct LoadingAnimation: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @Binding var isAnimating: Bool
    @Binding var pulse: Bool

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    LinearGradient(colors: [themeSettings.currentTheme.primaryColor, themeSettings.currentTheme.primaryColor.opacity(0)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 190, height: 190)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 2.2).repeatForever(autoreverses: false), value: isAnimating)
                .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.4), radius: 12)

            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(
                    LinearGradient(colors: [Color(hex: "4A90D9"), Color(hex: "4A90D9").opacity(0)], startPoint: .bottom, endPoint: .top),
                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                )
                .frame(width: 148, height: 148)
                .rotationEffect(.degrees(isAnimating ? -360 : 0))
                .animation(.linear(duration: 3.2).repeatForever(autoreverses: false), value: isAnimating)

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [themeSettings.currentTheme.primaryColor, Color(hex: "4A90D9").opacity(0.3)]),
                        center: .center, startRadius: 0, endRadius: 48
                    )
                )
                .frame(width: 82, height: 82)
                .scaleEffect(pulse ? 1.18 : 0.88)
                .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.8), radius: pulse ? 32 : 12)
                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulse)

            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
                .scaleEffect(pulse ? 1.12 : 0.9)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
        }
        .onAppear {
            isAnimating = true
            pulse = true
        }
    }
}
