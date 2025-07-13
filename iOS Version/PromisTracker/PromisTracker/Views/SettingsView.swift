import SwiftUI

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = true
    @AppStorage("userName") private var userName: String = ""

    var body: some View {
        NavigationView {
            Form {
                // Section Apparence
                Section(header: Text(NSLocalizedString("appearance", comment: "Apparence"))) {
                    Toggle(NSLocalizedString("dark_mode", comment: "Mode Sombre"), isOn: $isDarkMode)
                }

                // Section Nom utilisateur
                Section(header: Text(NSLocalizedString("username", comment: "Nom de l'utilisateur"))) {
                    TextField(NSLocalizedString("enter_username", comment: "Entrer le nom"), text: $userName)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }

                // Section Tutoriel
                Section(header: Text(NSLocalizedString("tutorial", comment: "Tutoriel"))) {
                    Button(NSLocalizedString("review_tutorial", comment: "Revoir le tutoriel")) {
                        hasSeenTutorial = false
                    }
                }
            }
            .navigationTitle(NSLocalizedString("settings", comment: "Réglages"))
        }
    }
}
