import Foundation

struct GoalPlan: Identifiable, Codable {
    var id: UUID = UUID()
    let goal: String
    let steps: [GoalStep]
}

struct GoalStep: Identifiable, Codable {
    var id: UUID = UUID()
    let timeframe: String
    let title: String
    let description: String
}
