import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: FeedStore

    var body: some View {
        TabView(selection: $store.activeTab) {
            FeedView()
                .tabItem { Label("Feed", systemImage: "play.rectangle.fill") }
                .tag(0)

            DiscoverView()
                .tabItem { Label("Discover", systemImage: "magnifyingglass") }
                .tag(1)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(2)
        }
        .tint(EVTheme.lime)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(EVTheme.ink)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
