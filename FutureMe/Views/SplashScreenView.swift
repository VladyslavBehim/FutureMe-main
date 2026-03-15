//
//  SplashScreenView.swift
//  FutureMe
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isActive: Bool
    @EnvironmentObject var themeSettings: ThemeSettings
    
    @State private var timelineProgress: CGFloat = 0.0
    @State private var branchesProgress: CGFloat = 0.0
    @State private var textScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0.0
    @State private var textGlow: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            // Cosmic Background
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Central subtle glow
            RadialGradient(
                colors: [themeSettings.currentTheme.primaryColor.opacity(0.15), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                
                Spacer()
                
                // The Timeline Graphic
                ZStack {
                    // Central Timeline
                    Path { path in
                        path.move(to: CGPoint(x: 100, y: 0))
                        path.addLine(to: CGPoint(x: 100, y: 160))
                    }
                    .trim(from: 0, to: timelineProgress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")],
                            startPoint: .top, endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .shadow(color: Color(hex: "C4A6F0").opacity(0.8), radius: 8)
                    
                    // Left Branch 1
                    BranchPath(start: CGPoint(x: 100, y: 30), isLeft: true)
                        .trim(from: 0, to: branchesProgress)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "7EC8E3"), Color(hex: "00F0FF")],
                                startPoint: .top, endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .shadow(color: Color(hex: "00F0FF").opacity(0.6), radius: 6)
                    
                    // Right Branch 1
                    BranchPath(start: CGPoint(x: 100, y: 70), isLeft: false)
                        .trim(from: 0, to: branchesProgress)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "C4A6F0"), themeSettings.currentTheme.primaryColor],
                                startPoint: .top, endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .shadow(color: themeSettings.currentTheme.primaryColor.opacity(0.6), radius: 6)
                    
                    // Left Branch 2
                    BranchPath(start: CGPoint(x: 100, y: 110), isLeft: true)
                        .trim(from: 0, to: branchesProgress)
                        .stroke(
                            LinearGradient(
                                colors: [themeSettings.currentTheme.primaryColor, Color(hex: "C4A6F0")],
                                startPoint: .top, endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .shadow(color: Color(hex: "C4A6F0").opacity(0.6), radius: 6)
                    
                    // Nodes
                    if branchesProgress > 0.1 {
                        NodeView(color: Color(hex: "7EC8E3"))
                            .position(x: 60, y: 70)
                            .opacity(Double(branchesProgress))
                        
                        NodeView(color: themeSettings.currentTheme.primaryColor)
                            .position(x: 140, y: 110)
                            .opacity(Double(branchesProgress))
                            
                        NodeView(color: Color(hex: "C4A6F0"))
                            .position(x: 60, y: 150)
                            .opacity(Double(branchesProgress))
                    }
                }
                .frame(width: 200, height: 160)
                
                // Typography Title
                VStack(spacing: 8) {
                    Text("Future")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Explorer")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "C4A6F0"), Color(hex: "7EC8E3")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                }
                .shadow(color: Color(hex: "7EC8E3").opacity(textGlow), radius: 15, x: 0, y: 0)
                .opacity(textOpacity)
                .scaleEffect(textScale)
                
                Spacer()
                
                Text("Simulate a thousand lives.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .opacity(textOpacity)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Animate Graphic Line
            withAnimation(.easeInOut(duration: 0.9)) {
                self.timelineProgress = 1.0
            }
            // Animate Branches
            withAnimation(.easeOut(duration: 1.1).delay(0.5)) {
                self.branchesProgress = 1.0
            }
            
            // Animate Text Scale & Fade
            withAnimation(.easeIn(duration: 1.0).delay(0.2)) {
                self.textScale = 1.0
                self.textOpacity = 1.0
            }
            // Text glow pulse
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.2)) {
                self.textGlow = 0.6
            }
            
            // End Splash Screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.6)) {
                    self.isActive = false
                }
            }
        }
    }
}

// MARK: - Branch Curve Path
private struct BranchPath: Shape {
    let start: CGPoint
    let isLeft: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        let endX = isLeft ? start.x - 40 : start.x + 40
        let endY = start.y + 40
        
        let control1 = CGPoint(x: start.x + (isLeft ? -15 : 15), y: start.y + 10)
        let control2 = CGPoint(x: endX + (isLeft ? 5 : -5), y: endY - 20)
        
        path.addCurve(to: CGPoint(x: endX, y: endY), control1: control1, control2: control2)
        return path
    }
}

// MARK: - Glowing Node View
private struct NodeView: View {
    let color: Color
    @State private var pulse = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .shadow(color: color.opacity(0.8), radius: 6)
            .overlay(
                Circle()
                    .stroke(color.opacity(0.6), lineWidth: 2)
                    .scaleEffect(pulse ? 2.5 : 1)
                    .opacity(pulse ? 0 : 1)
            )
            .onAppear {
                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    pulse = true
                }
            }
    }
}
