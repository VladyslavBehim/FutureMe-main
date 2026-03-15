import Foundation
import Combine

@MainActor
class SimulationViewModel: ObservableObject {
    @Published var scenarios: [Scenario]?
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    let decision: Decision
    let questions: [Question]
    
    func generateSimulations() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await OpenAIService.shared.generateScenarios(decision: decision.text, mode: decision.mode, questions: questions)
            self.scenarios = fetched
            
            // Save to history
            branch = Branch(parentDecision: decision, scenarios: fetched)
            if let b = branch { HistoryManager.shared.addBranch(b) }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    func generateNextSteps(for parentId: UUID) async {
        updateScenario(id: parentId) { $0.isGeneratingChildren = true }
        
        guard let parent = findScenario(id: parentId) else { return }
        
        do {
            let newChildren = try await OpenAIService.shared.generateNextSteps(for: parent, decision: decision.text, mode: decision.mode)
            updateScenario(id: parentId) { 
                $0.isGeneratingChildren = false
                $0.children = ($0.children ?? []) + newChildren
                $0.isExpanded = true
            }
            saveCurrentStateToHistory()
        } catch {
            print("Error generating next steps: \(error)")
            updateScenario(id: parentId) { $0.isGeneratingChildren = false }
        }
    }
    
    func toggleExpand(for id: UUID) {
        updateScenario(id: id) { $0.isExpanded?.toggle() }
        saveCurrentStateToHistory()
    }
    
    var branch: Branch?
    
    init(decision: Decision, questions: [Question] = [], scenarios: [Scenario]? = nil) {
        self.decision = decision
        self.questions = questions
        self.scenarios = scenarios
        if let s = scenarios {
            self.branch = Branch(parentDecision: decision, scenarios: s)
        }
    }
    
    private func saveCurrentStateToHistory() {
        guard let scenarios = self.scenarios, var b = self.branch else { return }
        b.scenarios = scenarios
        self.branch = b
        HistoryManager.shared.updateBranch(b)
    }
    
    private func findScenario(id: UUID, in list: [Scenario]? = nil) -> Scenario? {
        let targets = list ?? scenarios ?? []
        for s in targets {
            if s.id == id { return s }
            if let children = s.children, let found = findScenario(id: id, in: children) {
                return found
            }
        }
        return nil
    }
    
    private func updateScenario(id: UUID, transform: (inout Scenario) -> Void) {
        guard var currentScenarios = self.scenarios else { return }
        if updateScenarioRecursive(id: id, in: &currentScenarios, transform: transform) {
            self.scenarios = currentScenarios
        }
    }
    
    private func updateScenarioRecursive(id: UUID, in list: inout [Scenario], transform: (inout Scenario) -> Void) -> Bool {
        for i in 0..<list.count {
            if list[i].id == id {
                transform(&list[i])
                return true
            }
            if var children = list[i].children {
                if updateScenarioRecursive(id: id, in: &children, transform: transform) {
                    list[i].children = children
                    return true
                }
            }
        }
        return false
    }
}
