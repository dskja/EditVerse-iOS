import SwiftUI

enum EVTheme {
    static let void = Color(red: 0.02, green: 0.02, blue: 0.025)
    static let stage = Color(red: 0.07, green: 0.07, blue: 0.08)
    static let tungsten = Color(red: 0.79, green: 0.64, blue: 0.42)
    static let ember = Color(red: 0.89, green: 0.34, blue: 0.18)
    static let steel = Color(red: 0.55, green: 0.62, blue: 0.70)
    static let ivory = Color(red: 0.95, green: 0.93, blue: 0.90)
    static let fog = Color(red: 0.72, green: 0.70, blue: 0.66)

    static let brandFont = Font.system(size: 32, weight: .bold, design: .serif)
    static let displayFont = Font.system(size: 22, weight: .semibold, design: .serif)
    static let titleFont = Font.system(size: 17, weight: .semibold)
    static let bodyFont = Font.system(size: 14, weight: .regular)
    static let captionFont = Font.system(size: 11, weight: .semibold)

    static var stageGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.09, green: 0.07, blue: 0.05), void, Color(red: 0.03, green: 0.04, blue: 0.06)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
