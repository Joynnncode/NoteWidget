import SwiftUI
import SwiftData

struct TagFilterBar: View {
    @Query(sort: \Tag.name) private var tags: [Tag]
    @Binding var selectedTag: Tag?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                pill(title: "全部", color: .brandPink, isSelected: selectedTag == nil) {
                    selectedTag = nil
                }
                ForEach(tags) { tag in
                    pill(title: tag.name, color: Color(hex: tag.colorHex), isSelected: selectedTag == tag) {
                        selectedTag = tag
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private func pill(title: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.15))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
