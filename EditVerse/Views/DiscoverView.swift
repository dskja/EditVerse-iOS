import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var store: FeedStore

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Find the cut that hits.")
                        .font(EVTheme.bodyFont)
                        .foregroundStyle(EVTheme.mist)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(store.posts) { post in
                            DiscoverTile(post: post)
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
            RoundedRectangle(cornerRadius: 18, style: .continuous)
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
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white.opacity(0.22))
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
            (r, g, b) = (1, 1, 1)
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
