import SwiftUI

struct ArticleDetailView: View {
    let model: MentalModel
    @Environment(\.dismiss) private var dismiss
    @State private var appear = false
    @State private var showQuiz = false

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "070B14").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Hero Image with Parallax
                    GeometryReader { geometry in
                        let minY = geometry.frame(in: .global).minY
                        let height = max(0, 350 + (minY > 0 ? minY : 0))
                        let offset = minY > 0 ? -minY : 0
                        
                        ZStack(alignment: .bottom) {
                            Image(model.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: height)
                                .clipped()
                                .overlay(
                                    LinearGradient(
                                        colors: [.clear, Color(hex: "070B14").opacity(0.6), Color(hex: "070B14")],
                                        startPoint: .center,
                                        endPoint: .bottom
                                    )
                                )
                            
                            // Floating Icon
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: model.gradientColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: model.gradientColors[0].opacity(0.6), radius: 15, y: 5)
                                
                                Image(systemName: model.iconName)
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .offset(y: 40) // Half out of the image bounds
                            .scaleEffect(appear ? 1.0 : 0.8)
                            .opacity(appear ? 1.0 : 0.0)
                        }
                        .offset(y: offset)
                    }
                    .frame(height: 350)
                    .zIndex(1)

                    // MARK: - Content Section
                    VStack(alignment: .leading, spacing: 24) {
                        
                        VStack(alignment: .center, spacing: 12) {
                            Text(model.title)
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(model.subtitle)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(model.gradientColors[0])
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50) // Spacer for the floating icon
                        .opacity(appear ? 1.0 : 0.0)
                        .offset(y: appear ? 0 : 20)

                        // Markdown parsing
                        Text(try! AttributedString(markdown: model.content, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
                            .font(.system(size: 17, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.85))
                            .lineSpacing(7)
                            .opacity(appear ? 1.0 : 0.0)
                            .offset(y: appear ? 0 : 20)
                        
                        // Take Quiz Button
                        Button {
                            showQuiz = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 20))
                                Text("Take Knowledge Quiz")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: model.gradientColors,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: model.gradientColors[0].opacity(0.5), radius: 15, y: 8)
                        }
                        .padding(.top, 32)
                        .opacity(appear ? 1.0 : 0.0)
                        .offset(y: appear ? 0 : 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                    .zIndex(0)
                }
            }
            .ignoresSafeArea(edges: .top)

            // MARK: - Nav Bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 8)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16) // Safe area keeps it below notch
        }
        .fullScreenCover(isPresented: $showQuiz) {
            QuizView(model: model)
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
}
