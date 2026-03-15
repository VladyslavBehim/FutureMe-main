import SwiftUI

// MARK: - WowFeatureView
struct WowFeatureView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var achievementManager: AchievementManager
    @StateObject private var viewModel = WowViewModel()
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var appear = false
    @State private var warpSpeed = false

    var body: some View {
        ZStack {
            // Background
            if viewModel.showFinalClimax {
                AngularGradient(
                    gradient: Gradient(colors: [Color(hex: "FF007F"), Color(hex: "7B5EA7"), Color(hex: "00F0FF"), Color(hex: "FF007F")]),
                    center: .center,
                    angle: .degrees(warpSpeed ? 360 : 0)
                )
                .ignoresSafeArea()
                .animation(.linear(duration: 18).repeatForever(autoreverses: false), value: warpSpeed)
                .onAppear { warpSpeed = true }

                Color.black.opacity(0.5).ignoresSafeArea()

            } else if viewModel.isRevealing || viewModel.isSimulating {
                AnimatedWarpBackground(isActive: true).ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: themeSettings.currentTheme.backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Cyan glow
                RadialGradient(
                    colors: [Color(hex: "00F0FF").opacity(0.07), .clear],
                    center: .init(x: 0.5, y: 0.1),
                    startRadius: 0, endRadius: 400
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // MARK: Nav Bar
                HStack {
                    NavBackButton { dismiss() }
                    Spacer()

                    // Mode badge
                    if !viewModel.isRevealing && !viewModel.showFinalClimax {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(hex: "00F0FF"))
                                .frame(width: 6, height: 6)
                                .shadow(color: Color(hex: "00F0FF"), radius: 4)
                            Text("Butterfly Effect")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "00F0FF").opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(hex: "00F0FF").opacity(0.08))
                                .overlay(Capsule().stroke(Color(hex: "00F0FF").opacity(0.2), lineWidth: 1))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 8)

                if viewModel.isRevealing || viewModel.showFinalClimax {
                    WowResultView(viewModel: viewModel)
                } else {
                    WowInputSection(viewModel: viewModel, isFocused: _isFocused, appear: appear)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            achievementManager.unlock(Achievement.butterflyEffect)
            withAnimation(.spring(response: 0.65, dampingFraction: 0.78)) {
                appear = true
                isFocused = true
            }
        }
    }
}

// MARK: - Input Section
struct WowInputSection: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @ObservedObject var viewModel: WowViewModel
    @FocusState var isFocused: Bool
    let appear: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero Block
            VStack(spacing: 16) {
                ZStack {
                    // Glow rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(Color(hex: "00F0FF").opacity(appear ? 0.15 - Double(i) * 0.04 : 0), lineWidth: 1)
                            .frame(width: CGFloat(80 + i * 28), height: CGFloat(80 + i * 28))
                            .scaleEffect(appear ? 1 : 0.6)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double(i) * 0.08 + 0.1), value: appear)
                    }

                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(hex: "00F0FF").opacity(0.18), .clear],
                            center: .center, startRadius: 0, endRadius: 36
                        ))
                        .frame(width: 72, height: 72)

                    Image(systemName: "hurricane")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "00F0FF"), Color(hex: "C4A6F0")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: "00F0FF").opacity(0.8), radius: 14)
                }

                VStack(spacing: 8) {
                    Group {
                        Text("Butterfly")
                            .font(.system(size: 35, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        + Text("\nEffect")
                            .font(.system(size: 35, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "00F0FF"), Color(hex: "C4A6F0")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .shadow(color: Color(hex: "00F0FF").opacity(0.3), radius: 12)
                    .multilineTextAlignment(.center)

                    Text("Enter any tiny action and watch it ripple into chaos across time.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                }
            }
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.88)
            .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.05), value: appear)


            // Input Field
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {

                    TextField("e.g. I decided to wear mismatched socks today...", text: $viewModel.actionText)
                        .focused($isFocused)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .padding(14)
//                        .frame(height: 130)
                        
                }
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(hex: "0D0A1A").opacity(0.6))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        isFocused
                        ? LinearGradient(colors: [themeSettings.currentTheme.primaryColor.opacity(0.8), Color(hex: "C4A6F0").opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.white.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5
                    )
                    .animation(.easeInOut(duration: 0.3), value: isFocused)
            )
            .shadow(color: isFocused ? themeSettings.currentTheme.primaryColor.opacity(0.2) : .clear, radius: 20, y: 6)
            .animation(.easeInOut(duration: 0.3), value: isFocused)
            .padding(.horizontal, 24)
            .opacity(appear ? 1 : 0)
            .animation(.spring(response: 0.65, dampingFraction: 0.75).delay(0.14), value: appear)
            .padding(.vertical)

            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red.opacity(0.8))
                    .font(.system(size: 13, design: .rounded))
                    .padding(.top, 10)
            }

            Spacer()

            // CTA Button
            Button {
                Task {
                    isFocused = false
                    await viewModel.simulate()
                }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isSimulating {
                        ProgressView().tint(.black)
                        Text("Entering time warp...")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    } else {
                        Text("Simulate Chaos")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Image(systemName: "hurricane")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .foregroundColor(!viewModel.actionText.isEmpty ? .black : .white.opacity(0.35))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                !viewModel.actionText.isEmpty
                                    ? LinearGradient(colors: [themeSettings.currentTheme.primaryColor, Color(hex: "5EC4FF")], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                !viewModel.actionText.isEmpty ? Color.white.opacity(0.2) : Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    }
                )
                .shadow(
                    color: !viewModel.actionText.isEmpty ? themeSettings.currentTheme.primaryColor.opacity(0.5) : .clear,
                    radius: 20, y: 8
                )
            }
            .disabled(viewModel.actionText.isEmpty || viewModel.isSimulating)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .opacity(appear ? 1 : 0)
            .animation(.spring(response: 0.65, dampingFraction: 0.75).delay(0.22), value: appear)

        }
    }
}

// MARK: - Result View
struct WowResultView: View {
    @ObservedObject var viewModel: WowViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Action Origin Card ─────────────────────────────────
                    if let action = viewModel.timeline?.action {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "00F0FF").opacity(0.05))
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "00F0FF").opacity(0.22), lineWidth: 1)

                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "00F0FF").opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "hurricane")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(hex: "00F0FF"))
                                        .shadow(color: Color(hex: "00F0FF").opacity(0.6), radius: 6)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ORIGIN ACTION")
                                        .font(.system(size: 9, weight: .black, design: .rounded))
                                        .foregroundColor(Color(hex: "00F0FF").opacity(0.5))
                                        .tracking(2.5)
                                    Text("\"\(action)\"")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.85))
                                        .italic()
                                        .lineLimit(2)
                                        .lineSpacing(3)
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 28)
                    }

                    // ── Timeline Nodes ─────────────────────────────────────
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.revealedNodes.enumerated()), id: \.element.id) { index, node in
                            VStack(spacing: 0) {
                                // Connector line (skip before first node)
                                if index > 0 {
                                    HStack(spacing: 0) {
                                        Spacer().frame(width: 30)
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "00F0FF").opacity(0.4), Color(hex: "7B5EA7").opacity(0.2)],
                                                    startPoint: .top, endPoint: .bottom
                                                )
                                            )
                                            .frame(width: 1.5, height: 32)
                                        Spacer()
                                    }
                                }

                                WowNodeView(
                                    node: node,
                                    index: index,
                                    isFinal: viewModel.showFinalClimax && node.isFinal
                                )
                                .id(node.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Loading indicator while more nodes are coming
                    if viewModel.isRevealing && !viewModel.showFinalClimax {
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(Color(hex: "00F0FF"))
                                .scaleEffect(0.8)
                            Text("Rippling through time...")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "00F0FF").opacity(0.5))
                        }
                        .padding(.top, 20)
                        .id("loader")
                    }

                    Color.clear.frame(height: 120).id("bottom")
                }
            }
            .onChange(of: viewModel.revealedNodes.count) { _, _ in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}

// MARK: - Node View
struct WowNodeView: View {
    let node: WowNode
    let index: Int
    let isFinal: Bool
    @State private var appear = false
    @State private var glowPulse = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // ── Left: Number Column ──────────────────────────────────
            VStack(spacing: 0) {
                ZStack {
                    if isFinal {
                        // Star burst for final node
                        Circle()
                            .fill(Color.white.opacity(glowPulse ? 0.25 : 0.12))
                            .frame(width: 44, height: 44)
                            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: glowPulse)
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1.2)
                            .frame(width: 34, height: 34)
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .fill(Color(hex: "00F0FF").opacity(0.12))
                            .frame(width: 34, height: 34)
                        Circle()
                            .stroke(Color(hex: "00F0FF").opacity(0.4), lineWidth: 1)
                            .frame(width: 34, height: 34)
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "00F0FF"))
                    }
                }
                .padding(.top, 18)
            }
            .frame(width: 34)

            // ── Right: Card Content ──────────────────────────────────
            VStack(alignment: .leading, spacing: 10) {
                // Timeframe badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(isFinal ? Color.white : Color(hex: "00F0FF"))
                        .frame(width: 5, height: 5)
                        .shadow(color: isFinal ? .white.opacity(0.8) : Color(hex: "00F0FF").opacity(0.8), radius: 3)
                    Text(node.timeframe.uppercased())
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(isFinal ? .white.opacity(0.7) : Color(hex: "00F0FF").opacity(0.8))
                        .tracking(2.2)
                }

                Text(node.description)
                    .font(.system(size: isFinal ? 20 : 15, weight: isFinal ? .bold : .medium, design: .rounded))
                    .foregroundColor(isFinal ? .white : .white.opacity(0.88))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    if isFinal {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color(hex: "C4A6F0").opacity(0.06)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(glowPulse ? 0.45 : 0.25), lineWidth: 1.2)
                            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: glowPulse)
                    } else {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "0A0818").opacity(0.65))
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "00F0FF").opacity(0.14), lineWidth: 1)
                    }
                }
            )
            .shadow(
                color: isFinal ? Color.white.opacity(0.12) : Color(hex: "00F0FF").opacity(0.06),
                radius: isFinal ? 24 : 8, y: 4
            )
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 18)
        .animation(.spring(response: 0.55, dampingFraction: 0.78), value: appear)
        .onAppear {
            withAnimation { appear = true }
            if isFinal { glowPulse = true }
        }
    }
}


// MARK: - Warp Background Graphic
struct AnimatedWarpBackground: View {
    let isActive: Bool
    @State private var phase = 0.0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(hex: "070B14")

                ForEach(0..<40) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.8)))
                        .frame(width: Double.random(in: 2...6))
                        .offset(x: isActive ? (proxy.size.width * 2) : 0)
                        .rotationEffect(.degrees(Double(i) * 360/40))
                        .animation(
                            .linear(duration: Double.random(in: 0.5...2.0))
                            .repeatForever(autoreverses: false),
                            value: isActive
                        )
                }

                // Central black hole
                Circle()
                    .fill(Color.black)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(hex: "00F0FF"), radius: isActive ? 50 : 0)
                    .animation(.easeInOut(duration: 1).repeatForever(), value: isActive)
            }
        }
        .drawingGroup()
    }
}
