import AppKit
import SwiftUI

/// A titleless NSPanel doesn't accept becoming key window by default (can't receive text input).
final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

/// `acceptsFirstMouse` is an NSView method, not a window one: overriding it lets a
/// non-activating panel respond to the very first click before it becomes key window
/// (instead of the first click just activating the window and the second click hitting the button).
final class ClickThroughHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}
