import SwiftUI

// MARK: - Layout Preferences
struct TimelineMapData: Equatable {
    var bounds: [UUID: Anchor<CGRect>] = [:]
    var connections: [NodeConnectionData] = []
}

struct NodeConnectionData: Equatable {
    let parentId: UUID
    let childId: UUID
    let color: Color
}

struct TimelineMapKey: PreferenceKey {
    static var defaultValue = TimelineMapData()
    static func reduce(value: inout TimelineMapData, nextValue: () -> TimelineMapData) {
        let next = nextValue()
        value.bounds.merge(next.bounds) { $1 }
        value.connections.append(contentsOf: next.connections)
    }
}

// MARK: - Main Horizontal Future Map
struct FutureMapView: View {
    let decision: Decision
    @ObservedObject var viewModel: SimulationViewModel
    @EnvironmentObject var themeSettings: ThemeSettings
    @Environment(\.dismiss) private var dismiss

    @State private var appearAnimation = false
    @State private var backgroundPulse = false
    @State private var selectedScenario: Scenario?

    // Zoom State
    @State private var currentZoom: CGFloat = 1.0
    @GestureState private var gestureZoom: CGFloat = 1.0

    // Image Export
    @State private var renderedImage: Image?
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            // Map
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ScrollViewReader { proxy in
                    ZStack(alignment: .leading) {
                        TimelineContent(decision: decision, viewModel: viewModel, onDetails: { scenario in
                            selectedScenario = scenario
                        })
                            .backgroundPreferenceValue(TimelineMapKey.self) { mapData in
                                GeometryReader { geo in
                                    ConnectionsCanvas(data: mapData, geo: geo)
                                }
                            }
                    }
                    .padding(.vertical, 160) // Safe padding for infinite expanding
                    .scaleEffect(currentZoom * gestureZoom)
                    .gesture(
                        MagnificationGesture()
                            .updating($gestureZoom) { value, state, _ in
                                state = value
                            }
                            .onEnded { value in
                                let newZoom = currentZoom * value
                                currentZoom = min(max(newZoom, 0.4), 3.0)
                            }
                    )
                    .opacity(appearAnimation ? 1 : 0)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                            appearAnimation = true
                        }
                    }
                }
            }
            .coordinateSpace(name: "TimelineSpace")

            // ── Floating top bar ──────────────────────────────────
            VStack {
                HStack {
                    // Close — posts notification to collapse entire stack to HomeView
                    Button(action: {
                        NotificationCenter.default.post(name: .dismissToHome, object: nil)
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 3)
                    }

                    Spacer()

                    // Title badge
                    Text("Timeline Map")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        )

                    Spacer()

                    // Invisible spacer to balance HStack (same width as close button)
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                Spacer()
            }
        }
        .ignoresSafeArea()
        .sheet(item: $selectedScenario) { scenario in
            ScenarioDetailView(scenario: scenario)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                backgroundPulse = true
            }
        }
    }
    
    @MainActor
    private func renderMap() {
        // Build the view content we want to export
        let mapContent = mapRenderContent
            .frame(width: 2500, height: 1500) // Render a large canvas area
            .background(
                LinearGradient(
                    colors: themeSettings.currentTheme.backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        
        let renderer = ImageRenderer(content: mapContent)
        renderer.scale = 2.0
        
        if let uiImage = renderer.uiImage {
            self.renderedImage = Image(uiImage: uiImage)
        }
    }
    
    // Abstracted content just for rendering export
    private var mapRenderContent: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            TimelineContent(decision: decision, viewModel: viewModel, onDetails: { scenario in
                selectedScenario = scenario
            })
                .backgroundPreferenceValue(TimelineMapKey.self) { mapData in
                    GeometryReader { geo in
                        ConnectionsCanvas(data: mapData, geo: geo)
                    }
                }
        }
        .padding(160)
    }
}

// MARK: - Timeline Content Extracted for Preferences
struct TimelineContent: View {
    let decision: Decision
    @ObservedObject var viewModel: SimulationViewModel
    let onDetails: (Scenario) -> Void
    
    var body: some View {
        HStack(spacing: 80) {
            DecisionTimelineNode(decision: decision)
                .anchorPreference(key: TimelineMapKey.self, value: .bounds) {
                    TimelineMapData(bounds: [decision.id: $0])
                }
                .id("root")
                .padding(.leading, 60)
            
            if let scenarios = viewModel.scenarios {
                VStack(spacing: 80) {
                    ForEach(scenarios) { scenario in
                        RecursiveTimelineNode(
                            scenario: scenario,
                            parentId: decision.id,
                            viewModel: viewModel,
                            onDetails: onDetails
                        )
                    }
                }
                .background(
                    Color.clear.preference(key: TimelineMapKey.self, value: TimelineMapData(connections: scenarios.map {
                        NodeConnectionData(parentId: decision.id, childId: $0.id, color: $0.type == .optimistic ? Color(hex: "4A90D9") : Color(hex: "FF6B35"))
                    }))
                )
                .padding(.trailing, 100)
            }
        }
    }
}

// MARK: - Connections Canvas (GPU Accelerated Lines)
struct ConnectionsCanvas: View {
    let data: TimelineMapData
    let geo: GeometryProxy
    
    @State private var dashPhase: CGFloat = 0
    
    var body: some View {
        Canvas { context, size in
            for conn in data.connections {
                guard let parentAnchor = data.bounds[conn.parentId],
                      let childAnchor = data.bounds[conn.childId] else { continue }
                
                // Use explicit bounds resolution
                let parentRect = geo[parentAnchor]
                let childRect = geo[childAnchor]
                
                // Map connection points
                let start = CGPoint(x: parentRect.maxX, y: parentRect.midY)
                let end = CGPoint(x: childRect.minX, y: childRect.midY)
                
                // Double check we are actually drawing something
                if start.x.isNaN || end.x.isNaN { continue }
                
                var path = Path()
                path.move(to: start)
                
                let controlLength = max(abs(end.x - start.x) * 0.45, 40)
                let control1 = CGPoint(x: start.x + controlLength, y: start.y)
                let control2 = CGPoint(x: end.x - controlLength, y: end.y)
                
                path.addCurve(to: end, control1: control1, control2: control2)
                
                // Outer glow stroke
                context.stroke(
                    path,
                    with: .color(conn.color.opacity(0.35)),
                    lineWidth: 8
                )
                
                // Inner dashed energy line
                var dashedPath = path
                context.stroke(
                    dashedPath,
                    with: .color(conn.color.opacity(0.9)),
                    style: StrokeStyle(lineWidth: 3.0, lineCap: .round, dash: [10, 20], dashPhase: dashPhase)
                )
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                dashPhase -= 60
            }
        }
    }
}

// MARK: - Recursive Node
struct RecursiveTimelineNode: View {
    let scenario: Scenario
    let parentId: UUID
    @ObservedObject var viewModel: SimulationViewModel
    let onDetails: (Scenario) -> Void
    
    var isOptimistic: Bool { scenario.type == .optimistic }
    var primaryColor: Color { isOptimistic ? Color(hex: "4A90D9") : Color(hex: "FF6B35") }
    
    var body: some View {
        HStack(spacing: 80) {
            
            // 1. The Scenario Card itself
            TimelineScenarioCard(scenario: scenario, viewModel: viewModel, primaryColor: primaryColor, onDetails: onDetails)
                .anchorPreference(key: TimelineMapKey.self, value: .bounds) {
                    TimelineMapData(bounds: [scenario.id: $0])
                }
            
            // 2. Its Children
            if scenario.isGeneratingChildren == true {
                let loadingId = UUID()
                TimelineLoadingBlock(color: primaryColor)
                    .anchorPreference(key: TimelineMapKey.self, value: .bounds) { anchor in
                        TimelineMapData(
                            bounds: [loadingId: anchor],
                            connections: [NodeConnectionData(parentId: scenario.id, childId: loadingId, color: primaryColor)]
                        )
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
            } else if scenario.isExpanded == true, let children = scenario.children {
                VStack(spacing: 70) {
                    ForEach(children) { child in
                        RecursiveTimelineNode(
                            scenario: child,
                            parentId: scenario.id,
                            viewModel: viewModel,
                            onDetails: onDetails
                        )
                    }
                }
                .background(
                    Color.clear.preference(key: TimelineMapKey.self, value: TimelineMapData(connections: children.map {
                        NodeConnectionData(parentId: scenario.id, childId: $0.id, color: $0.type == .optimistic ? Color(hex: "4A90D9") : Color(hex: "FF6B35"))
                    }))
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .leading)),
                    removal: .opacity.combined(with: .scale(scale: 0.9, anchor: .leading))
                ))
            }
        }
    }
}

// MARK: - Timeline Scenario Card
struct TimelineScenarioCard: View {
    let scenario: Scenario
    @ObservedObject var viewModel: SimulationViewModel
    let primaryColor: Color
    let onDetails: (Scenario) -> Void
    @State private var hover = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Header: Icon + Title
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(primaryColor.opacity(0.15)).frame(width: 44, height: 44)
                    Circle().stroke(primaryColor.opacity(0.4), lineWidth: 1).frame(width: 44, height: 44)
                    Image(systemName: scenario.iconName ?? (scenario.type == .optimistic ? "sun.max.fill" : "cloud.bolt.fill"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(primaryColor)
                        .shadow(color: primaryColor.opacity(0.6), radius: 5)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(scenario.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text("\(scenario.probability)% probability")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(primaryColor)
                }
                Spacer()
            }
            
            // Subtle Divider
            Rectangle()
                .fill(LinearGradient(colors: [primaryColor.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
            
            // Event Previews (Mini Timeline)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(scenario.events.prefix(3)) { event in
                    HStack(alignment: .top, spacing: 8) {
                        Circle().fill(primaryColor).frame(width: 6, height: 6).padding(.top, 5)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.title)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            Text(event.description)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            
            // Footer Action Buttons
            HStack(spacing: 10) {
                // Details Button
                Button(action: {
                    onDetails(scenario)
                }) {
                    HStack {
                        Image(systemName: "doc.plaintext.fill")
                        Text("Details")
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                }
                
                // Branch Expand Button
                Button(action: {
                    if scenario.children == nil {
                        Task { await viewModel.generateNextSteps(for: scenario.id) }
                    } else {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                            viewModel.toggleExpand(for: scenario.id)
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: scenario.children == nil ? "point.topleft.down.curvedto.point.bottomright.up" : (scenario.isExpanded == true ? "chevron.left" : "chevron.right"))
                        Text(scenario.children == nil ? "Branch" : (scenario.isExpanded == true ? "Collapse" : "Expand"))
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(LinearGradient(colors: [primaryColor.opacity(0.4), primaryColor.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(primaryColor.opacity(0.6), lineWidth: 1))
                }
            }
            .padding(.top, 4)
        }
        .padding(18)
        .frame(width: 300) // Fixed Card Width
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 24).fill(
                    LinearGradient(
                        colors: [Color(hex: "070B14").opacity(0.6), Color(hex: "1F0D05").opacity(scenario.type == .optimistic ? 0.0 : 0.4)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(primaryColor.opacity(hover ? 0.8 : 0.3), lineWidth: hover ? 1.5 : 1))
        .shadow(color: primaryColor.opacity(hover ? 0.2 : 0.05), radius: hover ? 20 : 10, y: 5)
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                hover = true
            }
        }
    }
}

// MARK: - Decision Timeline Node
struct DecisionTimelineNode: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let decision: Decision
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(themeSettings.currentTheme.primaryColor.opacity(pulse ? 0.3 : 0.15))
                    .frame(width: 56, height: 56)
                    .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.5), radius: pulse ? 15 : 5)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulse)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [Color(hex: "C9A84C"), Color(hex: "F7E98E")], startPoint: .top, endPoint: .bottom))
            }
            
            Text("Inception")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(themeSettings.currentTheme.primaryColor)
                .textCase(.uppercase)
                .tracking(2)
            
            Text(decision.text)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(24)
        .frame(width: 240)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 28).fill(Color.black.opacity(0.3))
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(themeSettings.currentTheme.primaryColor.opacity(0.6), lineWidth: 1.5))
        .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.2), radius: 20)
        .onAppear { pulse = true }
    }
}

// MARK: - Timeline Loading Block
struct TimelineLoadingBlock: View {
    let color: Color
    @State private var rotation: Double = 0
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().stroke(color.opacity(0.2), lineWidth: 3).frame(width: 32, height: 32)
                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(rotation))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
            }
            
            Text("Simulating Futures...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.4), lineWidth: 1))
        .onAppear { rotation = 360 }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
