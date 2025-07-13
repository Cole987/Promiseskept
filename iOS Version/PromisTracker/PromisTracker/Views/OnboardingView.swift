import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
}

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    
    let pages = [
        OnboardingPage(
            title: NSLocalizedString("onboarding_title_1", comment: "Bienvenue"),
            description: NSLocalizedString("onboarding_desc_1", comment: "Suivez vos promesses facilement et simplement."),
            systemImage: "checklist"
        ),
        OnboardingPage(
            title: NSLocalizedString("onboarding_title_2", comment: "Priorisez"),
            description: NSLocalizedString("onboarding_desc_2", comment: "Attribuez des priorités et suivez la progression."),
            systemImage: "flag.fill"
        ),
        OnboardingPage(
            title: NSLocalizedString("onboarding_title_3", comment: "Rapide & Pratique"),
            description: NSLocalizedString("onboarding_desc_3", comment: "Utilisez 3D Touch pour modifier rapidement vos tâches."),
            systemImage: "bolt.fill"
        )
    ]
    
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    VStack(spacing: 30) {
                        Spacer()
                        Image(systemName: page.systemImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.orange)
                        Text(page.title)
                            .font(.largeTitle)
                            .bold()
                        Text(page.description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
            Button(action: {
                if currentPage == pages.count - 1 {
                    hasSeenOnboarding = true
                } else {
                    currentPage += 1
                }
            }) {
                Text(currentPage == pages.count - 1 ? NSLocalizedString("onboarding_button_start", comment: "Commencer") : NSLocalizedString("onboarding_button_next", comment: "Suivant"))
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}
