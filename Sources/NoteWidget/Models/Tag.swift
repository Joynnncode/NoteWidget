import Foundation
import SwiftData

@Model
final class Tag {
    var name: String
    var colorHex: String = "#FF6B9D"

    init(name: String, colorHex: String = "#FF6B9D") {
        self.name = name
        self.colorHex = colorHex
    }
}
