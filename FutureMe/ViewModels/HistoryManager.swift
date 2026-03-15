import Foundation
import Combine

@MainActor
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published var history: [Branch] = [] {
        didSet { saveToDisk() }
    }
    
    private let saveKey = "futureMeHistoryKey"
    
    private init() {
        loadFromDisk()
    }
    
    func addBranch(_ branch: Branch) {
        if let idx = history.firstIndex(where: { $0.parentDecision.id == branch.parentDecision.id }) {
            history[idx] = branch
        } else {
            history.insert(branch, at: 0)
        }
        
        // Check for simulation achievements
        AchievementManager.shared.checkSimulationCount(history.count)
    }
    
    func clearHistory() {
        history.removeAll()
    }
    
    func updateBranch(_ branch: Branch) {
        if let idx = history.firstIndex(where: { $0.id == branch.id }) {
            history[idx] = branch
        }
    }
    
    func deleteBranch(_ branch: Branch) {
        history.removeAll(where: { $0.id == branch.id })
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadFromDisk() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Branch].self, from: data) {
            self.history = decoded
        }
    }
}
