//
//  FutureMeApp.swift
//  FutureMe
//
//  Created by Vladyslav Behim on 13.03.2026.
//

import SwiftUI

@main
struct FutureMeApp: App {
    @StateObject private var historyManager = HistoryManager.shared
    @StateObject private var storeManager = StoreManager()
    @StateObject private var themeSettings = ThemeSettings()
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView(isActive: $showSplash)
                        .preferredColorScheme(.dark)
                        .environmentObject(themeSettings)
                        .transition(.opacity)
                } else {
                    ContentView()
                        .preferredColorScheme(.dark)
                        .environmentObject(historyManager)
                        .environmentObject(storeManager)
                        .environmentObject(themeSettings)
                        .environmentObject(achievementManager)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: showSplash)
        }
    }
}
