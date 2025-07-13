import SwiftUI
import UserNotifications
import WidgetKit
import CloudKit

// MARK: - Modèle
struct Promise: Identifiable, Codable {
    var id = UUID()
    var title: String
    var endDate: Date
    var progress: Double
}

// MARK: - ViewModel (simulé pour la démo, sans vrai CloudKit)
class PromiseViewModel: ObservableObject {
    @Published var promises: [Promise] = [] {
        didSet { save() }
    }

    init() { load() }

    func load() {
        // Charger localement, ici simulé
        if let data = UserDefaults.standard.data(forKey: "promises"),
           let decoded = try? JSONDecoder().decode([Promise].self, from: data) {
            promises = decoded
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(promises) {
            UserDefaults.standard.set(encoded, forKey: "promises")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func addPromise(_ promise: Promise) {
        promises.append(promise)
        scheduleNotification(for: promise)
    }

    func scheduleNotification(for promise: Promise) {
        let content = UNMutableNotificationContent()
        content.title = "Rappel promesse"
        content.body = "La promesse '\(promise.title)' approche de sa date limite!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(identifier: promise.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Vue principale
struct ContentView: View {
    @StateObject var viewModel = PromiseViewModel()
    @State private var newTitle = ""
    @State private var newEndDate = Date().addingTimeInterval(3600)
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.promises) { promise in
                        HStack {
                            Text(promise.title)
                            Spacer()
                            Text("\(Int(promise.progress * 100))%")
                        }
                    }
                }
                Form {
                    Section(header: Text("Nouvelle promesse")) {
                        TextField("Titre", text: $newTitle)
                        DatePicker("Date limite", selection: $newEndDate, displayedComponents: [.date, .hourAndMinute])
                        Button("Ajouter") {
                            guard !newTitle.isEmpty else { return }
                            let promise = Promise(title: newTitle, endDate: newEndDate, progress: 0)
                            viewModel.addPromise(promise)
                            newTitle = ""
                            showAlert = true
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Promesse ajoutée"), message: Text("Une notification sera envoyée 10s après."), dismissButton: .default(Text("Ok")))
                }
            }
            .navigationTitle("Promise Tracker V0.3 Demo")
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                    if !success {
                        print("Autorisation notifications refusée")
                    }
                }
            }
        }
    }
}

// MARK: - Widget simple
import WidgetKit
import SwiftUI

struct PromiseEntry: TimelineEntry {
    let date: Date
    let promises: [Promise]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PromiseEntry {
        PromiseEntry(date: Date(), promises: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (PromiseEntry) -> ()) {
        completion(PromiseEntry(date: Date(), promises: loadPromises()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PromiseEntry>) -> ()) {
        let entry = PromiseEntry(date: Date(), promises: loadPromises())
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 15)))
        completion(timeline)
    }

    func loadPromises() -> [Promise] {
        if let data = UserDefaults.standard.data(forKey: "promises"),
           let decoded = try? JSONDecoder().decode([Promise].self, from: data) {
            return decoded
        }
        return []
    }
}

struct PromiseWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Promesses actives")
                .font(.headline)
            ForEach(entry.promises.prefix(3)) { promise in
                Text(promise.title)
                    .font(.subheadline)
            }
            if entry.promises.isEmpty {
                Text("Aucune promesse")
                    .font(.subheadline)
            }
        }
        .padding()
    }
}

@main
struct PromiseWidget: Widget {
    let kind: String = "PromiseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PromiseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Suivi Promesses")
        .description("Affiche vos promesses actives.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
