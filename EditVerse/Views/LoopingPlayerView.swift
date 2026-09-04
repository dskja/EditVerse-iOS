import SwiftUI
import AVFoundation

struct LoopingPlayerView: UIViewRepresentable {
    let url: URL
    let isActive: Bool

    func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView(url: url)
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.setActive(isActive)
    }
}

final class PlayerUIView: UIView {
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private let playerLayer = AVPlayerLayer()

    init(url: URL) {
        super.init(frame: .zero)
        backgroundColor = .black
        let item = AVPlayerItem(url: url)
        let queue = AVQueuePlayer(playerItem: item)
        looper = AVPlayerLooper(player: queue, templateItem: item)
        player = queue
        playerLayer.player = queue
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        queue.isMuted = false
        queue.pause()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    func setActive(_ active: Bool) {
        if active {
            player?.play()
        } else {
            player?.pause()
            player?.seek(to: .zero)
        }
    }
}
