import Foundation
import Combine

@MainActor
class GoalViewModel: ObservableObject {
    @Published var goalText: String = ""
    @Published var isLoading: Bool = false
    @Published var goalPlan: GoalPlan?
    @Published var error: String?
    @Published var isExploring: Bool = false
    
    func generatePlan() async {
        guard !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isLoading = true
        error = nil
        do {
            let plan = try await OpenAIService.shared.generateGoalPlan(for: goalText)
            self.goalPlan = plan
            self.isExploring = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
