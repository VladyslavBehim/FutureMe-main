import Foundation

enum SimulationMode: String, CaseIterable, Codable {
    case realistic = "Realistic"
    case extreme = "Extreme"
    case sciFi = "Sci-Fi"
    case stoic = "Stoic"
    case butterflyEffect = "Butterfly Effect"
    case absurd = "Absurd Comedy"
    case fantasy = "Medieval Fantasy"
    case cyberpunk = "Cyberpunk"
}

struct Decision: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    var mode: SimulationMode = .realistic
    let date: Date
}
