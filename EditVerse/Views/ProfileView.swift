import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var session: SessionStore
    @State private var showAuth = false
    @State private var saved: [EditPost] = []
    @State private var liked: [EditPost] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if let user = session.user {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(EVTheme.tungsten.gradient)
                                .frame(width: 72, height: 72)
                                .overlay(
                                    Text(String(user.displayName.prefix(1)).uppercased())
                                        .font(.system(size: 26, weight: .bold, design: .serif))
                                        .foregroundStyle(EVTheme.void)
                                )
                            VStack(alignment: .leading, spacing: 6) {
                                Text(user.displayName).font(EVTheme.displayFont).foregroundStyle(EVTheme.ivory)
                                Text("@\(user.username)").font(EVTheme.bodyFont).foregroundStyle(EVTheme.steel)
                                Text("\(user.followersCount) followers · \(user.editsCount) edits")
                                    .font(EVTheme.captionFont).foregroundStyle(EVTheme.fog)
                            }
                        }
                        HStack(spacing: 12) {
                            stat("Saved", "\(saved.count)")
                            stat("Liked", "\(liked.count)")
                            stat("Following", "\(user.followingCount)")
                        }
                        Button("Sign out") { session.logout() }
                            .font(EVTheme.captionFont)
                            .foregroundStyle(EVTheme.ember)
                        section("Saved Edits", saved)
                        section("Liked Edits", liked)
                    } else {
                        VStack(spacing: 16) {
                            Text("EDITVERSE")
                                .font(EVTheme.brandFont)
                                .tracking(6)
                                .foregroundStyle(EVTheme.tungsten)
                            Text("Sign in to save cuts, follow editors, and publish.")
                                .font(EVTheme.bodyFont)
                                .foregroundStyle(EVTheme.fog)
                                .multilineTextAlignment(.center)
                            Button("Enter EditVerse") { showAuth = true }
                                .font(EVTheme.captionFont)
                                .foregroundStyle(EVTheme.void)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(EVTheme.tungsten)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    }
                }
                .padding(16)
            }
            .background(EVTheme.void.ignoresSafeArea())
            .navigationTitle("Profile")
            .toolbarBackground(EVTheme.void, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showAuth) { AuthView().environmentObject(session) }
            .task(id: session.token) { await loadLists() }
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 20, weight: .bold, design: .serif)).foregroundStyle(EVTheme.tungsten)
            Text(title).font(EVTheme.captionFont).foregroundStyle(EVTheme.fog)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(EVTheme.stage)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func section(_ title: String, _ posts: [EditPost]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(EVTheme.titleFont).foregroundStyle(EVTheme.ivory)
            if posts.isEmpty {
                Text("Nothing here yet.").font(EVTheme.bodyFont).foregroundStyle(EVTheme.fog)
            } else {
                ForEach(posts) { post in
                    Button { store.activeTab = 0 } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(post.title).font(EVTheme.bodyFont).foregroundStyle(EVTheme.ivory)
                                Text(post.category).font(EVTheme.captionFont).foregroundStyle(EVTheme.tungsten)
                            }
                            Spacer()
                            Text(post.durationLabel).font(EVTheme.captionFont).foregroundStyle(EVTheme.fog)
                        }
                        .padding(12)
                        .background(EVTheme.stage)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func loadLists() async {
        guard session.isAuthenticated else { saved = []; liked = []; return }
        do {
            let s: ItemsEnvelope<EditPost> = try await APIClient.shared.request(
                "GET", path: "/api/users/me/saved", authorized: true
            )
            saved = s.items
        } catch { saved = [] }
        do {
            let l: ItemsEnvelope<EditPost> = try await APIClient.shared.request(
                "GET", path: "/api/users/me/liked", authorized: true
            )
            liked = l.items
        } catch { liked = [] }
    }
}
