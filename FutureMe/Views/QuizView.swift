import SwiftUI

struct QuizView: View {
    let model: MentalModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var achievementManager: AchievementManager
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerIndex: Int? = nil
    @State private var showingExplanation = false
    @State private var score = 0
    @State private var quizCompleted = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "070B14"), model.gradientColors[0].opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("Question \(currentQuestionIndex + 1) of \(model.quiz.count)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                
                if quizCompleted {
                    // Completion View
                    VStack(spacing: 24) {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(model.gradientColors[0].opacity(0.2))
                                .frame(width: 120, height: 120)
                            Image(systemName: score == model.quiz.count ? "star.fill" : "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(colors: model.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .shadow(color: model.gradientColors[0].opacity(0.5), radius: 10)
                        }
                        
                        Text("Quiz Completed!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("You scored \(score) out of \(model.quiz.count)")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Finish")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(LinearGradient(colors: model.gradientColors, startPoint: .leading, endPoint: .trailing))
                                )
                                .padding(.horizontal, 40)
                                .padding(.top, 20)
                        }
                        Spacer()
                    }
                    .onAppear {
                        achievementManager.unlock(Achievement.quizMaster)
                    }
                } else {
                    // Question View
                    let currentQuestion = model.quiz[currentQuestionIndex]
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text(currentQuestion.question)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            
                            VStack(spacing: 16) {
                                ForEach(0..<currentQuestion.options.count, id: \.self) { index in
                                    AnswerCard(
                                        text: currentQuestion.options[index],
                                        isSelected: selectedAnswerIndex == index,
                                        isCorrect: index == currentQuestion.correctIndex,
                                        showResult: showingExplanation,
                                        action: {
                                            if !showingExplanation {
                                                selectedAnswerIndex = index
                                                showingExplanation = true
                                                if index == currentQuestion.correctIndex {
                                                    score += 1
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                            
                            if showingExplanation {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: selectedAnswerIndex == currentQuestion.correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(selectedAnswerIndex == currentQuestion.correctIndex ? .green : .red)
                                        Text(selectedAnswerIndex == currentQuestion.correctIndex ? "Correct!" : "Incorrect")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(selectedAnswerIndex == currentQuestion.correctIndex ? .green : .red)
                                    }
                                    
                                    Text(currentQuestion.explanation)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineSpacing(4)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                                .padding(.top, 10)
                                
                                Button {
                                    if currentQuestionIndex < model.quiz.count - 1 {
                                        currentQuestionIndex += 1
                                        selectedAnswerIndex = nil
                                        showingExplanation = false
                                    } else {
                                        withAnimation {
                                            quizCompleted = true
                                        }
                                    }
                                } label: {
                                    Text(currentQuestionIndex < model.quiz.count - 1 ? "Next Question" : "View Results")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(LinearGradient(colors: model.gradientColors, startPoint: .leading, endPoint: .trailing))
                                        )
                                }
                                .padding(.top, 20)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct AnswerCard: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let showResult: Bool
    let action: () -> Void
    
    var borderColor: Color {
        if !showResult {
            return isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.1)
        }
        if isCorrect {
            return Color.green.opacity(0.8)
        }
        if isSelected && !isCorrect {
            return Color.red.opacity(0.8)
        }
        return Color.white.opacity(0.1)
    }
    
    var backgroundColor: Color {
        if !showResult {
            return isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.05)
        }
        if isCorrect {
            return Color.green.opacity(0.15)
        }
        if isSelected && !isCorrect {
            return Color.red.opacity(0.15)
        }
        return Color.white.opacity(0.05)
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(showResult && isSelected && !isCorrect ? .white.opacity(0.7) : .white)
                    .multilineTextAlignment(.leading)
                Spacer()
                
                if showResult {
                    if isCorrect {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.system(size: 18, weight: .bold))
                    } else if isSelected {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .font(.system(size: 18, weight: .bold))
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(showResult)
    }
}
