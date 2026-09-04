import Foundation
import Combine

@MainActor
final class FeedStore: ObservableObject {
    @Published var posts: [EditPost] = SampleEdits.all
    @Published var selectedCategory: EditCategory?
    @Published var following: Set<String> = []

    var filteredPosts: [EditPost] {
        guard let selectedCategory else { return posts }
        return posts.filter { $0.category == selectedCategory }
    }

    func toggleLike(_ id: String) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        posts[index].isLiked.toggle()
        posts[index].likes += posts[index].isLiked ? 1 : -1
    }

    func toggleSave(_ id: String) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        posts[index].isSaved.toggle()
    }

    func toggleFollow(_ handle: String) {
        if following.contains(handle) {
            following.remove(handle)
        } else {
            following.insert(handle)
        }
    }

    func isFollowing(_ handle: String) -> Bool {
        following.contains(handle)
    }
}

enum SampleEdits {
    private static let samples: [URL] = [
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!,
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!,
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!,
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4")!,
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4")!,
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4")!
    ]

    static let all: [EditPost] = [
        EditPost(id: "1", title: "Clutch Ace Montage", caption: "0.3s cuts · punch zooms · hard drops only", creatorHandle: "nocturne.cuts", creatorDisplayName: "Nocturne", category: .gaming, videoURL: samples[0], thumbnailGradient: ["#0B1C1A", "#B8F52E"], likes: 48210, comments: 912, shares: 3401, isLiked: false, isSaved: false, durationLabel: "0:18", songTitle: "Night Drift — EditVerse Sound"),
        EditPost(id: "2", title: "Sakura Speed Edit", caption: "Frame holds + smear trails. Soft flash transitions.", creatorHandle: "hanabi.fx", creatorDisplayName: "Hanabi", category: .anime, videoURL: samples[1], thumbnailGradient: ["#1A1024", "#33EBD9"], likes: 92104, comments: 2104, shares: 8802, isLiked: false, isSaved: true, durationLabel: "0:22", songTitle: "Bloom Pulse — EditVerse Sound"),
        EditPost(id: "3", title: "Final Whistle", caption: "Slow-mo impact frames synced to the kick drum.", creatorHandle: "pitchfire", creatorDisplayName: "Pitchfire", category: .sports, videoURL: samples[2], thumbnailGradient: ["#120A08", "#FF6B61"], likes: 33120, comments: 640, shares: 1904, isLiked: false, isSaved: false, durationLabel: "0:15", songTitle: "Stadium Heat — EditVerse Sound"),
        EditPost(id: "4", title: "Noir Trailer Cut", caption: "Letterbox · light leaks · cinematic whip pans.", creatorHandle: "reelnoir", creatorDisplayName: "Reel Noir", category: .cinema, videoURL: samples[3], thumbnailGradient: ["#0A0C12", "#7AE8DE"], likes: 12044, comments: 288, shares: 701, isLiked: false, isSaved: false, durationLabel: "0:27", songTitle: "Glass Corridor — EditVerse Sound"),
        EditPost(id: "5", title: "Bass Drop Sync", caption: "Waveform-driven cuts. Every hit lands on the beat.", creatorHandle: "kilohertz", creatorDisplayName: "Kilohertz", category: .music, videoURL: samples[4], thumbnailGradient: ["#0C1014", "#C8F52E"], likes: 77401, comments: 1502, shares: 4200, isLiked: true, isSaved: false, durationLabel: "0:20", songTitle: "Voltage — EditVerse Sound"),
        EditPost(id: "6", title: "Midnight Apex", caption: "Tunnel light streaks + engine RPM matched to BPM.", creatorHandle: "apexlane", creatorDisplayName: "Apex Lane", category: .cars, videoURL: samples[5], thumbnailGradient: ["#0B0E12", "#33EBD9"], likes: 54002, comments: 998, shares: 2601, isLiked: false, isSaved: false, durationLabel: "0:24", songTitle: "Carbon Night — EditVerse Sound")
    ]
}
