import SwiftData

enum AppModelContainer {
    static let shared: ModelContainer = {
        do {
            return try ModelContainer(for: Note.self, Tag.self)
        } catch {
            fatalError("Failed to create local database: \(error)")
        }
    }()
}
