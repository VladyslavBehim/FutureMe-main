import SwiftUI

// MARK: - Main QuestionsView

struct QuestionsView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @StateObject private var viewModel: QuestionsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var backgroundPulse = false
    @State private var currentIndex = 0
    @State private var showPredict = false
    @State private var answerText = ""
    @FocusState private var fieldFocused: Bool

    init(decision: Decision) {
        _viewModel = StateObject(wrappedValue: QuestionsViewModel(decision: decision))
    }

    private var totalQuestions: Int { viewModel.questions.count }
    private var currentQuestion: Question? {
        guard !viewModel.questions.isEmpty, currentIndex < viewModel.questions.count else { return nil }
        return viewModel.questions[currentIndex]
    }

    var body: some View {
        ZStack {
            // ── Background ──────────────────────────────────────
            LinearGradient(colors: themeSettings.currentTheme.backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            RadialGradient(
                colors: [Color(hex: "4A90D9").opacity(backgroundPulse ? 0.22 : 0.08), .clear],
                center: .init(x: 0.8, y: 0.1),
                startRadius: 10, endRadius: 380
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: backgroundPulse)

            RadialGradient(
                colors: [themeSettings.currentTheme.primaryColor.opacity(backgroundPulse ? 0.18 : 0.06), .clear],
                center: .init(x: 0.15, y: 0.85),
                startRadius: 10, endRadius: 260
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true).delay(1.5), value: backgroundPulse)

            // ── States ──────────────────────────────────────────
            if viewModel.isLoading {
                QuestionsLoadingView()
            } else if let error = viewModel.error {
                ErrorStateView(message: error) {
                    Task { await viewModel.loadQuestions() }
                }
            } else {
                cardFlowContent
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .fullScreenCover(isPresented: $viewModel.isSimulating) {
            SimulationLoadingView(decision: viewModel.decision, questions: viewModel.questions)
        }
        .task {
            backgroundPulse = true
            if viewModel.questions.isEmpty {
                await viewModel.loadQuestions()
            }
            // Init first card
            if !viewModel.questions.isEmpty {
                answerText = viewModel.questions[0].answer ?? ""
                fieldFocused = true
            }
        }
        .onChange(of: viewModel.questions.isEmpty) { isEmpty in
            if !isEmpty {
                answerText = viewModel.questions[0].answer ?? ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { fieldFocused = true }
            }
        }
    }

    // MARK: - Card Flow Content

    private var cardFlowContent: some View {
        VStack(spacing: 0) {

            // ── Top bar ──────────────────────────────────────────
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                .frame(width: 38, height: 38)
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    Spacer()
                }

                // Progress dots
                if !viewModel.questions.isEmpty {
                    HStack(spacing: 7) {
                        ForEach(0..<totalQuestions, id: \.self) { i in
                            Capsule()
                                .fill(i <= currentIndex
                                      ? themeSettings.currentTheme.primaryColor
                                      : Color.white.opacity(0.15))
                                .frame(width: i == currentIndex ? 22 : 8, height: 8)
                                .shadow(color: i == currentIndex ? themeSettings.currentTheme.primaryColor.opacity(0.7) : .clear, radius: 6)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentIndex)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 20)

            // ── Counter label ────────────────────────────────────
            if !showPredict && !viewModel.questions.isEmpty {
                HStack {
                    Text("Question \(min(currentIndex + 1, totalQuestions)) of \(totalQuestions)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                        .tracking(0.5)
                        .textCase(.uppercase)
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 10)
            }

            // ── Main area ────────────────────────────────────────
            if showPredict {
                ScrollView(showsIndicators: false) {
                    PredictReadyView(onSimulate: { viewModel.simulate() })
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 60)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.88)),
                    removal: .opacity
                ))
            } else if let question = currentQuestion {
                // One card at a time — .id() + .transition() handles slide animation cleanly
                ScrollView(showsIndicators: false) {
                    QuestionSlideCard(
                        question: question,
                        index: currentIndex,
                        total: totalQuestions,
                        answer: $answerText,
                        focused: $fieldFocused,
                        primaryColor: themeSettings.currentTheme.primaryColor,
                        onNext: submitAndAdvance
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 60)
                }
                .scrollDismissesKeyboard(.interactively)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(currentIndex)
            }
        }
    }

    // MARK: - Advance Logic

    private func submitAndAdvance() {
        guard currentIndex < viewModel.questions.count else { return }
        let trimmed = answerText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Save answer
        viewModel.questions[currentIndex].answer = trimmed
        viewModel.checkAnswers()
        fieldFocused = false

        let isLast = currentIndex >= totalQuestions - 1

        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
            if isLast {
                showPredict = true
            } else {
                currentIndex += 1
                answerText = viewModel.questions[currentIndex].answer ?? ""
            }
        }

        if !isLast {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                fieldFocused = true
            }
        }
    }
}

// MARK: - Question Slide Card

private struct QuestionSlideCard: View {
    let question: Question
    let index: Int
    let total: Int
    @Binding var answer: String
    var focused: FocusState<Bool>.Binding
    let primaryColor: Color
    let onNext: () -> Void

    private var hasAnswer: Bool { !answer.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Question text
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    // Number badge
                    ZStack {
                        Circle()
                            .fill(primaryColor.opacity(0.18))
                            .frame(width: 36, height: 36)
                        Circle()
                            .stroke(primaryColor.opacity(0.4), lineWidth: 1)
                            .frame(width: 36, height: 36)
                        Text("\(index + 1)")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(primaryColor)
                    }
                    .shadow(color: primaryColor.opacity(0.5), radius: 8)

                    Spacer()

                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(primaryColor.opacity(0.5))
                }

                Text(question.text)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Divider
            Rectangle()
                .fill(LinearGradient(colors: [primaryColor.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)

            // Answer field
            VStack(alignment: .leading, spacing: 8) {
                TextField("Your answer…", text: $answer)
                    .focused(focused)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white)
                    .tint(primaryColor)
                    .submitLabel(.done)
                    .onSubmit { if hasAnswer { onNext() } }

                if focused.wrappedValue {
                    Text("Be specific — better context = better predictions")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(primaryColor.opacity(0.55))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: focused.wrappedValue)

            // Next / Submit button
            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text(hasAnswer ? "Next →" : "Type your answer first")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(hasAnswer ? .white : .white.opacity(0.3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(hasAnswer
                                  ? LinearGradient(colors: [primaryColor, Color(hex: "4A90D9")], startPoint: .leading, endPoint: .trailing)
                                  : LinearGradient(colors: [Color.white.opacity(0.05), Color.white.opacity(0.03)], startPoint: .leading, endPoint: .trailing))
                            .animation(.easeInOut(duration: 0.35), value: hasAnswer)
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(hasAnswer ? Color.white.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
                    }
                )
                .shadow(color: hasAnswer ? primaryColor.opacity(0.45) : .clear, radius: 18, y: 6)
            }
            .disabled(!hasAnswer)
        }
        .padding(26)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient(
                        colors: [Color(hex: "1A1035").opacity(0.7), Color(hex: "0D1A2E").opacity(0.6)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(colors: [primaryColor.opacity(0.4), Color(hex: "4A90D9").opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.2
                    )
            }
        )
        .shadow(color: primaryColor.opacity(0.15), radius: 24, y: 8)
    }
}

// MARK: - Predict Ready View

private struct PredictReadyView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let onSimulate: () -> Void
    @State private var glowPulse = false
    @State private var pressed = false

    var body: some View {
        VStack(spacing: 32) {

            // Success state icon
            ZStack {
                Circle()
                    .fill(themeSettings.currentTheme.primaryColor.opacity(0.12))
                    .frame(width: 110, height: 110)
                    .scaleEffect(glowPulse ? 1.15 : 0.9)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glowPulse)

                Circle()
                    .stroke(themeSettings.currentTheme.primaryColor.opacity(0.35), lineWidth: 1.5)
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(LinearGradient(
                        colors: [Color(hex: "00D4A8"), themeSettings.currentTheme.primaryColor],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .shadow(color: Color(hex: "00D4A8").opacity(0.6), radius: 16)
            }

            VStack(spacing: 10) {
                Text("All set!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("AI has everything it needs to\nmap your possible futures.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // Predict Future CTA
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { pressed = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation { pressed = false }
                    onSimulate()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 18, weight: .semibold))
                        .symbolEffect(.bounce, value: glowPulse)
                    Text("Predict Future")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(
                    ZStack {
                        // Glow halo
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(
                                colors: [themeSettings.currentTheme.primaryColor.opacity(glowPulse ? 0.55 : 0.3), Color(hex: "4A90D9").opacity(glowPulse ? 0.45 : 0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .blur(radius: 20)
                            .offset(y: 5)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowPulse)

                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(
                                colors: [themeSettings.currentTheme.primaryColor, Color(hex: "4A90D9")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    }
                )
                .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.5), radius: 24, y: 8)
                .scaleEffect(pressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.28, dampingFraction: 0.65), value: pressed)
            }
            .padding(.horizontal, 24)
        }
        .onAppear { glowPulse = true }
    }
}

// MARK: - Fraction Badge

struct FractionBadge: View {
    let answered: Int
    let total: Int
    var isComplete: Bool { answered == total && total > 0 }

    var body: some View {
        HStack(spacing: 5) {
            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "00D4A8"))
                    .transition(.scale.combined(with: .opacity))
            }
            Text(isComplete ? "Ready!" : "\(answered)/\(total)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(isComplete ? Color(hex: "00D4A8") : Color.white.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(isComplete ? Color(hex: "00D4A8").opacity(0.15) : Color.white.opacity(0.07))
                .overlay(
                    Capsule().stroke(
                        isComplete ? Color(hex: "00D4A8").opacity(0.4) : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
                )
        )
        .shadow(color: isComplete ? Color(hex: "00D4A8").opacity(0.3) : .clear, radius: 8, y: 3)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isComplete)
    }
}

// MARK: - Answer Progress Bar

struct AnswerProgressBar: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let answered: Int
    let total: Int
    @State private var animated = false

    var progress: CGFloat { total > 0 ? CGFloat(answered) / CGFloat(total) : 0 }
    var isComplete: Bool { answered == total && total > 0 }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.07))
                    .frame(height: 5)
                Capsule()
                    .fill(LinearGradient(
                        colors: isComplete
                            ? [Color(hex: "00D4A8"), Color(hex: "4A90D9")]
                            : [themeSettings.currentTheme.primaryColor, Color(hex: "4A90D9")],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(width: animated ? max(geo.size.width * progress, progress > 0 ? 16 : 0) : 0, height: 5)
                    .shadow(color: (isComplete ? Color(hex: "00D4A8") : Color(hex: "4A90D9")).opacity(0.6), radius: 6)
                    .animation(.spring(response: 0.55, dampingFraction: 0.75), value: progress)
            }
        }
        .frame(height: 5)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.25)) { animated = true }
        }
    }
}

// MARK: - Inline Simulate Button (inside ScrollView)

struct InlineSimulateButton: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let allAnswered: Bool
    let answeredCount: Int
    let total: Int
    let onSimulate: () -> Void

    @State private var glowPulse = false
    @State private var pressed = false

    var remainingCount: Int { total - answeredCount }

    var body: some View {
        VStack(spacing: 10) {
            if !allAnswered && total > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 12))
                    Text("\(remainingCount) more question\(remainingCount == 1 ? "" : "s") to go")
                        .font(.system(size: 13, design: .rounded))
                }
                .foregroundColor(Color.white.opacity(0.3))
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Button(action: {
                guard allAnswered else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { pressed = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation { pressed = false }
                    onSimulate()
                }
            }) {
                HStack(spacing: 10) {
                    Text("Simulate Future")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 16, weight: .semibold))
                        .symbolEffect(.bounce, value: allAnswered)
                }
                .foregroundColor(allAnswered ? .white : Color.white.opacity(0.3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    ZStack {
                        if allAnswered {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(LinearGradient(
                                    colors: [themeSettings.currentTheme.primaryColor.opacity(glowPulse ? 0.55 : 0.35), Color(hex: "4A90D9").opacity(glowPulse ? 0.45 : 0.25)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .blur(radius: 18)
                                .offset(y: 4)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowPulse)
                        }
                        RoundedRectangle(cornerRadius: 22)
                            .fill(allAnswered
                                  ? LinearGradient(colors: [themeSettings.currentTheme.primaryColor, Color(hex: "4A90D9")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                  : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .animation(.easeInOut(duration: 0.4), value: allAnswered)
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(allAnswered ? Color.white.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
                    }
                )
                .shadow(color: allAnswered ? themeSettings.currentTheme.primaryColor.opacity(0.4) : .clear, radius: 20, y: 6)
                .scaleEffect(pressed ? 0.96 : 1.0)
                .animation(.spring(response: 0.28, dampingFraction: 0.65), value: pressed)
            }
            .disabled(!allAnswered)
        }
        .animation(.easeInOut(duration: 0.35), value: allAnswered)
        .onAppear { glowPulse = true }
    }
}

// MARK: - Bottom Simulate Bar

struct BottomSimulateBar: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let allAnswered: Bool
    let answeredCount: Int
    let total: Int
    let onSimulate: () -> Void

    @State private var glowPulse = false
    @State private var pressed = false

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color(hex: "070B14").opacity(0), Color(hex: "070B14")],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 36)

            VStack(spacing: 10) {
                if !allAnswered && total > 0 {
                    Text("\(total - answeredCount) more question\(total - answeredCount == 1 ? "" : "s") to go")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.3))
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Button(action: {
                    guard allAnswered else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { pressed = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation { pressed = false }
                        onSimulate()
                    }
                }) {
                    HStack(spacing: 10) {
                        Text("Simulate Future")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 16, weight: .semibold))
                            .symbolEffect(.bounce, value: allAnswered)
                    }
                    .foregroundColor(allAnswered ? .white : Color.white.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            if allAnswered {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(LinearGradient(
                                        colors: [themeSettings.currentTheme.primaryColor.opacity(glowPulse ? 0.5 : 0.3), Color(hex: "4A90D9").opacity(glowPulse ? 0.4 : 0.2)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ))
                                    .blur(radius: 18)
                                    .offset(y: 4)
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowPulse)
                            }
                            RoundedRectangle(cornerRadius: 22)
                                .fill(allAnswered
                                      ? LinearGradient(colors: [themeSettings.currentTheme.primaryColor, Color(hex: "4A90D9")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                      : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .animation(.easeInOut(duration: 0.4), value: allAnswered)
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(allAnswered ? Color.white.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
                        }
                    )
                    .scaleEffect(pressed ? 0.96 : 1.0)
                    .animation(.spring(response: 0.28, dampingFraction: 0.65), value: pressed)
                }
                .disabled(!allAnswered)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 44)
            .background(themeSettings.currentTheme.backgroundColors.first ?? Color(hex: "070B14"))
        }
        .onAppear { glowPulse = true }
        .animation(.easeInOut(duration: 0.35), value: allAnswered)
    }
}

// MARK: - Questions Loading View

struct QuestionsLoadingView: View {
    @State private var phraseIndex = 0
    @State private var phraseVisible = true

    private let phrases = [
        "AI is crafting questions…",
        "Analyzing your decision…",
        "Personalizing the survey…",
    ]

    var body: some View {
        VStack(spacing: 32) {
            CosmicMiniLoader()

            VStack(spacing: 8) {
                Text(phrases[phraseIndex])
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(phraseVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.35), value: phraseVisible)

                Text("Tailored to your specific decision")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.4))
            }
        }
        .onAppear { startCycling() }
    }

    private func startCycling() {
        Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { _ in
            withAnimation { phraseVisible = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                phraseIndex = (phraseIndex + 1) % phrases.count
                withAnimation { phraseVisible = true }
            }
        }
    }
}

// MARK: - Cosmic Mini Loader

struct CosmicMiniLoader: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @State private var rotation1: Double = 0
    @State private var rotation2: Double = 0
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    LinearGradient(colors: [themeSettings.currentTheme.primaryColor, themeSettings.currentTheme.primaryColor.opacity(0)], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 70, height: 70)
                .rotationEffect(.degrees(rotation1))
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: rotation1)

            Circle()
                .trim(from: 0.1, to: 0.85)
                .stroke(
                    LinearGradient(colors: [Color(hex: "4A90D9"), Color(hex: "4A90D9").opacity(0)], startPoint: .bottom, endPoint: .top),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(rotation2))
                .animation(.linear(duration: 2.2).repeatForever(autoreverses: false), value: rotation2)

            Image(systemName: "sparkles")
                .font(.system(size: 18))
                .foregroundStyle(LinearGradient(colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .scaleEffect(pulse ? 1.15 : 0.9)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
        }
        .onAppear {
            rotation1 = 360
            rotation2 = -360
            pulse = true
        }
    }
}

// MARK: - Error State View

struct ErrorStateView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let message: String
    let onRetry: () -> Void
    @State private var appear = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: "FF6B35").opacity(0.12))
                    .frame(width: 88, height: 88)
                    .blur(radius: 8)
                Circle()
                    .fill(Color(hex: "FF6B35").opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(LinearGradient(colors: [Color(hex: "FF6B35"), Color(hex: "F7C948")], startPoint: .top, endPoint: .bottom))
            }

            VStack(spacing: 6) {
                Text("Something went wrong")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(message)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .lineSpacing(3)
            }

            Button(action: onRetry) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 13)
                .background(
                    Capsule()
                        .fill(themeSettings.currentTheme.primaryColor.opacity(0.45))
                        .overlay(Capsule().stroke(themeSettings.currentTheme.primaryColor.opacity(0.6), lineWidth: 1))
                )
                .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.35), radius: 14, y: 5)
            }
        }
        .opacity(appear ? 1 : 0)
        .scaleEffect(appear ? 1 : 0.88)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.72)) { appear = true }
        }
    }
}

// MARK: - Question Card (legacy — kept for any external references)

struct QuestionCard: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @State var question: Question
    let index: Int
    let total: Int
    let appear: Bool
    let viewModel: QuestionsViewModel
    @FocusState private var isFocused: Bool

    private var hasAnswer: Bool {
        !(question.answer ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var answerBinding: Binding<String> {
        Binding<String>(
            get: { question.answer ?? "" },
            set: { newValue in
                question.answer = newValue
                if let idx = viewModel.questions.firstIndex(where: { $0.id == question.id }) {
                    viewModel.questions[idx].answer = newValue
                }
                viewModel.checkAnswers()
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(hasAnswer ? Color(hex: "00D4A8").opacity(0.2) : Color.clear)
                        .frame(width: 40, height: 40)
                        .blur(radius: 6)
                        .animation(.easeInOut(duration: 0.4), value: hasAnswer)
                    Circle()
                        .fill(hasAnswer
                              ? LinearGradient(colors: [Color(hex: "4A90D9"), Color(hex: "00D4A8")], startPoint: .topLeading, endPoint: .bottomTrailing)
                              : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(Circle().stroke(hasAnswer ? Color(hex: "00D4A8").opacity(0.35) : Color.white.opacity(0.1), lineWidth: 1))
                        .frame(width: 34, height: 34)
                        .animation(.spring(response: 0.4, dampingFraction: 0.65), value: hasAnswer)
                    if hasAnswer {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(.white)
                            .transition(.scale(scale: 0.3).combined(with: .opacity))
                    } else {
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.45))
                            .transition(.opacity)
                    }
                }
                .animation(.spring(response: 0.38, dampingFraction: 0.65), value: hasAnswer)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Question \(index + 1) of \(total)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.3))
                        .textCase(.uppercase)
                        .tracking(0.8)
                    Text(question.text)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Rectangle()
                .fill(LinearGradient(
                    colors: isFocused
                        ? [Color(hex: "4A90D9").opacity(0.5), themeSettings.currentTheme.primaryColor.opacity(0.3), .clear]
                        : [Color.white.opacity(0.08), .clear],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(height: 1)
                .animation(.easeInOut(duration: 0.25), value: isFocused)

            VStack(alignment: .leading, spacing: 6) {
                TextField("Your answer…", text: answerBinding)
                    .focused($isFocused)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(hasAnswer ? .white : Color.white.opacity(0.6))
                    .tint(Color(hex: "4A90D9"))
                if isFocused {
                    Text("Be specific for better results")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color(hex: "4A90D9").opacity(0.6))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isFocused)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 22)
                    .fill(hasAnswer
                          ? LinearGradient(colors: [Color(hex: "0A1F30").opacity(0.8), Color(hex: "0A2018").opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [Color.white.opacity(0.04), Color.white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .animation(.easeInOut(duration: 0.45), value: hasAnswer)
                if isFocused {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(LinearGradient(colors: [Color(hex: "4A90D9").opacity(0.08), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .transition(.opacity)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    isFocused
                        ? LinearGradient(colors: [themeSettings.currentTheme.primaryColor.opacity(0.7), Color(hex: "4A90D9").opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : hasAnswer
                            ? LinearGradient(colors: [Color(hex: "4A90D9").opacity(0.35), Color(hex: "00D4A8").opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.09), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.3
                )
                .animation(.easeInOut(duration: 0.25), value: isFocused)
                .animation(.easeInOut(duration: 0.4), value: hasAnswer)
        )
        .shadow(
            color: isFocused ? Color(hex: "4A90D9").opacity(0.18) : hasAnswer ? Color(hex: "00D4A8").opacity(0.08) : .black.opacity(0.2),
            radius: isFocused ? 18 : 10, y: 4
        )
        .animation(.easeInOut(duration: 0.25), value: isFocused)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 32)
        .blur(radius: appear ? 0 : 2)
        .animation(.spring(response: 0.58, dampingFraction: 0.78).delay(Double(index) * 0.10), value: appear)
    }
}
