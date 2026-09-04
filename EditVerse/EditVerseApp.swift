import SwiftUI

@main
struct EditVerseApp: App {
    @StateObject private var feedStore = FeedStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(feedStore)
                .preferredColorScheme(.dark)
        }
    }
}
