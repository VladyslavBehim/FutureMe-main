import SwiftUI

struct GoalInputView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var achievementManager: AchievementManager
    @StateObject private var viewModel = GoalViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var backgroundPulse = false
    @State private var headerAppear = false
    @State private var contentAppear = false
    @Environment(\.dismiss) private var dismiss

    private let maxChars = 300
    private var charCount: Int { viewModel.goalText.count }
    private var charFraction: CGFloat { CGFloat(charCount) / CGFloat(maxChars) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // MARK: Back Button
                NavBackButton { dismiss() }
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // MARK: Header
                VStack(alignment: .leading, spacing: 10) {
                    Text("What's your")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    + Text("\nultimate goal?")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [themeSettings.currentTheme.primaryColor, Color(hex: "C4A6F0")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Let AI reverse-engineer the path from success to today.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.55))
                        .lineSpacing(4)
                }
                .padding(.top, 20)
                .opacity(headerAppear ? 1 : 0)
                .offset(y: headerAppear ? 0 : -24)
                .animation(.spring(response: 0.7, dampingFraction: 0.75), value: headerAppear)

                Spacer().frame(height: 32)

                // MARK: Text Editor Card
                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                       
                        TextField(("e.g. Become a senior developer and move to Japan."), text: Binding(
                            get: { viewModel.goalText },
                            set: { viewModel.goalText = String($0.prefix(maxChars)) }
                        ))
                        .focused($isInputFocused)
                        .padding(14)
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.white)
                        .font(.system(size: 15, design: .rounded))

                        
                    }

                    // Bottom char counter row
                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 2)
                                    .frame(width: 22, height: 22)
                                Circle()
                                    .trim(from: 0, to: charFraction)
                                    .stroke(
                                        charFraction > 0.9 ? Color(hex: "FF6B35") : themeSettings.currentTheme.primaryColor,
                                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                    )
                                    .frame(width: 22, height: 22)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 0.2), value: charCount)
                            }
                            Text("\(maxChars - charCount)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(charFraction > 0.9 ? Color(hex: "FF6B35") : Color.white.opacity(0.35))
                                .animation(.easeInOut, value: charCount)
                        }
                        .padding(.trailing, 14)
                        .padding(.bottom, 12)
                    }
                }
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "0D1A2E").opacity(0.6), Color(hex: "1A1035").opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            isInputFocused
                                ? LinearGradient(colors: [themeSettings.currentTheme.primaryColor.opacity(0.8), Color(hex: "7B5EA7").opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                        .animation(.easeInOut(duration: 0.3), value: isInputFocused)
                )
                .shadow(color: isInputFocused ? themeSettings.currentTheme.primaryColor.opacity(0.3) : .clear, radius: 20, y: 6)
                .animation(.easeInOut(duration: 0.3), value: isInputFocused)
                .opacity(contentAppear ? 1 : 0)
                .scaleEffect(contentAppear ? 1 : 0.95)
                .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.12), value: contentAppear)

                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.top, 16)
                }

                Spacer()

                // MARK: CTA Button
                Button {
                    Task {
                        await viewModel.generatePlan()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Reverse Engineer Goal")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                            Image(systemName: "arrow.triangle.pull")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(
                                    viewModel.goalText.isEmpty || viewModel.isLoading
                                        ? LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(colors: [themeSettings.currentTheme.primaryColor, Color(hex: "7B5EA7")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(
                                    viewModel.goalText.isEmpty || viewModel.isLoading
                                        ? Color.white.opacity(0.08)
                                        : Color.white.opacity(0.25),
                                    lineWidth: 1
                                )
                        }
                    )
                    .shadow(
                        color: viewModel.goalText.isEmpty || viewModel.isLoading ? .clear : themeSettings.currentTheme.primaryColor.opacity(0.55),
                        radius: 24, y: 10
                    )
                    .scaleEffect(viewModel.goalText.isEmpty || viewModel.isLoading ? 0.98 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.goalText.isEmpty || viewModel.isLoading)
                }
                .disabled(viewModel.goalText.isEmpty || viewModel.isLoading)
                .opacity(contentAppear ? 1 : 0)
                .offset(y: contentAppear ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.22), value: contentAppear)
                .padding(.bottom, 10) // Space for custom tab bar
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $viewModel.isExploring) {
            if let plan = viewModel.goalPlan {
                GoalPlanView(plan: plan)
            } else {
                EmptyView()
            }
        }
        .onAppear {
            achievementManager.unlock(Achievement.goalSetter)
            isInputFocused = true
            backgroundPulse = true
            withAnimation { headerAppear = true }
            withAnimation { contentAppear = true }
        }
    }
}
