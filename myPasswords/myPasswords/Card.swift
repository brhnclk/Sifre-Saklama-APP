import UIKit
struct Card: Codable {
    let title: String
    let subtitle: String
    let additionalText: String
    let password: String
    let colorIndex: Int
    static func getColor(for index: Int) -> UIColor {
        switch index {
        case 0:
            return .systemGray6
        case 1:
            return .systemBlue.withAlphaComponent(0.5)
        case 2:
            return .systemGreen.withAlphaComponent(0.5)
        case 3:
            return .systemPink.withAlphaComponent(0.5)
        case 4:
            return .systemRed.withAlphaComponent(0.5)
        case 5:
            return .systemYellow.withAlphaComponent(0.5)
        case 6:
            return .systemCyan.withAlphaComponent(0.5)
        default:
            return .systemGray6
        }
    }
    static func getColorIndex(for color: UIColor) -> Int {
        if color.isEqual(UIColor.systemGray6) {
            return 0
        } else if color.isEqual(UIColor.systemBlue.withAlphaComponent(0.5)) {
            return 1
        } else if color.isEqual(UIColor.systemGreen.withAlphaComponent(0.5)) {
            return 2
        } else if color.isEqual(UIColor.systemPink.withAlphaComponent(0.5)) {
            return 3
        } else if color.isEqual(UIColor.systemRed.withAlphaComponent(0.5)){
            return 4
        } else if color.isEqual(UIColor.systemYellow.withAlphaComponent(0.5)){
            return 5
        } else if color.isEqual(UIColor.systemCyan.withAlphaComponent(0.5)){
            return 6
        }
        return 0
    }
} 
