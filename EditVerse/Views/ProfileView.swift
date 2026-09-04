import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: FeedStore

    private var saved: [EditPost] { store.posts.filter(\.isSaved) }
    private var liked: [EditPost] { store.posts.filter(\.isLiked) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [EVTheme.lime, EVTheme.cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)
                            .overlay(
                                Text("EV")
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(EVTheme.ink)
                            )

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Your Edit Desk")
                                .font(EVTheme.titleFont)
                                .foregroundStyle(EVTheme.soft)
                            Text("Curator mode · \(store.following.count) following")
                                .font(EVTheme.bodyFont)
                                .foregroundStyle(EVTheme.mist)
                        }
                    }

                    HStack(spacing: 12) {
                        statTile(title: "Saved", value: "\(saved.count)")
                        statTile(title: "Liked", value: "\(liked.count)")
                        statTile(title: "Following", value: "\(store.following.count)")
                    }

                    section(title: "Saved Edits", posts: saved)
                    section(title: "Liked Edits", posts: liked)
                }
                .padding(16)
            }
            .background(EVTheme.ink.ignoresSafeArea())
            .navigationTitle("Profile")
            .toolbarBackground(EVTheme.ink, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func statTile(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(EVTheme.lime)
            Text(title)
                .font(EVTheme.captionFont)
                .foregroundStyle(EVTheme.mist)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(EVTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func section(title: String, posts: [EditPost]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(EVTheme.titleFont)
                .foregroundStyle(EVTheme.soft)

            if posts.isEmpty {
                Text("Nothing here yet — double-tap edits you love.")
                    .font(EVTheme.bodyFont)
                    .foregroundStyle(EVTheme.mist)
            } else {
                ForEach(posts) { post in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.title)
                                .font(EVTheme.bodyFont)
                                .foregroundStyle(EVTheme.soft)
                            Text(post.category.rawValue)
                                .font(EVTheme.captionFont)
                                .foregroundStyle(EVTheme.cyan)
                        }
                        Spacer()
                        Text(post.durationLabel)
                            .font(EVTheme.captionFont)
                            .foregroundStyle(EVTheme.mist)
                    }
                    .padding(12)
                    .background(EVTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }
}
