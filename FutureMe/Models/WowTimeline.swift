import Foundation

struct WowTimeline: Identifiable, Codable {
    var id: UUID = UUID()
    let action: String
    let steps: [WowNode]
}

struct WowNode: Identifiable, Codable {
    var id: UUID = UUID()
    let timeframe: String
    let description: String
    let isFinal: Bool
}
