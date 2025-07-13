import SwiftUI

struct PromiseDetailView: View {
    let promise: Promise
    @ObservedObject var viewModel: PromiseViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showEdit = false

    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("detail_title", comment: "Titre"))) {
                Text(promise.title)
            }
            Section(header: Text(NSLocalizedString("detail_notes", comment: "Notes"))) {
                Text(promise.notes.isEmpty ? NSLocalizedString("detail_no_notes", comment: "Aucune note") : promise.notes)
                    .foregroundColor(promise.notes.isEmpty ? .gray : .primary)
            }
            Section(header: Text(NSLocalizedString("detail_progress", comment: "Progression"))) {
                ProgressView(value: promise.progress)
                    .accentColor(promise.failed ? .red : promise.completed ? .green : .orange)
                Text(String(format: NSLocalizedString("detail_progress_percent", comment: "Progression : %d%%"), Int(promise.progress * 100)))
            }
            Section(header: Text(NSLocalizedString("detail_status", comment: "Statut"))) {
                Label(
                    promise.completed ? NSLocalizedString("detail_status_completed", comment: "Accomplie") : NSLocalizedString("detail_status_active", comment: "En cours"),
                    systemImage: promise.completed ? "checkmark.circle.fill" : "clock"
                )
                if promise.failed {
                    Label(NSLocalizedString("detail_status_failed", comment: "Échouée"), systemImage: "xmark.octagon.fill")
                        .foregroundColor(.red)
                }
                if promise.pinned {
                    Label(NSLocalizedString("detail_status_pinned", comment: "Épinglée"), systemImage: "pin.fill")
                        .foregroundColor(.orange)
                }
            }
            Section(header: Text(NSLocalizedString("detail_priority", comment: "Priorité"))) {
                Text(priorityText)
                    .foregroundColor(priorityColor)
            }
            Section(header: Text(NSLocalizedString("detail_dates", comment: "Dates"))) {
                Text(String(format: NSLocalizedString("detail_start_date", comment: "Début : %@"), formattedDate(promise.startDate)))
                Text(String(format: NSLocalizedString("detail_end_date", comment: "Fin : %@"), formattedDate(promise.endDate)))
            }
            if !promise.files.isEmpty {
                Section(header: Text(NSLocalizedString("detail_files", comment: "Fichiers"))) {
                    ForEach(promise.files, id: \.self) { file in
                        Text(file.lastPathComponent)
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("detail_navigation_title", comment: "Détail"))
        .navigationBarItems(trailing: Button(NSLocalizedString("detail_edit_button", comment: "Modifier")) {
            showEdit = true
        })
        .sheet(isPresented: $showEdit) {
            NavigationView {
                PromiseEditView(viewModel: viewModel, promise: promise)
            }
        }
    }

    var priorityText: String {
        switch promise.priority {
        case 2: return NSLocalizedString("priority_high", comment: "Haute")
        case 1: return NSLocalizedString("priority_medium", comment: "Moyenne")
        default: return NSLocalizedString("priority_low", comment: "Basse")
        }
    }

    var priorityColor: Color {
        switch promise.priority {
        case 2: return .red
        case 1: return .orange
        default: return .green
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
