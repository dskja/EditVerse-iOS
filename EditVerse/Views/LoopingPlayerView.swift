import SwiftUI
import AVFoundation

struct LoopingPlayerView: UIViewRepresentable {
    let url: URL?
    let isActive: Bool
    let isMuted: Bool
    let isPaused: Bool

    func makeUIView(context: Context) -> PlayerUIView {
        let v = PlayerUIView()
        if let url { v.configure(url: url) }
        v.apply(isActive: isActive, isMuted: isMuted, isPaused: isPaused)
        return v
    }
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        if let url, uiView.currentURL != url { uiView.configure(url: url) }
        uiView.apply(isActive: isActive, isMuted: isMuted, isPaused: isPaused)
    }
    static func dismantleUIView(_ uiView: PlayerUIView, coordinator: ()) { uiView.shutdown() }
}

final class PlayerUIView: UIView {
    private(set) var currentURL: URL?
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private let playerLayer = AVPlayerLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); playerLayer.frame = bounds }
    func configure(url: URL) {
        guard currentURL != url else { return }
        shutdown(); currentURL = url
        let item = AVPlayerItem(url: url)
        let queue = AVQueuePlayer(playerItem: item)
        looper = AVPlayerLooper(player: queue, templateItem: item)
        player = queue; playerLayer.player = queue
        queue.actionAtItemEnd = .none; queue.pause()
    }
    func apply(isActive: Bool, isMuted: Bool, isPaused: Bool) {
        player?.isMuted = isMuted
        guard let player else { return }
        if isActive && !isPaused {
            if player.timeControlStatus != .playing { player.play() }
        } else {
            player.pause()
            if !isActive { player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) }
        }
    }
    func shutdown() {
        player?.pause(); player?.removeAllItems()
        looper = nil; player = nil; playerLayer.player = nil; currentURL = nil
    }
}
