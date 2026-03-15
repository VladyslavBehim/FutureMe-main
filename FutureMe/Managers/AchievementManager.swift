//
//  AchievementManager.swift
//  FutureMe
//

import Foundation
import SwiftUI
import Combine

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var achievements: [Achievement] = []
    private let saveKey = "SavedAchievements"
    
    init() {
        loadAchievements()
    }
    
    private let defaultAchievements: [Achievement] = [
        Achievement(
            id: Achievement.timeTraveler,
            title: "Time Traveler",
            description: "Run your very first simulation and glimpse the future.",
            iconName: "wand.and.stars",
            isUnlocked: false
        ),
        Achievement(
            id: Achievement.visionary,
            title: "Visionary",
            description: "Run 10 simulations. You're starting to see the matrix.",
            iconName: "eye.fill",
            isUnlocked: false
        ),
        Achievement(
            id: Achievement.butterflyEffect,
            title: "Chaos Theory",
            description: "Use the Butterfly Effect to explore a hypothetical scenario.",
            iconName: "hurricane",
            isUnlocked: false
        ),
        Achievement(
            id: Achievement.goalSetter,
            title: "Architect of Fate",
            description: "Set your first goal and reverse-engineer your success.",
            iconName: "target",
            isUnlocked: false
        ),
        Achievement(
            id: Achievement.scholar,
            title: "Model Scholar",
            description: "Open the Mental Library to sharpen your mind.",
            iconName: "books.vertical.fill",
            isUnlocked: false
        ),
        Achievement(
            id: Achievement.quizMaster,
            title: "Quiz Master",
            description: "Complete your first mental model quiz.",
            iconName: "checkmark.seal.fill",
            isUnlocked: false
        )
    ]
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let saved = try? JSONDecoder().decode([Achievement].self, from: data) {
            
            // Merge saved state with defaults (in case we add new ones)
            var merged = defaultAchievements
            for i in 0..<merged.count {
                if let savedDoc = saved.first(where: { $0.id == merged[i].id }) {
                    merged[i].isUnlocked = savedDoc.isUnlocked
                    merged[i].unlockedDate = savedDoc.unlockedDate
                }
            }
            self.achievements = merged
            
        } else {
            self.achievements = defaultAchievements
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    func unlock(_ id: String) {
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        
        if !achievements[index].isUnlocked {
            achievements[index].isUnlocked = true
            achievements[index].unlockedDate = Date()
            saveAchievements()
            
            // Optional: trigger a notification or haptic feedback here
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    func checkSimulationCount(_ count: Int) {
        if count >= 1 {
            unlock(Achievement.timeTraveler)
        }
        if count >= 10 {
            unlock(Achievement.visionary)
        }
    }
}
