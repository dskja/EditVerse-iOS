import SwiftUI

struct EditCardView: View {
    let post: EditPost
    let isActive: Bool
    let isFollowing: Bool
    let onLike: () -> Void
    let onSave: () -> Void
    let onFollow: () -> Void

    @State private var showHeartBurst = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LoopingPlayerView(url: post.videoURL, isActive: isActive)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.15), .black.opacity(0.78)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                HStack(alignment: .bottom, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text(post.category.rawValue.uppercased())
                                .font(EVTheme.captionFont)
                                .tracking(1.2)
                                .foregroundStyle(EVTheme.lime)
                            Text(post.durationLabel)
                                .font(EVTheme.captionFont)
                                .foregroundStyle(EVTheme.mist)
                        }

                        Text(post.title)
                            .font(EVTheme.titleFont)
                            .foregroundStyle(EVTheme.soft)
                            .lineLimit(2)

                        Text("@\(post.creatorHandle)")
                            .font(EVTheme.bodyFont)
                            .foregroundStyle(EVTheme.cyan)

                        Text(post.caption)
                            .font(EVTheme.bodyFont)
                            .foregroundStyle(EVTheme.mist)
                            .lineLimit(3)

                        HStack(spacing: 8) {
                            Image(systemName: "music.note")
                            Text(post.songTitle).lineLimit(1)
                        }
                        .font(EVTheme.captionFont)
                        .foregroundStyle(EVTheme.soft.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 18) {
                        Button(action: onFollow) {
                            ZStack {
                                Circle()
                                    .fill(EVTheme.panel)
                                    .frame(width: 48, height: 48)
                                    .overlay(Circle().stroke(EVTheme.lime.opacity(0.7), lineWidth: 1.5))
                                Text(String(post.creatorDisplayName.prefix(1)))
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundStyle(EVTheme.lime)
                                Image(systemName: isFollowing ? "checkmark.circle.fill" : "plus.circle.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(isFollowing ? EVTheme.cyan : EVTheme.coral)
                                    .offset(y: 20)
                            }
                        }

                        sideButton(symbol: post.isLiked ? "heart.fill" : "heart", value: format(post.likes), tint: post.isLiked ? EVTheme.coral : .white) {
                            onLike()
                            pulse()
                        }
                        sideButton(symbol: "bubble.right", value: format(post.comments), tint: .white) {}
                        sideButton(symbol: post.isSaved ? "bookmark.fill" : "bookmark", value: "Save", tint: post.isSaved ? EVTheme.lime : .white, action: onSave)
                        sideButton(symbol: "arrowshape.turn.up.right", value: format(post.shares), tint: .white) {}
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 28)

                if showHeartBurst {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 84, weight: .bold))
                        .foregroundStyle(EVTheme.coral)
                        .scaleEffect(showHeartBurst ? 1 : 0.4)
                        .opacity(showHeartBurst ? 1 : 0)
                        .allowsHitTesting(false)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                if !post.isLiked { onLike() }
                pulse()
            }
        }
    }

    private func pulse() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) { showHeartBurst = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { showHeartBurst = false }
    }

    private func sideButton(symbol: String, value: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(tint)
                    .shadow(color: .black.opacity(0.45), radius: 6, y: 2)
                Text(value)
                    .font(EVTheme.captionFont)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }

    private func format(_ value: Int) -> String {
        if value >= 1_000_000 { return String(format: "%.1fM", Double(value) / 1_000_000) }
        if value >= 1_000 { return String(format: "%.1fK", Double(value) / 1_000) }
        return "\(value)"
    }
}
