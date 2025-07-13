import SwiftUI
import Foundation

// MARK: - Notifications Quick Actions
extension Notification.Name {
    static let addPromiseShortcut = Notification.Name("addPromiseShortcut")
    static let toggleCompleteShortcut = Notification.Name("toggleCompleteShortcut")
}

struct ContentView: View {
    @StateObject var viewModel = PromiseViewModel()
    @State private var showAdd = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedPromise: Promise? = nil
    @State private var showiCloudPrompt = true
    @State private var selectedTab = 0
    @State private var searchText = ""

    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @AppStorage("userName") private var userName: String = ""

    let addShortcutNotification = NotificationCenter.default.publisher(for: .addPromiseShortcut)
    let toggleCompleteNotification = NotificationCenter.default.publisher(for: .toggleCompleteShortcut)

    var filteredActive: [Promise] {
        if searchText.isEmpty {
            return viewModel.active
        }
        return viewModel.active.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    var filteredCompleted: [Promise] {
        if searchText.isEmpty {
            return viewModel.completed
        }
        return viewModel.completed.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    var filteredFailed: [Promise] {
        if searchText.isEmpty {
            return viewModel.failed
        }
        return viewModel.failed.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Sections pour alléger le body

    var activeSection: some View {
        Section(header: Text(NSLocalizedString("ActivePromisesSection", comment: "Active promises section header"))) {
            ForEach(filteredActive) { promise in
                PromiseRowView(promise: promise, viewModel: viewModel)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPromise = promise
                    }
            }
            .onDelete(perform: viewModel.deletePromise)
        }
    }

    var completedSection: some View {
        Section(header: Text(NSLocalizedString("CompletedPromisesSection", comment: "Completed promises section header"))) {
            ForEach(filteredCompleted) { promise in
                PromiseRowView(promise: promise, viewModel: viewModel)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPromise = promise
                    }
            }
            .onDelete(perform: viewModel.deletePromise)
        }
    }

    var failedSection: some View {
        Section(header: Text(NSLocalizedString("FailedPromisesSection", comment: "Failed promises section header"))) {
            ForEach(filteredFailed) { promise in
                PromiseRowView(promise: promise, viewModel: viewModel)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPromise = promise
                    }
            }
            .onDelete(perform: viewModel.deletePromise)
        }
    }

    // MARK: - Body

    var body: some View {
        Group {
            if !hasSeenTutorial {
                TutorialView(hasSeenTutorial: $hasSeenTutorial)
            } else {
                TabView(selection: $selectedTab) {
                    NavigationView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(format: NSLocalizedString("HelloUser", comment: "Greeting with username"), userName.isEmpty ? "Yanis" : userName))
                                .font(.largeTitle)
                                .bold()
                                .padding(.horizontal)

                            Text(String(format: NSLocalizedString("YouHaveActivePromises", comment: "User active promises count"), viewModel.active.count))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)

                            SearchBar(text: $searchText, placeholder: NSLocalizedString("SearchPlaceholder", comment: "Search bar placeholder"))
                                .padding(.horizontal)

                            List {
                                activeSection
                                completedSection
                                failedSection
                            }
                        }
                        .navigationTitle("") // Titre supprimé
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: { showAdd = true }) {
                                    Image(systemName: "plus")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                    .tabItem { Label(NSLocalizedString("TabTracking", comment: "Tab label tracking"), systemImage: "checklist") }
                    .tag(0)

                    SettingsView(isDarkMode: $isDarkMode)
                        .tabItem { Label(NSLocalizedString("TabSettings", comment: "Tab label settings"), systemImage: "gear") }
                        .tag(1)

                    AccountView()
                        .tabItem { Label(NSLocalizedString("TabAccount", comment: "Tab label account"), systemImage: "person.circle") }
                        .tag(2)
                }
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .sheet(isPresented: $showAdd) {
                    AddPromiseView(viewModel: viewModel)
                }
                .sheet(item: $selectedPromise) { promise in
                    NavigationView {
                        PromiseDetailView(promise: promise, viewModel: viewModel)
                    }
                }
                .onReceive(addShortcutNotification) { _ in
                    showAdd = true
                }
                .onReceive(toggleCompleteNotification) { _ in
                    if let last = viewModel.promises.last {
                        var updated = last
                        updated.completed.toggle()
                        viewModel.updatePromise(updated)
                        alertMessage = updated.completed
                            ? NSLocalizedString("AlertPromiseCompleted", comment: "Alert message when promise completed")
                            : NSLocalizedString("AlertPromiseIncomplete", comment: "Alert message when promise marked incomplete")
                        showAlert = true
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(NSLocalizedString("AlertQuickAction", comment: "Quick action alert title")),
                          message: Text(alertMessage),
                          dismissButton: .default(Text(NSLocalizedString("OkButton", comment: "Ok button text"))))
                }
                .alert(isPresented: $showiCloudPrompt) {
                    Alert(
                        title: Text(NSLocalizedString("AlertiCloudTitle", comment: "iCloud alert title")),
                        message: Text(NSLocalizedString("AlertiCloudMessage", comment: "iCloud alert message")),
                        dismissButton: .default(Text(NSLocalizedString("OkButton", comment: "Ok button text"))) {
                            showiCloudPrompt = false
                        }
                    )
                }
            }
        }
    }
}

// MARK: - SearchBar compatible iOS 14+ and 15+
struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.text = ""
            text = ""
            searchBar.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = placeholder
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}
