import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var achievementManager: AchievementManager
    @State private var backgroundPulse = false
    @Environment(\.dismiss) private var dismiss
    @State private var selectedModel: MentalModel?
    let models = LibraryData.models
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: themeSettings.currentTheme.backgroundColors,
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Library")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Mental models and decision theory.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(models) { model in
                            Button {
                                selectedModel = model
                            } label: {
                                LibraryCardView(model: model)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100) // Space for TabBar
                }
            }
        }
        .fullScreenCover(item: $selectedModel) { model in
            ArticleDetailView(model: model)
        }
        .navigationBarHidden(true)
        .onAppear {
            achievementManager.unlock(Achievement.scholar)
            backgroundPulse = true
        }
    }
}

struct LibraryCardView: View {
    let model: MentalModel
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: model.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: model.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(model.subtitle)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.7))
                    .lineLimit(2)
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.white.opacity(0.3))
        }
        .padding(16)
        .frame(height: 120) // Give the card a fixed height for the image to fill nicely
        .background(
            ZStack {
                // Image Background
                GeometryReader { geo in
                    Image(model.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .cornerRadius(20)
                
                // Dimming overlay so text is readable
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "070B14").opacity(0.65))
                
                // Border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(LinearGradient(colors: [Color.white.opacity(0.25), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            }
        )
        .shadow(color: Color.black.opacity(0.3), radius: 12, y: 6)
    }
}
