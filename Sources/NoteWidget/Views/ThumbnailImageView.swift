import AppKit
import SwiftUI

/// 缩略图展示：点一下可以放大看完整图片。
struct ThumbnailImageView: View {
    let imageData: Data
    var maxHeight: CGFloat = 80

    @State private var showFullSize = false

    var body: some View {
        if let nsImage = NSImage(data: imageData) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: maxHeight)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contentShape(Rectangle())
                .onTapGesture { showFullSize = true }
                .help("Click to view full size")
                .sheet(isPresented: $showFullSize) {
                    VStack(spacing: 12) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                        Button("Close") { showFullSize = false }
                    }
                    .padding(16)
                    .frame(minWidth: 320, idealWidth: 520, minHeight: 320, idealHeight: 520)
                }
        }
    }
}
