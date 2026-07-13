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
            Text("管理标签")
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
                        .help("删除标签（用到这个标签的笔记会变成未分类）")
                    }
                }
            }
            .frame(minHeight: 160)

            HStack {
                TextField("新标签名称", text: $newTagName)
                    .textFieldStyle(.roundedBorder)
                ColorPicker("", selection: $newTagColor)
                    .labelsHidden()
                Button("添加", action: addTag)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.brandPink)
                    .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            HStack {
                Spacer()
                Button("完成") { dismiss() }
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
