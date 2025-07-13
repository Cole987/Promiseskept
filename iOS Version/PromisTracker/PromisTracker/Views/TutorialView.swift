import SwiftUI

struct TutorialView: View {
    @Binding var hasSeenTutorial: Bool

    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 20)

                VStack(spacing: 32) {
                    // Titre & sous-titre
                    VStack(spacing: 12) {
                        Text(NSLocalizedString("tutorial_welcome", comment: "Bienvenue dans PromiseTracker"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text(NSLocalizedString("tutorial_intro", comment: "Voici comment fonctionne l’application :"))
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }

                    // Étapes du tutoriel
                    VStack(spacing: 24) {
                        TutorialExplanationBlock(icon: "plus.circle", titleKey: "tutorial_add_promise")
                        TutorialExplanationBlock(icon: "chart.bar.fill", titleKey: "tutorial_progress_bar")
                        TutorialExplanationBlock(icon: "hand.point.up.left.fill", titleKey: "tutorial_mark_status")
                        TutorialExplanationBlock(icon: "gear", titleKey: "tutorial_manage_settings")
                    }
                    .padding(.horizontal)
                }

                Spacer()

                Button(action: {
                    hasSeenTutorial = true
                }) {
                    Text(NSLocalizedString("tutorial_start", comment: "Commencer"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitle(NSLocalizedString("tutorial_title", comment: "Tutoriel"), displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .ignoresSafeArea(edges: .bottom)
    }
}

// ✅ Bloc élégant avec texte bien centré verticalement avec l’icône
struct TutorialExplanationBlock: View {
    var icon: String
    var titleKey: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .font(.title2)
                .frame(width: 32, height: 32)

            Text(NSLocalizedString(titleKey, comment: ""))
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
}
