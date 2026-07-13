import SwiftUI
import SwiftData

struct TagManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var tags: [Tag]

    @State private var newTagName: String = ""
    @State private var newTagColor: Color = .brandPink

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Manage Tags")
                .font(.system(.headline, design: .rounded))

            List {
                ForEach(tags) { tag in
                    HStack {
                        ColorPicker("", selection: Binding(
                            get: { Color(hex: tag.colorHex) },
                            set: { tag.colorHex = $0.toHex() }
                        ))
                        .labelsHidden()
                        Text(tag.name)
                        Spacer()
                        Button(role: .destructive) {
                            modelContext.delete(tag)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                        .help("Delete tag (notes using it will become untagged)")
                    }
                }
            }
            .frame(minHeight: 160)

            HStack {
                TextField("New tag name", text: $newTagName)
                    .textFieldStyle(.roundedBorder)
                ColorPicker("", selection: $newTagColor)
                    .labelsHidden()
                Button("Add", action: addTag)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.brandPink)
                    .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            HStack {
                Spacer()
                Button("Done") { dismiss() }
            }
        }
        .padding(16)
        .font(.system(.body, design: .rounded))
        .frame(width: 360, height: 380)
    }

    private func addTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        modelContext.insert(Tag(name: trimmed, colorHex: newTagColor.toHex()))
        newTagName = ""
        newTagColor = .brandPink
    }
}
