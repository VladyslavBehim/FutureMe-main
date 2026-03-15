import Foundation

enum ScenarioType: String, Codable {
    case optimistic
    case challenging
}

struct Scenario: Identifiable, Codable {
    let id: UUID
    let title: String
    let probability: Int
    let description: String
    let type: ScenarioType
    let iconName: String?
    let events: [FutureEvent]
    var children: [Scenario]?
    var isGeneratingChildren: Bool? = false
    var isExpanded: Bool? = false
}
