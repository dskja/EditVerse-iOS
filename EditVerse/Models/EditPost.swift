import Foundation

struct EditPost: Identifiable, Hashable {
    let id: String
    let title: String
    let caption: String
    let creatorHandle: String
    let creatorDisplayName: String
    let category: EditCategory
    let videoURL: URL
    let thumbnailGradient: [String]
    var likes: Int
    var comments: Int
    var shares: Int
    var isLiked: Bool
    var isSaved: Bool
    let durationLabel: String
    let songTitle: String
}

enum EditCategory: String, CaseIterable, Identifiable {
    case gaming = "Gaming"
    case anime = "Anime"
    case sports = "Sports"
    case cinema = "Cinema"
    case music = "Music"
    case cars = "Cars"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .gaming: return "gamecontroller.fill"
        case .anime: return "sparkles"
        case .sports: return "figure.run"
        case .cinema: return "film"
        case .music: return "waveform"
        case .cars: return "car.fill"
        }
    }
}
