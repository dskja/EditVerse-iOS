import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var store: FeedStore
    @State private var query = ""
    @State private var results: [EditPost] = []
    @State private var searching = false

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Search edits & editors", text: $query)
                        .padding(12)
                        .background(EVTheme.stage)
                        .foregroundStyle(EVTheme.ivory)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .onSubmit { Task { await runSearch() } }
                        .onChange(of: query) { _, value in
                            if value.trimmingCharacters(in: .whitespaces).isEmpty {
                                results = store.posts
                            }
                        }

                    Text(results.isEmpty ? "Nothing on this reel yet." : "Cuts that hit.")
                        .font(EVTheme.bodyFont)
                        .foregroundStyle(EVTheme.fog)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(results) { post in
                            Button {
                                store.activeTab = 0
                                Task { await store.selectCategory(post.category) }
                            } label: {
                                DiscoverTile(post: post)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
            .background(EVTheme.void.ignoresSafeArea())
            .navigationTitle("Discover")
            .toolbarBackground(EVTheme.void, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                results = store.posts
                if results.isEmpty {
                    await store.refreshFeed()
                    results = store.posts
                }
            }
            .overlay { if searching { ProgressView().tint(EVTheme.tungsten) } }
        }
    }

    private func runSearch() async {
        searching = true
        defer { searching = false }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        results = trimmed.isEmpty ? store.posts : await store.search(trimmed)
    }
}

private struct DiscoverTile: View {
    let post: EditPost
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [EVTheme.stage, Color(red: 0.12, green: 0.09, blue: 0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .overlay(
                    Image(systemName: "film")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(EVTheme.tungsten.opacity(0.2))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(12)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title).font(EVTheme.bodyFont).foregroundStyle(EVTheme.ivory).lineLimit(2)
                Text("@\(post.author.username)").font(EVTheme.captionFont).foregroundStyle(EVTheme.fog)
            }
            .padding(12)
        }
    }
}
