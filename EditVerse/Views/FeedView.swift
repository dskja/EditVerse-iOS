import SwiftUI
import UIKit

struct FeedView: View {
    @EnvironmentObject private var store: FeedStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var activeID: String?
    @State private var pausedIDs: Set<String> = []

    private var posts: [EditPost] { store.filteredPosts }

    var body: some View {
        ZStack(alignment: .top) {
            EVTheme.ink.ignoresSafeArea()

            if posts.isEmpty {
                emptyState
            } else {
                TabView(selection: $activeID) {
                    ForEach(posts) { post in
                        EditCardView(
                            post: post,
                            isActive: store.isFeedVisible && activeID == post.id && scenePhase == .active,
                            isMuted: store.isMuted,
                            isPaused: pausedIDs.contains(post.id),
                            isFollowing: store.isFollowing(post.creatorHandle),
                            onLike: {
                                store.toggleLike(post.id)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            },
                            onSave: { store.toggleSave(post.id) },
                            onFollow: { store.toggleFollow(post.creatorHandle) },
                            onShare: { store.shareCountBump(post.id) },
                            onToggleMute: { store.isMuted.toggle() },
                            onTogglePause: {
                                if pausedIDs.contains(post.id) {
                                    pausedIDs.remove(post.id)
                                } else {
                                    pausedIDs.insert(post.id)
                                }
                            }
                        )
                        .tag(Optional(post.id))
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                .onAppear { ensureActiveID() }
                .onChange(of: store.selectedCategory) { _, _ in
                    pausedIDs.removeAll()
                    activeID = posts.first?.id
                }
                .onChange(of: store.activeTab) { _, tab in
                    if tab == 0 { ensureActiveID() }
                }
            }

            topChrome
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "film.stack")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(EVTheme.cyan)
            Text("No edits in this lane")
                .font(EVTheme.titleFont)
                .foregroundStyle(EVTheme.soft)
            Text("Pick another category or jump back to For You.")
                .font(EVTheme.bodyFont)
                .foregroundStyle(EVTheme.mist)
                .multilineTextAlignment(.center)
            Button("Back to For You") {
                store.selectedCategory = nil
            }
            .font(EVTheme.captionFont)
            .foregroundStyle(EVTheme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(EVTheme.lime)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.top, 6)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var topChrome: some View {
        VStack(spacing: 10) {
            HStack {
                Text("EditVerse")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [EVTheme.lime, EVTheme.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                Text("EDITS ONLY")
                    .font(EVTheme.captionFont)
                    .tracking(1.2)
                    .foregroundStyle(EVTheme.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(EVTheme.lime)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip("For You", selected: store.selectedCategory == nil) {
                        store.selectedCategory = nil
                    }
                    ForEach(EditCategory.allCases) { category in
                        chip(category.rawValue, selected: store.selectedCategory == category) {
                            store.selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 18)
            }
        }
        .padding(.bottom, 10)
        .background(
            LinearGradient(
                colors: [EVTheme.ink.opacity(0.94), EVTheme.ink.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
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
                .background(selected ? EVTheme.cyan : EVTheme.panel.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func ensureActiveID() {
        if activeID == nil || !posts.contains(where: { $0.id == activeID }) {
            activeID = posts.first?.id
        }
    }
}
