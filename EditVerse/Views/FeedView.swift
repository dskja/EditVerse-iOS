import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var store: FeedStore
    @State private var activeID: String?

    var body: some View {
        ZStack(alignment: .top) {
            EVTheme.ink.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(store.filteredPosts) { post in
                        EditCardView(
                            post: post,
                            isActive: activeID == post.id,
                            isFollowing: store.isFollowing(post.creatorHandle),
                            onLike: { store.toggleLike(post.id) },
                            onSave: { store.toggleSave(post.id) },
                            onFollow: { store.toggleFollow(post.creatorHandle) }
                        )
                        .containerRelativeFrame(.vertical)
                        .id(post.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $activeID)
            .ignoresSafeArea()

            topChrome
        }
        .onAppear {
            if activeID == nil { activeID = store.filteredPosts.first?.id }
        }
        .onChange(of: store.selectedCategory) { _, _ in
            activeID = store.filteredPosts.first?.id
        }
    }

    private var topChrome: some View {
        VStack(spacing: 10) {
            HStack {
                Text("EditVerse")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [EVTheme.lime, EVTheme.cyan], startPoint: .leading, endPoint: .trailing)
                    )
                Spacer()
                Text("EDITS ONLY")
                    .font(EVTheme.captionFont)
                    .tracking(1.4)
                    .foregroundStyle(EVTheme.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(EVTheme.lime)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip("For You", selected: store.selectedCategory == nil) { store.selectedCategory = nil }
                    ForEach(EditCategory.allCases) { category in
                        chip(category.rawValue, selected: store.selectedCategory == category) {
                            store.selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 18)
            }
        }
        .padding(.bottom, 8)
        .background(
            LinearGradient(colors: [EVTheme.ink.opacity(0.92), EVTheme.ink.opacity(0)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(edges: .top)
        )
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(EVTheme.captionFont)
                .foregroundStyle(selected ? EVTheme.ink : EVTheme.soft)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? EVTheme.cyan : EVTheme.panel.opacity(0.85))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
