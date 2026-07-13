import AppKit
import SwiftUI
import SwiftData
import KeyboardShortcuts

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static var shared: AppDelegate!

    private var floatingPanel: FloatingPanel!
    private var listWindow: FloatingPanel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        NSApp.setActivationPolicy(.regular)

        seedDefaultTagsIfNeeded()
        renameLegacyChineseTagsIfNeeded()

        let widgetView = FloatingWidgetView()
            .modelContainer(AppModelContainer.shared)

        let panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 220),
            styleMask: [.nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        panel.minSize = NSSize(width: 220, height: 160)
        panel.isMovableByWindowBackground = true
        panel.contentView = ClickThroughHostingView(rootView: widgetView)
        panel.center()
        panel.delegate = self
        panel.makeKeyAndOrderFront(nil)

        floatingPanel = panel

        // 列表窗口在启动时就预先建好（先隐藏），而不是等第一次点击才建：
        // 实测如果等到别的 App 已经进入全屏之后才临时创建新窗口，
        // 系统不会把这个新窗口放进那个全屏 Space；必须提前存在才行。
        let list = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 600),
            styleMask: [.nonactivatingPanel, .titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        list.title = "My Notes"
        list.isFloatingPanel = true
        list.level = .floating
        list.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        list.contentViewController = NSHostingController(
            rootView: NoteListView().modelContainer(AppModelContainer.shared)
        )
        list.center()
        list.orderOut(nil)

        listWindow = list

        NSApp.activate(ignoringOtherApps: true)

        KeyboardShortcuts.onKeyUp(for: .toggleWidget) { [weak self] in
            self?.toggleWidget()
        }
    }

    func toggleWidget() {
        if floatingPanel.isVisible {
            floatingPanel.orderOut(nil)
        } else {
            floatingPanel.makeKeyAndOrderFront(nil)
        }
    }

    func showListWindow() {
        listWindow.makeKeyAndOrderFront(nil)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !floatingPanel.isVisible {
            floatingPanel.makeKeyAndOrderFront(nil)
        }
        return true
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // 悬浮框点关闭时只是隐藏，不销毁，方便点 Dock 图标随时召回
        if sender === floatingPanel {
            sender.orderOut(nil)
            return false
        }
        return true
    }

    private func seedDefaultTagsIfNeeded() {
        let context = AppModelContainer.shared.mainContext
        let count = (try? context.fetchCount(FetchDescriptor<Tag>())) ?? 0
        guard count == 0 else { return }
        context.insert(Tag(name: "French Learning", colorHex: "#FF6B9D"))
        context.insert(Tag(name: "General", colorHex: "#8E8E93"))
        try? context.save()
    }

    /// 早期版本的默认标签是中文名字，这里做一次性改名，切到全英文界面。
    private func renameLegacyChineseTagsIfNeeded() {
        let context = AppModelContainer.shared.mainContext
        guard let tags = try? context.fetch(FetchDescriptor<Tag>()) else { return }
        for tag in tags {
            if tag.name == "法语学习" { tag.name = "French Learning" }
            if tag.name == "常规" { tag.name = "General" }
        }
        try? context.save()
    }
}
