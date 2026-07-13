import Foundation
import SwiftData

@Model
final class Note {
    var text: String
    var createdAt: Date
    var tag: Tag?
    var imageData: Data?

    init(text: String, createdAt: Date = .now, tag: Tag? = nil, imageData: Data? = nil) {
        self.text = text
        self.createdAt = createdAt
        self.tag = tag
        self.imageData = imageData
    }
}
