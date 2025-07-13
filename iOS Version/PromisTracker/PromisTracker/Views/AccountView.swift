import SwiftUI

struct AccountView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()
                Text(NSLocalizedString("AccountLoginPrompt", comment: "Prompt to login"))
                    .font(.headline)
                Button(NSLocalizedString("AccountLoginButton", comment: "Login button title")) {
                    // Ajoute ici ta logique de connexion (ex: iCloud)
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("AccountTitle", comment: "Account view title"))
        }
    }
}
