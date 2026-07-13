import Foundation
import SwiftData

@Model
final class Note {
    var text: String
    var createdAt: Date
    var tag: Tag?

    init(text: String, createdAt: Date = .now, tag: Tag? = nil) {
        self.text = text
        self.createdAt = createdAt
        self.tag = tag
    }
}
