import Foundation

struct FutureEvent: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
}
