import AppKit
import SwiftUI

/// A hand-rolled multi-line text field replacing SwiftUI's built-in TextField(axis: .vertical)
/// and TextEditor: the former selects all text on Enter instead of inserting a newline in this
/// project, and the latter has a text-clipping rendering bug on this machine (see the stage-1
/// notes in docs/04-execution-plan.md). Wrapping a plain NSTextView directly is the most
/// predictable option.
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
