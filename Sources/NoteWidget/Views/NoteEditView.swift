import AppKit
import SwiftUI
import SwiftData

struct NoteEditView: View {
    @Bindable var note: Note
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edit Note")
                .font(.system(.headline, design: .rounded))

            if let imageData = note.imageData {
                ZStack(alignment: .topTrailing) {
                    ThumbnailImageView(imageData: imageData, maxHeight: 120)
                    Button {
                        note.imageData = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white, .black.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .padding(4)
                }
            }

            TextField("", text: $note.text, axis: .vertical)
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
                Button("Done") {
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
