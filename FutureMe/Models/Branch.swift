import Foundation

struct Branch: Identifiable, Codable {
    var id = UUID()
    let parentDecision: Decision
    var scenarios: [Scenario]
}
