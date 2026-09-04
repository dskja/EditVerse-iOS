import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var store: FeedStore
    @State private var query = ""

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private var results: [EditPost] {
        let base = store.posts
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return base }
        return base.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed)
                || $0.creatorHandle.localizedCaseInsensitiveContains(trimmed)
                || $0.category.rawValue.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Search edits, creators, categories", text: $query)
                        .font(EVTheme.bodyFont)
                        .padding(12)
                        .background(EVTheme.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(EVTheme.soft)

                    Text(results.isEmpty ? "No matches." : "Find the cut that hits.")
                        .font(EVTheme.bodyFont)
                        .foregroundStyle(EVTheme.mist)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(results) { post in
                            Button {
                                store.selectedCategory = post.category
                                store.activeTab = 0
                            } label: {
                                DiscoverTile(post: post)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
            .background(EVTheme.ink.ignoresSafeArea())
            .navigationTitle("Discover")
            .toolbarBackground(EVTheme.ink, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct DiscoverTile: View {
    let post: EditPost

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: post.thumbnailGradient[0]),
                            Color(hex: post.thumbnailGradient[1])
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 210)
                .overlay(
                    Image(systemName: post.category.symbol)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white.opacity(0.2))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(14)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(EVTheme.bodyFont)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text("@\(post.creatorHandle)")
                    .font(EVTheme.captionFont)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(12)
        }
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (20, 20, 20)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
