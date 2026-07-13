import AppKit
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct FloatingWidgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var tags: [Tag]

    @State private var draftText: String = ""
    @State private var selectedTag: Tag?
    @State private var showTagManagement = false
    @State private var attachedImageData: Data?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Menu {
                    ForEach(tags) { tag in
                        Button(tag.name) { selectedTag = tag }
                    }
                    Divider()
                    Button("Manage Tags...") { showTagManagement = true }
                } label: {
                    Label(selectedTag?.name ?? "Select Tag", systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundStyle(Color.brandPink)
                }
                .menuStyle(.borderlessButton)
                .layoutPriority(0)

                Spacer(minLength: 4)

                Button {
                    AppDelegate.shared.showListWindow()
                } label: {
                    Image(systemName: "list.bullet")
                        .imageScale(.large)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.brandPink)
                .fixedSize()
                .layoutPriority(1)
                .help("Open note list")

                Button {
                    AppDelegate.shared.toggleWidget()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.secondary)
                .fixedSize()
                .layoutPriority(1)
                .help("Hide widget (⌃⌥N or click the Dock icon to bring it back)")
            }

            VStack(alignment: .leading, spacing: 6) {
                if let attachedImageData {
                    ZStack(alignment: .topTrailing) {
                        ThumbnailImageView(imageData: attachedImageData, maxHeight: 90)
                        Button {
                            self.attachedImageData = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white, .black.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                        .padding(4)
                    }
                }

                TextField("", text: $draftText, axis: .vertical)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.brandPink.opacity(0.25))
            )
            .onDrop(of: [.image], isTargeted: nil, perform: handleDrop)

            Button("Save", action: saveNote)
                .frame(maxWidth: .infinity)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .tint(Color.brandPink)
                .disabled(
                    draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        && attachedImageData == nil
                )
        }
        .padding(16)
        .font(.system(.body, design: .rounded))
        .frame(minWidth: 220, maxWidth: .infinity, minHeight: 160, maxHeight: .infinity)
        .onAppear {
            if selectedTag == nil {
                selectedTag = tags.first
            }
        }
        .sheet(isPresented: $showTagManagement) {
            TagManagementView()
        }
    }

    private func saveNote() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || attachedImageData != nil else { return }
        modelContext.insert(Note(text: trimmed, tag: selectedTag, imageData: attachedImageData))
        draftText = ""
        attachedImageData = nil
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.canLoadObject(ofClass: NSImage.self) }) else {
            return false
        }
        provider.loadObject(ofClass: NSImage.self) { image, _ in
            guard let nsImage = image as? NSImage, let data = nsImage.pngData() else { return }
            DispatchQueue.main.async {
                attachedImageData = data
            }
        }
        return true
    }
}
