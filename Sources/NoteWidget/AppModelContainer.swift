import SwiftData

enum AppModelContainer {
    static let shared: ModelContainer = {
        do {
            return try ModelContainer(for: Note.self, Tag.self)
        } catch {
            fatalError("无法创建本地数据库: \(error)")
        }
    }()
}
