//
//  Achievement.swift
//  FutureMe
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    // Quick predefined achievements
    static let timeTraveler = "time_traveler"
    static let butterflyEffect = "butterfly_effect"
    static let goalSetter = "goal_setter"
    static let scholar = "scholar"
    static let visionary = "visionary"
    static let quizMaster = "quiz_master"
}
