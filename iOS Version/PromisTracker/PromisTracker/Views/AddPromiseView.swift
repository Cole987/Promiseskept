import SwiftUI
import UniformTypeIdentifiers

struct AddPromiseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PromiseViewModel

    @State private var title = ""
    @State private var notes = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400)
    @State private var selectedFiles: [URL] = []
    @State private var showFileImporter = false
    @State private var priority = 1

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("AddPromiseTitleHeader", comment: "Section header for title"))) {
                    TextField(NSLocalizedString("AddPromiseTitlePlaceholder", comment: "Placeholder for title"), text: $title)
                }
                Section(header: Text(NSLocalizedString("AddPromiseNotesHeader", comment: "Section header for notes"))) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                Section(header: Text(NSLocalizedString("AddPromiseDatesHeader", comment: "Section header for dates"))) {
                    DatePicker(NSLocalizedString("AddPromiseStartDate", comment: "Label for start date picker"), selection: $startDate, displayedComponents: .date)
                    DatePicker(NSLocalizedString("AddPromiseEndDate", comment: "Label for end date picker"), selection: $endDate, displayedComponents: .date)
                }
                Section(header: Text(NSLocalizedString("AddPromisePriorityHeader", comment: "Section header for priority"))) {
                    Picker(NSLocalizedString("AddPromisePriorityPicker", comment: "Picker label for priority"), selection: $priority) {
                        Text(NSLocalizedString("PriorityLow", comment: "Low priority")).tag(0)
                        Text(NSLocalizedString("PriorityMedium", comment: "Medium priority")).tag(1)
                        Text(NSLocalizedString("PriorityHigh", comment: "High priority")).tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text(NSLocalizedString("AddPromiseFilesHeader", comment: "Section header for files"))) {
                    Button(NSLocalizedString("AddPromiseImportFilesButton", comment: "Button to import files")) {
                        showFileImporter = true
                    }
                    ForEach(selectedFiles, id: \.self) { file in
                        Text(file.lastPathComponent)
                    }
                }
            }
            .navigationBarTitle(NSLocalizedString("AddPromiseNavTitle", comment: "Navigation bar title for adding promise"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(NSLocalizedString("Cancel", comment: "Cancel button")) {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(NSLocalizedString("Add", comment: "Add button")) {
                    let newPromise = Promise(
                        title: title,
                        notes: notes,
                        startDate: startDate,
                        endDate: endDate,
                        progress: 0,
                        completed: false,
                        pinned: false,
                        files: selectedFiles,
                        priority: priority
                    )
                    viewModel.addPromise(newPromise)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty || endDate <= startDate)
            )
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.data],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                selectedFiles.append(contentsOf: urls)
            case .failure:
                break
            }
        }
    }
}
