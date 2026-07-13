import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]
    @State private var editingNote: Note?
    @State private var selectedTag: Tag?

    private var filteredNotes: [Note] {
        guard let selectedTag else { return notes }
        return notes.filter { $0.tag == selectedTag }
    }

    var body: some View {
        VStack(spacing: 0) {
            TagFilterBar(selectedTag: $selectedTag)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredNotes) { note in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(note.text)
                                    .lineLimit(3)
                                HStack {
                                    if let tag = note.tag {
                                        Text(tag.name)
                                            .font(.caption2)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color(hex: tag.colorHex).opacity(0.2))
                                            .foregroundStyle(Color(hex: tag.colorHex))
                                            .clipShape(Capsule())
                                    }
                                    Text(note.createdAt, style: .relative)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingNote = note
                            }

                            Spacer()

                            Button {
                                modelContext.delete(note)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)
                            .help("删除这条笔记")
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(nsColor: .controlBackgroundColor))
                                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                        )
                    }
                }
                .padding(16)
            }
        }
        .font(.system(.body, design: .rounded))
        .frame(minWidth: 420, minHeight: 520)
        .sheet(item: $editingNote) { note in
            NoteEditView(note: note)
        }
    }
}
