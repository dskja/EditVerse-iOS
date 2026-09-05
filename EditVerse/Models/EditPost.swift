import Foundation

struct UserProfile: Identifiable, Codable, Hashable {
    let id: String
    var email: String?
    var username: String
    var displayName: String
    var bio: String
    var avatarUrl: String
    var createdAt: String?
    var followersCount: Int
    var followingCount: Int
    var editsCount: Int
    var isFollowing: Bool
    var isSelf: Bool

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        username = try c.decode(String.self, forKey: .username)
        displayName = try c.decode(String.self, forKey: .displayName)
        bio = try c.decodeIfPresent(String.self, forKey: .bio) ?? ""
        avatarUrl = try c.decodeIfPresent(String.self, forKey: .avatarUrl) ?? ""
        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)
        followersCount = try c.decodeIfPresent(Int.self, forKey: .followersCount) ?? 0
        followingCount = try c.decodeIfPresent(Int.self, forKey: .followingCount) ?? 0
        editsCount = try c.decodeIfPresent(Int.self, forKey: .editsCount) ?? 0
        isFollowing = try c.decodeIfPresent(Bool.self, forKey: .isFollowing) ?? false
        isSelf = try c.decodeIfPresent(Bool.self, forKey: .isSelf) ?? false
    }
}

struct AuthorRef: Codable, Hashable {
    let id: String
    let username: String
    let displayName: String
    let avatarUrl: String
}

struct EditPost: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var caption: String
    var category: String
    var videoUrl: String
    var thumbnailUrl: String
    var durationMs: Int
    var durationLabel: String
    var songTitle: String
    var likes: Int
    var comments: Int
    var shares: Int
    var saves: Int
    var views: Int
    var isLiked: Bool
    var isSaved: Bool
    var isFollowingAuthor: Bool
    var createdAt: String
    var author: AuthorRef
    var videoURL: URL? { URL(string: videoUrl) }
}

struct EditComment: Identifiable, Codable, Hashable {
    let id: String
    let body: String
    let createdAt: String
    let author: AuthorRef
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
