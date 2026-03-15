import SwiftUI
import Foundation

struct ScenarioDetailView: View {
    let scenario: Scenario
    @State private var appearElements = false
    @State private var glowPulse = false

    var isOptimistic: Bool { scenario.type == .optimistic }
    var primaryColor: Color { isOptimistic ? Color(hex: "4A90D9") : Color(hex: "FF6B35") }
    var secondaryColor: Color { isOptimistic ? Color(hex: "00D4A8") : Color(hex: "F7C948") }

    var body: some View {
        ZStack {
            // Background
            Color(hex: "070B14").edgesIgnoringSafeArea(.all)

            RadialGradient(
                gradient: Gradient(colors: [primaryColor.opacity(0.18), .clear]),
                center: .init(x: 0.5, y: 0.1),
                startRadius: 20,
                endRadius: 380
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Header card
                    VStack(spacing: 16) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [primaryColor.opacity(0.4), primaryColor.opacity(0.05)],
                                        center: .center, startRadius: 0, endRadius: 40
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .blur(radius: glowPulse ? 6 : 10)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowPulse)

                            Image(systemName: isOptimistic ? "sun.max.fill" : "cloud.bolt.fill")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .shadow(color: primaryColor.opacity(0.8), radius: 12)
                        }

                        Text(scenario.title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        // Probability Arc
                        ProbabilityArcView(probability: scenario.probability, primaryColor: primaryColor, secondaryColor: secondaryColor)
                            .frame(height: 80)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .padding(.horizontal, 20)
                    .background(GlassCard())
                    .opacity(appearElements ? 1 : 0)
                    .scaleEffect(appearElements ? 1 : 0.88)
                    .animation(.spring(response: 0.7, dampingFraction: 0.7), value: appearElements)

                    // MARK: Description card
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Overview", systemImage: "text.alignleft")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(primaryColor)
                            .textCase(.uppercase)
                            .tracking(1)

                        Text(scenario.description)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.82))
                            .lineSpacing(6)
                    }
                    .padding(20)
                    .background(GlassCard())
                    .opacity(appearElements ? 1 : 0)
                    .offset(y: appearElements ? 0 : 20)
                    .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1), value: appearElements)

                    // MARK: Timeline
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Timeline", systemImage: "calendar.badge.clock")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(primaryColor)
                            .textCase(.uppercase)
                            .tracking(1)
                            .padding(.bottom, 4)

                        ForEach(Array(scenario.events.enumerated()), id: \.element.id) { index, event in
                            TimelineEventRow(
                                event: event,
                                index: index,
                                isLast: index == scenario.events.count - 1,
                                primaryColor: primaryColor,
                                secondaryColor: secondaryColor,
                                appear: appearElements
                            )
                        }
                    }
                    .padding(20)
                    .background(GlassCard())
                    .opacity(appearElements ? 1 : 0)
                    .offset(y: appearElements ? 0 : 30)
                    .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2), value: appearElements)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation { appearElements = true }
            glowPulse = true
        }
    }
}

// MARK: - Probability Arc View

struct ProbabilityArcView: View {
    let probability: Int
    let primaryColor: Color
    let secondaryColor: Color
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            // Track
            Arc(startAngle: .degrees(150), endAngle: .degrees(390))
                .stroke(Color.white.opacity(0.08), style: StrokeStyle(lineWidth: 6, lineCap: .round))

            // Fill
            Arc(startAngle: .degrees(150), endAngle: .degrees(150.0 + 240.0 * Double(progress)))
                .stroke(
                    LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .shadow(color: primaryColor.opacity(0.6), radius: 6)

            VStack(spacing: 2) {
                Text("\(probability)%")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .leading, endPoint: .trailing)
                    )

                Text("Probability")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.45))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                progress = CGFloat(probability) / 100
            }
        }
    }
}

struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        Path { p in
            p.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                     radius: min(rect.width, rect.height) / 2,
                     startAngle: startAngle,
                     endAngle: endAngle,
                     clockwise: false)
        }
    }
}

// MARK: - Timeline Event Row

struct TimelineEventRow: View {
    let event: FutureEvent
    let index: Int
    let isLast: Bool
    let primaryColor: Color
    let secondaryColor: Color
    let appear: Bool

    @State private var dotPulse = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Dot + line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(dotPulse ? 0.35 : 0.15))
                        .frame(width: 22, height: 22)
                        .blur(radius: 4)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(Double(index) * 0.3), value: dotPulse)

                    Circle()
                        .fill(
                            LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 11, height: 11)
                        .shadow(color: primaryColor.opacity(0.7), radius: 5)
                }
                .padding(.top, 4)

                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [primaryColor.opacity(0.4), primaryColor.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1.5)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 5) {
                Text(event.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text(event.description)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.6))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, isLast ? 0 : 20)
        }
        .opacity(appear ? 1 : 0)
        .offset(x: appear ? 0 : 18)
        .animation(.easeOut(duration: 0.55).delay(Double(index) * 0.12 + 0.35), value: appear)
        .onAppear { dotPulse = true }
    }
}

// MARK: - Glass Card Background

struct GlassCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.03))
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }
}
