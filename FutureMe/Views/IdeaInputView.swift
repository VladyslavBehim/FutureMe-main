import SwiftUI

struct IdeaInputView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @StateObject private var viewModel = DecisionViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var headerAppear = false
    @State private var contentAppear = false
    @State private var shimmerPhase: CGFloat = 0.0
    @Environment(\.dismiss) private var dismiss

    private let maxChars = 300
    private var charCount: Int { viewModel.decisionText.count }
    private var charFraction: CGFloat { CGFloat(charCount) / CGFloat(maxChars) }

    var body: some View {
        ZStack {
            // Static Cosmic Background
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // MARK: Back Button
                NavBackButton { dismiss() }
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // MARK: Header
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        Text("What's on")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        + Text("\nyour mind?")
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

                    Text("Enter a life decision and let AI explore all possible futures.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.6))
                        .lineSpacing(4)
                }
                .padding(.top, 24)
                .opacity(headerAppear ? 1 : 0)
                .offset(y: headerAppear ? 0 : -20)
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: headerAppear)

                Spacer().frame(height: 32)

                // MARK: Text Editor Card
                HStack{
                    VStack(spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            // Placeholder
                            
                            TextField("e.g. Should I move to another country?", text: Binding(
                                get: { viewModel.decisionText },
                                set: { viewModel.decisionText = String($0.prefix(maxChars)) }
                            ))
                            .focused($isInputFocused)
                            .padding(14)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(.white)
                            .font(.system(size: 15, design: .rounded))

                            
                        }
                    }
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 22)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "1A1035").opacity(0.6), Color(hex: "0D1A2E").opacity(0.5)],
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
                                    ? LinearGradient(colors: [themeSettings.currentTheme.primaryColor.opacity(0.8), Color(hex: "4A90D9").opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
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
//                    .padding(.trailing, 14)
//                    .padding(.bottom, 12)
                }
                

                // MARK: Simulation Mode Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Simulation Mode")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 4)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(SimulationMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        viewModel.selectedMode = mode
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Text(mode.rawValue)
                                            .font(.system(size: 14, weight: viewModel.selectedMode == mode ? .bold : .medium, design: .rounded))
                                        
                                        if viewModel.selectedMode == mode {
                                            Circle()
                                                .fill(Color(hex: "00F0FF"))
                                                .frame(width: 6, height: 6)
                                                .shadow(color: Color(hex: "00F0FF"), radius: 4)
                                        }
                                    }
                                    .foregroundColor(viewModel.selectedMode == mode ? .white : .white.opacity(0.5))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 12)
                                    .background(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(viewModel.selectedMode == mode ? Color.white.opacity(0.12) : Color.white.opacity(0.05))
                                            
                                            if viewModel.selectedMode == mode {
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(
                                                        LinearGradient(colors: [themeSettings.currentTheme.primaryColor.opacity(0.8), Color(hex: "4A90D9").opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                        lineWidth: 1.5
                                                    )
                                            } else {
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                            }
                                        }
                                    )
                                    .shadow(color: viewModel.selectedMode == mode ? themeSettings.currentTheme.primaryColor.opacity(0.4) : .clear, radius: 10, y: 4)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.bottom, 12)
                    }
                }
                .opacity(contentAppear ? 1 : 0)
                .offset(y: contentAppear ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.17), value: contentAppear)
                .padding(.top , 10)

                Spacer()

                // MARK: CTA Button
                Button {
                    viewModel.explore()
                } label: {
                    HStack(spacing: 10) {
                        Text("Explore the Future")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(
                                    viewModel.decisionText.isEmpty
                                        ? LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(colors: [themeSettings.currentTheme.primaryColor, Color(hex: "4A90D9")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            
                            // Shimmer/Shine Effect for active state
                            if !viewModel.decisionText.isEmpty {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: .clear, location: 0),
                                                .init(color: .white.opacity(0.3), location: 0.5),
                                                .init(color: .clear, location: 1)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .offset(x: shimmerPhase * 400 - 200)
                                    .mask(RoundedRectangle(cornerRadius: 22))
                                    .animation(.linear(duration: 2.5).repeatForever(autoreverses: false), value: shimmerPhase)
                            }
                            
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(
                                    viewModel.decisionText.isEmpty
                                        ? Color.white.opacity(0.08)
                                        : Color.white.opacity(0.3),
                                    lineWidth: 1
                                )
                        }
                    )
                    .shadow(
                        color: viewModel.decisionText.isEmpty ? .clear : Color(hex: "4A90D9").opacity(0.6),
                        radius: 20, y: 8
                    )
                    .scaleEffect(viewModel.decisionText.isEmpty ? 0.98 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.decisionText.isEmpty)
                }
                .disabled(viewModel.decisionText.isEmpty)
                .opacity(contentAppear ? 1 : 0)
                .offset(y: contentAppear ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.22), value: contentAppear)
                .onAppear {
                    shimmerPhase = 1.0
                }
                .padding(.bottom, 10) // Space for custom tab bar
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $viewModel.isExploring) {
            QuestionsView(decision: Decision(text: viewModel.decisionText, mode: viewModel.selectedMode, date: Date()))
        }
        .onAppear {
            isInputFocused = true
            withAnimation { headerAppear = true }
            withAnimation { contentAppear = true }
        }
    }
}
