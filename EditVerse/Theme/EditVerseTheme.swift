import SwiftUI
import AVFoundation

enum EVTheme {
    static let ink = Color(red: 0.04, green: 0.05, blue: 0.07)
    static let panel = Color(red: 0.09, green: 0.10, blue: 0.13)
    static let lime = Color(red: 0.72, green: 0.96, blue: 0.18)
    static let cyan = Color(red: 0.20, green: 0.92, blue: 0.86)
    static let coral = Color(red: 1.0, green: 0.42, blue: 0.38)
    static let mist = Color.white.opacity(0.72)
    static let soft = Color.white.opacity(0.92)

    static let titleFont = Font.system(size: 18, weight: .bold, design: .rounded)
    static let bodyFont = Font.system(size: 14, weight: .medium, design: .rounded)
    static let captionFont = Font.system(size: 12, weight: .semibold, design: .rounded)
}
