import AppKit
import SwiftUI
import SwiftData

struct FloatingWidgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var tags: [Tag]

    @State private var draftText: String = ""
    @State private var selectedTag: Tag?
    @State private var showTagManagement = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Menu {
                    ForEach(tags) { tag in
                        Button(tag.name) { selectedTag = tag }
                    }
                    Divider()
                    Button("管理标签...") { showTagManagement = true }
                } label: {
                    Label(selectedTag?.name ?? "选择标签", systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundStyle(Color.brandPink)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()

                Spacer()

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
                .help("打开笔记列表")

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
                .help("隐藏便签框（⌃⌥N 或点 Dock 图标可以重新召回）")
            }

            TextField("写点什么...", text: $draftText, axis: .vertical)
                .textFieldStyle(.plain)
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

            Button("保存", action: saveNote)
                .frame(maxWidth: .infinity)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .tint(Color.brandPink)
                .disabled(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        guard !trimmed.isEmpty else { return }
        modelContext.insert(Note(text: trimmed, tag: selectedTag))
        draftText = ""
    }
}
