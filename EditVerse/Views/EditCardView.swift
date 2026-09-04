import SwiftUI

struct EditCardView: View {
    let post: EditPost
    let isActive: Bool
    let isMuted: Bool
    let isPaused: Bool
    let isFollowing: Bool
    let onLike: () -> Void
    let onSave: () -> Void
    let onFollow: () -> Void
    let onShare: () -> Void
    let onToggleMute: () -> Void
    let onTogglePause: () -> Void

    @State private var showHeartBurst = false
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

                LinearGradient(
                    colors: [
                        .black.opacity(0.35),
                        .clear,
                        .black.opacity(0.2),
                        .black.opacity(0.82)
                    ],
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
                        .font(.system(size: 54, weight: .bold))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(22)
                        .background(.black.opacity(0.35))
                        .clipShape(Circle())
                        .transition(.scale.combined(with: .opacity))
                        .allowsHitTesting(false)
                }

                if showHeartBurst {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 84, weight: .bold))
                        .foregroundStyle(EVTheme.coral)
                        .scaleEffect(showHeartBurst ? 1 : 0.35)
                        .opacity(showHeartBurst ? 1 : 0)
                        .allowsHitTesting(false)
                }

                HStack(alignment: .bottom, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Label(post.category.rawValue.uppercased(), systemImage: post.category.symbol)
                                .font(EVTheme.captionFont)
                                .tracking(1.1)
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
                            Text(post.songTitle)
                                .lineLimit(1)
                        }
                        .font(EVTheme.captionFont)
                        .foregroundStyle(EVTheme.soft.opacity(0.92))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 16) {
                        followButton

                        actionButton(
                            symbol: post.isLiked ? "heart.fill" : "heart",
                            value: format(post.likes),
                            tint: post.isLiked ? EVTheme.coral : .white,
                            action: {
                                onLike()
                                if post.isLiked == false { pulseHeart() }
                            }
                        )

                        actionButton(symbol: "bubble.right", value: format(post.comments), tint: .white) {}

                        actionButton(
                            symbol: post.isSaved ? "bookmark.fill" : "bookmark",
                            value: "Save",
                            tint: post.isSaved ? EVTheme.lime : .white,
                            action: onSave
                        )

                        ShareLink(item: post.videoURL, subject: Text(post.title), message: Text(post.caption)) {
                            VStack(spacing: 4) {
                                Image(systemName: "arrowshape.turn.up.right")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.45), radius: 6, y: 2)
                                Text(format(post.shares))
                                    .font(EVTheme.captionFont)
                                    .foregroundStyle(.white)
                            }
                        }
                        .simultaneousGesture(TapGesture().onEnded { onShare() })

                        actionButton(
                            symbol: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill",
                            value: isMuted ? "Muted" : "Sound",
                            tint: .white,
                            action: onToggleMute
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, bottomPad)
            }
        }
        .background(EVTheme.ink)
    }

    private var followButton: some View {
        Button(action: onFollow) {
            ZStack(alignment: .bottom) {
                Circle()
                    .fill(EVTheme.panel)
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(EVTheme.lime.opacity(0.75), lineWidth: 1.5))
                Text(String(post.creatorDisplayName.prefix(1)))
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(EVTheme.lime)
                Image(systemName: isFollowing ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isFollowing ? EVTheme.cyan : EVTheme.coral)
                    .background(Circle().fill(EVTheme.ink).padding(-2))
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
        pulseHeart()
    }

    private func pulseHeart() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.52)) {
            showHeartBurst = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeOut(duration: 0.15)) {
                showHeartBurst = false
            }
        }
    }

    private func actionButton(
        symbol: String,
        value: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 24, weight: .semibold))
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
