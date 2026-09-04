import SwiftUI
import AVFoundation

@main
struct EditVerseApp: App {
    @StateObject private var feedStore = FeedStore()

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(feedStore)
                .preferredColorScheme(.dark)
        }
    }
}
