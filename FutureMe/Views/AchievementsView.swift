//
//  AchievementsView.swift
//  FutureMe
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var achievementManager: AchievementManager
    @EnvironmentObject var themeSettings: ThemeSettings
    @Environment(\.dismiss) var dismiss
    
    // Split achievements
    private var unlockedAchievements: [Achievement] {
        achievementManager.achievements.filter { $0.isUnlocked }
    }
    
    private var lockedAchievements: [Achievement] {
        achievementManager.achievements.filter { !$0.isUnlocked }
    }
    
    var body: some View {
        ZStack {
            // Cosmic Background
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle top glow
            RadialGradient(
                colors: [themeSettings.currentTheme.primaryColor.opacity(0.12), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Custom Navigation Bar
                HStack(spacing: 20) {
                    NavBackButton(action: { dismiss() })
                    
                    Text("Achievements")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Total count badge
                    Text("\(unlockedAchievements.count)/\(achievementManager.achievements.count)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(themeSettings.currentTheme.primaryColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(themeSettings.currentTheme.primaryColor.opacity(0.15))
                                Capsule()
                                    .stroke(themeSettings.currentTheme.primaryColor.opacity(0.3), lineWidth: 1)
                            }
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // MARK: - Unlocked Section
                        if !unlockedAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("UNLOCKED")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.4))
                                    .tracking(1.4)
                                    .padding(.horizontal, 20)
                                
                                VaporwaveGrid(achievements: unlockedAchievements, isLocked: false)
                            }
                        }
                        
                        // MARK: - Locked Section
                        if !lockedAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("LOCKED")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.4))
                                    .tracking(1.4)
                                    .padding(.horizontal, 20)
                                
                                VaporwaveGrid(achievements: lockedAchievements, isLocked: true)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Vaporwave Grid Helper
private struct VaporwaveGrid: View {
    let achievements: [Achievement]
    let isLocked: Bool
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(achievements) { achievement in
                AchievementCard(achievement: achievement, isLocked: isLocked)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Achievement Card
private struct AchievementCard: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let achievement: Achievement
    let isLocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            
            // Icon Area
            ZStack {
                Circle()
                    .fill(isLocked ? Color.white.opacity(0.05) : themeSettings.currentTheme.primaryColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                if !isLocked {
                    Circle()
                        .stroke(themeSettings.currentTheme.primaryColor.opacity(0.4), lineWidth: 1)
                        .frame(width: 50, height: 50)
                }
                
                Image(systemName: isLocked ? "lock.fill" : achievement.iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isLocked ? .white.opacity(0.3) : themeSettings.currentTheme.primaryColor)
                    .shadow(color: isLocked ? .clear : themeSettings.currentTheme.primaryColor.opacity(0.6), radius: 6)
            }
            .padding(.top, 16)
            
            // Text Area
            VStack(spacing: 6) {
                Text(achievement.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isLocked ? .white.opacity(0.4) : .white)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(isLocked ? .white.opacity(0.25) : .white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(height: 40, alignment: .top)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                if !isLocked {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [themeSettings.currentTheme.primaryColor.opacity(0.05), .clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [themeSettings.currentTheme.primaryColor.opacity(0.3), .clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "0x0A0D14").opacity(0.4))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
            }
        )
        // Only unlocked items get the outer shadow drop
        .shadow(color: isLocked ? .clear : themeSettings.currentTheme.primaryColor.opacity(0.1), radius: 10, y: 5)
    }
}
