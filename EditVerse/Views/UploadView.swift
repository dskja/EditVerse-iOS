import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct UploadView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    var onUploaded: (EditPost) -> Void

    @State private var pickerItem: PhotosPickerItem?
    @State private var fileURL: URL?
    @State private var title = ""
    @State private var caption = ""
    @State private var songTitle = ""
    @State private var category = EditCategory.cinema.rawValue
    @State private var busy = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                EVTheme.stageGradient.ignoresSafeArea()
                Form {
                    Section("Picture lock") {
                        PhotosPicker(selection: $pickerItem, matching: .videos) {
                            Label(fileURL == nil ? "Choose edit video" : "Video selected", systemImage: "film")
                                .foregroundStyle(EVTheme.tungsten)
                        }
                        .onChange(of: pickerItem) { _, item in
                            Task { await load(item) }
                        }
                    }
                    Section("Title card") {
                        TextField("Title", text: $title)
                        TextField("Caption", text: $caption, axis: .vertical)
                        TextField("Song / score", text: $songTitle)
                        Picker("Category", selection: $category) {
                            ForEach(EditCategory.allCases) { Text($0.rawValue).tag($0.rawValue) }
                        }
                    }
                    if let error {
                        Section { Text(error).foregroundStyle(EVTheme.ember) }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publish") { Task { await publish() } }
                        .disabled(busy || fileURL == nil || title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .toolbarBackground(EVTheme.void, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func load(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
                try data.write(to: url)
                fileURL = url
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func publish() async {
        guard let fileURL else { return }
        busy = true
        error = nil
        defer { busy = false }
        do {
            let post = try await APIClient.shared.uploadEdit(
                fileURL: fileURL,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category,
                songTitle: songTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                durationMs: 0
            )
            onUploaded(post)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
