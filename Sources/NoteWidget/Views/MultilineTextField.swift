import AppKit
import SwiftUI

/// 自己写的多行输入框，替代 SwiftUI 自带的 TextField(axis: .vertical) 和 TextEditor：
/// 前者在这个项目里按 Enter 会把已输入的文字全选而不是换行；
/// 后者在这台机器上有渲染裁切的 bug（见 docs/04-执行步骤.md 阶段1踩坑记录）。
/// 直接包一层原生 NSTextView，行为最稳定可控。
struct MultilineTextField: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.font = Self.font
        textView.textContainerInset = NSSize(width: 0, height: 0)
        textView.string = text
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true

        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    private static var font: NSFont {
        let descriptor = NSFontDescriptor.preferredFontDescriptor(forTextStyle: .body).withDesign(.rounded)
            ?? NSFontDescriptor.preferredFontDescriptor(forTextStyle: .body)
        return NSFont(descriptor: descriptor, size: 0) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
        }
    }
}
