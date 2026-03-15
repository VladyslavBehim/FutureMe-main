import Foundation
import Combine

@MainActor
class QuestionsViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var allAnswered: Bool = false
    @Published var isSimulating: Bool = false
    
    let decision: Decision
    
    init(decision: Decision) {
        self.decision = decision
    }
    
    func loadQuestions() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await OpenAIService.shared.generateQuestions(for: decision.text)
            self.questions = fetched
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    func checkAnswers() {
        allAnswered = !questions.isEmpty && questions.allSatisfy { ($0.answer ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
    }
    
    func simulate() {
        guard allAnswered else { return }
        isSimulating = true
    }
}
