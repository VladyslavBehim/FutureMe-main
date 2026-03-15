import Foundation

struct Question: Identifiable, Codable {
    let id: UUID
    let text: String
    var answer: String?
}
