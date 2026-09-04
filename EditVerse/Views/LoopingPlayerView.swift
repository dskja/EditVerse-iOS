import SwiftUI
import AVFoundation

struct LoopingPlayerView: UIViewRepresentable {
    let url: URL
    let isActive: Bool
    let isMuted: Bool
    var isPaused: Bool = false

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.configure(url: url)
        view.apply(isActive: isActive, isMuted: isMuted, isPaused: isPaused)
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        if uiView.currentURL != url {
            uiView.configure(url: url)
        }
        uiView.apply(isActive: isActive, isMuted: isMuted, isPaused: isPaused)
    }

    static func dismantleUIView(_ uiView: PlayerUIView, coordinator: ()) {
        uiView.shutdown()
    }
}

final class PlayerUIView: UIView {
    private(set) var currentURL: URL?
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private let playerLayer = AVPlayerLayer()
    private var isConfiguredActive = false
    private var isConfiguredPaused = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    func configure(url: URL) {
        guard currentURL != url else { return }
        shutdown()
        currentURL = url

        let item = AVPlayerItem(url: url)
        let queue = AVQueuePlayer(playerItem: item)
        looper = AVPlayerLooper(player: queue, templateItem: item)
        player = queue
        playerLayer.player = queue
        queue.actionAtItemEnd = .none
        queue.pause()
    }

    func apply(isActive: Bool, isMuted: Bool, isPaused: Bool) {
        player?.isMuted = isMuted
        isConfiguredActive = isActive
        isConfiguredPaused = isPaused

        guard let player else { return }

        if isActive && !isPaused {
            if player.timeControlStatus != .playing {
                player.play()
            }
        } else {
            player.pause()
            if !isActive {
                player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }

    func shutdown() {
        player?.pause()
        player?.removeAllItems()
        looper = nil
        player = nil
        playerLayer.player = nil
        currentURL = nil
    }
}
