import Foundation
import Combine
import SwiftUI

@MainActor
class WowViewModel: ObservableObject {
    @Published var actionText: String = ""
    @Published var isSimulating: Bool = false
    @Published var timeline: WowTimeline?
    @Published var error: String?
    @Published var isRevealing: Bool = false
    
    // UI state for progressively showing nodes
    @Published var revealedNodes: [WowNode] = []
    @Published var showFinalClimax: Bool = false
    
    func simulate() async {
        guard !actionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSimulating = true
        error = nil
        revealedNodes = []
        showFinalClimax = false
        
        do {
            let result = try await OpenAIService.shared.generateButterflyTimeline(for: actionText)
            self.timeline = result
            self.isRevealing = true
            
            // Start the dramatic reveal
            await startProgressiveReveal(result.steps)
            
        } catch {
            self.error = error.localizedDescription
            self.isSimulating = false
        }
    }
    
    private func startProgressiveReveal(_ steps: [WowNode]) async {
        isSimulating = false // transition to reveal UI
        
        for step in steps {
            // Wait heavily for dramatic effect
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                revealedNodes.append(step)
                
                if step.isFinal {
                    // Trigger haptics and major UI state change
                    showFinalClimax = true
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.impactOccurred()
                } else {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
            }
        }
    }
}
