import Foundation
import Combine

@MainActor
class DecisionViewModel: ObservableObject {
    @Published var decisionText: String = ""
    @Published var selectedMode: SimulationMode = .realistic
    @Published var isExploring: Bool = false
    
    func explore() {
        guard !decisionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isExploring = true
    }
}
