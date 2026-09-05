import SwiftUI
import AVFoundation

@main
struct EditVerseApp: App {
    @StateObject private var session = SessionStore()
    @StateObject private var feed = FeedStore()

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isBootstrapping {
                    ZStack {
                        EVTheme.stageGradient.ignoresSafeArea()
                        VStack(spacing: 14) {
                            Text("EDITVERSE")
                                .font(EVTheme.brandFont)
                                .tracking(8)
                                .foregroundStyle(EVTheme.tungsten)
                            ProgressView().tint(EVTheme.tungsten)
                        }
                    }
                } else {
                    MainTabView()
                }
            }
            .environmentObject(session)
            .environmentObject(feed)
            .preferredColorScheme(.dark)
        }
    }
}
