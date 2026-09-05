import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var session: SessionStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var activeID: String?
    @State private var pausedIDs: Set<String> = []
    @State private var showUpload = false
    @State private var showAuth = false

    var body: some View {
        ZStack(alignment: .top) {
            EVTheme.void.ignoresSafeArea()
            if store.isRefreshing && store.posts.isEmpty {
                ProgressView().tint(EVTheme.tungsten)
            } else if store.posts.isEmpty {
                emptyState
            } else {
                GeometryReader { geo in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(store.posts) { post in
                                EditCardView(
                                    post: post,
                                    isActive: store.isFeedVisible && activeID == post.id && scenePhase == .active,
                                    isMuted: store.isMuted,
                                    isPaused: pausedIDs.contains(post.id),
                                    onLike: { Task { await store.toggleLike(post.id) } },
                                    onSave: {
                                        guard session.isAuthenticated else { showAuth = true; return }
                                        Task { await store.toggleSave(post.id) }
                                    },
                                    onFollow: {
                                        guard session.isAuthenticated else { showAuth = true; return }
                                        Task { await store.toggleFollow(username: post.author.username, editId: post.id) }
                                    },
                                    onShare: { Task { await store.shareBump(post.id) } },
                                    onToggleMute: { store.isMuted.toggle() },
                                    onTogglePause: {
                                        if pausedIDs.contains(post.id) { pausedIDs.remove(post.id) }
                                        else { pausedIDs.insert(post.id) }
                                    }
                                )
                                .frame(width: geo.size.width, height: geo.size.height)
                                .id(post.id)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: $activeID)
                    .ignoresSafeArea()
                    .onAppear { if activeID == nil { activeID = store.posts.first?.id } }
                    .onChange(of: store.posts.map(\.id)) { _, ids in
                        if activeID == nil || !ids.contains(where: { $0 == activeID }) { activeID = ids.first }
                    }
                }
            }
            topChrome
        }
        .task { await store.bootstrap() }
        .sheet(isPresented: $showUpload) {
            UploadView { post in store.prepend(post); activeID = post.id }
                .environmentObject(session)
        }
        .sheet(isPresented: $showAuth) { AuthView().environmentObject(session) }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Spacer()
            Text("EDITVERSE").font(EVTheme.brandFont).tracking(6).foregroundStyle(EVTheme.tungsten)
            Text("The stage is dark.").font(EVTheme.displayFont).foregroundStyle(EVTheme.ivory)
            Text(store.errorMessage ?? "No edits yet. Be the first cut on the reel.")
                .font(EVTheme.bodyFont).foregroundStyle(EVTheme.fog).multilineTextAlignment(.center).padding(.horizontal, 32)
            Button {
                if session.isAuthenticated { showUpload = true } else { showAuth = true }
            } label: {
                Text(session.isAuthenticated ? "Upload an Edit" : "Enter EditVerse")
                    .font(EVTheme.captionFont).tracking(1.2).foregroundStyle(EVTheme.void)
                    .padding(.horizontal, 18).padding(.vertical, 12).background(EVTheme.tungsten)
            }
            Button("Refresh") { Task { await store.refreshFeed() } }
                .font(EVTheme.captionFont).foregroundStyle(EVTheme.steel)
            Spacer()
        }
        .background(EVTheme.stageGradient.ignoresSafeArea())
    }

    private var topChrome: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("EDITVERSE").font(.system(size: 22, weight: .bold, design: .serif)).tracking(4).foregroundStyle(EVTheme.ivory)
                    Text("EDITS ONLY").font(EVTheme.captionFont).tracking(2).foregroundStyle(EVTheme.tungsten)
                }
                Spacer()
                Button {
                    if session.isAuthenticated { showUpload = true } else { showAuth = true }
                } label: {
                    Image(systemName: "plus.rectangle.on.rectangle")
                        .font(.system(size: 18, weight: .semibold)).foregroundStyle(EVTheme.tungsten)
                        .padding(10).background(EVTheme.stage.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .padding(.horizontal, 18).padding(.top, 8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip("For You", store.selectedCategory == nil) { Task { await store.selectCategory(nil) } }
                    ForEach(store.categories, id: \.self) { cat in
                        chip(cat, store.selectedCategory == cat) { Task { await store.selectCategory(cat) } }
                    }
                }.padding(.horizontal, 18)
            }
        }
        .padding(.bottom, 10)
        .background(LinearGradient(colors: [EVTheme.void.opacity(0.92), EVTheme.void.opacity(0)], startPoint: .top, endPoint: .bottom).ignoresSafeArea(edges: .top))
    }

    private func chip(_ title: String, _ selected: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(EVTheme.captionFont).tracking(0.8)
                .foregroundStyle(selected ? EVTheme.void : EVTheme.ivory)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(selected ? EVTheme.tungsten : EVTheme.stage.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(EVTheme.tungsten.opacity(selected ? 0 : 0.25), lineWidth: 1))
        }.buttonStyle(.plain)
    }
}
