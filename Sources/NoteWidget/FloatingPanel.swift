import AppKit
import SwiftUI

/// 无标题栏的 NSPanel 默认不接受成为 key window（无法输入文字）。
final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

/// `acceptsFirstMouse` 是 NSView 的方法，不是窗口的方法：覆写它才能让
/// "不抢焦点"面板在还没成为 key window 时，第一次点击就直接生效
/// （而不是先点一下只把窗口激活、第二下才真正点到按钮）。
final class ClickThroughHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}
