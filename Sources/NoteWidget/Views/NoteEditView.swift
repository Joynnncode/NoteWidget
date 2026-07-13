import SwiftUI
import SwiftData

struct NoteEditView: View {
    @Bindable var note: Note
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("编辑笔记")
                .font(.system(.headline, design: .rounded))

            TextField("笔记内容", text: $note.text, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(6...20)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.brandPink.opacity(0.25))
                )

            HStack {
                Spacer()
                Button("完成") {
                    try? modelContext.save()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.brandPink)
            }
        }
        .padding(16)
        .font(.system(.body, design: .rounded))
        .frame(width: 420, height: 280)
    }
}
