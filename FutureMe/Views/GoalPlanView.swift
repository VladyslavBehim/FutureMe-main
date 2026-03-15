import SwiftUI

struct GoalPlanView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    let plan: GoalPlan
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    Spacer()
                    Text("Your Goal Path")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text(plan.goal)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.bottom, 16)

                        ForEach(Array(plan.steps.enumerated()), id: \.element.id) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                                // Timeline Line
                                VStack {
                                    Circle()
                                        .fill(themeSettings.currentTheme.primaryColor)
                                        .frame(width: 14, height: 14)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    if index < plan.steps.count - 1 {
                                        Rectangle()
                                            .fill(LinearGradient(colors: [themeSettings.currentTheme.primaryColor, Color(hex: "7B5EA7").opacity(0.3)], startPoint: .top, endPoint: .bottom))
                                            .frame(width: 2)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(step.timeframe)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "C4A6F0"))
                                    
                                    Text(step.title)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)

                                    Text(step.description)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(Color.white.opacity(0.7))
                                        .lineSpacing(4)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "1A1035").opacity(0.6))
                                )
                                .padding(.bottom, index < plan.steps.count - 1 ? 8 : 0)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
