import SwiftUI

struct EditCardView: View {
    let post: EditPost
    let isActive: Bool
    let isMuted: Bool
    let isPaused: Bool
    let onLike: () -> Void
    let onSave: () -> Void
    let onFollow: () -> Void
    let onShare: () -> Void
    let onToggleMute: () -> Void
    let onTogglePause: () -> Void

    @State private var showHeart = false
    @State private var showPauseIcon = false

    var body: some View {
        GeometryReader { geo in
            let bottomPad = max(geo.safeAreaInsets.bottom, 8) + 58

            ZStack {
                LoopingPlayerView(
                    url: post.videoURL,
                    isActive: isActive,
                    isMuted: isMuted,
                    isPaused: isPaused
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()

                // Letterbox + vignette atmosphere
                VStack(spacing: 0) {
                    Rectangle().fill(.black.opacity(0.35)).frame(height: 28)
                    Spacer()
                    Rectangle().fill(.black.opacity(0.45)).frame(height: 28)
                }
                .allowsHitTesting(false)

                LinearGradient(
                    colors: [.black.opacity(0.45), .clear, .black.opacity(0.15), .black.opacity(0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2, perform: handleDoubleTap)
                    .onTapGesture(count: 1, perform: handleSingleTap)

                if showPauseIcon && isPaused {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(20)
                        .background(.black.opacity(0.4))
                        .clipShape(Circle())
                        .allowsHitTesting(false)
                }

                if showHeart {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 78, weight: .bold))
                        .foregroundStyle(EVTheme.ember)
                        .shadow(color: .black.opacity(0.5), radius: 12)
                        .allowsHitTesting(false)
                }

                HStack(alignment: .bottom, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(post.category.uppercased())
                                .font(EVTheme.captionFont)
                                .tracking(1.4)
                                .foregroundStyle(EVTheme.tungsten)
                            Text(post.durationLabel)
                                .font(EVTheme.captionFont)
                                .foregroundStyle(EVTheme.fog)
                        }

                        Text(post.title)
                            .font(EVTheme.displayFont)
                            .foregroundStyle(EVTheme.ivory)
                            .lineLimit(2)

                        Text("@\(post.author.username)")
                            .font(EVTheme.bodyFont)
                            .foregroundStyle(EVTheme.steel)

                        if !post.caption.isEmpty {
                            Text(post.caption)
                                .font(EVTheme.bodyFont)
                                .foregroundStyle(EVTheme.fog)
                                .lineLimit(3)
                        }

                        if !post.songTitle.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "music.note")
                                Text(post.songTitle).lineLimit(1)
                            }
                            .font(EVTheme.captionFont)
                            .foregroundStyle(EVTheme.ivory.opacity(0.9))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 16) {
                        followButton
                        action(post.isLiked ? "heart.fill" : "heart", format(post.likes), post.isLiked ? EVTheme.ember : .white, onLike)
                        action("bubble.right", format(post.comments), .white) {}
                        action(post.isSaved ? "bookmark.fill" : "bookmark", "Save", post.isSaved ? EVTheme.tungsten : .white, onSave)
                        if let url = post.videoURL {
                            ShareLink(item: url, subject: Text(post.title), message: Text(post.caption)) {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrowshape.turn.up.right")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text(format(post.shares)).font(EVTheme.captionFont).foregroundStyle(.white)
                                }
                            }
                            .simultaneousGesture(TapGesture().onEnded { onShare() })
                        }
                        action(isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill", isMuted ? "Muted" : "Sound", .white, onToggleMute)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, bottomPad)
            }
        }
        .background(EVTheme.void)
    }

    private var followButton: some View {
        Button(action: onFollow) {
            ZStack(alignment: .bottom) {
                Circle()
                    .fill(EVTheme.stage)
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(EVTheme.tungsten.opacity(0.7), lineWidth: 1.2))
                Text(String(post.author.displayName.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(EVTheme.tungsten)
                Image(systemName: post.isFollowingAuthor ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(post.isFollowingAuthor ? EVTheme.steel : EVTheme.ember)
                    .background(Circle().fill(EVTheme.void).padding(-2))
                    .offset(y: 18)
            }
            .frame(height: 66)
        }
        .buttonStyle(.plain)
    }

    private func handleSingleTap() {
        onTogglePause()
        withAnimation(.easeOut(duration: 0.15)) { showPauseIcon = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeOut(duration: 0.2)) { showPauseIcon = false }
        }
    }

    private func handleDoubleTap() {
        if !post.isLiked { onLike() }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.52)) { showHeart = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeOut(duration: 0.15)) { showHeart = false }
        }
    }

    private func action(_ symbol: String, _ value: String, _ tint: Color, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(tint)
                    .shadow(color: .black.opacity(0.45), radius: 6, y: 2)
                Text(value).font(EVTheme.captionFont).foregroundStyle(.white)
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
