import SwiftUI

struct PromiseEditView: View {
    @ObservedObject var viewModel: PromiseViewModel
    @State var promise: Promise
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("edit_title", comment: "Titre de la promesse"))) {
                TextField(NSLocalizedString("edit_title_placeholder", comment: "Placeholder du titre"), text: $promise.title)
            }

            Section(header: Text(NSLocalizedString("edit_notes", comment: "Notes de la promesse"))) {
                TextEditor(text: $promise.notes)
                    .frame(height: 100)
            }

            Section(header: Text(NSLocalizedString("edit_priority", comment: "Priorité de la promesse"))) {
                Picker(NSLocalizedString("edit_priority", comment: "Priorité"), selection: $promise.priority) {
                    Text(NSLocalizedString("priority_low", comment: "Priorité basse")).tag(0)
                    Text(NSLocalizedString("priority_medium", comment: "Priorité moyenne")).tag(1)
                    Text(NSLocalizedString("priority_high", comment: "Priorité haute")).tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text(NSLocalizedString("edit_dates", comment: "Dates de la promesse"))) {
                DatePicker(NSLocalizedString("edit_start_date", comment: "Date de début"), selection: $promise.startDate, displayedComponents: .date)
                DatePicker(NSLocalizedString("edit_end_date", comment: "Date de fin"), selection: $promise.endDate, displayedComponents: .date)
            }
        }
        .navigationTitle(NSLocalizedString("edit_navigation_title", comment: "Titre de navigation"))
        .navigationBarItems(
            leading: Button(NSLocalizedString("button_cancel", comment: "Annuler")) {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button(NSLocalizedString("button_save", comment: "Enregistrer")) {
                viewModel.updatePromise(promise)
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
}
